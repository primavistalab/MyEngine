unit me_Settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, FloatUtils, ExtCtrls;

type
  TfmSettings = class(TForm)
    Button1: TButton;
    Button2: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    GroupBox1: TGroupBox;
    rb_xx_proc: TRadioButton;
    rb_xx_step: TRadioButton;
    GroupBox2: TGroupBox;
    rb_temp_dir: TRadioButton;
    rb_temp_nondir: TRadioButton;
    GroupBox3: TGroupBox;
    rb_thr_grad: TRadioButton;
    rb_thr_proc: TRadioButton;
    GroupBox4: TGroupBox;
    rb_air_0: TRadioButton;
    rb_air_1: TRadioButton;
    rb_air_2: TRadioButton;
    rb_air_3: TRadioButton;
    rb_air_4: TRadioButton;
    rb_air_5: TRadioButton;
    GroupBox5: TGroupBox;
    rb_corr_proc: TRadioButton;
    rb_corr_v: TRadioButton;
    TabSheet3: TTabSheet;
    GroupBox6: TGroupBox;
    Label2: TLabel;
    edInjCnt: TEdit;
    Label3: TLabel;
    edInjPower: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    edInjFire: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    cbEngineDef: TComboBox;
    Label8: TLabel;
    TabSheet4: TTabSheet;
    lbVersion: TLabel;
    Label9: TLabel;
    GroupBox7: TGroupBox;
    Label1: TLabel;
    cb_ports: TComboBox;
    btUpdateCOMs: TButton;
    cb_invert: TCheckBox;
    cbInjTruncate: TCheckBox;
    Image1: TImage;
    GroupBox8: TGroupBox;
    cbRunMinimize: TCheckBox;
    cbAutoRun: TCheckBox;
    cbHideMinimized: TCheckBox;
    cbAskOnExit: TCheckBox;
    Label10: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btUpdateCOMsClick(Sender: TObject);
    procedure cbEngineDefChange(Sender: TObject);
    procedure Label9Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowSettings;

    procedure LoadSettings;

    // флаг _onlyTrip говорит о том, что должны быть сохранены только текущие
    // данные о работе авто
    procedure SaveSettings(_onlyTrip : boolean = false);
    procedure SaveAutoRunParam;
  end;

var
  fmSettings: TfmSettings;

implementation

uses
  me_Vars, IniFiles, ShellAPI, Registry;

var
  AutoRunKey : TRegistry;

{$R *.dfm}

procedure TfmSettings.Button1Click(Sender: TObject);
var
  i : int;
begin
  try
    g_settings.InjCount:=StrToInt(edInjCnt.Text);
  except
    Application.MessageBox('Ќеверное значение пол€ "„исло форсунок"',cpt,MB_ICONSTOP);
    edInjCnt.SetFocus;
    edInjCnt.SelectAll;
    exit;
  end;

  if not TryStrToFloatAny(edInjPower.Text,g_settings.InjPower) then
    begin
      Application.MessageBox('Ќеверное значение пол€ "ѕроизводительность"',cpt,MB_ICONSTOP);
      edInjPower.SetFocus;
      edInjPower.SelectAll;
      exit;
    end;

  try
    g_settings.InjFireCount:=StrToInt(edInjFire.Text);
  except
      Application.MessageBox('Ќеверное значение пол€ "„исло срабатываний"',cpt,MB_ICONSTOP);
      edInjFire.SetFocus;
      edInjFire.SelectAll;
      exit;
  end;

  if cb_ports.ItemIndex<>-1 then
    g_settings.strComPort:=cb_ports.Items.Strings[cb_ports.ItemIndex]
  else
    g_settings.strComPort:='';

  g_settings.InvAdapter:=cb_invert.Checked;
  g_settings.AutoRun:=cbAutoRun.Checked;
  g_settings.RunMinimize:=cbRunMinimize.Checked;
  g_settings.HideMinimized:=cbHideMinimized.Checked;
  g_settings.AskOnExit:=cbAskOnExit.Checked;
  g_settings.InjTruncate:=cbInjTruncate.Checked;

  g_settings.ValveXXInSteps:=rb_xx_step.Checked;
  g_settings.DirectTemper:=rb_temp_dir.Checked;
  g_settings.ThrottleInProc:=rb_thr_proc.Checked;
  g_settings.CorrectInProc:=rb_corr_proc.Checked;

  for i:=0 to 5 do
    if (FindComponent('rb_air_'+inttostr(i)) as TRadioButton).Checked then
      begin
        g_settings.AirFlow:=AirFlow_set(i);
        break;
      end;

  SaveSettings();
  SaveAutoRunParam();

  ModalResult:=mrOk;
  //Close;
end;

procedure TfmSettings.Button2Click(Sender: TObject);
begin
  ModalResult:=mrCancel;
  //Close;
end;

