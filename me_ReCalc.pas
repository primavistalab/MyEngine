{
  Пересчет данных кадра Тойоты в зависимости от настроек.
}

unit me_ReCalc;

interface

uses
  me_Vars;

function ReCalcFrame(_frame : frame_t) : recalc_frame_t;

implementation

uses
  Windows;

function ReCalcFrame(_frame : frame_t) : recalc_frame_t;
var
  _temp : byte;
begin
{
  Ниже есть закомментированные строки пересчета
  Формулы там нормальные. Это сделано для того, чтобы
  лишний раз не пересчитывать не нужные данные.
  Если они понадобятся просто раскомментируйте строку.
}

  ZeroMemory(@result,sizeof(result));

  result._00_FrameID:=_frame._00_FrameID;

  result._01_Injector:=_frame._01_Injector*0.125;

  result._02_Ignition:=_frame._02_Ignition*0.47-30;
//
  if g_settings.ValveXXInSteps then
    result._03_ValveXX:=_frame._03_ValveXX
  else
    result._03_ValveXX:=_frame._03_ValveXX/255*100;

  result._04_RPM:=_frame._04_RPM*25;

  case g_settings.AirFlow of
    afMAP_kPa:
      result._05_AirFlow:=_frame._05_AirFlow*0.6515;
    afMAP_mm:
      result._05_AirFlow:=_frame._05_AirFlow*4.886;
    afMAPt_kPa:
      result._05_AirFlow:=_frame._05_AirFlow*0.97;
    afMAPt_mm:
      result._05_AirFlow:=_frame._05_AirFlow*7.732;
    afMAF:
      result._05_AirFlow:=_frame._05_AirFlow;
    afVAF:
      result._05_AirFlow:=_frame._05_AirFlow/255*5;
  end;

  if g_settings.DirectTemper then
    _temp:=_frame._06_Temperature
  else
    _temp:=255-_frame._06_Temperature;

  case _temp of
    0..14:
      result._06_Temperature:=(_temp - 5) * 2 - 60;
    15..38:
      result._06_Temperature:=(_temp - 15) * 0.83 - 40;
    39..81:
      result._06_Temperature:=(_temp - 39) * 0.47 - 20;
    82..134:
      result._06_Temperature:=(_temp - 82) * 0.38;
    135..179:
      result._06_Temperature:=(_temp - 135) * 0.44 + 20;
    180..209:
      result._06_Temperature:=(_temp - 180) * 0.67 + 40;
    210..227:
      result._06_Temperature:=(_temp - 210) * 1.11 + 60;
    228..236:
      result._06_Temperature:=(_temp - 228) * 2.11 + 80;
    237..242:
      result._06_Temperature:=(_temp - 237) * 3.83 + 99;
    243..255:
      result._06_Temperature:=(_temp - 243) * 9.8 + 122;
  end;

  if g_settings.ThrottleInProc then
    result._07_ThrottleBody:=_frame._07_ThrottleBody/1.8
  else
    result._07_ThrottleBody:=_frame._07_ThrottleBody/2;

  result._08_Speed:=_frame._08_Speed;

  { TODO :
Сделать настройку коррекции в % как в версии 8000
Сейчас только вольты }
  if g_settings.CorrectInProc then
    begin
	
	{
		solve:
		Диапазон значения в вольтах от 0 до 5:
		0V = -20%
		5V = +20%
		
		Зависимость линейная, например:
		0V		= -20%
		0,25V	= -10%
		2,5V	= 0%
		3.75V	= +10%
		5V 		= +20%
		
		Поэтому для решения сдвинем значения в процентах на +20:
		0V = 0%
		5V = +40%
		
		Пересчитаем значение в проценты по пропорции и вычтем поправочный коэффициен (20):
		  x V
		( --- * 40 ) - 20  = Y %
		  5 V
		  
		ДАННЫЙ МЕТОД ПРОВЕРЕН И СВЕРЕН С ВЕРСИЕЙ 8000
	}
      result._09_CorrectionL:=(_frame._09_CorrectionL / 5.0) * 40 - 20;
      result._10_CorrectionR:=(_frame._10_CorrectionR / 5.0) * 40 - 20;
    end
  else
    begin
      { TODO : Почему 256, а не 255 ? }
      result._09_CorrectionL:=_frame._09_CorrectionL*5/256;
      result._10_CorrectionR:=_frame._10_CorrectionR*5/256;
    end;

  // ФЛАГИ - не пересчитываются в принципе
  result._11_0_ColdStart:=    _frame._11_0_ColdStart;
  result._11_1_ColdEngine:=   _frame._11_1_ColdEngine;
  result._11_2_Unknown:=      _frame._11_2_Unknown;
  result._11_3_Unknown:=      _frame._11_3_Unknown;
  result._11_4_Knock:=        _frame._11_4_Knock;
  result._11_5_Feedback:=     _frame._11_5_Feedback;
  result._11_6_Enrichment:=   _frame._11_6_Enrichment;
  result._11_7_Unknown:=      _frame._11_7_Unknown;

  result._12_0_Starter:=      _frame._12_0_Starter;
  result._12_1_Throttle:=     _frame._12_1_Throttle;
  result._12_2_AirCond:=      _frame._12_2_AirCond;
  result._12_3_Neutral:=      _frame._12_3_Neutral;
  result._12_4_MixL:=         _frame._12_4_MixL;
  result._12_5_MixR:=         _frame._12_5_MixR;
  result._12_6_Unknown:=      _frame._12_6_Unknown;
  result._12_7_Unknown:=      _frame._12_7_Unknown;
end;

end.
