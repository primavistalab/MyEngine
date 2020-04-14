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
  Mask,Trans,Errs,ModemState : DWord;
  Ovr : TOverlapped;
  Reciv : pointer;
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
  //стартуем бесконечный цикл
  GetCommModemStatus(Parms.hPort,ModemState);
  Parms.Terminated:=False;
  while not Parms.Terminated do {with Parms do}
    begin

      if Parms.Terminated then
        break;

      Mask := 0;
      //запрашиваем (ожидаем) маску эвентов
      if (not WaitCommEvent(Parms.hPort,Mask,@Ovr)) then
        //обрабатываем "отложенную" операцию ввода-вывода
        if (GetLastError() = ERROR_IO_PENDING) and
           (WaitForSingleObject(Ovr.hEvent,INFINITE)=Wait_Object_0) then
              GetOverlappedResult(Parms.hPort,Ovr,Trans,False);

      //очищаем ошибки с получением статуса порта, обязательно!!!
      ClearCommError(Parms.hPort,Errs,@Parms.Stat);

      if Parms.Terminated then
        break;

      if Mask = 0  then
        continue;

      //============
      if (Mask and EV_DSR) = EV_DSR then    // изменился сигнал
        begin
          GetCommModemStatus(Parms.hPort,ModemState);

          if (ModemState and MS_DSR_ON) = MS_DSR_ON then
            Parms.RecivBuff[cnt].Value:=0
          else
            Parms.RecivBuff[cnt].Value:=1;

          if g_settings.InvAdapter then
            Parms.RecivBuff[cnt].Value:=not Parms.RecivBuff[cnt].Value;

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
                      GetMem(Reciv, (len)*SizeOf(TPacket));
                      Move(Parms.RecivBuff[first], Reciv^, (len)*SizeOf(TPacket));
                      Move(Parms.RecivBuff[last], Parms.RecivBuff[0], SizeOf(TPacket));
                      //шлем сообщение основному потоку
                      QueryPerformanceCounter(g_tmNow);
                      PostMessage(fmMainForm.Handle,cmRxByte,Integer(Reciv),(len) {*SizeOf(TPacket)});

                      Parms.Terminated:=False;
                      cnt:=0;
                      summa:=0;
                    end;
                end;
            end;

          Inc(cnt);
          if cnt>=328 then
            cnt:=0;
        end; //if (Mask and EV_DSR) = EV_DSR then begin
    end;

  CloseHandle(Ovr.hEvent);
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
          Exit;
        end;

      //устанавливаем приоритет дочернего потока
      SetThreadPriority(CommThread, THREAD_PRIORITY_TIME_CRITICAL);
      Result := True;
    end;
end;

function CloseComm(var Com_Var : TComVar): boolean;
begin
  Com_Var.Terminated := True;
  SetCommMask(Com_Var.hPort,0);
  Sleep(100);
  CloseHandle(Com_Var.hPort);

  Result := True;
end;

end.
