{
  Отрисовка фрейма на экране
}

unit me_Draw;

interface

uses
  me_vars, me_StrRes;

procedure DrawTripInfo(_tripComp : trip_comp_t);
procedure DrawCaptionsMeasures;

implementation

uses
  me_MainForm, SysUtils, FloatUtils, Windows, Graphics, StdCtrls;

procedure DrawTripInfo(_tripComp : trip_comp_t);
var
  i : int;
  lb : TLabel;
begin
  with fmMainForm do
    begin
      // Основные поля с информацией
      for i:=1 to ValueFieldCount do
        begin
          lb:=g_value_fields[i].lbValue;

          case g_value_fields[i].ViewVariant of
            vvAvrgFuelChargeBy100km:
              if _tripComp.Dist>0.2 then    // проехали более 200 м.
                lb.Caption:=FormatFloatDot('0.0',_tripComp.AvrgFuelChargeBy100km)
              else
                lb.Caption:='-.-';

            vvFuelCharge:
              lb.Caption:=FormatFloatDot('0.0',_tripComp.FuelChargeAll);

            vvMaxSpeed:
              lb.Caption:=IntToStr(_tripComp.MaxSpeed);

            vvFuelTank:
              lb.Caption:=FormatFloatDot('0.0',_tripComp.FuelTank);

            vvToStop:
              lb.Caption:=FormatFloatDot('0',_tripComp.ToStop);

            vvAllTime:
              lb.Caption:=TimeToHM(_tripComp.AllTime);

            vvDriveTime:
              lb.Caption:=TimeToHM(_tripComp.DriveTime);

            vvStayTime:
              lb.Caption:=TimeToHM(_tripComp.StayTime);

            vvLiveDist:                   // текущий пробег
              lb.Caption:=FormatFloatDot('0.0',_tripComp.Dist);

            vvAvrgSpeed:                  // вредняя скорость
              lb.Caption:=FormatFloatDot('0.0',_tripComp.AvrgSpeed);

            vvFuelChargeNowBy100km:       // мгновенный расход на 100 км
              if _tripComp.ReCalcValues._08_Speed>0 then
                lb.Caption:=FormatFloatDot('0.0',_tripComp.FuelChargeNowBy100km)
              else
                lb.Caption:='-.-';

            vvAvrgFuelChargeByHour:       // средний расход в час
              lb.Caption:=FormatFloatDot('0.0',_tripComp.AvrgFuelChargeByHour);

            vvFuelChargeNowByHour:        // мгновенный расход в час
              lb.Caption:=FormatFloatDot('0.0',_tripComp.FuelChargeNowByHour);

            vvFuelEconomy:        // экономия
              lb.Caption:=FormatFloatDot('0.0',_tripComp.FuelEconomy);

            vvODO:
                lb.Caption:=FormatFloatDot('0.0',_tripComp.ODO);
            vvODO_A:
                lb.Caption:=FormatFloatDot('0.0',_tripComp.ODO_A);
            vvODO_B:
                lb.Caption:=FormatFloatDot('0.0',_tripComp.ODO_B);

            // Диагностические параметры
            vv_01_Injector:           // время открытия форсунки
              lb.Caption:=FormatFloatDot('0.00',_tripComp.ReCalcValues._01_Injector);

            vv_02_Ignition:           // Угол зажигания
              lb.Caption:=FormatFloatDot('0.0',_tripComp.ReCalcValues._02_Ignition);

            vv_03_ValveXX:            // Клапан ХХ
              if g_settings.ValveXXInSteps then
                lb.Caption:=FormatFloatDot('0',_tripComp.ReCalcValues._03_ValveXX)
              else
                lb.Caption:=FormatFloatDot('0.0',_tripComp.ReCalcValues._03_ValveXX);

            vv_04_RPM:                // Обороты
             lb.Caption:=inttostr(_tripComp.ReCalcValues._04_RPM);

            vv_05_AirFlow:            // MAF|MAP
              case g_settings.AirFlow of
                afMAP_kPa:
                  lb.Caption:=FormatFloatDot('0.0',_tripComp.ReCalcValues._05_AirFlow);
                afMAP_mm:
                  lb.Caption:=FormatFloatDot('0',_tripComp.ReCalcValues._05_AirFlow);
                afMAPt_kPa:
                  lb.Caption:=FormatFloatDot('0.0',_tripComp.ReCalcValues._05_AirFlow);
                afMAPt_mm:
                  lb.Caption:=FormatFloatDot('0',_tripComp.ReCalcValues._05_AirFlow);
                afMAF:
                  lb.Caption:=FormatFloatDot('0.0',_tripComp.ReCalcValues._05_AirFlow);
                afVAF:
                  lb.Caption:=FormatFloatDot('0.00',_tripComp.ReCalcValues._05_AirFlow);
              end;

            vv_06_Temperature:            // T
              lb.Caption:=FormatFloatDot('0.0',_tripComp.ReCalcValues._06_Temperature);

            vv_07_ThrottleBody:           // БДЗ
              lb.Caption:=FormatFloatDot('0.0',_tripComp.ReCalcValues._07_ThrottleBody);

            vv_08_Speed:              // Скорость
              lb.Caption:=IntToStr(_tripComp.ReCalcValues._08_Speed);

            vv_09_CorrectionL:            // Коррекция Левая
              lb.Caption:=FormatFloatDot('0.00',_tripComp.ReCalcValues._09_CorrectionL);

            vv_10_CorrectionR:            // Коррекция Правая
              lb.Caption:=FormatFloatDot('0.00',_tripComp.ReCalcValues._10_CorrectionR);

            // ФЛАГИ
            vv_11_0_ColdStart:            // 11.0  Переоб.посл.зап.
              if _tripComp.ReCalcValues._11_0_ColdStart then
                lb.Caption := rsOn
              else
                lb.Caption := rsOff;

            vv_11_1_ColdEngine:           // 11.1  Холодный двиг.
              if _tripComp.ReCalcValues._11_1_ColdEngine then
                lb.Caption := rsYes
              else
                lb.Caption := rsNo;

            vv_11_2_Unknown:
              lb.Caption:=IntToStr(int(_tripComp.ReCalcValues._11_2_Unknown));

            vv_11_3_Unknown:
              lb.Caption:=IntToStr(int(_tripComp.ReCalcValues._11_3_Unknown));

            vv_11_4_Knock:              // 11.4  Детонация
              if _tripComp.ReCalcValues._11_4_Knock then
                lb.Caption := rsYes
              else
                lb.Caption := rsNo;

            vv_11_5_Feedback:           // 11.5
              if _tripComp.ReCalcValues._11_5_Feedback then
                lb.Caption := rsHave
              else
                lb.Caption := rsHaveNot;

            vv_11_6_Enrichment:         // 11.6  Доп.обогащение
              if _tripComp.ReCalcValues._11_6_Enrichment then
                lb.Caption := rsOn
              else
                lb.Caption := rsOff;

            vv_11_7_Unknown:
              lb.Caption:=IntToStr(int(_tripComp.ReCalcValues._11_7_Unknown));

            vv_12_0_Starter:            // 12.0  Стартер
              if _tripComp.ReCalcValues._12_0_Starter then
                lb.Caption := rsOn
              else
                lb.Caption := rsOff;

            vv_12_1_Throttle:           // 12.1  Дроссельная засл
              if _tripComp.ReCalcValues._12_1_Throttle then
                lb.Caption := rsClose
              else
                lb.Caption := rsOpen;

            vv_12_2_AirCond:            // 12.2  Кондиционер
              if _tripComp.ReCalcValues._12_2_AirCond then
                lb.Caption := rsOn
              else
                lb.Caption := rsOff;

            vv_12_3_Neutral:            // 12.3  Нейтраль
              if _tripComp.ReCalcValues._12_3_Neutral then
                lb.Caption := rsOn
              else
                lb.Caption := rsOff;

            vv_12_4_MixL:               // 12.4  Смесь Левая
              if _tripComp.ReCalcValues._12_4_MixL then
                lb.Caption := rsMixRich
              else
                lb.Caption := rsMixLean;

            vv_12_5_MixR:                // 12.5  Смесь Правая
              if _tripComp.ReCalcValues._12_5_MixR then
                lb.Caption := rsMixRich
              else
                lb.Caption := rsMixLean;

            vv_12_6_Unknown:
              lb.Caption:=IntToStr(int(_tripComp.ReCalcValues._12_6_Unknown));
              
            vv_12_7_Unknown:
              if _tripComp.ReCalcValues._12_7_Unknown then
                lb.Caption := rsNo
              else
                lb.Caption := rsYes
          end;
        end;

      // Дисплей пробега
      case g_settings.currODO of
        ODO:
            lbODOValue.Caption:=FormatFloatDot('0.0',_tripComp.ODO);
        ODO_A:
            lbODOValue.Caption:=FormatFloatDot('0.0',_tripComp.ODO_A);
        ODO_B:
            lbODOValue.Caption:=FormatFloatDot('0.0',_tripComp.ODO_B);
      end;

      // Круиз дисплей
      case g_settings.currCruise of
        AllTime:
            lbCruiseValue.Caption:=TimeToHM(_tripComp.AllTime);
        DriveTime:
            lbCruiseValue.Caption:=TimeToHM(_tripComp.DriveTime);
        StayTime:
            lbCruiseValue.Caption:=TimeToHM(_tripComp.StayTime);
        LiveDist:
            lbCruiseValue.Caption:=FormatFloatDot('0.0',_tripComp.Dist);
        AvrgSpeed:
            lbCruiseValue.Caption:=FormatFloatDot('0.0',_tripComp.AvrgSpeed);
        Charge100Now:
            if _tripComp.ReCalcValues._08_Speed>0 then
              lbCruiseValue.Caption:=FormatFloatDot('0.0',_tripComp.FuelChargeNowBy100km)
            else
              lbCruiseValue.Caption:='-.-';
        ChargeHourAvrg:
            lbCruiseValue.Caption:=FormatFloatDot('0.0',_tripComp.AvrgFuelChargeByHour);
        ChargeHourNow:
            lbCruiseValue.Caption:=FormatFloatDot('0.0',_tripComp.FuelChargeNowByHour);
      end;

    // Фоксированные поля
    lbSpeed.Caption:=IntToStr(_tripComp.ReCalcValues._08_Speed);
    lbRPM.Caption:= IntToStr(_tripComp.ReCalcValues._04_RPM);

  end; //   with fmMainForm do
