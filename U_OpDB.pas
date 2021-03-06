unit U_OpDB;

interface

uses
   Windows,SysUtils, Classes, DB, ADODB, ActiveX, DBTables, SqlExpr,
   DBClient, DBXpress, Provider;

const
  dtDB2 = 1;
  dtOracle = 2;
  dtMSSQL = 3;
  dtParadox = 4;
  dtFireBird = 5;

type

   ExxProviderUpdateError = class(Exception);

  TBaseDB = class
  private
    FErrStr: string;
    FDBIP: string;
    FDBName: string;
    FConnectionStr : string;
    function  GetDataSet: TDataSet; virtual;
    procedure SetConnected(Value: Boolean); virtual;  abstract;
    function  GetConnected: Boolean; virtual; abstract;
  public
    constructor Create;
    destructor  Destroy; override;
    function ProcExec(procName:String;tableType:Integer):Integer;virtual;
    //2014-01-23 区域应答ID
    function ProcGetMessage(var responseMessageId:String):Boolean;virtual;

    function CreateTempTb(tableName:String):Boolean;virtual;
    function QuerySQL(aSql: string): Boolean; virtual;
    function ExecSQL(aSql: string): Boolean; virtual;
    function ExecSQLEx(aSql: string;ImgParaName: string;ImgStream: TMemoryStream): Boolean; virtual;
    function BeginTrans: Boolean; virtual;
    function RollBack: Boolean; virtual;
    function Commit: Boolean; virtual;
    function GetPKeys(aTbName: string; var aPKList: TStringList): Boolean; virtual;
    function writedblog(Str: String):Boolean ;virtual;

  published
    property Query: TDataSet read GetDataSet;
    property DBName: string read FDBName write FDBName;
    property DBIP: string read FDBIP write FDBIP;
    property Connected: Boolean read GetConnected write SetConnected;
    property ConnectionStr: string read FConnectionStr write FConnectionStr;
    property ErrStr: string read FErrStr write FErrStr;
  end;

  TOleDB = class(TBaseDB)
  private
    FConn:  TAdoConnection;
    FExec:  TAdoQuery;
    FQuery: TAdoQuery;
    FDBType: Integer;

    function  GetDataSet: TDataSet; override;
    procedure SetConnected(Value: Boolean); override;
    function  GetConnected: Boolean; override;
  public
    FBatchoquery:TAdoQuery;//向外提供一个供批量处理的Adoquery1205
    FAdqSproc:TADOStoredProc; //新增存储过程控件
    FAdqSprocMessageID:TADOStoredProc;//新增取消息ID控件2014-01-23
    constructor Create;
    destructor  Destroy; override;
    function ProcExec(procName:String;tableType:Integer):Integer;override;

    function ProcGetMessage(var responseMessageId:String):Boolean;override;

    function writedblog(Str: String):Boolean ;override;

    function QuerySQL(aSql: string): Boolean; override;
    
    function ExecSQL(aSql: string): Boolean;  override;

    {
     函数功能：创建临时表
    }
    function CreateTempTb(tableName:String):Boolean; override;
    function ExecSQLEx(aSql: string;ImgParaName: string;ImgStream: TMemoryStream): Boolean;override;
    function BeginTrans: Boolean; override;
    function RollBack: Boolean; override;
    function Commit: Boolean; override;
    function GetPKeys(aTbName: string; var aPKList: TStringList): Boolean; override;
  published
    property DBType: Integer read FDBType write FDBType;
    property Connected: Boolean read GetConnected write SetConnected;
  end;

  TBdeDB = class(TBaseDB)
  private
    FConn: TDataBase;
    FQuery: TQuery;
    FExec: TQuery;
    FDBPath: string;
    function  GetDataSet: TDataSet; override;
    procedure SetConnected(Value: Boolean); override;
    function  GetConnected: Boolean; override;
    procedure Buildbdeconn;
    function BeginTrans: Boolean;
  public
    constructor Create;
    destructor  Destroy; override;
    function    QuerySQL(aSql: string): Boolean; override;
    function    ExecSQL(aSql: string): Boolean; override;
    function    ExecSQLEx(aSql: string;ImgParaName: string;ImgStream: TMemoryStream): Boolean;override;
    function    RollBack: Boolean; override;
    function    Commit: Boolean; override;
    function    GetPKeys(aTbName: string; var aPKList: TStringList): Boolean; override;
  published
    property DBPath: string  read FDBPath write FDBPath;
  end;

  TExprDB = class(TBaseDB)
  private
    FTD: TTransactionDesc;
    FConn: TSQLConnection;
    FClientQuery: TClientDataSet;
    FQuery: TSQLQuery;
    FProvider: TDataSetProvider;
    FExec: TSQLDataSet;
    function GetDataSet: TDataSet; override;
    procedure SetConnected(Value: Boolean); override;
    function GetConnected: Boolean; override;
  public
    constructor Create;
    destructor Destroy; override;
    function QuerySQL(aSql: string): Boolean; override;
    function ExecSQL(aSql: string): Boolean; override;
    function ExecSQLEx(aSql: string;ImgParaName: string;ImgStream: TMemoryStream): Boolean;override;
    function BeginTrans: Boolean; override;
    function RollBack: Boolean; override;
    function Commit: Boolean; override;
    function GetPKeys(aTbName: string; var aPKList: TStringList): Boolean; override;
  published
  end;

