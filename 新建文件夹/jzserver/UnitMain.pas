unit UnitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,U_Imp;

type
  TFrmMain = class(TForm)
    btnBtnStart: TButton;
    BtnStop: TButton;
    procedure btnBtnStartClick(Sender: TObject);
    procedure BtnStopClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation
 uses  U_thrWork;

{$R *.dfm}

procedure TFrmMain.btnBtnStartClick(Sender: TObject);
begin
 StartWork;
 btnBtnStart.Enabled:=False;
 BtnStop.Enabled:=True;
end;

procedure TFrmMain.BtnStopClick(Sender: TObject);
begin
 StopWork;
 btnBtnStart.Enabled:=True;
 BtnStop.Enabled:=False;
end;

end.
