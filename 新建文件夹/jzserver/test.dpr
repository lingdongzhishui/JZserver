program test;
uses
  Forms,
  Uwork in 'Uwork.pas',
  func_ty in 'func_ty.pas',
  JzService in 'JzService.pas' {FrmjzSvc: TService},
  Param in 'Param.pas',
  U_Global in 'U_Global.pas',
  U_Imp in 'U_Imp.pas',
  U_OpDB in 'U_OpDB.pas',
  U_thrWork in 'U_thrWork.pas',
  UnitMain in 'UnitMain.pas' {FrmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