type
  TOpDB = class
  private
   // FDBObj : TBaseDB;
    FDBType: Integer;
    FDBPath: string;
    FDBName : string;
    function  GetConnected: Boolean;
    procedure SetConnected(Value: Boolean);
    function  GetQueryObj: TDataSet;
    function  GetErrStr: string;
    procedure SetDBName(Value: string);
    function  GetDBName : string;
    procedure SetDBIp(Value: string);
    procedure SetConnectionStr(value : string);
    function  GetConnectionStr : string;
    procedure SetErrStr(const Value: string);
  public
    FDBObj : TBaseDB;//为了黑名单放出来adqouery
    constructor Create(aDBType: Integer);
    destructor Destroy; override;

    function  CreateTempTb(tableName:String):Boolean;
    function  ProcExec(procName:String;tableType:Integer):Integer;

    function QuerySQL(aSql: string): Boolean;
    function ExecSQL(aSql: string): Boolean;
    function ExecSQLEx(aSql:string;ImgParaName : string;ImgStream : TMemoryStream):Boolean;

    function ProcGetMessage(var responseMessageId:String):Boolean;

    function BeginTrans: Boolean;
    function RollBack: Boolean;
    function Commit: Boolean;
    function GetPKeys(aTbName: string; var aPKList: TStringList): Boolean;
  published
    property Query: TDataSet read GetQueryObj;
    property Connected: Boolean read GetConnected write SetConnected;
    property ErrStr: string read GetErrStr  write SetErrStr ;
    property ConnectionStr : string read GetConnectionStr write SetConnectionstr;
    property DBName: string read GetDBName write SetDBName;
    property DBIP: string write SetDBIP;
    property DBPath: string  read FDBPath write FDBPath;
  end;

implementation


procedure CheckAdoErrors(AdoConn:TAdoConnection);
Var
   ConnAdoErrors:Errors;
   adoError:Error;
   iCount:Integer;
   aErrorMsg: String ;
begin
   ConnAdoErrors := AdoConn.Errors;
   aErrorMsg := '';
   For iCount:= 0 to ConnAdoErrors.Count -1 do
     begin
       AdoError := ConnAdoErrors.Item[iCount] ;
       aErrorMsg := aErrorMsg + AdoError.Description + 'NativeError'
        + IntToStr(AdoError.NativeError) + 'Number' + IntToStr(AdoError.Number);
     end;
  if (aErrorMsg<>'') or (ConnAdoErrors.Count>0) then
   begin
   raise ExxProviderUpdateError.Create(aErrorMsg);
   end;
end;

{ TOpDB }

function TOpDB.BeginTrans: Boolean;
begin
  Result := FDBObj.BeginTrans;
end;

function TOpDB.Commit: Boolean;
begin
  Result := FDBObj.Commit;
end;

constructor TOpDB.Create(aDBType: Integer);
begin
  //CoInitialize(nil);
  FDBType := aDBType;
  case aDBType of
    dtDB2,dtOracle,dtMSSQL:
      FDBObj := TOleDB.Create;
    dtParadox:
      FDBObj := TBDEDB.Create;
    dtFireBird:
      FDBObj := TExprDB.Create;
  else
    FDBObj := nil;
  end;
