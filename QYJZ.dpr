program QYJZ;

uses
 // SvcMgr,
 Forms,
  Uwork in 'Uwork.pas',
  dm in 'dm.pas',
  func_ty in 'func_ty.pas',
  UntJMJ in 'UntJMJ.pas',
  JzService in 'JzService.pas' {QyJZService: TService},
  U_Imp in 'U_Imp.pas',
  U_thrWork in 'U_thrWork.pas',
  U_OpDB in 'U_OpDB.pas',
  Param in 'Param.pas',
  U_Global in 'U_Global.pas',
  UnitMain in 'UnitMain.pas' {FrmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TQyJZService, QyJZService);
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
