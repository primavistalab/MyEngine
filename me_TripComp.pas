{
  ���������� ���������
  ��� ������ ������������� � ���������� ����������
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
  ��������� ���������� ���������� � ���������� ����������� my_engine.trip_comp
  �� ������ ������ ������ �� _recalc
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
  _RPS : c_float;      // �������� ��������
  _RotCnt  : c_float;  // ������� ���� ������� ��������
  _InjOpenTime : c_float;       //  ����� �������� �������� � ��������
  _FuelChargeNow : c_float;    //  ���������� ������ �������
  _TimeTo100km : c_float;      // ����� ��� ������� 100 ��
begin
  with g_trip_comp do
    begin
      if _recalc._08_Speed>0 then
        DriveTime:=DriveTime+_dT
      else
        StayTime:=StayTime+_dT;
      AllTime:=DriveTime+StayTime;

      // ���������� ����������, ��
      if _recalc._08_Speed>0 then
        begin
          _dist:=(_dT / 3600.0) * _recalc._08_Speed;  // S = t * U

          Dist  :=Dist  +_dist;
          ODO   :=ODO   +_dist;
          ODO_A :=ODO_A +_dist;
          ODO_B :=ODO_B +_dist;
        end;

      // �������� � �������
      _RPS:=_recalc._04_RPM/60.0;

      // ������� ���� ������� �������� �� ����� _dT
      _RotCnt:=_RPS*_dT;

      // ����� �������� �������� (����!!)- � �������� �� �������� _dT
      // ?? RotCnt ����� �� 2 �.�. ������ ����� 1 ������ ??
      _InjOpenTime:=(_RotCnt / 2) * g_settings.InjFireCount *
         g_settings.InjCount * _recalc._01_Injector / 1000.0;

      // ���������� ������ ������� � ������
      // InjPower - ������������������ ��������-������ �� 15 ���
      _FuelChargeNow:=_InjOpenTime*(g_settings.InjPower/15);

      // ��������� �� ������� ������� �������
      // ���� ��� ����� ��������

      if (g_settings.InjTruncate) and
        (_recalc._12_1_Throttle) and (not _recalc._11_5_Feedback)
          and (_recalc._08_Speed>0) then
            begin
              FuelEconomy:=FuelEconomy+_FuelChargeNow;  // �������� �������
              _FuelChargeNow:=0.0;      // ���� �������!!! ���������� ������ = 0,0!
            end;

      // ������ �� ��� � ����� ������
      FuelChargeNowByHour:=_FuelChargeNow*3600/_dT;

      // �� ����� ������� �� ������� ���������� ������ �� 100 ��
      if _recalc._08_Speed>0 then
        begin
          // ����� � ���. ����������� 100 �� � ����� ���������
          _TimeTo100km:=(100.0 / _recalc._08_Speed) * 3600.0;
          // ������ �� 100 ��
          FuelChargeNowBy100km := _FuelChargeNow * _TimeTo100km / _dT;
        end
      else
        FuelChargeNowBy100km:=0.0;   // Inf. -.-

      // ����� ��������������
      FuelChargeAll:=FuelChargeAll+_FuelChargeNow;
      if _recalc._08_Speed>0 then
        FuelChargeDrive:=FuelChargeDrive+_FuelChargeNow
      else
        FuelChargeStay:=FuelChargeStay+_FuelChargeNow;

      // ��������
      FuelTank:=FuelTank-_FuelChargeNow;

      // ������ ������� ����������

      // ������� ��������
      if (DriveTime>1) then
          AvrgSpeed		            := Dist	/ DriveTime * 3600.0;

      // ������� ������ ������� � ���
      if AllTime>1 then
        AvrgFuelChargeByHour	    := FuelChargeAll / AllTime * 3600.0;

      // ������� ������ ������� �� 100 �� ����
      if  (Dist>0) and (DriveTime>1) then
        AvrgFuelChargeBy100km	:= FuelChargeDrive / Dist * 100.0;

      // �� ��������� ��� ����� ������� ������� �� 100 ��
      if (AvrgFuelChargeBy100km>0.1) then
		    ToStop:=FuelTank/AvrgFuelChargeBy100km*100.0;

      // ���������� ������������ ��������
      if _recalc._08_Speed>MaxSpeed then
        MaxSpeed:=_recalc._08_Speed;
    end;
end;

end.
