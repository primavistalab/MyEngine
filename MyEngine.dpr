program MyEngine;

uses
  Forms,
  me_MainForm in 'me_MainForm.pas' {fmMainForm},
  me_Vars in 'me_Vars.pas',
  me_Draw in 'me_Draw.pas',
  me_ReCalc in 'me_ReCalc.pas',
  me_Settings in 'me_Settings.pas' {fmSettings},
  ComUnit in 'ComUnit.pas',
  me_TripComp in 'me_TripComp.pas',
  FloatUtils in 'FloatUtils.pas',
  me_Reset in 'me_Reset.pas' {fmReset},
  me_FuelTank in 'me_FuelTank.pas' {fmFuelTank},
  me_SelectView in 'me_SelectView.pas' {fmSelectView},
  me_Warning in 'me_Warning.pas' {fmWarning},
  me_StrRes in 'me_StrRes.pas';

{$E exe}

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'MyEngine';

  Application.CreateForm(TfmMainForm, fmMainForm);
  Application.CreateForm(TfmSettings, fmSettings);
  Application.CreateForm(TfmReset, fmReset);
  Application.CreateForm(TfmFuelTank, fmFuelTank);
  Application.CreateForm(TfmSelectView, fmSelectView);
  Application.CreateForm(TfmWarning, fmWarning);
  Application.Run;
end.
