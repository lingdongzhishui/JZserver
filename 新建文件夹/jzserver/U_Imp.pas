unit U_Imp;

interface

uses
  Classes, SysUtils,Windows,Param, U_thrWork,U_Global,SyncObjs,IniFiles;


procedure StartWork;

procedure StopWork;

procedure InitializeServer;

procedure UnInitializeServer;

implementation

procedure StartWork;
var
  s : string;
  i : Integer;
begin
  s := gParam.ExePath+'send\';
  if not DirectoryExists(s) then
    MkDir(s);
  s := gParam.ExePath+'ErrFile\';
  if not DirectoryExists(s) then
    MkDir(s);
  thrSend := TSendData.Create;
  Sleep(100);
end;

procedure StopWork;
var
  i ,MsgID:Integer;
  Ahandle:THandle;
begin

  if thrSend<>nil then
  begin
    thrSend.Stop := True;
    thrSend.Terminate;
    Sleep(1000);
  end;
  {退出进程，在服务里时候会报错
  }
 // AHandle := GetCurrentProcess ;
 // TerminateProcess(AHandle,0);

  Sleep(1000);
end;

procedure InitializeServer;
var
  s: string;
begin
  s := ExtractFilePath(ParamStr(0)) + 'tlqServer.ini';
  //加载参数
  gParam := TWorkParam.Create;
  gParam.GetParam(s);

end;

procedure UnInitializeServer;
begin
  gParam.Free;
end;

initialization
  InitializeServer;
finalization
  UnInitializeServer;
end.
