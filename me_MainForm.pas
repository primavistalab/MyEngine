unit me_MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg, ComCtrls;

const
  cmRxByte  = WM_USER + 1;
  cmWakeUp  = WM_USER + 2;
  cmTrayMsg = WM_USER + 3;

type
  TfmMainForm = class(TForm)
    imMainSkin: TImage;
    lbClose: TLabel;
    lbSettings: TLabel;
    lbReset: TLabel;
    Label1: TLabel;
    lbSpeed: TLabel;
    lbRPM: TLabel;
    Label4: TLabel;
    lbCaption6: TLabel;
    lbValue6: TLabel;
    lbODOName: TLabel;
    lbODOValue: TLabel;
    lvODOMeasure: TLabel;
    lbCruiseName: TLabel;
    lbCruiseValue: TLabel;
    lbCruiseMeasure: TLabel;
    lbCaption4: TLabel;
    lbCaption5: TLabel;
    lbValue5: TLabel;
    lbValue4: TLabel;
    lbCaption3: TLabel;
    lbCaption1: TLabel;
    lbCaption2: TLabel;
    lbMeasure4: TLabel;
    lbMeasure5: TLabel;
    lbMeasure6: TLabel;
    lbMeasure1: TLabel;
    lbMeasure2: TLabel;
    lbMeasure3: TLabel;
    lbValue3: TLabel;
    lbValue2: TLabel;
    lbValue1: TLabel;
    lbStatus: TLabel;
    lbMinimize: TLabel;
    tmSaveSettings: TTimer;
    lbFilling: TLabel;
    lbCrTime: TLabel;
    tmTime: TTimer;
    Label2: TLabel;
    lbVer: TLabel;
    lbCruiseFields: TLabel;
    lbODOFields: TLabel;
    TrayIcon: TTrayIcon;
    tmResetODO: TTimer;

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbCloseClick(Sender: TObject);
    procedure lbSettingsClick(Sender: TObject);
    procedure imMainSkinMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imMainSkinMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imMainSkinMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lbResetClick(Sender: TObject);
    procedure lbMinimizeClick(Sender: TObject);
    procedure tmSaveSettingsTimer(Sender: TObject);
    procedure FillStringArrays;

    procedure ClickOnValueLabel(Sender: TObject);
    procedure lbFillingClick(Sender: TObject);
    procedure tmTimeTimer(Sender: TObject);
    procedure lbCruiseFieldsClick(Sender: TObject);
    procedure lbODOFieldsClick(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure lbODOFieldsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lbODOFieldsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tmResetODOTimer(Sender: TObject);
  private
    procedure PortMessage(var _msg : TMessage); message cmRxByte;
    procedure WakeUP(var _msg : TMessage); message cmWakeUp;
    procedure StartStop;
    { Private declarations }
  public

  end;

var
  fmMainForm: TfmMainForm;

  fODOMouseDown : Boolean = false;

implementation

uses
  me_vars, me_Settings, me_Draw,
  ComUnit, me_Recalc, me_TripComp, me_Reset, me_FuelTank, me_SelectView,
  me_Warning, me_StrRes;

{$R *.dfm}

var
  // для таскания формы мышкой
  LMouseDown : boolean = false;
  xLDown, yLDown : Integer;

  hMutex : HWND = 0;

procedure BringWindowToForeground(_hWnd : HWND);
var
  dwTimeout, i, d : DWORD;
  hCurWnd : HWND;
  bNeedTopmost : boolean;
  nMyTID, nCurTID : integer;
begin
    SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @dwTimeout, 0);
    SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, nil, 0);

    bNeedTopmost := (GetWindowLong(_hWnd, GWL_EXSTYLE) and WS_EX_TOPMOST) = 0;

    if (bNeedTopmost) then
      SetWindowPos(_hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);

    i:=0;
    hCurWnd := GetForegroundWindow();
    while (i<10) and (hCurWnd<>_hWnd) do
      begin
        nMyTID  := GetCurrentThreadId();
        nCurTID := GetWindowThreadProcessId(hCurWnd, @d);

        AttachThreadInput(nMyTID, nCurTID, TRUE);

        SetForegroundWindow(_hWnd);

        AttachThreadInput(nMyTID, nCurTID, FALSE);

        Sleep(20);

        inc(i);
        hCurWnd := GetForegroundWindow();
      end;

    if(bNeedTopmost) then
        SetWindowPos(_hWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);

    SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, @dwTimeout, 0);