end;

function TOpDB.CreateTempTb(tableName: String): Boolean;
begin
  Result := False;
  if not Assigned(FDBObj) then
    Exit;
  if FDBObj.CreateTempTb(tableName) then
  begin
    Result := True;
  end else
  begin
    Result := False;
  end;
end;

destructor TOpDB.Destroy;
begin
  if Assigned(FDBObj) then
    FDBObj.Free;
 // CoUnInitialize;
  inherited;
end;

function TOpDB.ExecSQL(aSql: string): Boolean;
begin
  Result := False;
  if not Assigned(FDBObj) then
    Exit;

  if not FDBObj.Connected then
    FDBobj.Connected := True;
  if not FDBObj.Connected then
    Exit;
  if FDBObj.ExecSQL(aSql) then
  begin
    Result := True;
  end else
  begin
    Result := False;
    FDBobj.Connected := False;
  end;
end;

function TOpDB.ExecSQLEx(aSql, ImgParaName: string;
  ImgStream: TMemoryStream): Boolean;
begin
  Result := False;
  if not Assigned(FDBObj) then
    Exit;

  if not FDBObj.Connected then
    FDBobj.Connected := True;
  if not FDBObj.Connected then
    Exit;

  if FDBObj.ExecSQLEx(aSql,ImgParaName,ImgStream) then
  begin
    Result := True;
  end else
  begin
    Result := False;
    FDBobj.Connected := False;
  end;
end;

function TOpDB.GetConnected: Boolean;
begin
  Result := FDBObj.Connected;
end;

function TOpDB.GetConnectionStr: string;
begin
  Result := FDBObj.ConnectionStr;
end;

function TOpDB.GetDBName: string;
begin
  Result := FDBName;
end;

function TOpDB.GetErrStr: string;
begin
  if not Assigned(FDBObj) then
    Result := '数据库设置错误!'
  else
    Result := FDBObj.ErrStr;
end;

function TOpDB.GetPKeys(aTbName: string;
  var aPKList: TStringList): Boolean;
begin
  Result := FDBObj.GetPKeys(aTbName, aPKList);
end;

function TOpDB.GetQueryObj: TDataSet;
begin
  Result := nil;
  if not Assigned(FDBObj) then
    Exit;
  Result := FDBObj.GetDataSet;
end;

function TOpDB.QuerySQL(aSql: string): Boolean;
begin
  Result := False;
  if not Assigned(FDBObj) then
  begin
    ErrStr:='FDBObj未初始化';
    Exit;
  end;
  if not FDBObj.Connected then
  begin
    ErrStr:='FDBObj.connected:=False';
    FDBobj.Connected := True;
  end;
  if not FDBObj.Connected then
    Exit;
  if FDBObj.QuerySQL(aSql) then
  begin
    Result := True;
  end else
  begin
    Result := False;
    //ywh04-20执行失败后，不要关闭
    //FDBobj.Connected := False;
  end;
end;

function TOpDB.RollBack: Boolean;
begin
  Result := False;
  if not Assigned(FDBObj) then
    Exit;
  Result := FDBObj.RollBack;
end;

procedure TOpDB.SetConnected(Value: Boolean);
begin
  if not Assigned(FDBObj) then
    Exit;
  case FDBType of
    dtDB2,dtOracle,dtMSSql:
      TOleDB(FDBObj).DBType := FDBType;
    dtParadox:
      TBDEDB(FDBObj).DBPath := FDBPath;
  else
  end;
  FDBObj.Connected := Value;
end;

procedure TOpDB.SetConnectionStr(value: string);
begin
  FDBObj.ConnectionStr := value;
end;

procedure TOpDB.SetDBIp(Value: string);
begin
  if not Assigned(FDBObj) then
    Exit;
  FDBObj.DBIP := Value;
end;

procedure TOpDB.SetDBName(Value: string);
begin
  if not Assigned(FDBObj) then
    Exit;
  FDBObj.DBName := Value;
  FDBName := Value;
end;