end;

procedure DrawCaptionsMeasures;
var
  i : int;
begin
  with fmMainForm do
    begin
      // Дисплей пробега
      case g_settings.currODO of
        ODO:
            lbODOName.Caption:='Общий пробег';
        ODO_A:
            lbODOName.Caption:='Пробег А';
        ODO_B:
            lbODOName.Caption:='Пробег Б';
      end;

      // Круиз дисплей
      case g_settings.currCruise of
        AllTime:
          begin
            lbCruiseName.Caption:='Общее время';
            lbCruiseMeasure.Caption:='';
          end;
        DriveTime:
          begin
            lbCruiseName.Caption:='Время движения';
            lbCruiseMeasure.Caption:='';
          end;
        StayTime:
          begin
            lbCruiseName.Caption:='Время остановок';
            lbCruiseMeasure.Caption:='';
          end;
        LiveDist:
          begin
            lbCruiseName.Caption:='Текущий пробег';
            lbCruiseMeasure.Caption:='км';
          end;
        AvrgSpeed:
          begin
            lbCruiseName.Caption:='Средняя скорость';
            lbCruiseMeasure.Caption:='км/ч';
          end;
        Charge100Now:
          begin
            lbCruiseName.Caption:='Мгновенный расход';
            lbCruiseMeasure.Caption:='л/100км';
          end;
        ChargeHourAvrg:
          begin
            lbCruiseName.Caption:='Средний расход';
            lbCruiseMeasure.Caption:='л/час';
          end;
        ChargeHourNow:
          begin
            lbCruiseName.Caption:='Мгновенный расход';
            lbCruiseMeasure.Caption:='л/час';
          end;
      end;

      // Подписываем поля в главном окне
      for i:=1 to ValueFieldCount do
        begin
          g_value_fields[i].lbCaption.Caption:=g_Captions[g_value_fields[i].ViewVariant];
          g_value_fields[i].lbMeasure.Caption:=g_Measures[g_value_fields[i].ViewVariant];
        end;

  end; //   with fmMainForm do
end;

end.
