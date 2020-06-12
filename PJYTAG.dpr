program PJYTAG;

uses
  Forms,
  UNITJYTAG in 'UNITJYTAG.pas' {Form1},
  UntJMJ in 'UntJMJ.pas',
  Uwork in 'Uwork.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
