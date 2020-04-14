unit me_Warning;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfmWarning = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmWarning: TfmWarning;

implementation

{$R *.dfm}

procedure TfmWarning.Button1Click(Sender: TObject);
begin
  ModalResult:=mrOk;
end;

procedure TfmWarning.Button2Click(Sender: TObject);
begin
  ModalResult:=mrCancel;
end;

procedure TfmWarning.FormShow(Sender: TObject);
begin
  fmWarning.Color:=RGB(63, 63, 63);
  
end;

end.