end;

procedure TfmMainForm.PortMessage(var _msg: TMessage);
var
  _len, i, j : int;

  rcvPacket, pTemp : PPacket;

  _bitFrame : array[1..163] of byte;      // 163 бита - длина нормального кадра
  _bitCnt, B : byte;

  subExit : boolean;

  _frame : frame_t;
  _recalc : recalc_frame_t;

  dT : c_float;    // время между пакетами в секунадх
begin
  // каждый пакет несет в себе информация о бите 0 или 1 (Value)
  // число так битов показывает параметр Time
  // число пакетов показывает сколько раз менялся 0 на 1
  // набор полученных пакетов за раз = 1 кадру из 163 бит

  rcvPacket:=PPacket(_msg.WParam);
  _len:=_msg.LParam; // div SizeOf(TPacket);

  pTemp:=rcvPacket;

  // перенесем все биты полученного пакета в сплошной массив _bitFrame
  // для дальнейшей обработки
  ZeroMemory(@_bitFrame,sizeof(_bitFrame));
  _bitCnt:=1;
  subExit:=false;

  // перебираем каждый полученный пакет....
  for i:=1 to _len do
    begin
      B:=rcvPacket^.Value;              // чтобы каждый раз не разыменовывать указатель.....

      for j:=1 to rcvPacket^.Time do    // число бит со значением 'B'
        begin
          if _bitCnt > 163 then         // число бит достигло 163, но биты не закончились. выходим....
            begin
              subExit:=true;
              break;
            end;

          _bitFrame[_bitCnt]:=B;

          inc(_bitCnt);
        end;

      if subExit then
        break;

      inc(rcvPacket);              // следующий пакет
    end;

  FreeMem(pTemp);                  // освобождаем память, котору нам дал ComUnit

  if subExit then  // произошел принудительный выход
    exit;
  if _bitCnt-1 <> 163 then
    begin
      {$ifdef DEBUG}
      log.Add('Число бит в пакете != 163');
      {$endif}

      exit;
    end;

  // разбираем массив бит
  // учитываем стартовый бит 0 и стоповые биты 11

{ 163 bit:

  011111110001011   - ID
  00100100011
  01010101011
  01101100011
  01101100011
  01001010011
  00001011111
  00000000011
  00000000011
  01011111011
  00000000011
  00000010011
  00101100111
  1111111111111111 - next frame 16 start bits
}

//  // проверяем стоповые биты FrameID
  if not ((_bitFrame[1]=0) and (_bitFrame[14]=1) and (_bitFrame[15]=1)) then
    begin
      {$ifdef DEBUG}
      log.Add('Ошибка в стоповых битах');
      {$endif}

      exit;
    end;
//  // проверяем стоповые биты данных
  for i:=0 to 11 do
    if not ((_bitFrame[i*11+15+1]=0) and (_bitFrame[i*11+15+1+9]=1) and (_bitFrame[i*11+15+1+10]=1)) then
      begin
        {$ifdef DEBUG}
        log.Add('Ошибка в стоповых битах');
        {$endif}

        exit;
      end;

  // ....все стоповые биты соответствуют протоколу...

  // прошедшее время в секундах
  dT := (g_tmNow - g_tmLast) / g_speed;
  g_tmLast := g_tmNow;

  if (dT<0.1) or (dT>3.0) then   // должно быть ~1.3 сек, так же отсекаем первый пакет, когда tmLast было = 0
    begin
      {$ifdef DEBUG}
      log.Add('Время между пакетами больше 3 сек, или меньше 0.1 сек. ('+FormatFloat('0.00',dT)+' сек.)');
      {$endif}

      exit;
    end;

