{
  ���������� ���������� � "������� ���������"
}

unit me_Vars;

interface

uses
  Windows, StdCtrls;

const
  cpt = 'MyEngine';
  ver = '1.3.3';
  build_date = '19.10.2011';

type
  c_float = double;       // C++ float
  int     = integer;      // C++ int

type
  byte_t = array[0..7] of byte;
  pbyte_t = ^byte_t;
  // ������������� ������/������ ??
  frame_id_t    = array[1..12] of byte;

type
  // ������ �� ������ ������ ���������� �� ���������
  // ����� ������ ���������
  TPacket = record
    Value   : byte;       // �������� ����
    Time    : Int64;      // ���-�� ����� ��� ������
  end;
  PPacket = ^TPacket;

type
  // ��������� ���������� ��������� ��� �����
  // � ��������� � ���� ����������
  TComVar = record
    hPort   : DWord;
    DCB     : TDCB;
    Stat    : TComStat;

    // ��� ������ � ������ ������
    CommThread  : THandle;
    RecivBuff   : array [0..329] of TPacket;  // 329 - ����� ���������� ��� ��������� ����� ��������� 0-1
    Terminated  : boolean;
  end;

type
  // ������ ���������� �� EMC
  // �� �������������
  frame_t = record
    _00_FrameID       : frame_id_t;

    _01_Injector      : byte;       // ����� �������� ��������
    _02_Ignition      : byte;       // ���� ���������
    _03_ValveXX       : byte;       // ������ ��
    _04_RPM           : byte;       // �������
    _05_AirFlow       : byte;       // MAF|MAP
    _06_Temperature   : byte;       // T
    _07_ThrottleBody  : byte;       // ���
    _08_Speed         : byte;       // ��������
    _09_CorrectionL   : byte;       // ��������� �����
    _10_CorrectionR   : byte;       // ��������� ������

    _11_0_ColdStart   : boolean;    // 11.0  ������.����.���.
    _11_1_ColdEngine  : boolean;    // 11.1  �������� ����.
    _11_2_Unknown     : boolean;    //
    _11_3_Unknown     : boolean;    //
    _11_4_Knock       : boolean;    // 11.4  ���������
    _11_5_Feedback    : boolean;    // 11.5  ������.�����
    _11_6_Enrichment  : boolean;    // 11.6  ���.����������
    _11_7_Unknown     : boolean;

    _12_0_Starter     : boolean;    // 12.0  �������
    _12_1_Throttle    : boolean;    // 12.1  ����������� ����
    _12_2_AirCond     : boolean;    // 12.2  �����������
    _12_3_Neutral     : boolean;    // 12.3  ��������
    _12_4_MixL        : boolean;    // 12.4  ����� �����
    _12_5_MixR        : boolean;    // 12.5  ����� ������
    _12_6_Unknown     : boolean;    //
    _12_7_Unknown     : boolean;    // 12.7 �����������?
  end;
  frames_t = array of frame_t;

  // ������������� ������
  // �� ��� ������������� �� ����� ������ ���������� (��������, �����...)
  recalc_frame_t = record
    _00_FrameID       : frame_id_t;

    _01_Injector      : c_float;       // ����� �������� ��������
    _02_Ignition      : c_float;       // ���� ���������
    _03_ValveXX       : c_float;       // ������ ��
    _04_RPM           : word;         // �������
    _05_AirFlow       : c_float;       // MAF|MAP
    _06_Temperature   : c_float;       // T
    _07_ThrottleBody  : c_float;       // ���
    _08_Speed         : byte;          // ��������
    _09_CorrectionL   : c_float;       // ��������� �����
    _10_CorrectionR   : c_float;       // ��������� ������

    _11_0_ColdStart   : boolean;    // 11.0  ������.����.���.
    _11_1_ColdEngine  : boolean;    // 11.1  �������� ����.
    _11_2_Unknown     : boolean;    //
    _11_3_Unknown     : boolean;    //
    _11_4_Knock       : boolean;    // 11.4  ���������
    _11_5_Feedback    : boolean;    // 11.5  ������.�����
    _11_6_Enrichment  : boolean;    // 11.6  ���.����������
    _11_7_Unknown     : boolean;

    _12_0_Starter     : boolean;    // 12.0  �������
    _12_1_Throttle    : boolean;    // 12.1  ����������� ����
    _12_2_AirCond     : boolean;    // 12.2  �����������
    _12_3_Neutral     : boolean;    // 12.3  ��������
    _12_4_MixL        : boolean;    // 12.4  ����� �����
    _12_5_MixR        : boolean;    // 12.5  ����� ������
    _12_6_Unknown     : boolean;    //
    _12_7_Unknown     : boolean;    //
  end;

  // ������ ����������� ����������
  trip_comp_t = record
    ReCalcValues  : recalc_frame_t; 

    AllTime       : c_float;    // ����� �����, ���
    StayTime      : c_float;    // ����� ������� � ���.
    DriveTime     : c_float;    // ����� �������� � ���.

    // ������
    Dist          : c_float;    // ���������� ���������� � �� �� ������
    ODO           : c_float;    // ������ � ������� ��������� ���������
    ODO_A         : c_float;    // ������ ������� 1
    ODO_B         : c_float;    // ������ ������� 1

    FuelChargeAll   : c_float;    // ����� ������ (������� �������������� �� �������)
    FuelChargeStay  : c_float;    // ������ �� �����
    FuelChargeDrive : c_float;    // ������ ��� ��������
    FuelEconomy     : c_float;    // �������� �������

    FuelTank      : c_float;    // ��������

    ToStop        : c_float;    // �� ���������, �� (���� �� �������� ����.)

    // ���������� ����������
    FuelChargeNowByHour    : c_float;  // ���������� ������ �� ��� � ������� ������
    FuelChargeNowBy100km   : c_float;  // ���������� ������ �� 100 �� � ������� ������

    // ������� ����������
	  AvrgSpeed           : c_float;   // ������� ��������
	  AvrgFuelChargeByHour   : c_float;   // ������� ������ � ���
	  AvrgFuelChargeBy100km  : c_float;   // ������� ������ �� 100 ��

    // ������������ ����������
    MaxSpeed      : byte;
  end;