function TOpDB.ProcExec(procName:String;tableType:Integer):Integer;
begin
  Result := 0;
  if not Assigned(FDBObj) then
    Exit;
  Result := FDBObj.ProcExec(procName,tableType);
end;

function TOpDB.ProcGetMessage(var responseMessageId: String):Boolean;
begin
  Result :=True;
  if not Assigned(FDBObj) then
    Exit;
  Result := FDBObj.ProcGetMessage(responseMessageId);
end;

procedure TOpDB.SetErrStr(const Value: string);
begin

end;

{ TBaseDB }

function TBaseDB.BeginTrans: Boolean;
begin
  Result := True;
end;

function TBaseDB.Commit: Boolean;
begin
  Result := True;

end;

constructor TBaseDB.Create;
begin

end;

function TBaseDB.CreateTempTb(tableName: String): Boolean;
begin
  Result:=True;
end;

destructor TBaseDB.Destroy;
begin
end;

function TBaseDB.ExecSQL(aSql: string): Boolean;
begin
  Result := True;
end;


function TBaseDB.ExecSQLEx(aSql, ImgParaName: string;
  ImgStream: TMemoryStream): Boolean;
begin
  Result := True;
end;

function TBaseDB.GetDataSet: TDataSet;
begin
    Result := Nil;
end;

function TBaseDB.GetPKeys(aTbName: string;
  var aPKList: TStringList): Boolean;
begin
  Result:=True;
end;

function TBaseDB.QuerySQL(aSql: string):Boolean;
begin
  Result := True;
end;

function TBaseDB.RollBack: Boolean;
begin
  Result := True;
end;


function TBaseDB.ProcExec(
  procName:String;tableType:Integer):Integer;
begin
  Result := 0;
end;

function TBaseDB.ProcGetMessage(var responseMessageId: String): Boolean;
begin
  result:=False;
end;

function TBaseDB.writedblog(Str: String): Boolean;
begin
  result:=False;
end;

{ TOleDB }

function TOleDB.BeginTrans: Boolean;
begin
  Result := True;
  if FConn.Connected then
    FConn.BeginTrans
  else
    Result := False;
end;

function TOleDB.Commit: Boolean;
begin
  Result := True;
  if (FConn.Connected) and (FConn.InTransaction)then
    FConn.CommitTrans
  else
    Result := False;
end;

constructor TOleDB.Create;
begin
//  CoInitialize(nil);
  FConn := TAdoConnection.Create(nil);
  FConn.LoginPrompt := False;
  FQuery := TAdoQuery.Create(nil);
  FQuery.Connection := FConn;
  FExec := TAdoQuery.Create(nil);
  FExec.Connection := FConn;
  FAdqSproc:=TADOStoredProc.Create(nil);
  FAdqSprocMessageID:=TADOStoredProc.Create(nil);
  FAdqSproc.Connection:=FConn;
  FAdqSprocMessageID.Connection:=FConn;

  FBatchoquery:= TAdoQuery.Create(nil);
  FBatchoquery.Connection:=FConn;
  FBatchoquery.CommandTimeout := 1000*60*500;   //5分钟查询超时

  FQuery.CommandTimeout := 1000*60*50;   //5分钟查询超时
  FExec.CommandTimeout := 1000*60*50;   //5分钟查询超时
  FAdqSprocMessageID.CommandTimeout := 1000*60*50;
  FAdqSproc.CommandTimeout := 1000*60*500;
end;

function TOleDB.CreateTempTb(tableName: String): Boolean;
var
  sSql:String;
begin
  result:=False;
  {1.建立退款临时表}
   sSql := 'select * from tempdb.dbo.sysobjects where id = object_id(N'
      + quotedstr('tempdb..#'+tableName) + ') and type=''U'' ';
   if not QuerySQL(sSql) then exit;
  {2.删除临时表}
   if FQuery.RecordCount>0 then
   begin
     sSql := 'drop table #'+tableName;
     if not ExecSQL(sSql) then
     Exit;
   end;
   {3.建立临时表}
   sSql := 'select * into '+'#'+tableName+' from '+tableName+' where 1=0';
   if not ExecSQL(SSQL) then
   Exit;
   Result:=True;
end;