// Интерпретация значений из битового представления
// у каждого поля фиксированное место в массиве _bitFrame[]

  CopyMemory(@_frame._00_FrameID[1],@_bitFrame[2],12);

  _frame._01_Injector         :=_8BitToValue(@_bitFrame[17]);
  _frame._02_Ignition         :=_8BitToValue(@_bitFrame[28]);
  _frame._03_ValveXX          :=_8BitToValue(@_bitFrame[39]);
  _frame._04_RPM              :=_8BitToValue(@_bitFrame[50]);
  _frame._05_AirFlow          :=_8BitToValue(@_bitFrame[61]);
  _frame._06_Temperature      :=_8BitToValue(@_bitFrame[72]);
  _frame._07_ThrottleBody     :=_8BitToValue(@_bitFrame[83]);
  _frame._08_Speed            :=_8BitToValue(@_bitFrame[94]);
  _frame._09_CorrectionL      :=_8BitToValue(@_bitFrame[105]);
  _frame._10_CorrectionR      :=_8BitToValue(@_bitFrame[116]);

  _frame._11_0_ColdStart      :=Boolean(_bitFrame[127]);
  _frame._11_1_ColdEngine     :=Boolean(_bitFrame[128]);
  _frame._11_2_Unknown        :=Boolean(_bitFrame[129]);
  _frame._11_3_Unknown        :=Boolean(_bitFrame[130]);
  _frame._11_4_Knock          :=Boolean(_bitFrame[131]);
  _frame._11_5_Feedback       :=Boolean(_bitFrame[132]);
  _frame._11_6_Enrichment     :=Boolean(_bitFrame[133]);
  _frame._11_7_Unknown        :=Boolean(_bitFrame[134]);

  _frame._12_0_Starter        :=Boolean(_bitFrame[138]);
  _frame._12_1_Throttle       :=Boolean(_bitFrame[139]);
  _frame._12_2_AirCond        :=Boolean(_bitFrame[140]);
  _frame._12_3_Neutral        :=Boolean(_bitFrame[141]);
  _frame._12_4_MixL           :=Boolean(_bitFrame[142]);
  _frame._12_5_MixR           :=Boolean(_bitFrame[143]);
  _frame._12_6_Unknown        :=Boolean(_bitFrame[144]);
  _frame._12_7_Unknown        :=Boolean(_bitFrame[145]);

  // пересчитываем полученый кадр
  _recalc:=ReCalcFrame(_frame);

  // обновляем параметры маршрутного компа
  UpdateTripInfo(_recalc,dT);

  // Переписываем полностью данные с ECU
  g_trip_comp.ReCalcValues:=_recalc;

  // Отрисовываем на экране
  DrawTripInfo(g_trip_comp);
end;

procedure TfmMainForm.StartStop;
begin
  if g_bActive then
    begin
      {$ifdef DEBUG}
      log.Add(rsCOMPortIsClose);
      {$endif}

      CloseComm(g_ComPort);
      g_bActive:=false;
      lbStatus.Caption := rsNotConnected;

      tmSaveSettings.Enabled:=false;
      fmSettings.SaveSettings();
    end
  else
    begin
      if not QueryPerformanceFrequency(g_speed) then
        begin
          {$ifdef DEBUG}
          log.Add('Ошибка QueryPerformanceFrequency');
          {$endif}

          lbStatus.Caption:='QueryPerformanceFrequency(1) ERROR!';
          exit;
        end;

      if g_speed = 0 then
        begin
          {$ifdef DEBUG}
          log.Add('Ошибка: QueryPerformanceFrequency = 0');
          {$endif}

          lbStatus.Caption:='QueryPerformanceFrequency(2) ERROR!';
          exit;
        end;

      ZeroMemory(@g_ComPort,sizeof(g_ComPort));
      if OpenComm(g_settings.strComPort,g_ComPort) then
        begin
          {$ifdef DEBUG}
          log.Add(rsCOMPortIsOpen);
          {$endif}

          lbStatus.Caption := rsReadingPort;

          {$ifdef DEBUG}
          lbStatus.Caption := lbStatus.Caption + '(DEBUG mode)';
          {$endif}

          tmSaveSettings.Enabled:=true;

          g_bActive:=true;
        end
      else
        begin
          {$ifdef DEBUG}
          log.Add(Format(rsOpenPortError, [g_settings.strComPort]));
          {$endif}

          lbStatus.Caption := Format(rsOpenPortError, [g_settings.strComPort]);
        end;
    end;