type
  // ��� ������� ������� �������
  AirFlow_set = (afMAP_kPa = 0, afMAP_mm, afMAPt_kPa, afMAPt_mm, afMAF, afVAF);

  // ������� ����� ������� �������
  ODO_set = (ODO = 0, ODO_A, ODO_B);

  // ������� ����� ����� �������
  Cruise_set = (
    AllTime = 0,         // ����� � ����
    DriveTime,          // ����� ��������
    StayTime,           // ����� ���������
    LiveDist,           // ������� ������
    AvrgSpeed,          // ������� ��������
    Charge100Now,       // ���������� ������ �� 100 ��
    ChargeHourAvrg,     // ������� ������ � ���
    ChargeHourNow      // ���������� ������ � ���
  );

const
  ValueFieldCount   = 6;    // ����� �����-�������� �� ������� �����

type
  // ��� ����� ���������� �� ������
  ViewVariants_set = (
    // ���������� ��
    vvAvrgFuelChargeBy100km = 0,
    vvFuelChargeNowBy100km,       // ���������� ������ �� 100 ��
    vvAvrgFuelChargeByHour,       // ������� ������ � ���
    vvFuelChargeNowByHour,        // ���������� ������ � ���
    vvFuelCharge,                 // ���������� ���������������� ������� �� �������
    vvFuelTank,
    vvToStop,
    vvFuelEconomy,

    // �������� �������� �������� �� ���������,
    // �� �.�. ��� ������ �������� ����������� ����������, �� ��� ����������
    // ����. �� �������� � ����� ���� 08 ���������.
    vv_08_Speed,                  // ��������
    vvAvrgSpeed,                  // ������� ��������
    vvMaxSpeed,
    
    vvAllTime,
    vvDriveTime,
    vvStayTime,
    vvLiveDist,                   // ������� ������

    vvODO,
    vvODO_A,
    vvODO_B,

    // ��������������� ���������
    vv_01_Injector,           // ����� �������� ��������
    vv_02_Ignition,           // ���� ���������
    vv_03_ValveXX,            // ������ ��
    vv_04_RPM,                // �������
    vv_05_AirFlow,            // MAF|MAP
    vv_06_Temperature,            // T
    vv_07_ThrottleBody,           // ���
//    vv_08_Speed,              // ��������    ------>>> ������� ������ � ����. ���������
    vv_09_CorrectionL,            // ��������� �����
    vv_10_CorrectionR,            // ��������� ������

    vv_11_0_ColdStart,            // 11.0  ������.����.���.
    vv_11_1_ColdEngine,           // 11.1  �������� ����.

vv_11_2_Unknown,
vv_11_3_Unknown,

    vv_11_4_Knock,              // 11.4  ���������

vv_11_5_Feedback,                 // 11.5  ������.�����    

    vv_11_6_Enrichment,         // 11.6  ���.����������

vv_11_7_Unknown,

    vv_12_0_Starter,            // 12.0  �������
    vv_12_1_Throttle,           // 12.1  ����������� ����
    vv_12_2_AirCond,            // 12.2  �����������
    vv_12_3_Neutral,            // 12.3  ��������
    vv_12_4_MixL,               // 12.4  ����� �����
    vv_12_5_MixR,                // 12.5  ����� ������

vv_12_6_Unknown,
vv_12_7_Unknown
  );

  // ���� ��� ������:
  // ���������, ��������� - ��������
  value_field_t = record
    lbCaption     : TLabel;
    lbMeasure     : TLabel;
    lbValue       : TLabel;

    ViewVariant   : ViewVariants_set;
  end;

  // ���������
  settings_t = record
    // ����������
    strComPort      : string;
    InvAdapter      : boolean;

    LastRun         : TDateTime;  // ����� ���������� �������

    // ��������� ��
    ValveXXInSteps  : boolean;    // ��� � ���������
    DirectTemper    : boolean;    // ������ �����������
    ThrottleInProc  : boolean;    // ��� � %
    AirFlow         : AirFlow_set;
    CorrectInProc   : boolean;    // ��������� � ���������
    InjCount        : byte;       // ����� ��������
    InjPower        : c_float;    // ������. ��������
    InjFireCount    : byte;       // ����� ������������ �� 2 ��. ������
    InjTruncate     : boolean; // ��������� ������� �������

    // ���� ���� ��� ��������� ���� 11.5
    // ������ ����� ����� ������ ���� �������
    // ������ ���� ����� �� �� ��������� ������, ��
    // ������� ����������� ��������� (�.�. 11.5 ��� = ��� �������)
    OneChange_11_5  : boolean;

    // ����������
    AutoRun         : boolean;
    //
    RunMinimize     : boolean;
    HideMinimized   : boolean;
    //
    AskOnExit       : boolean;

    // ������� ���� ��� �����������
    currODO         : ODO_set;
    currCruise      : Cruise_set; 
  end;

