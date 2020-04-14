{
  Глобальные переменные и "функции помошники"
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
  // Идентификатор машины/пакета ??
  frame_id_t    = array[1..12] of byte;

type
  // Данные от потока чтения передаются на обработку
  // через данную структуру
  TPacket = record
    Value   : byte;       // значение бита
    Time    : Int64;      // кол-во таких бит подряд
  end;
  PPacket = ^TPacket;

type
  // Структура объединяет параметры ком порта
  // и считанную с него информацию
  TComVar = record
    hPort   : DWord;
    DCB     : TDCB;
    Stat    : TComStat;

    // Для работы в потоке чтения
    CommThread  : THandle;
    RecivBuff   : array [0..329] of TPacket;  // 329 - чтобы уместились все возможные смены состояния 0-1
    Terminated  : boolean;
  end;

type
  // данные полученные от EMC
  // не пересчитанные
  frame_t = record
    _00_FrameID       : frame_id_t;

    _01_Injector      : byte;       // время открытия форсунки
    _02_Ignition      : byte;       // Угол зажигания
    _03_ValveXX       : byte;       // Клапан ХХ
    _04_RPM           : byte;       // Обороты
    _05_AirFlow       : byte;       // MAF|MAP
    _06_Temperature   : byte;       // T
    _07_ThrottleBody  : byte;       // БДЗ
    _08_Speed         : byte;       // Скорость
    _09_CorrectionL   : byte;       // Коррекция Левая
    _10_CorrectionR   : byte;       // Коррекция Правая

    _11_0_ColdStart   : boolean;    // 11.0  Переоб.посл.зап.
    _11_1_ColdEngine  : boolean;    // 11.1  Холодный двиг.
    _11_2_Unknown     : boolean;    //
    _11_3_Unknown     : boolean;    //
    _11_4_Knock       : boolean;    // 11.4  Детонация
    _11_5_Feedback    : boolean;    // 11.5  Обратн.связь
    _11_6_Enrichment  : boolean;    // 11.6  Доп.обогащение
    _11_7_Unknown     : boolean;

    _12_0_Starter     : boolean;    // 12.0  Стартер
    _12_1_Throttle    : boolean;    // 12.1  Дроссельная засл
    _12_2_AirCond     : boolean;    // 12.2  Кондиционер
    _12_3_Neutral     : boolean;    // 12.3  Нейтраль
    _12_4_MixL        : boolean;    // 12.4  Смесь Левая
    _12_5_MixR        : boolean;    // 12.5  Смесь Правая
    _12_6_Unknown     : boolean;    //
    _12_7_Unknown     : boolean;    // 12.7 Диагностика?
  end;
  frames_t = array of frame_t;

  // пересчитанные данные
  // то что пересчитывать не нужно просто копируется (скорость, флаги...)
  recalc_frame_t = record
    _00_FrameID       : frame_id_t;

    _01_Injector      : c_float;       // время открытия форсунки
    _02_Ignition      : c_float;       // Угол зажигания
    _03_ValveXX       : c_float;       // Клапан ХХ
    _04_RPM           : word;         // Обороты
    _05_AirFlow       : c_float;       // MAF|MAP
    _06_Temperature   : c_float;       // T
    _07_ThrottleBody  : c_float;       // БДЗ
    _08_Speed         : byte;          // Скорость
    _09_CorrectionL   : c_float;       // Коррекция Левая
    _10_CorrectionR   : c_float;       // Коррекция Правая

    _11_0_ColdStart   : boolean;    // 11.0  Переоб.посл.зап.
    _11_1_ColdEngine  : boolean;    // 11.1  Холодный двиг.
    _11_2_Unknown     : boolean;    //
    _11_3_Unknown     : boolean;    //
    _11_4_Knock       : boolean;    // 11.4  Детонация
    _11_5_Feedback    : boolean;    // 11.5  Обратн.связь
    _11_6_Enrichment  : boolean;    // 11.6  Доп.обогащение
    _11_7_Unknown     : boolean;

    _12_0_Starter     : boolean;    // 12.0  Стартер
    _12_1_Throttle    : boolean;    // 12.1  Дроссельная засл
    _12_2_AirCond     : boolean;    // 12.2  Кондиционер
    _12_3_Neutral     : boolean;    // 12.3  Нейтраль
    _12_4_MixL        : boolean;    // 12.4  Смесь Левая
    _12_5_MixR        : boolean;    // 12.5  Смесь Правая
    _12_6_Unknown     : boolean;    //
    _12_7_Unknown     : boolean;    //
  end;

  // данные маршрутного компьютера
  trip_comp_t = record
    ReCalcValues  : recalc_frame_t; 

    AllTime       : c_float;    // общее время, сек
    StayTime      : c_float;    // время стоянок в сек.
    DriveTime     : c_float;    // время движения в сек.

    // пробег
    Dist          : c_float;    // пройденное расстояние в км за сессию
    ODO           : c_float;    // пробег с момента установки программы
    ODO_A         : c_float;    // пробег счетчки 1
    ODO_B         : c_float;    // пробег счетчки 1

    FuelChargeAll   : c_float;    // общий расход (сколько израсходованно за поездку)
    FuelChargeStay  : c_float;    // расход на месте
    FuelChargeDrive : c_float;    // расход при движении
    FuelEconomy     : c_float;    // экономия топлива

    FuelTank      : c_float;    // Бензобак

    ToStop        : c_float;    // До остановки, км (пока не кончится бенз.)

    // мгновенные показатели
    FuelChargeNowByHour    : c_float;  // мгновенный расход за час в текущем режиме
    FuelChargeNowBy100km   : c_float;  // мгновенный расход на 100 км в текущем режиме

    // средние показатели
	  AvrgSpeed           : c_float;   // средняя скорость
	  AvrgFuelChargeByHour   : c_float;   // средний расход в час
	  AvrgFuelChargeBy100km  : c_float;   // средний расход на 100 км

    // максимальные показатели
    MaxSpeed      : byte;
  end;

type
  // тип датчика расхода воздуха
  AirFlow_set = (afMAP_kPa = 0, afMAP_mm, afMAPt_kPa, afMAPt_mm, afMAF, afVAF);

  // текущий режим дисплея пробега
  ODO_set = (ODO = 0, ODO_A, ODO_B);

  // текущий режим круиз дисплея
  Cruise_set = (
    AllTime = 0,         // время в пути
    DriveTime,          // время движения
    StayTime,           // время остановок
    LiveDist,           // текущий пробег
    AvrgSpeed,          // вредняя скорость
    Charge100Now,       // мгновенный расход на 100 км
    ChargeHourAvrg,     // средний расход в час
    ChargeHourNow      // мгновенный расход в час
  );

const
  ValueFieldCount   = 6;    // число полей-значений на главной форме

type
  // что можно отображать на экране
  ViewVariants_set = (
    // Маршрутный ПК
    vvAvrgFuelChargeBy100km = 0,
    vvFuelChargeNowBy100km,       // мгновенный расход на 100 км
    vvAvrgFuelChargeByHour,       // средний расход в час
    vvFuelChargeNowByHour,        // мгновенный расход в час
    vvFuelCharge,                 // Количество израсходованного топлива за поездку
    vvFuelTank,
    vvToStop,
    vvFuelEconomy,

    // скорость береться напрямую из протокола,
    // но т.к. это больше параметр маршрутного компьютера, то она перенесена
    // сюда. но название и номер поля 08 сохранено.
    vv_08_Speed,                  // Скорость
    vvAvrgSpeed,                  // вредняя скорость
    vvMaxSpeed,
    
    vvAllTime,
    vvDriveTime,
    vvStayTime,
    vvLiveDist,                   // текущий пробег

    vvODO,
    vvODO_A,
    vvODO_B,

    // Диагностические параметры
    vv_01_Injector,           // время открытия форсунки
    vv_02_Ignition,           // Угол зажигания
    vv_03_ValveXX,            // Клапан ХХ
    vv_04_RPM,                // Обороты
    vv_05_AirFlow,            // MAF|MAP
    vv_06_Temperature,            // T
    vv_07_ThrottleBody,           // БДЗ
//    vv_08_Speed,              // Скорость    ------>>> перенес наверх в марш. параметры
    vv_09_CorrectionL,            // Коррекция Левая
    vv_10_CorrectionR,            // Коррекция Правая

    vv_11_0_ColdStart,            // 11.0  Переоб.посл.зап.
    vv_11_1_ColdEngine,           // 11.1  Холодный двиг.

vv_11_2_Unknown,
vv_11_3_Unknown,

    vv_11_4_Knock,              // 11.4  Детонация

vv_11_5_Feedback,                 // 11.5  Обратн.связь    

    vv_11_6_Enrichment,         // 11.6  Доп.обогащение

vv_11_7_Unknown,

    vv_12_0_Starter,            // 12.0  Стартер
    vv_12_1_Throttle,           // 12.1  Дроссельная засл
    vv_12_2_AirCond,            // 12.2  Кондиционер
    vv_12_3_Neutral,            // 12.3  Нейтраль
    vv_12_4_MixL,               // 12.4  Смесь Левая
    vv_12_5_MixR,                // 12.5  Смесь Правая

vv_12_6_Unknown,
vv_12_7_Unknown
  );

  // поле для вывода:
  // заголовок, измерение - значение
  value_field_t = record
    lbCaption     : TLabel;
    lbMeasure     : TLabel;
    lbValue       : TLabel;

    ViewVariant   : ViewVariants_set;
  end;

  // настройки
  settings_t = record
    // соединение
    strComPort      : string;
    InvAdapter      : boolean;

    LastRun         : TDateTime;  // время последнего запуска

    // параметры ТС
    ValveXXInSteps  : boolean;    // КХХ в процентах
    DirectTemper    : boolean;    // Прямая температура
    ThrottleInProc  : boolean;    // БДЗ в %
    AirFlow         : AirFlow_set;
    CorrectInProc   : boolean;    // коррекция в процентах
    InjCount        : byte;       // число форсунок
    InjPower        : c_float;    // произв. форсунки
    InjFireCount    : byte;       // число срабатываний за 2 об. колена
    InjTruncate     : boolean; // учитывать отсечки впрыска

    // хоть один раз изменился флаг 11.5
    // только после этого делаем учет отсечек
    // бывает если ехать на не прогретой машине, то
    // отсечка срабатывает постоянно (т.к. 11.5 еще = НЕТ ВПРЫСКА)
    OneChange_11_5  : boolean;

    // автозапуск
    AutoRun         : boolean;
    //
    RunMinimize     : boolean;
    HideMinimized   : boolean;
    //
    AskOnExit       : boolean;

    // текущие поля для отображения
    currODO         : ODO_set;
    currCruise      : Cruise_set; 
  end;

type
  my_engine_t = record
    main_form     : HWND;

    frames        : frames_t; // кадры
    frames_cnt    : int;    // текущая позиция кадра
    frames_alloc  : int;    // выделено памяти
  end;

var
  g_bActive     : boolean = false;  // программа в работе (идет чтение данных)
  g_ComPort     : TComVar;

  // для подсчета времени между пакетами
  g_tmNow   : Int64 = 0;
  g_tmLast  : Int64 = 0;
  g_speed   : Int64 = 0;

  my_engine   : my_engine_t;
  g_settings  : settings_t;
  g_trip_comp : trip_comp_t;
  g_value_fields : array[1..ValueFieldCount] of value_field_t;
  g_ClickByLabel : integer = -1;

  // Текстовые поля - заголовок поля и величина измерения
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
// функция переводить время из секунд в
// представление HH:MM - ЧАСЫ:МИНУТЫ в виде текста
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

// функция переводить время из секунд в
// представление HH:MM - ЧАСЫ:МИНУТЫ в виде текста
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

  // есть хоть один час
  if sec>=3600 then
    begin
      H:=trunc(_sec/60/60); // выделяем часы
      sec:=sec - H*60*60;   // убираем часы из общих секунд
    end;

  // есть минутка
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