end;

procedure TfmMainForm.tmResetODOTimer(Sender: TObject);
var
  A, B : Boolean;
begin
  tmResetODO.Enabled:=False;

  A:=g_settings.currODO=ODO_A;
  B:=g_settings.currODO=ODO_B;

  if A then
    g_trip_comp.ODO_A:=0;
  if B then
    g_trip_comp.ODO_B:=0;

  if (A) or (B) then
    begin
      fODOMouseDown:=false;
      DrawCaptionsMeasures;
      DrawTripInfo(g_trip_comp);
      fmSettings.SaveSettings();
    end;
end;

procedure TfmMainForm.tmSaveSettingsTimer(Sender: TObject);
begin
  fmSettings.SaveSettings(true);
end;

procedure TfmMainForm.tmTimeTimer(Sender: TObject);
begin
  lbCrTime.Caption:=FormatDateTime('hh:nn', Now);
end;

procedure TfmMainForm.TrayIconClick(Sender: TObject);
begin
  Application.Restore;
  ShowWindow(Application.Handle, SW_SHOW);
  ShowWindow(fmMainForm.Handle, SW_SHOW);
  BringWindowToForeground(fmMainForm.Handle);
end;

procedure TfmMainForm.WakeUP(var _msg: TMessage);
begin
  Application.Restore;
  ShowWindow(Application.Handle, SW_SHOW);
  ShowWindow(fmMainForm.Handle, SW_SHOW);
  BringWindowToForeground(fmMainForm.Handle);
end;

procedure TfmMainForm.ClickOnValueLabel(Sender: TObject);
begin
  g_ClickByLabel:=(Sender as TLabel).Tag;

  if fmSelectView.ShowModal = mrOk then
    begin
      DrawCaptionsMeasures();
      DrawTripInfo(g_trip_comp);
      fmSettings.SaveSettings();
    end;
end;