type
  my_engine_t = record
    main_form     : HWND;

    frames        : frames_t; // �����
    frames_cnt    : int;    // ������� ������� �����
    frames_alloc  : int;    // �������� ������
  end;

var
  g_bActive     : boolean = false;  // ��������� � ������ (���� ������ ������)
  g_ComPort     : TComVar;

  // ��� �������� ������� ����� ��������
  g_tmNow   : Int64 = 0;
  g_tmLast  : Int64 = 0;
  g_speed   : Int64 = 0;

  my_engine   : my_engine_t;
  g_settings  : settings_t;
  g_trip_comp : trip_comp_t;
  g_value_fields : array[1..ValueFieldCount] of value_field_t;
  g_ClickByLabel : integer = -1;

  // ��������� ���� - ��������� ���� � �������� ���������
  g_Captions, g_Measures : array[ViewVariants_set] of string;

{$ifdef DEBUG}
type
  TLogClass = class
    fFile       : textfile;
    fOk         : Boolean;

    constructor Create;
    destructor Destroy; override;

    procedure Add(_str :  string);
  end;

var
  log : TLogClass;
{$endif}

function _strLen(_str : PAnsiChar) : int;
function _strAssign(_str : PAnsiChar) : PAnsiChar;
function _8BitToValue(_8b : pbyte_t) : byte;
// ������� ���������� ����� �� ������ �
// ������������� HH:MM - ����:������ � ���� ������
function TimeToHM(_sec : c_float) : string;

implementation

uses SysUtils;

function _strLen(_str : PAnsiChar) : int;
begin
  result:=0;
  if _str=nil then
    exit;
  result:=strlen(_str);
end;

function _strAssign(_str : PAnsiChar) : PAnsiChar;
var
  _cLen : int;
begin
  Result:=nil;
  _cLen:=_strLen(_str);
  if _cLen=0 then
    exit;

  Result:=AllocMem(_cLen+1);
  StrPCopy(Result,_str);
end;

function _8BitToValue(_8b : pbyte_t) : byte;
var
  i : int;
begin
  result:=0;

  for i:=0 to 7 do
    result:=result or (_8b[i] shl i);
end;

// ������� ���������� ����� �� ������ �
// ������������� HH:MM - ����:������ � ���� ������
function TimeToHM(_sec : c_float) : string;
var
  sec, H, M : int;
begin
  Result:='00:00';
  H:=0;
  M:=0;

  sec:=Trunc(_sec);

  if _sec<60 then
    exit;

  // ���� ���� ���� ���
  if sec>=3600 then
    begin
      H:=trunc(_sec/60/60); // �������� ����
      sec:=sec - H*60*60;   // ������� ���� �� ����� ������
    end;

  // ���� �������
  if sec>=60 then
    M:=Trunc(sec/60);

  if H<10 then
    Result:='0'+inttostr(H)
  else
    Result:=inttostr(H);

  Result:=Result+':';

  if M<10 then
    Result:=Result+'0'+inttostr(M)
  else
    Result:=Result+inttostr(M);
end;


{ TLogClass }

{$ifdef DEBUG}

procedure TLogClass.Add(_str: string);
begin
  if fOk then
    begin
      writeln(fFile,FormatDateTime('DD-MM-YY hh:nn:ss.zzz',now),', ',_str);
      flush(fFile);
    end;
end;

constructor TLogClass.Create;
begin
  AssignFile(fFile,'c:\myengine_log.txt');

  {$I-}
  if FileExists('c:\myengine_log.txt') then
    Append(fFile)
  else
    Rewrite(fFile);
  {$I+}

  fOk:=IOResult = NO_ERROR;
end;

destructor TLogClass.Destroy;
begin
  {$I-}
  if fOk then
    CloseFile(fFile);
  {$I+}
end;

{$endif}

end.
