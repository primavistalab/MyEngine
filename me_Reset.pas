unit me_Reset;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfmReset = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmReset: TfmReset;

implementation

uses
  me_Vars;

{$R *.dfm}

procedure TfmReset.Button1Click(Sender: TObject);
begin
  g_trip_comp.MaxSpeed:=0;
  ModalResult:=mrOk;
end;

procedure TfmReset.Button2Click(Sender: TObject);
begin
  g_trip_comp.ODO_A:=0;
  ModalResult:=mrOk;
end;

procedure TfmReset.Button3Click(Sender: TObject);
begin
  g_trip_comp.ODO_B:=0;
  ModalResult:=mrOk;
end;

procedure TfmReset.Button4Click(Sender: TObject);
begin
  ModalResult:=mrCancel;
end;

procedure TfmReset.Button5Click(Sender: TObject);
begin
  g_trip_comp.FuelTank:=0;
  ModalResult:=mrOk;
end;

procedure TfmReset.Button6Click(Sender: TObject);
begin
  g_value_fields[1].ViewVariant:=vvAvrgFuelChargeBy100km;
  g_value_fields[2].ViewVariant:=vvFuelCharge;
  g_value_fields[3].ViewVariant:=vvMaxSpeed;
  g_value_fields[4].ViewVariant:=vvFuelTank;
  g_value_fields[5].ViewVariant:=vvToStop;
  g_value_fields[6].ViewVariant:=vv_06_Temperature;

  ModalResult:=mrOk;
end;

procedure TfmReset.Button7Click(Sender: TObject);
begin
{
  —брасываем:
    - врем€ поездки
    - пройденное рассто€ние
    - израсходованное топливо
    - сэкономлено

    - данные завис€щие от вышесброшенных:
      - до остановки, средн€€ скорость, все виды расходов
}
  g_trip_comp.AllTime:=0;
  g_trip_comp.StayTime:=0;
  g_trip_comp.DriveTime:=0;
  g_trip_comp.Dist:=0;
  g_trip_comp.FuelChargeAll:=0;
  g_trip_comp.FuelChargeStay:=0;
  g_trip_comp.FuelChargeDrive:=0;
  g_trip_comp.FuelEconomy:=0;

  g_trip_comp.ToStop:=0;
  g_trip_comp.AvrgSpeed:=0;
  g_trip_comp.AvrgFuelChargeByHour:=0;
  g_trip_comp.AvrgFuelChargeBy100km:=0;
  g_trip_comp.FuelChargeNowByHour:=0;
  g_trip_comp.FuelChargeNowBy100km:=0;

  ModalResult:=mrOk;
end;

end.