procedure TfmMainForm.FillStringArrays;
begin
  g_Captions[vvAvrgFuelChargeBy100km] := rsAvrgFuelChargeBy100km;
  g_Captions[vvFuelChargeNowBy100km] := rsFuelChargeNowBy100km;
  g_Captions[vvAvrgFuelChargeByHour] := rsAvrgFuelChargeByHour;
  g_Captions[vvFuelChargeNowByHour] := rsFuelChargeNowByHour;
  g_Captions[vvFuelCharge] := rsFuelCharge;
  g_Captions[vvFuelTank] := rsFuelTank;
  g_Captions[vvToStop] := rsToStop;
  g_Captions[vvFuelEconomy] := rsFuelEconomy;

  g_Captions[vv_08_Speed] := rs_08_Speed;
  g_Captions[vvAvrgSpeed] := rsAvrgSpeed;
  g_Captions[vvMaxSpeed] := rsMaxSpeed;

  g_Captions[vvAllTime] := rsAllTime;
  g_Captions[vvDriveTime] := rsDriveTime;
  g_Captions[vvStayTime] := rsStayTime;
  g_Captions[vvLiveDist] := rsLiveDist;

  g_Captions[vvODO] := rsODO;
  g_Captions[vvODO_A] := rsODO_A;
  g_Captions[vvODO_B] := rsODO_B;

  g_Captions[vv_01_Injector] := rs_01_Injector;
  g_Captions[vv_02_Ignition] := rs_02_Ignition;
  g_Captions[vv_03_ValveXX] := rs_03_ValveXX;
  g_Captions[vv_04_RPM] := rs_04_RPM;

  case g_settings.AirFlow of
  afMAP_kPa, afMAP_mm, afMAPt_kPa, afMAPt_mm:
    g_Captions[vv_05_AirFlow] := rs_05_AirFlowMAP;
  afMAF:
    g_Captions[vv_05_AirFlow] := rs_05_AirFlowMAF;
  afVAF:
    g_Captions[vv_05_AirFlow] := rs_05_AirFlowVAF;
  end;

  g_Captions[vv_06_Temperature] := rs_06_Temperature;
  g_Captions[vv_07_ThrottleBody] := rs_07_ThrottleBody;
  g_Captions[vv_09_CorrectionL] := rs_09_CorrectionL;
  g_Captions[vv_10_CorrectionR] := rs_10_CorrectionR;

  g_Captions[vv_11_0_ColdStart] := rs_11_0_ColdStart;
  g_Captions[vv_11_1_ColdEngine] := rs_11_1_ColdEngine;
  g_Captions[vv_11_2_Unknown] := rs_11_2_Unknown;
  g_Captions[vv_11_3_Unknown] := rs_11_3_Unknown;
  g_Captions[vv_11_4_Knock] := rs_11_4_Knock;
  g_Captions[vv_11_5_Feedback] := rs_11_5_Feedback;
  g_Captions[vv_11_6_Enrichment] := rs_11_6_Enrichment;
  g_Captions[vv_11_7_Unknown] := rs_11_7_Unknown;

  g_Captions[vv_12_0_Starter] := rs_12_0_Starter;
  g_Captions[vv_12_1_Throttle] := rs_12_1_Throttle;
  g_Captions[vv_12_2_AirCond] := rs_12_2_AirCond;
  g_Captions[vv_12_3_Neutral] := rs_12_3_Neutral;
  g_Captions[vv_12_4_MixL] := rs_12_4_MixL;
  g_Captions[vv_12_5_MixR] := rs_12_5_MixR;
  g_Captions[vv_12_6_Unknown] := rs_12_6_Unknown;
  g_Captions[vv_12_7_Unknown] := rs_12_7_Unknown;

  g_Measures[vvAvrgFuelChargeBy100km] := rsLitersOn100km;
  g_Measures[vvFuelChargeNowBy100km]  := rsLitersOn100km;
  g_Measures[vvAvrgFuelChargeByHour]  := rsLitersOnH;
  g_Measures[vvFuelChargeNowByHour]   := rsLitersOnH;
  g_Measures[vvFuelCharge] := rsLiters;
  g_Measures[vvFuelTank] := rsLiters;
  g_Measures[vvToStop] := rsKm;
  g_Measures[vvFuelEconomy] := rsLiters;

  g_Measures[vv_08_Speed] := rsKmH;
  g_Measures[vvAvrgSpeed] := rsKmH;
  g_Measures[vvMaxSpeed] := rsKmH;
  g_Measures[vvAllTime] := '';
  g_Measures[vvDriveTime] := '';
  g_Measures[vvStayTime] := '';
  g_Measures[vvLiveDist] := rsKm;

  g_Measures[vvODO] := rsKm;
  g_Measures[vvODO_A] := rsKm;
  g_Measures[vvODO_B] := rsKm;

  g_Measures[vv_01_Injector] := rsMs;
  g_Measures[vv_02_Ignition] := rsGrad;

  if g_settings.ValveXXInSteps then
    g_Measures[vv_03_ValveXX] := rsStep
  else
    g_Measures[vv_03_ValveXX] := rsProc;

  g_Measures[vv_04_RPM] := rsRPM;

  case g_settings.AirFlow of
  afMAP_kPa, afMAPt_kPa:
    g_Measures[vv_05_AirFlow] := rs_kPa;
  afMAP_mm, afMAPt_mm:
    g_Measures[vv_05_AirFlow] := rs_mmRtSt;
  afMAF:
    g_Measures[vv_05_AirFlow] := rs_GrSec;
  afVAF:
    g_Measures[vv_05_AirFlow] := rsVolts;
  end;

  g_Measures[vv_06_Temperature] := rsTemp;

  if g_settings.ThrottleInProc then
    g_Measures[vv_07_ThrottleBody] := rsProc
  else
    g_Measures[vv_07_ThrottleBody] := rsGrad;

  if g_settings.CorrectInProc then
    begin
      g_Measures[vv_09_CorrectionL] := rsProc;
      g_Measures[vv_10_CorrectionR] := rsProc;
    end
  else
    begin
      g_Measures[vv_09_CorrectionL] := rsVolts;
      g_Measures[vv_10_CorrectionR] := rsVolts;
    end;

  g_Measures[vv_11_0_ColdStart]:='';
  g_Measures[vv_11_1_ColdEngine]:='';