procedure TfmSettings.cbEngineDefChange(Sender: TObject);
begin
  case cbEngineDef.ItemIndex of
//1JZ,2JZ-GE (1992-1996)
  0:
      begin
        edInjCnt.Text:='6';
        edInjPower.Text:='0,0825';
        edInjFire.Text:='1';
      end;
//1JZ-GTE (1992-1996)
  1:
      begin
        edInjCnt.Text:='6';
        edInjPower.Text:='0,095';
        edInjFire.Text:='1';
      end;
//2JZ-GTE (1992-1996)
  2:
      begin
        edInjCnt.Text:='6';
        edInjPower.Text:='0,134';
        edInjFire.Text:='1';
      end;
//1JZ-GE (1996-2000)
  3:
      begin
        edInjCnt.Text:='6';
        edInjPower.Text:='0,063';
        edInjFire.Text:='1';
      end;
//2JZ-GE (1996-2000)
  4:
      begin
        edInjCnt.Text:='6';
        edInjPower.Text:='0,0785';
        edInjFire.Text:='1';
      end;
//1JZ-GTE (1996-2000)
  5:
      begin
        edInjCnt.Text:='6';
        edInjPower.Text:='0,095';
        edInjFire.Text:='1';
      end;
//5S-FE
  6:
      begin
        edInjCnt.Text:='4';
        edInjPower.Text:='0,056';
        edInjFire.Text:='1';
      end;
//5A-FE
  7:
    begin
        edInjCnt.Text:='4';
        edInjPower.Text:='0,044';
        edInjFire.Text:='2';
    end;
//4E-FE, 5E-FE
  8:
    begin
        edInjCnt.Text:='4';
        edInjPower.Text:='0,039';
        edInjFire.Text:='2';
    end;
//4E-FE (после 1995)
  9:
    begin
        edInjCnt.Text:='4';
        edInjPower.Text:='0,044';
        edInjFire.Text:='2';
    end;
//7M-GE

//7M-GTE
//1G-E
//1G-FE
  13:
    begin
        edInjCnt.Text:='6';
        edInjPower.Text:='0,039';
        edInjFire.Text:='1';
    end;

//1G-GE
//1G-GZE,-GTE (ран.)
//1G-GZE,-GTE (поздн.)

  end;
end;

procedure TfmSettings.FormShow(Sender: TObject);
begin
  ShowSettings;
end;

procedure TfmSettings.Label9Click(Sender: TObject);
begin
  ShellExecute(0,'open','http://primavistalab.com/myengine','','',0);
end;

procedure TfmSettings.LoadSettings;
var
  _ini : TIniFile;
  af : byte;
  i, j : integer;
