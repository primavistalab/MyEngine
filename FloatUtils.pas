{

  Функции конвертации дробных чисел

  Функции не зависимы от региоанльных настроек системы

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

{ Формирование и возврат FormatSettings с установленной десятичной точкой }
function DotSettings: TFormatSettings;
begin
  GetLocaleFormatSettings (GetThreadLocale, Result);
  Result.DecimalSeparator := '.';
end;

{ Формирование и возврат FormatSettings с установленной десятичной запятой }
function CommaSettings: TFormatSettings;
begin
  GetLocaleFormatSettings (GetThreadLocale, Result);
  Result.DecimalSeparator := ',';
end;

{ StrToFloat с точкой в роли десятичного разделителя }
function StrToFloatDot(const Value: string): c_float;
begin
  Result := StrToFloat (Value, DotSettings);
end;

{ StrToFloat с запятой в роли десятичного разделителя }
function StrToFloatComma(const Value: string): c_float;
begin
  Result := StrToFloat (Value, CommaSettings);
end;

function StrToFloatAny (const Value: string): c_float;
begin
  if not TryStrToFloat (Value, Result, CommaSettings) then
    Result := StrToFloat (Value, DotSettings);
end;

{ TryStrToFloat с точкой в роли десятичного разделителя }
function TryStrToFloatDot (const Value: string; out FValue: c_float): boolean;
begin
  Result := TryStrToFloat (Value, FValue, DotSettings);
end;

{ TryStrToFloat с запятой в роли десятичного разделителя }
function TryStrToFloatComma (const Value: string; out FValue: c_float): boolean;
begin
  Result := TryStrToFloat (Value, FValue, CommaSettings);
end;

function TryStrToFloatAny(const Value: string; out FValue: c_float): boolean;
begin
  Result:=TryStrToFloatComma(Value, FValue);  // пробуем перевести используя запятую

  if not Result then                  // если не прошло пробуем точку
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
