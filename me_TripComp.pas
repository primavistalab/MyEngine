{
  Маршрутный компьютер
  Вся работа осуществяется с глобальной переменной
  my_engine.trip_comp
}

unit me_TripComp;

interface

uses
  me_Vars, me_MainForm;

procedure ResetMaxSpeed;
procedure ResetODO_A;
procedure ResetODO_B;

{
  Обновляет глобальную переменную с маршрутной информацией my_engine.trip_comp
  на основе свежих данных из _recalc
}
procedure UpdateTripInfo(const _recalc : recalc_frame_t; const _dT : c_float);

implementation

uses
  Windows, SysUtils;

procedure ResetMaxSpeed;
begin
  g_trip_comp.MaxSpeed:=0;
end;

procedure ResetODO_A;
begin
  g_trip_comp.ODO_A:=0;
end;

procedure ResetODO_B;
begin
  g_trip_comp.ODO_B:=0;
end;


procedure UpdateTripInfo(const _recalc : recalc_frame_t; const _dT : c_float);
var
  _dist : c_float;
  _RPS : c_float;      // оборотов всекунду
  _RotCnt  : c_float;  // сколько было сделано оборотов
  _InjOpenTime : c_float;       //  время открытия форсунок в секундах
  _FuelChargeNow : c_float;    //  мгновенный расход топлива
  _TimeTo100km : c_float;      // время для проезда 100 км
begin
  with g_trip_comp do
    begin
      if _recalc._08_Speed>0 then
        DriveTime:=DriveTime+_dT
      else
        StayTime:=StayTime+_dT;
      AllTime:=DriveTime+StayTime;

      // пройденное расстояние, КМ
      if _recalc._08_Speed>0 then
        begin
          _dist:=(_dT / 3600.0) * _recalc._08_Speed;  // S = t * U

          Dist  :=Dist  +_dist;
          ODO   :=ODO   +_dist;
          ODO_A :=ODO_A +_dist;
          ODO_B :=ODO_B +_dist;
        end;

      // оборотов в секунду
      _RPS:=_recalc._04_RPM/60.0;

      // сколько было сделано оборотов за время _dT
      _RotCnt:=_RPS*_dT;

      // время открытия форсунок (всех!!)- в секундах за интервал _dT
      // ?? RotCnt делим на 2 т.е. впрыск через 1 цилинд ??
      _InjOpenTime:=(_RotCnt / 2) * g_settings.InjFireCount *
         g_settings.InjCount * _recalc._01_Injector / 1000.0;

      // мгновенный расход топлива в литрах
      // InjPower - производительность форсунки-литров за 15 сек
      _FuelChargeNow:=_InjOpenTime*(g_settings.InjPower/15);

      // Проверяем на отсечку впрыска топлива
      // если эта опция включена

      if (g_settings.InjTruncate) and
        (_recalc._12_1_Throttle) and (not _recalc._11_5_Feedback)
          and (_recalc._08_Speed>0) then
            begin
              FuelEconomy:=FuelEconomy+_FuelChargeNow;  // экономия топлива
              _FuelChargeNow:=0.0;      // есть отческа!!! мгновенный расход = 0,0!
            end;

      // расход за час в таком режиме
      FuelChargeNowByHour:=_FuelChargeNow*3600/_dT;

      // во время стоянки не считаем мгновенный расход на 100 км
      if _recalc._08_Speed>0 then
        begin
          // время в сек. прохождения 100 км с такой скоростью
          _TimeTo100km:=(100.0 / _recalc._08_Speed) * 3600.0;
          // расход на 100 км
          FuelChargeNowBy100km := _FuelChargeNow * _TimeTo100km / _dT;
        end
      else
        FuelChargeNowBy100km:=0.0;   // Inf. -.-

      // всего израсходованно
      FuelChargeAll:=FuelChargeAll+_FuelChargeNow;
      if _recalc._08_Speed>0 then
        FuelChargeDrive:=FuelChargeDrive+_FuelChargeNow
      else
        FuelChargeStay:=FuelChargeStay+_FuelChargeNow;

      // Бензобак
      FuelTank:=FuelTank-_FuelChargeNow;

      // считам средние показатели

      // Средняя скорость
      if (DriveTime>1) then
          AvrgSpeed		            := Dist	/ DriveTime * 3600.0;

      // Средний расход топлива в час
      if AllTime>1 then
        AvrgFuelChargeByHour	    := FuelChargeAll / AllTime * 3600.0;

      // Средний расход топлива на 100 км пути
      if  (Dist>0) and (DriveTime>1) then
        AvrgFuelChargeBy100km	:= FuelChargeDrive / Dist * 100.0;

      // До остановки при таком среднем расходе на 100 км
      if (AvrgFuelChargeBy100km>0.1) then
		    ToStop:=FuelTank/AvrgFuelChargeBy100km*100.0;

      // Запоминаем максимальную скорость
      if _recalc._08_Speed>MaxSpeed then
        MaxSpeed:=_recalc._08_Speed;
    end;
end;

end.
