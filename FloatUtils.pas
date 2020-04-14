{

  ������� ����������� ������� �����

  ������� �� �������� �� ������������ �������� �������

}

unit FloatUtils;

interface

uses
  me_Vars;

// StrToFloat
function StrToFloatDot(const Value: string): c_float;
function StrToFloatComma(const Value: string): c_float;
function StrToFloatAny (const Value: string): c_float;

function TryStrToFloatDot (const Value: string; out FValue: c_float): boolean;
function TryStrToFloatComma (const Value: string; out FValue: c_float): boolean;
function TryStrToFloatAny(const Value: string; out FValue: c_float): boolean;

// FloatToStr
function FormatFloatDot(const Format: string; Value: Extended): string;
function FormatFloatComma(const Format: string; Value: Extended): string;
function FloatToStrDot(const Value : Extended) : string;
function FloatToStrComma(const Value : Extended) : string;

implementation

uses
  SysUtils, Windows;

{ ������������ � ������� FormatSettings � ������������� ���������� ������ }
function DotSettings: TFormatSettings;
begin
  GetLocaleFormatSettings (GetThreadLocale, Result);
  Result.DecimalSeparator := '.';
end;

{ ������������ � ������� FormatSettings � ������������� ���������� ������� }
function CommaSettings: TFormatSettings;
begin
  GetLocaleFormatSettings (GetThreadLocale, Result);
  Result.DecimalSeparator := ',';
end;

{ StrToFloat � ������ � ���� ����������� ����������� }
function StrToFloatDot(const Value: string): c_float;
begin
  Result := StrToFloat (Value, DotSettings);
end;

{ StrToFloat � ������� � ���� ����������� ����������� }
function StrToFloatComma(const Value: string): c_float;
begin
  Result := StrToFloat (Value, CommaSettings);
end;

function StrToFloatAny (const Value: string): c_float;
begin
  if not TryStrToFloat (Value, Result, CommaSettings) then
    Result := StrToFloat (Value, DotSettings);
end;

{ TryStrToFloat � ������ � ���� ����������� ����������� }
function TryStrToFloatDot (const Value: string; out FValue: c_float): boolean;
begin
  Result := TryStrToFloat (Value, FValue, DotSettings);
end;

{ TryStrToFloat � ������� � ���� ����������� ����������� }
function TryStrToFloatComma (const Value: string; out FValue: c_float): boolean;
begin
  Result := TryStrToFloat (Value, FValue, CommaSettings);
end;

function TryStrToFloatAny(const Value: string; out FValue: c_float): boolean;
begin
  Result:=TryStrToFloatComma(Value, FValue);  // ������� ��������� ��������� �������

  if not Result then                  // ���� �� ������ ������� �����
    Result:=TryStrToFloatDot(Value, FValue);
end;

function FormatFloatDot(const Format: string; Value: Extended): string;
begin
  Result:=FormatFloat(Format,Value,DotSettings);
end;

function FormatFloatComma(const Format: string; Value: Extended): string;
begin
  Result:=FormatFloat(Format,Value,CommaSettings);
end;

function FloatToStrDot(const Value : Extended) : string;
begin
  Result:=FloatToStr(Value,DotSettings);
end;

function FloatToStrComma(const Value : Extended) : string;
begin
  Result:=FloatToStr(Value,CommaSettings);
end;


end.