destructor TOleDB.Destroy;
begin
  FQuery.Active := False;
  FExec.Active := False;
  SetConnected(False);
  FQuery.Free;
  FExec.Free;
  FAdqSproc.Free;
  FAdqSprocMessageID.Free;
  FConn.Free;

 // CoUnInitialize;
end;

function TOleDB.ExecSQL(aSql: string): Boolean;
begin
  FErrStr := '';
  Result := False;
  FExec.Sql.Clear;
  FExec.Sql.Add(aSql);
  try
   FExec.ExecSQL;
   Result := True;
  except
    on E: Exception do
    begin
      //2014测试
      WritedbLog('执行' + aSql + '失败!');
     // 2015-02-26
      writedblog(E.Message);
      ErrStr := E.Message;
    end;
  end;
end;

function TOleDB.ExecSQLEx(aSql, ImgParaName: string;
  ImgStream: TMemoryStream): Boolean;
begin
  FErrStr := '';
  Result := False;
//  if not GetConnected then
//     SetConnected(True);
//  if not GetConnected then
//    Exit;
  FExec.Parameters.AddParameter.Name := ImgParaName;
  FExec.Sql.Clear;
  FExec.Sql.Add(aSql);
  if ImgStream.Size > 0 then
    FExec.Parameters.ParamByName(ImgParaName).LoadFromStream(ImgStream,ftBlob)
  else
    FExec.Parameters.ParamByName(ImgParaName).Value := '';
  try
    FExec.ExecSQL;
    Result := True;
  except

    on E: Exception do
    begin
      ErrStr := E.Message;
      FConn.Connected := False;
    end;
  end;
end;

function TOleDB.GetConnected: Boolean;
begin
  Result := FConn.Connected;
end;

function TOleDB.GetDataSet: TDataSet;
begin
  Result := FQuery;
end;

function TOleDB.GetPKeys(aTbName: string;
  var aPKList: TStringList): Boolean;
var
  s: string;
begin
  Result := False;
  aPKList.Clear;
  case FDBType of
    dtDB2 : begin
      s := 'select COLNAME as COLUMN_NAME from syscat.keycoluse where tabschema=''JUSTDOIT'' and tabname=''%s''';
      s := Format(s, [aTBName]);
    end;
    dtOracle : begin
      s := 'select distinct a.r_constraint_name,b.table_name,b.column_name as COLUMN_NAME from user_constraints a, user_cons_columns b'
          +' WHERE a.constraint_type=''R'' and a.r_constraint_name=b.constraint_name and b.table_name=''%s''';
      s := Format(s, [aTBName]);
    end;
    dtMSSQL : begin
      s := 'sp_pkeys %s';
      s := Format(s, [aTBName]);
    end;
  else
    exit;
  end;

  if QuerySQL(s) then
  begin
    while not FQuery.Eof do
    begin
      aPKList.Add(Trim(FQuery.FieldByName('COLUMN_NAME').AsString));
      FQuery.Next;
    end;
  end else
    Exit;
  Result := True;
end;

function TOleDB.QuerySQL(aSql: string): Boolean;
begin
  FErrStr := '';
  Result := False;
try
 if
   FExec.Connection<>FQuery.Connection then
 begin
   raise Exception.Create('连接不同');
 end;
  FQuery.Active := False;
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Text := aSql;
  FQuery.Open;
  Result := True;
  except
    on E: Exception do
    begin
      ErrStr := E.Message + '/' + FQuery.Connection.ConnectionString ;
    end;
  end;
end;

function TOleDB.RollBack: Boolean;
begin
  Result := True;
  if FConn.Connected then
    FConn.CommitTrans
  else
    Result := False;
end;

procedure TOleDB.SetConnected(Value: Boolean);
var
  s: string;
begin
  inherited;
  if Value then
  begin
    FConn.Connected := False;
   if Trim(FConnectionStr) <> '' then
    begin
      FConn.ConnectionString := FConnectionStr;

    end;
      FConn.ConnectionString := FConnectionStr;
    try
      FConn.Connected := True;
      if FDBType=dtOracle then // Oracle;
      begin
        s := 'Alter Session set nls_date_format=''yyyy-mm-dd hh24:mi:ss''';
        ExecSql(s);
      end;
    except
      on e: Exception do
        FErrStr := e.Message + s;
    end;
  end else
  begin
    try
      FConn.Connected := False;
    except
    end;
  end;
