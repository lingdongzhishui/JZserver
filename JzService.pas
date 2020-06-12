unit JzService;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs;

type
  TQyJZService = class(TService)
   procedure ServiceStart(Sender: TService; var Started: Boolean);
   procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  QyJZService: TQyJZService;

implementation

uses U_Imp;

 


{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  QyJZService.Controller(CtrlCode);
end;

function TQyJZService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TQyJZService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  StartWork;
end;

procedure TQyJZService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  StopWork;
end;

end.
