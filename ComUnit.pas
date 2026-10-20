//юнит содержит минимальный, но достаточный набор
//процедур, функций, переменных для работы с СОМ-портами
//полностью фриваре
//может когда-нибудь кто-то вспомнит добрым словом
//автора - Пивко Василия.

unit ComUnit;

interface

uses
  Windows, SysUtils, Messages, SyncObjs, Math,

  me_MainForm, me_Vars;

function CloseComm(var Com_Var : TComVar): boolean;
function OpenComm(strPort : string; var Com_Var : TComVar) : boolean;

implementation

const
  DCB_FLAG_BINARY = $00000001;

var
  speed, timenew, timeold : int64;

//функция дочернего потока, обрабатывающего эвенты порта
//параметр введен для того, чтобы каждый (их стартует два)
//экземпляр работал с переменными "своего" порта
function WorkComm(var Parms : TComVar) : longint; stdcall;

function GetPeriod: Int64;
begin
  Result:=0;

  if not(QueryPerformanceFrequency(speed)) then
    exit;

  QueryPerformanceCounter(timenew);
  Result:=Round{Ceil}(((timenew-timeold) / (speed / 1000)) / 8.2);
  timeold:=timenew;
end;

var
  Mask,Trans,Errs,ModemState,LastError,WaitResult : DWord;
  Ovr : TOverlapped;
  RxMessage : PRxMessage;
  cnt: integer;
  summa: Int64;
  first, last, len: integer;
begin
  Result := 0;

  cnt:=0;
  timeold:=0;
  timenew:=0;
  summa:=0;
  first:=0;

  //инициализируем TOverlapped структуру
  FillChar(Ovr,SizeOf(TOverlapped),0);
  Ovr.hEvent := CreateEvent(nil,TRUE,FALSE,nil);
  if Ovr.hEvent=0 then
    exit;

  try
  //стартуем бесконечный цикл
  if not GetCommModemStatus(Parms.hPort,ModemState) then
    exit;
  while not Parms.Terminated do {with Parms do}
    begin

      if Parms.Terminated then
        break;

      Mask := 0;
      //запрашиваем (ожидаем) маску эвентов
      if not WaitCommEvent(Parms.hPort,Mask,@Ovr) then
        begin
        //обрабатываем "отложенную" операцию ввода-вывода
          LastError:=GetLastError();
          if LastError<>ERROR_IO_PENDING then
            break;

          WaitResult:=WaitForSingleObject(Ovr.hEvent,INFINITE);
          if WaitResult<>Wait_Object_0 then
            break;

          if Parms.Terminated then
            break;

          if not GetOverlappedResult(Parms.hPort,Ovr,Trans,False) then
            break;
        end;

      //очищаем ошибки с получением статуса порта, обязательно!!!
      if not ClearCommError(Parms.hPort,Errs,@Parms.Stat) then
        break;

      if Parms.Terminated then
        break;

      if Mask = 0  then
        continue;

      //============
      if (Mask and EV_DSR) = EV_DSR then    // изменился сигнал
        begin
          if not GetCommModemStatus(Parms.hPort,ModemState) then
            break;

          if (ModemState and MS_DSR_ON) = MS_DSR_ON then
            Parms.RecivBuff[cnt].Value:=0
          else
            Parms.RecivBuff[cnt].Value:=1;

          if g_settings.InvAdapter then
            Parms.RecivBuff[cnt].Value:=1-Parms.RecivBuff[cnt].Value;

          if timeold=0 then
            QueryPerformanceCounter(timeold);

          Parms.RecivBuff[cnt].Time:=GetPeriod;

          if first=1 then
            summa:=summa+Parms.RecivBuff[cnt].Time;

          if (Parms.RecivBuff[cnt].Value=1) and (Parms.RecivBuff[cnt].Time>=18) then
            begin
              if first=0 then
                begin
                  Move(Parms.RecivBuff[cnt], Parms.RecivBuff[0], SizeOf(TPacket));
                  first:=1;
                  cnt:=0;
                  summa:=0;
                end
              else
                begin
                  if summa>=163 then
                    begin
                      last:=cnt;
                      len:=last-first+1;

                      if len>0 then
                        begin
                          GetMem(RxMessage,SizeOf(TRxMessage)+(len-1)*SizeOf(TPacket));
                          QueryPerformanceCounter(RxMessage^.Timestamp);
                          RxMessage^.PacketCount:=len;
                          Move(Parms.RecivBuff[first],RxMessage^.Packets[0],len*SizeOf(TPacket));

                          if not PostMessage(fmMainForm.Handle,cmRxByte,Integer(RxMessage),0) then
                            FreeMem(RxMessage);
                        end;

                      Move(Parms.RecivBuff[last], Parms.RecivBuff[0], SizeOf(TPacket));
                      //шлем сообщение основному потоку
                      cnt:=0;
                      summa:=0;
                    end;
                end;
            end;

          Inc(cnt);
          if cnt>=328 then
            begin
              cnt:=0;
              summa:=0;
              first:=0;
            end;
        end; //if (Mask and EV_DSR) = EV_DSR then begin
    end;

  finally
    CloseHandle(Ovr.hEvent);
  end;