end;

function TOleDB.ProcExec(procName: String; tableType: Integer): Integer;
begin
  FErrStr := '';
  Result :=0;
  FAdqSproc.Connection:=FConn;
  with FAdqSproc do
  begin
    Close;
    ProcedureName :=procName;
    with Parameters do
    begin
      Clear;
      Refresh;
      Try
       FAdqSproc.Parameters.ParamByName('@tableType').Value:=tableType;
       FAdqSproc.Parameters.ParamByName('@ErrMsg').Value:='';
       FAdqSproc.ExecProc;
       ErrStr:=FAdqSproc.Parameters.ParamByName('@ErrMsg').Value;
       Result:=FAdqSproc.Parameters.ParamByName('@RETURN_VALUE').Value;
      except
       on e:exception do
       begin
         FErrStr :=E.Message;
       end;
      end;
    end;
  end;
end;

function TOleDB.ProcGetMessage(var responseMessageId: String): Boolean;
var
  tempId:Int64;
begin
  Result :=False;
  FAdqSprocMessageID.Connection:=FConn;
  with FAdqSprocMessageID do
  begin
    Close;
    ProcedureName :='GeneralMessageId';
    with Parameters do
    begin
    Try
      Clear;
      Refresh;

       FAdqSprocMessageID.Parameters.ParamByName('@MessageId').Value:=0;
       FAdqSprocMessageID.ExecProc;
       tempId:=FAdqSprocMessageID.Parameters.ParamByName('@MessageId').value;
       responseMessageId:=IntToStr(tempId);
       result:=True;
      except
       on e:exception do
       begin
         FErrStr :=E.Message;
       end;
      end;
    end;
  end;
end;

function TOleDB.writedblog(Str: String): Boolean;
var
  tmpStr,
  tmpName: String;
  SystemTime: TSystemTime;
  fsm       : TextFile;
begin
  if Str='' then Exit;
  tmpName :=  ExtractFilePath(ParamStr(0))+'Sendlog\';

  //目录存在性的判断
  if not DirectoryExists(tmpName) then
  begin
    if IOResult = 0 then
      MkDir(tmpName);
  end;
  //目录存在,文件不存在则新建,文件存在则加入.
  if DirectoryExists(tmpName) then
  begin
    GetLocalTime(SystemTime);
    with SystemTime do
      tmpName := tmpName + Format('%.4d%.2d%.2d',[wYear,wMonth,wDay]) + 'DB.txt';

    with SystemTime do
      tmpStr := Format('%.2d:%.2d:%.2d_%.3d   ',[wHour, wMinute, wSecond, wMilliSeconds]);
    tmpStr := tmpStr + Str;


//    if g_isLog<>0 then
    begin
      {$I-}
      AssignFile(fsm, tmpName);
      try
        if FileExists(tmpName) then
          Append(fsm)
        else ReWrite(fsm);
        Writeln(fsm,tmpStr);
      finally
        CloseFile(fsm);
        {$I+}
      end;
    end;
  end;
end;


{ TBdeDB }

function TBdeDB.BeginTrans: Boolean;
begin
  Result := True;
  if FConn.Connected then
    FConn.StartTransaction
  else
    Result := False;
end;

procedure TBdeDB.Buildbdeconn;
var
   ap:TStringList;   {数据库别名列表}
   Session: TSession;
begin
  Session := TSession.Create(nil);
  ap:=TStringlist.Create;
  try
    Session.GetAliasNames(ap);   //取得别名列表
    if (ap.IndexOf('Paramg')=-1) then   //判断别名是否存在
    begin
      Session.AddStandardAlias (FDBName,FDBPath,'Paradox');
      Session.SaveConfigFile ;    //BDE配置文件存盘
    end else
    begin
      ap.Clear;
      ap.Add('PATH=' +FDBPath);
      Session.ModifyAlias(DBName,ap);
      Session.SaveConfigFile;
    end;
    ap.Clear;
  finally
    ap.free;
    Session.Free;
  end;
end;

function TBdeDB.Commit: Boolean;
begin
  Result := True;
  if FConn.Connected then
    FConn.Commit
  else
    Result := False;
