unit me_FuelTank;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FloatUtils;

type
  TfmFuelTank = class(TForm)
    edValue: TEdit;
    bt_07: TButton;
    bt_08: TButton;
    bt_09: TButton;
    bt_04: TButton;
    bt_05: TButton;
    bt_06: TButton;
    bt_01: TButton;
    bt_02: TButton;
    bt_03: TButton;
    btClear: TButton;
    bt_00: TButton;
    btOK: TButton;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btOKClick(Sender: TObject);
    procedure edValueKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
  private
    procedure DigitalClick(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmFuelTank: TfmFuelTank;

implementation

uses
  me_Vars;

{$R *.dfm}

procedure TfmFuelTank.btClearClick(Sender: TObject);
begin
  if length(edValue.Text)>0 then
    edValue.Text:=copy(edValue.Text,1,length(edValue.Text)-1);
end;

procedure TfmFuelTank.btOKClick(Sender: TObject);
var
  _fuel : c_float;
begin
  if edValue.Text='' then
    ModalResult:=mrCancel
  else if TryStrToFloatAny(edValue.Text, _fuel) then
    begin
      g_trip_comp.FuelTank:=g_trip_comp.FuelTank + _fuel;
      ModalResult:=mrOk;
    end
  else
    begin
      Application.MessageBox('Ошибка в значении!',cpt,MB_ICONERROR);
      edValue.SetFocus;
      edValue.SelectAll;
    end;
end;

procedure TfmFuelTank.Button1Click(Sender: TObject);
begin
  if length(edValue.Text)<6 then
    edValue.Text:=edValue.Text+'.';
end;

procedure TfmFuelTank.DigitalClick(Sender: TObject);
begin
  if length(edValue.Text)<6 then
    edValue.Text:=edValue.Text+Inttostr((Sender as TButton).Tag);
end;

procedure TfmFuelTank.edValueKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',',','.']) then
    Key:=#0;
end;

procedure TfmFuelTank.FormCreate(Sender: TObject);
var
  i : integer;
  _b : TButton;
begin
  for i:=0 to 9 do
    begin
      _b:=FindComponent('bt_0'+inttostr(i)) as TButton;
      _b.Caption:=IntToStr(i);
      _b.Tag:=i;
      _b.OnClick:=DigitalClick;
    end;
end;

procedure TfmFuelTank.FormShow(Sender: TObject);
begin
  edValue.Text:='';
  edValue.SetFocus;
end;

end.