end;

function OpenComm(strPort : string; var Com_Var : TComVar) : boolean;
var
  ThreadId : DWord;
  TimeOuts : TCommTimeouts;
begin
  Result := False;

  with Com_Var do
    begin
      //получаем хэндл
      hPort := CreateFile(PChar('\\.\'+strPort),
                GENERIC_READ or GENERIC_WRITE,
                0,nil,OPEN_EXISTING,
                FILE_FLAG_OVERLAPPED,0);
      if hPort = INVALID_HANDLE_VALUE then
        Exit;

      //выполняем настройку порта с новым DCB
      ZeroMemory(@DCB, sizeof(DCB));
      DCB.DCBlength:=SizeOf(DCB);
      if not GetCommState(hPort,DCB) then
        begin
          CloseHandle(hPort);
          hPort:=INVALID_HANDLE_VALUE;
          Exit;
        end;

      DCB.Flags:=DCB_FLAG_BINARY;
      DCB.BaudRate := 9600;
      DCB.ByteSize := 8;
      DCB.Parity := NoParity;
      DCB.StopBits := OneStopBit;

      //устанавливаем маску эвентов
      if not (SetCommMask(hPort,EV_DSR) and
        //устанавливаем длину буферов ввода-вывода драйвера
        SetupComm(hPort,0,0) and
        //очищаем все и вся
        PurgeComm(hPort,PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR) and
        //записываем DCB
        SetCommState(hPort,DCB)) then
          begin
            CloseHandle(hPort);
            hPort:=INVALID_HANDLE_VALUE;
            Exit;
          end;

      //настраиваем таймауты на немедленный возврат из Read(Write)File
      ZeroMemory(@TimeOuts, sizeof(TimeOuts));
      TimeOuts.ReadIntervalTimeout := MAXDWORD;
//      TimeOuts.ReadTotalTimeoutMultiplier := 0;
//      TimeOuts.ReadTotalTimeoutConstant := 0;
//      TimeOuts.WriteTotalTimeoutMultiplier := 0;
//      TimeOuts.WriteTotalTimeoutConstant := 0;
      //записываем таймауты
      SetCommTimeouts(hPort,TimeOuts);
      //опускаем флаг завершения дочернего потока
      Terminated := False;
      //стартуем дочерний поток, функция потока - WorkComm
      CommThread := CreateThread(nil,0,@WorkComm,@Com_Var,0,ThreadID);

      if CommThread = 0 then
        begin
          CloseHandle(hPort);
          hPort:=INVALID_HANDLE_VALUE;
          Exit;
        end;

      //устанавливаем приоритет дочернего потока
      SetThreadPriority(CommThread, THREAD_PRIORITY_HIGHEST);
      Result := True;
    end;
end;

function CloseComm(var Com_Var : TComVar): boolean;
begin
  Com_Var.Terminated := True;

  if (Com_Var.hPort<>0) and (Com_Var.hPort<>INVALID_HANDLE_VALUE) then
    SetCommMask(Com_Var.hPort,0);

  if Com_Var.CommThread<>0 then
    begin
      WaitForSingleObject(Com_Var.CommThread,INFINITE);
      CloseHandle(Com_Var.CommThread);
      Com_Var.CommThread:=0;
    end;

  if (Com_Var.hPort<>0) and (Com_Var.hPort<>INVALID_HANDLE_VALUE) then
    begin
      CloseHandle(Com_Var.hPort);
      Com_Var.hPort:=INVALID_HANDLE_VALUE;
    end;

  Result := True;
end;

end.