end;

constructor TBdeDB.Create;
begin
  FConn := TDataBase.Create(nil);
  FConn.DatabaseName := 'BDEDB';
  FConn.LoginPrompt := False;
  FQuery := TQuery.Create(nil);
  FQuery.DatabaseName := 'BDEDB';
  FExec := TQuery.Create(nil);
  FExec.DatabaseName := 'BDEDB';
end;

destructor TBdeDB.Destroy;
begin
  FQuery.Active := False;
  FExec.Active := False;
  SetConnected(False) ;
  FQuery.Free;
  FExec.Free;
  FConn.Free;
end;

function TBdeDB.ExecSQL(aSql: string): Boolean;
begin
  ErrStr := '';
  Result := False;
  if not FConn.Connected then
    SetConnected(True);
  if not FConn.Connected then
    Exit;

  FExec.Active := False;
  FExec.SQL.Text := aSql;
  try
    FExec.ExecSQL;
    Result := True;
  except
    on E: Exception do
      ErrStr := E.Message;
  end;
end;


function TBdeDB.ExecSQLEx(aSql, ImgParaName: string;
  ImgStream: TMemoryStream): Boolean;
begin
Result := False;
end;

function TBdeDB.GetConnected: Boolean;
begin
  Result := FConn.Connected;
end;

function TBdeDB.GetDataSet: TDataSet;
begin
  Result := FQuery;
end;

function TBdeDB.GetPKeys(aTbName: string;
  var aPKList: TStringList): Boolean;
var
  aTable: TTable;
  s,s1: string;
  i, len: Integer;
begin
  Result := False;
  aPKList.Clear;

  aTable := TTable.Create(nil);
  aTable.DatabaseName := 'BDEDB';
  aTable.TableName := aTbName;
  try
    aTable.Active := True;
  except
    on E: Exception do
    begin
      FErrStr := Trim(E.Message);
      aTable.Free;
      Exit;
    end;
  end;

  if aTable.IndexDefs.Count>0 then
  begin
    s := aTable.IndexDefs.Items[0].Fields;
    s1 := '';
    len := Length(s);
    for i:=1 to len do
    begin
      if s[i] = ';' then
      begin
        aPKList.Add(s1);
        s1 := '';
      end else
        s1 := s1 + s[i];
    end;
  end;
  aTable.Active := False;
  aTable.Free;
  Result := True;
end;

function TBdeDB.QuerySQL(aSql: string): Boolean;
begin
  ErrStr := '';
  Result := False;
  if not FConn.Connected then
    SetConnected(True);
  if not FConn.Connected then
    Exit;

  FQuery.Active := False;
  FQuery.SQL.Text := aSql;
  try
    FQuery.Open;
    Result := True;
  except
    on E: Exception do
      ErrStr := E.Message;
  end;
end;

function TBdeDB.RollBack: Boolean;
begin
  Result := True;
  if (FConn.Connected) and (FConn.InTransaction) then
    FConn.Rollback
  else
    Result := False;
end;

procedure TBdeDB.SetConnected(Value: Boolean);
begin
  if Value then
  begin
    Buildbdeconn;
    FConn.Connected := False;
    FConn.AliasName := DBName;
    try
      FConn.Connected := True;
    except
      on e: Exception do
        FErrStr := e.Message;
    end;
  end else
    FConn.Connected := False;
end;

{ TExprDB }

function TExprDB.BeginTrans: Boolean;
begin
  Result := True;
  if FConn.Connected then
    FConn.StartTransaction(FTD)
  else
    Result := False;
end;

function TExprDB.Commit: Boolean;
begin
  Result := True;
  if FConn.Connected then
    FConn.Commit(FTD)
  else
    Result := False;
end;

constructor TExprDB.Create;
begin
  FTD.TransactionID := 1;
  FTD.IsolationLevel := xilREADCOMMITTED;
  FConn := TSQLConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.ConnectionName := 'FBConnection';
  FConn.LibraryName := 'dbexpint.dll';
  FConn.VendorLib := 'fbclient.dll';
  FConn.GetDriverFunc := 'getSQLDriverINTERBASE';
  FConn.DriverName := 'FIREBIRD';
  FExec := TSQLDataSet.Create(nil);
  FExec.SQLConnection := FConn;
  FQuery := TSQLQuery.Create(nil);
  FQuery.SQLConnection := FConn;
  FProvider := TDataSetProvider.Create(nil);
  FProvider.Name := 'pd';
  FProvider.DataSet := FQuery;
  FClientQuery := TClientDataSet.Create(nil);
  FClientQuery.ProviderName := FProvider.Name;
