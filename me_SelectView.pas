{
  ¬ыбор значени€ дл€ отображени€ на главной форме
}

unit me_SelectView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TfmSelectView = class(TForm)
    tmDown: TTimer;
    tmUp: TTimer;
    Panel1: TPanel;
    vlist: TListBox;
    bbUp: TBitBtn;
    bbDown: TBitBtn;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure bbDownClick(Sender: TObject);
    procedure bbUpClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure tmDownTimer(Sender: TObject);
    procedure bbDownMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bbDownMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tmUpTimer(Sender: TObject);
    procedure bbUpMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bbUpMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure vlistDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ListDown;
    procedure ListUp;
    { Public declarations }
  end;

var
  fmSelectView: TfmSelectView;

implementation

uses
  me_Vars;

{$R *.dfm}

procedure TfmSelectView.bbDownClick(Sender: TObject);
begin
  ListDown;
end;

procedure TfmSelectView.bbDownMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  tmDown.Interval:=600;
  tmDown.Enabled:=true;
end;

procedure TfmSelectView.bbDownMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  tmDown.Enabled:=false;
end;

procedure TfmSelectView.bbUpClick(Sender: TObject);
begin
  ListUp;
end;

procedure TfmSelectView.bbUpMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  tmUp.Interval:=600;
  tmUp.Enabled:=true;
end;

procedure TfmSelectView.bbUpMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  tmUp.Enabled:=false;
end;

procedure TfmSelectView.BitBtn1Click(Sender: TObject);
begin
  if vlist.ItemIndex<>-1 then
    g_value_fields[g_ClickByLabel].ViewVariant:=ViewVariants_set(vlist.ItemIndex);
end;

procedure TfmSelectView.FormShow(Sender: TObject);
var
  i : ViewVariants_set;
  _line : string;

  style : Integer;
begin
  style:=GetWindowLong(vlist.Handle,GWL_STYLE);
  SetWindowLong(vlist.Handle,GWL_STYLE,style and not WS_VSCROLL);

  if not (g_ClickByLabel in [1..ValueFieldCount]) then
    begin
      ModalResult:=mrCancel;
      exit;
    end;

  vlist.Clear;

  for i:=vvAvrgFuelChargeBy100km to high(ViewVariants_set) do
    begin
      _line:=g_Captions[i];
      if g_Measures[i]<>'' then
        _line:=_line+', '+g_Measures[i];

      vlist.Items.Add(_line);
    end;

  vlist.ItemIndex:=Integer(g_value_fields[g_ClickByLabel].ViewVariant);
  vlist.SetFocus;
end;

procedure TfmSelectView.ListDown;
begin
  if vlist.ItemIndex=vlist.Items.Count-1 then
    vlist.ItemIndex:=0
  else
    vlist.ItemIndex:=vlist.ItemIndex+1;
end;

procedure TfmSelectView.ListUp;
begin
  if vlist.ItemIndex=0 then
    vlist.ItemIndex:=vlist.Items.Count-1
  else
    vlist.ItemIndex:=vlist.ItemIndex-1;
end;

procedure TfmSelectView.tmDownTimer(Sender: TObject);
begin
  ListDown;

  tmDown.Interval:=100;  
end;

procedure TfmSelectView.tmUpTimer(Sender: TObject);
begin
  ListUp;

  tmUp.Interval:=100;
end;

procedure TfmSelectView.vlistDblClick(Sender: TObject);
begin
  if vlist.ItemIndex<>-1 then
    begin
      g_value_fields[g_ClickByLabel].ViewVariant:=ViewVariants_set(vlist.ItemIndex);
      ModalResult:=mrOk;
      CloseModal;
    end;

end;

end.