begin
  // AutoRun Key
  AutoRunKey := TRegistry.Create;
  AutoRunKey.RootKey := HKEY_LOCAL_MACHINE;
  AutoRunKey.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', true);
  g_settings.AutoRun:= (AutoRunKey.ReadString('MyEngine')) = (ParamStr(0));
  AutoRunKey.CloseKey;
  AutoRunKey.Free;

  _ini:=TIniFile.Create(ExtractFilePath(Paramstr(0))+'settings.ini');

  g_settings.strComPort:=_ini.ReadString('ComPort','Number','');
  g_settings.InvAdapter:=_ini.ReadBool('ComPort','InvAdapter',false);

  g_settings.LastRun:=_ini.ReadDateTime('View','LastRun',0);
  g_settings.RunMinimize:=_ini.ReadBool('View','RunMinimize',false);
  g_settings.HideMinimized:=_ini.ReadBool('View','HideMinimized',false);
  g_settings.AskOnExit:=_ini.ReadBool('View','AskOnExit',true);

  g_settings.ValveXXInSteps:=_ini.ReadBool('Engine','ValveXXInSteps',false);
  g_settings.DirectTemper:=_ini.ReadBool('Engine','DirectTemper',true);
  g_settings.ThrottleInProc:=_ini.ReadBool('Engine','ThrottleInProc',false);
  g_settings.CorrectInProc:=_ini.ReadBool('Engine','CorrectInProc',true);

  af:=_ini.ReadInteger('Engine','AirFlow',0);
  if not (af in [0..5]) then
    af:=0;
  g_settings.AirFlow:=AirFlow_set(af);

  g_settings.InjCount:=_ini.ReadInteger('Engine','InjCount',6);
  g_settings.InjPower:=_ini.ReadFloat('Engine','InjPower',0.0785);
  g_settings.InjFireCount:=_ini.ReadInteger('Engine','InjFireCount',1);
  g_settings.InjTruncate:=_ini.ReadBool('Engine','InjTruncate',false);

  g_trip_comp.ODO:=_ini.ReadFloat('TripPC','ODO',0);
  g_trip_comp.ODO_A:=_ini.ReadFloat('TripPC','ODO_A',0);
  g_trip_comp.ODO_B:=_ini.ReadFloat('TripPC','ODO_B',0);
  g_trip_comp.FuelTank:=_ini.ReadFloat('TripPC','FuelTank',0);
  g_trip_comp.MaxSpeed:=_ini.ReadInteger('TripPC','MaxSpeed',0);

  // по просьбе avgefke
  g_trip_comp.AllTime:=  _ini.ReadFloat('TripPC','AllTime',0);
  g_trip_comp.StayTime:=  _ini.ReadFloat('TripPC','StayTime',0);
  g_trip_comp.DriveTime:=  _ini.ReadFloat('TripPC','DriveTime',0);
  g_trip_comp.Dist:=  _ini.ReadFloat('TripPC','Dist',0);
  g_trip_comp.FuelChargeAll:=  _ini.ReadFloat('TripPC','FuelChargeAll',0);
  g_trip_comp.FuelChargeStay:=  _ini.ReadFloat('TripPC','FuelChargeStay',0);
  g_trip_comp.FuelChargeDrive:=  _ini.ReadFloat('TripPC','FuelChargeDrive',0);
  g_trip_comp.FuelEconomy:=  _ini.ReadFloat('TripPC','FuelEconomy',0);

  // читаем параметры отображени€ на главной форме
  // предустановки что показывать на экране.

  g_value_fields[1].ViewVariant:=vvAvrgFuelChargeBy100km;
  g_value_fields[2].ViewVariant:=vvFuelCharge;
  g_value_fields[3].ViewVariant:=vvMaxSpeed;
  g_value_fields[4].ViewVariant:=vvFuelTank;
  g_value_fields[5].ViewVariant:=vvToStop;
  g_value_fields[6].ViewVariant:=vv_06_Temperature;

  for i:=1 to ValueFieldCount do
    begin
      j:=_ini.ReadInteger('MainFormView','Field'+inttostr(i),-1);

      if j<0 then    // оставл€ем как настроено выше
        continue;

      if j>Integer(High(ViewVariants_set)) then
        continue;

      g_value_fields[i].ViewVariant:=ViewVariants_set(j);
    end;

  j:=_ini.ReadInteger('MainFormView','Cruise',-1);
  if j<0 then    // оставл€ем как настроено выше
    j:=0;
  if j>Integer(High(Cruise_set)) then
    j:=0;
  g_settings.currCruise:=Cruise_set(j);

  j:=_ini.ReadInteger('MainFormView','ODOs',-1);
  if j<0 then    // оставл€ем как настроено выше
    j:=0;
  if j>Integer(High(ODO_set)) then
    j:=0;
  g_settings.currODO:=ODO_set(j);

  FreeAndNil(_ini);
end;

procedure TfmSettings.SaveAutoRunParam;
begin
  // автозапуск
  AutoRunKey := TRegistry.Create;
  AutoRunKey.RootKey := HKEY_LOCAL_MACHINE;
  AutoRunKey.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', true);
  try
    if g_settings.AutoRun then
      AutoRunKey.WriteString('MyEngine',ParamStr(0))
    else
      AutoRunKey.DeleteValue('MyEngine');
  except
  end;
  AutoRunKey.CloseKey;
  AutoRunKey.Free;
end;

procedure  TfmSettings.SaveSettings(_onlyTrip : boolean = false);
var
  _ini : TIniFile;
  i : integer;