end;

destructor TExprDB.Destroy;
begin
  FQuery.Active := False;
  FExec.Active := False;
  FClientQuery.Active := False;
  FConn.Connected := False;
  FClientQuery.Free;
  FProvider.Free;
  FQuery.Free;
  FExec.Free;
  FConn.Free;
  inherited;
end;

function TExprDB.ExecSQL(aSql: string): Boolean;
begin
  Result := False;
  if not FConn.Connected then
    SetConnected(True);
  if FConn.Connected then
  begin
    FExec.CommandText := UpperCase(aSql);
    try
      FExec.ExecSQL();
      Result := True;
    except
      on E: Exception do
        ErrStr := E.Message;
    end;
  end;
end;

function TExprDB.ExecSQLEx(aSql, ImgParaName: string;
  ImgStream: TMemoryStream): Boolean;
begin
Result := False;
end;

function TExprDB.GetConnected: Boolean;
begin
  Result := FConn.Connected;
end;

function TExprDB.GetDataSet: TDataSet;
begin
  Result := FClientQuery;
//  Result := FQuery;
end;

function TExprDB.GetPKeys(aTbName: string;
  var aPKList: TStringList): Boolean;
var
  s: string;
begin
  Result := False;
  aPKList.Clear;
  s := 'select A.RDB$FIELD_NAME AS COLUMN_NAME FROM RDB$INDEX_SEGMENTS A, RDB$RELATION_CONSTRAINTS B'
      +' WHERE B.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'''
      +' AND B.RDB$RELATION_NAME = '''+ UpperCase(aTbName)+''''
      +' AND A.RDB$INDEX_NAME = B.RDB$INDEX_NAME'
      +' ORDER BY A.RDB$FIELD_POSITION';
  if QuerySQL(s) then
  begin
    while not FQuery.Eof do
    begin
      aPKList.Add(Trim(FQuery.FieldByName('COLUMN_NAME').AsString));
      FQuery.Next;
    end;
  end else
    Exit;
  Result := True;
end;

function TExprDB.QuerySQL(aSql: string): Boolean;
begin
  Result := False;
  FQuery.Active := False;
  FClientQuery.Active := False;
  if not FConn.Connected then
    SetConnected(True);
  if FConn.Connected then
  begin
    FQuery.SQL.Text := UpperCase(aSql);
    try
      FQuery.Open;
      FClientQuery.SetProvider(FProvider);
      FClientQuery.Active := True;
      Result := True;
    except
      on E: Exception do
        ErrStr := E.Message;
    end;
  end;
end;

function TExprDB.RollBack: Boolean;
begin
  Result := True;
  if FConn.Connected then
    FConn.Rollback(FTD)
  else
    Result := False;
end;

procedure TExprDB.SetConnected(Value: Boolean);
begin
  inherited;
  if Value then
  begin
    FConn.Connected := False;
    FConn.Params.Clear;
    FConn.Params.Add('Database='+ DBIP + ':' + DBName);
    FConn.Params.Add('RoleName=RoleName');
    FConn.Params.Add('User_Name=SYSDBA');
    FConn.Params.Add('Password=hyits');
    FConn.Params.Add('ServerCharSet=GB2312');
    FConn.Params.Add('SQLDialect=3');
    FConn.Params.Add('LocaleCode=0000');
    FConn.Params.Add('BlobSize=-1');
    FConn.Params.Add('CommitRetain=false');
    FConn.Params.Add('WaitOnLocks=true');
    FConn.Params.Add('Interbase TransIsolation=ReadCommited');
    FConn.Params.Add('Trim Char=false');
    try
      FConn.Connected := True;
    except
      on e: Exception do
        FErrStr := e.Message;
    end;
  end else
  begin
    FConn.Connected := False;
  end;
end;

end.