g_Measures[vv_11_2_Unknown]:='';
g_Measures[vv_11_3_Unknown]:='';
  g_Measures[vv_11_4_Knock]:='';
g_Measures[vv_11_5_Feedback]:='';
  g_Measures[vv_11_6_Enrichment]:='';
g_Measures[vv_11_7_Unknown]:='';

  g_Measures[vv_12_0_Starter]:='';
  g_Measures[vv_12_1_Throttle]:='';
  g_Measures[vv_12_2_AirCond]:='';
  g_Measures[vv_12_3_Neutral]:='';
  g_Measures[vv_12_4_MixL]:='';
  g_Measures[vv_12_5_MixR]:='';
g_Measures[vv_12_6_Unknown]:='';
g_Measures[vv_12_7_Unknown]:='';
end;

procedure TfmMainForm.FormActivate(Sender: TObject);
begin

  if g_settings.RunMinimize then
    begin
      Application.Minimize;

      if g_settings.HideMinimized then
        begin
          ShowWindow(fmMainForm.Handle, SW_HIDE);
          ShowWindow(Application.Handle, SW_HIDE);
        end;
    end;
end;

procedure TfmMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if g_settings.AskOnExit then
    if Application.MessageBox(PChar(rsQuit), cpt, MB_ICONQUESTION or MB_YESNO) = ID_NO then
      begin
        Action:=caNone;
        Exit;
      end;

  fmSettings.SaveSettings();

  if g_bActive then
    StartStop;

  if hMutex<>0 then
    CloseHandle(hMutex);
end;

procedure TfmMainForm.FormCreate(Sender: TObject);
begin
  ZeroMemory(@my_engine,sizeof(my_engine));
  ZeroMemory(@g_settings,sizeof(g_settings));
  ZeroMemory(@g_trip_comp,sizeof(g_trip_comp));
  
  my_engine.main_form:=handle;

  // Draw in memory first ;-)
  DoubleBuffered:=true;

{$ifdef DEBUG}
  log:=TLogClass.Create;
  log.Add('******** MyEngine debug mode ********');
{$endif}
end;


procedure TfmMainForm.FormShow(Sender: TObject);
var
  i : integer;
  _hwnd : HWND;
begin
  // Запрет запуска копий
  hMutex:=CreateMutex(nil,false,'MyEngineMutex');
  if GetLastError = ERROR_ALREADY_EXISTS then
    begin
      // Выводим вперед запущенное окно
      _hwnd:=FindWindow('TfmMainForm','MyEngine');
      // отправляем сообщение на разворачивание приложения
      SendMessage(_hwnd,cmWakeUp,0,0);
      // выводим на передний план главное окно
      //BringWindowToForeground(_hwnd);

      Application.Terminate;
      Exit;
    end;

  // Задаем поля для вывода информации
  ZeroMemory(@g_value_fields, sizeof(g_value_fields));
  for i:=1 to ValueFieldCount do
    begin
      g_value_fields[i].lbCaption:=FindComponent('lbCaption'+inttostr(i)) as TLabel;
      g_value_fields[i].lbMeasure:=FindComponent('lbMeasure'+inttostr(i)) as TLabel;
      g_value_fields[i].lbValue:=FindComponent('lbValue'+inttostr(i)) as TLabel;

      g_value_fields[i].lbValue.OnClick:=ClickOnValueLabel;
      g_value_fields[i].lbValue.Cursor:=crHandPoint;
      g_value_fields[i].lbValue.Tag:=i;
    end;

  lbVer.Caption:=ver;

  fmSettings.LoadSettings;

  FillStringArrays;

  DrawCaptionsMeasures();
  DrawTripInfo(g_trip_comp);

  if g_settings.strComPort='' then
    begin
      Application.MessageBox(PChar(rsFirstRun), cpt, MB_ICONINFORMATION);

      if fmSettings.ShowModal = mrOk then
        StartStop;
    end
  else
    StartStop;

  // Предупреждение об опасности выводим 1 раз в неделю
  // Если прошло больше недели то отображаем предупреждение
  if (Now-g_settings.LastRun)>7.0 then
    begin
      if fmWarning.ShowModal = mrCancel then
        begin
          Application.Terminate;
          exit;
        end
      else
        begin
          g_settings.LastRun:=Now;  // если приняли соглашение, то сохраняем эту дату
          fmSettings.SaveSettings();
        end;
    end;

  // переименовываем только после полного запуска
  // чтобы окно не находило само себя
  Caption := 'MyEngine';