begin
  _ini:=TIniFile.Create(ExtractFilePath(Paramstr(0))+'settings.ini');

  if not _onlyTrip then
    begin
      _ini.WriteString('ComPort','Number',g_settings.strComPort);
      _ini.WriteBool('ComPort','InvAdapter',g_settings.InvAdapter);

      _ini.WriteDateTime('View','LastRun',g_settings.LastRun);
      _ini.WriteBool('View','RunMinimize',g_settings.RunMinimize);
      _ini.WriteBool('View','HideMinimized',g_settings.HideMinimized);
      _ini.WriteBool('View','AskOnExit',g_settings.AskOnExit);

      _ini.WriteBool('Engine','ValveXXInSteps',g_settings.ValveXXInSteps);
      _ini.WriteBool('Engine','DirectTemper',g_settings.DirectTemper);
      _ini.WriteBool('Engine','ThrottleInProc',g_settings.ThrottleInProc);
      _ini.WriteInteger('Engine','AirFlow',byte(g_settings.AirFlow));
      _ini.WriteBool('Engine','CorrectInProc',g_settings.CorrectInProc);
      _ini.WriteInteger('Engine','InjCount',g_settings.InjCount);
      _ini.WriteFloat('Engine','InjPower',g_settings.InjPower);
      _ini.WriteInteger('Engine','InjFireCount',g_settings.InjFireCount);
      _ini.WriteBool('Engine','InjTruncate',g_settings.InjTruncate);

      // записываем параметры отображени€ на главной форме
      for i:=1 to ValueFieldCount do
        _ini.WriteInteger('MainFormView','Field'+inttostr(i),Integer(g_value_fields[i].ViewVariant));
      _ini.WriteInteger('MainFormView','Cruise',Integer(g_settings.currCruise));
      _ini.WriteInteger('MainFormView','ODOs',Integer(g_settings.currODO));

    end;

  // Trip info сохран€ем всегда
  _ini.WriteFloat('TripPC','ODO',g_trip_comp.ODO);
  _ini.WriteFloat('TripPC','ODO_A',g_trip_comp.ODO_A);
  _ini.WriteFloat('TripPC','ODO_B',g_trip_comp.ODO_B);
  _ini.WriteFloat('TripPC','FuelTank',g_trip_comp.FuelTank);
  _ini.WriteInteger('TripPC','MaxSpeed',g_trip_comp.MaxSpeed);

  // по просьб avgefke
  // сохран€ем параметры поездки
  _ini.WriteFloat('TripPC','AllTime',g_trip_comp.AllTime);
  _ini.WriteFloat('TripPC','StayTime',g_trip_comp.StayTime);
  _ini.WriteFloat('TripPC','DriveTime',g_trip_comp.DriveTime);
  _ini.WriteFloat('TripPC','Dist',g_trip_comp.Dist);
  _ini.WriteFloat('TripPC','FuelChargeAll',g_trip_comp.FuelChargeAll);
  _ini.WriteFloat('TripPC','FuelChargeStay',g_trip_comp.FuelChargeStay);
  _ini.WriteFloat('TripPC','FuelChargeDrive',g_trip_comp.FuelChargeDrive);
  _ini.WriteFloat('TripPC','FuelEconomy',g_trip_comp.FuelEconomy);

  _ini.Free;
end;

procedure TfmSettings.ShowSettings;
begin
  btUpdateCOMs.Click;   // выводим список портов, а так же выбранный пользователем
  cb_invert.Checked:=g_settings.InvAdapter;
  cbAutoRun.Checked:=g_settings.AutoRun;
  cbRunMinimize.Checked:=g_settings.RunMinimize;
  cbAskOnExit.Checked:=g_settings.AskOnExit;
  cbHideMinimized.Checked:=g_settings.HideMinimized;

  if g_settings.ValveXXInSteps then
    rb_xx_step.Checked:=true
  else
    rb_xx_proc.Checked:=true;

  if g_settings.DirectTemper then
    rb_temp_dir.Checked:=true
  else
    rb_temp_nondir.Checked:=true;

  if g_settings.ThrottleInProc then
    rb_thr_proc.Checked:=true
  else
    rb_thr_grad.Checked:=true;

  if g_settings.CorrectInProc then
    rb_corr_proc.Checked:=true
  else
    rb_corr_v.Checked:=true;

  (FindComponent('rb_air_'+inttostr(byte(g_settings.AirFlow))) as TRadioButton).Checked:=true;

  edInjCnt.Text:=IntToStr(g_settings.InjCount);
  edInjPower.Text:=FormatFloat('0.0000', g_settings.InjPower);
  edInjFire.Text:=IntToStr(g_settings.InjFireCount);
  cbInjTruncate.Checked:=g_settings.InjTruncate;


  // About tab
  lbVersion.Caption:=cpt+' '+ver+' ('+build_date+')';
//  lbCopy.Caption:='Copyright (C) ”ханов ≈вгений, 2011';

end;

procedure TfmSettings.btUpdateCOMsClick(Sender: TObject);
var
  chComPort : array[0..15] of char;
  i : integer;
  hSource : THandle;
begin
  cb_ports.Items.Clear;

  for i:=1 to 20 do
    begin
      ZeroMemory(@chComPort,sizeof(chComPort));

      StrPCopy(chComPort, '\\.\COM'+IntToStr(i));

      hSource := CreateFile(chComPort, GENERIC_READ or GENERIC_WRITE,
        0, nil, OPEN_EXISTING, 0, 0);

      if hSource<>INVALID_HANDLE_VALUE then
        begin
          CloseHandle(hSource);
          cb_ports.Items.Add('COM'+IntToStr(i));
        end;
    end;

  if cb_ports.Items.Count=0 then
    Application.MessageBox('¬ системе не обнаружено свободных COM портов!'#13#13'ѕримите меры!',cpt,MB_ICONWARNING)
  else
    begin
      // выдел€ем COM порт из настроект
      for i:=0 to cb_ports.Items.Count-1 do
        if cb_ports.Items.Strings[i] = g_settings.strComPort then
          begin
            cb_ports.ItemIndex:=i;
            exit;
          end;

      // если выхода выше не произошло, то выдел€ем первый порт
      cb_ports.ItemIndex:=0;
    end;
end;

end.