end;

procedure TfmMainForm.imMainSkinMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft then
    begin
      xLDown:=X;
      yLDown:=Y;
      LMouseDown:=true;
    end;
end;

procedure TfmMainForm.imMainSkinMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  // таскаем форму за мышкой
  if LMouseDown then
    begin
      fmMainForm.Top:=fmMainForm.Top + (Y-yLDown);
      fmMainForm.Left:=fmMainForm.Left + (X-xLDown);
    end;
end;

procedure TfmMainForm.imMainSkinMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft then
    LMouseDown:=false
end;

procedure TfmMainForm.lbCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfmMainForm.lbCruiseFieldsClick(Sender: TObject);
begin
  if g_settings.currCruise=ChargeHourNow then
    g_settings.currCruise:=AllTime
  else
    inc(g_settings.currCruise);

  DrawCaptionsMeasures();
  DrawTripInfo(g_trip_comp);
end;

procedure TfmMainForm.lbFillingClick(Sender: TObject);
begin
  if fmFuelTank.ShowModal = mrOk then
    begin
      DrawTripInfo(g_trip_comp);
      fmSettings.SaveSettings();
    end;
end;

procedure TfmMainForm.lbMinimizeClick(Sender: TObject);
begin
  Application.Minimize;

  if g_settings.HideMinimized then
    begin
      ShowWindow(fmMainForm.Handle, SW_HIDE);
      ShowWindow(Application.Handle, SW_HIDE);
    end;
end;

procedure TfmMainForm.lbODOFieldsClick(Sender: TObject);
begin
//  if g_settings.currODO=ODO_B then
//    g_settings.currODO:=ODO
//  else
//    inc(g_settings.currODO);
//
//  DrawCaptionsMeasures();
//  DrawTripInfo(g_trip_comp);
end;

procedure TfmMainForm.lbODOFieldsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fODOMouseDown:=True;
  tmResetODO.Enabled:=true;
end;

procedure TfmMainForm.lbODOFieldsMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  tmResetODO.Enabled:=False;

  if fODOMouseDown then
    begin
      if g_settings.currODO=ODO_B then
        g_settings.currODO:=ODO
      else
        inc(g_settings.currODO);

      DrawCaptionsMeasures();
      DrawTripInfo(g_trip_comp);

      fODOMouseDown:=False;
    end;
end;

procedure TfmMainForm.lbResetClick(Sender: TObject);
begin
  if fmReset.ShowModal = mrOk then
    begin
      DrawCaptionsMeasures;
      DrawTripInfo(g_trip_comp);
      fmSettings.SaveSettings();
    end;
end;

procedure TfmMainForm.lbSettingsClick(Sender: TObject);
begin
  // если запущены, то останавливаем
  if g_bActive then
    StartStop;

  fmSettings.ShowModal;

  // Перезаполняем строковый массив - новые значения
  // в измерениях

  FillStringArrays;
  DrawCaptionsMeasures;
  DrawTripInfo(g_trip_comp);

  // продолжаем работу
  if not g_bActive then
    StartStop;
end;

end.

