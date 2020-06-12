unit U_thrWork;

interface

uses
  Windows, SysUtils, Classes,IniFiles,ADODB,U_OpDB,DB, SyncObjs,
  ActiveX,DateUtils,Param,OleServer, ComObj;

type
  TSendData = class(TThread)
  private
    {Private declarations}
    FDBConnectWriteLog:Boolean;
    FOpDBWait  : TOpDB;
    FMessageID   : String;
    FStop        : Boolean;
  function GetChargeData: Boolean;

  function jzmx(Messageid:String):Boolean;

  function pkg(HeaderMessageid:String):Boolean;

  procedure WriteLog(Str:String);

  procedure WriteErrorLog(Str:String);

  protected

  procedure Execute;Override;

 public

   constructor Create;

   destructor  Destroy;Override;

   //初始化资源
   function    InitSource:Boolean;
   //释放资源
   function    FreeSource:Boolean;

published

   property  Stop: Boolean read FStop write FStop;

   property  MessageID : String read FMessageID;

end;


implementation

uses U_Global, func_ty,Uwork,UntJMJ;

{ TSendData }

constructor TSendData.Create;
begin
  FStop := False;
  inherited Create(False);
end;

destructor TSendData.Destroy;
begin
  inherited;
end;

procedure TSendData.Execute;
begin
  FreeOnTerminate:=True;
  CoInitialize(nil);
  try
   FDBConnectWriteLog:=True;
   while not FStop do
   begin
    try
     if not InitSource then
     begin
      if FDBConnectWriteLog then
      WriteErrorLog('发送线程数据库连接断开');
      FDBConnectWriteLog:=False;
      Continue;
     end;
     if FStop then
     Break;
     WriteLog('原始交易打包执行开始:');
     FOpDBWait.ProcExec('proc_Sendlocal_New',StrToInt('1'));
     WriteLog('原始交易打包执行完成');
     Sleep(1000);
     if not GetChargeData then
     begin
      Sleep(10000);
      Continue;
     end;


     WriteLog('');
     except

     end;
    end;
    finally
    end;
end;

function TSendData.FreeSource: Boolean;
begin
  FOpDBWait.Free;
end;

function TSendData.GetChargeData: Boolean;
var
  s:string;
begin
  Result:=False;
  {查询未记账的包}
  s :='select top 1 * from T_TransactionOriginalMain_Other  where ' +
      ' chargestate=0  order by cleartargetdate,Headermessageid ';
  if FOpDBWait.QuerySQL(s) then
  if not FOpDBWait.Query.IsEmpty then
  begin
    FMessageID:=FOpDBWait.Query.FieldByName('HeaderMessageId').AsString;
    WriteLog('开始处理'+FMessageID);
    //明细记账
    if not jzmx(FMessageID)  then
    begin
      exit;
    end;
    //包记录处理
    if not pkg(FMessageID)  then
    begin
      exit;
    end;
    result:=True;
  end;
end;


function TSendData.InitSource: Boolean;
var
  f: TiniFile;
  s: string;
  res:Integer;
begin
  Result:=False;
  FOpDBWait:= TOpDB.Create(gParam.DBType);
  s := gParam.ExePath+'tlqServer.ini';
  f := TIniFile.Create(s);
  FMessageID :='0';
  case gParam.DBType of
   3:
  begin
    s := 'Provider=SQLOLEDB.1;Password=%s;Persist Security Info=True;User ID=%s;' +
          'Initial Catalog=%s;Data Source=%s';
    FOpDBWait.ConnectionStr := Format(s,[gParam.DBPassword,gParam.DBUser,
          f.ReadString('DataBase', '基础库', ''),gParam.DBIP]);
  end;
  end;
  f.Free;
  if FOpDBWait.ConnectionStr <> '' then
      FOpDBWait.Connected := True
    else
      WriteLog('基础库未配置');
  Result:=FOpDBWait.Connected;
end;


function TSendData.jzmx(Messageid:String): Boolean;
var
    arr:array[0..16] of Byte;
    fchecktac:Tchecktac;
    mac1:array[0..3] of byte;
    errorid:integer;
    errormsg:string;
    strtmp:string;
    imoney:integer;
    jzresult:integer;
    i:integer;
    strtablename:string;
begin
 result:=False;
 {查询明细循环处理}
 try
   strtmp:= 'select a.* from  T_TransactionOriginal_other a '
            +'inner join T_TransactionOriginalMain_other c '
            +'on a.ServiceProviderId=c.ServiceProviderId '
            +'and a.IssuerId=c.IssuerId '
            +'and a.MessageId=c.MessageId '
            +'where  c.headerMessageid='+ Messageid
            +' and ((a.ChargeState=0) or (a.ChargeState is null))';

   if FOpDBWait.QuerySQL(strtmp) then
   begin
    if not FOpDBWait.Query.IsEmpty then
    begin
      with FOpDBWait.Query do
      begin
        FOpDBWait.Query.First;
        while not  FOpDBWait.Query.eof do
        begin
            jzresult:=0;
            Fillchar(fchecktac,SizeOf(Tchecktac),0);
            {卡号+金额+终端号+交易序列号,时间}
            fchecktac.hth:=FieldByName('cardid').asstring;
            fchecktac.money:=FieldByName('Fee').AsInteger;
            fchecktac.TerminalNo:=fieldbyname('terminalno').AsString;
            fchecktac.onlinesn:=fieldbyname('TerminalTransNo').AsString;
            fchecktac.CashDate:=formatdatetime('yyyymmdd',fieldbyname('optime').asdatetime);
            fchecktac.Cashtime:=formatdatetime('hhmmss',fieldbyname('optime').AsDateTime);
            fchecktac.Tac:=fieldbyname('tac').asstring;
            //验证Tac
           if not checktac(fchecktac,mainclass.SJMJSERVERIP,mainclass.SJMJPORT,
             mac1,errormsg)  then
           begin
             writelog('取Tac值失败：'+errormsg);
             Exit;
           end;
           strtmp:=mainclass.arraytostr(mac1);
           if UpperCase(FieldByName('tac').AsString)<>strtmp then
           begin
             jzresult:=1;
             errormsg:='TAC校验不过';
           end;
           //执行其它验证
           with TOleDB(FOpDBWait.FDBObj).FAdqSproc do
           begin
              close;
              errorid:=-1;
              ProcedureName:='proc_checkjzjg';
              Parameters.Clear;
              Parameters.CreateParameter('@ServiceProviderId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('ServiceProviderId').AsString);
              Parameters.CreateParameter('@IssuerId',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('IssuerId').AsString);
              Parameters.CreateParameter('@MessageId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('MessageId').AsString);
              Parameters.CreateParameter('@TransId',ftstring,pdInput,10,FOpDBWait.Query.fieldbyname('intTransId').AsString);
              Parameters.CreateParameter('@strtable',ftstring,pdInput,10,strtablename);
              Parameters.CreateParameter('@Result',ftinteger,pdoutput,7,jzresult);
              Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
              Parameters.CreateParameter('@errormsg',ftstring,pdInputOutput,512,errormsg);
              try
                 for i:=0 to Parameters.count-1 do
                 begin
                   strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                 end;
                 mainclass.writeerrorlog('数据校验失败:'+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
                 ExecProc;
                 i:=parameters.ParamByName('@Result').Value;
                 jzresult:=jzresult or i;
                 errormsg:=parameters.ParamByName('@errormsg').Value;
              except on e:exception do
              begin
                for i:=0 to Parameters.count-1 do
                begin
                    strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                end;
                mainclass.writeerrorlog('数据校验失败:'+e.message+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
              end;
              end;
            end;

             with TOleDB(FOpDBWait.FDBObj).FAdqSproc do
             begin

                close;
                errorid:=-1;
                ProcedureName:='proc_jzjg';
                Parameters.Clear;
                Parameters.CreateParameter('@ServiceProviderId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('ServiceProviderId').AsString);
                Parameters.CreateParameter('@IssuerId',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('IssuerId').AsString);
                Parameters.CreateParameter('@MessageId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('MessageId').AsString);
                Parameters.CreateParameter('@TransId',ftstring,pdInput,10,FOpDBWait.Query.fieldbyname('intTransId').AsString);
                Parameters.CreateParameter('@Result',ftinteger,pdInput,7,jzresult);
                Parameters.CreateParameter('@strtable',ftstring,pdInput,10,strtablename);
                Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
                Parameters.CreateParameter('@errormsg',ftstring,pdInput,512,errormsg);
             try
                ExecProc;
                except on e:exception do
                begin
                    strtmp:='';
                    for i:=0 to Parameters.count-1 do
                    begin
                        strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                    end;

                    mainclass.writeerrorlog('数据校验失败:'+e.message+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
                end;
               end;
             end;
             FOpDBWait.Query.next;
            //下个明细
        end; //eof
      end;
     writelog('校验完成包号：'+MESSAGEID);
    end ;//有未记账明细
   end
   else
   begin
      writelog('执行查询明细失败!');
   end;
   finally

   end;
 result:=true;
end;

function TSendData.pkg(HeaderMessageid:String): Boolean;
var
  i,errorid:integer;
  errormsg:string;
  strtmp:string;
  strtable:string;
begin
  result:=False;
  try
    strtmp:=  'select top 1 a.* from  T_TransactionOriginal_other a '
            +'inner join T_TransactionOriginalMain_other c '
            +'on a.ServiceProviderId=c.ServiceProviderId '
            +'and a.IssuerId=c.IssuerId '
            +'and a.MessageId=c.MessageId '
            +'where  c.headerMessageid='+ HeaderMessageid
            +' and (c.ChargeState=0)';
    if FOpDBWait.QuerySQL(strtmp) then
    begin
      if not FOpDBWait.Query.IsEmpty then
      begin
        FOpDBWait.Query. First;
        with  TOleDB(FOpDBWait.FDBObj).FAdqSproc  do
        begin
          errorid:=-1;
          Close;
          ProcedureName:='proc_sendjzjg';
          Parameters.Clear;
          Parameters.CreateParameter('@MessageId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('MessageId').AsString);
          Parameters.CreateParameter('@ServiceProviderId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('ServiceProviderId').AsString);
          Parameters.CreateParameter('@IssuerId',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('IssuerId').AsString);
          Parameters.CreateParameter('@strtable',ftstring,pdInput,10,strtable);
          Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
          Parameters.CreateParameter('@errormsg',ftstring,pdoutput,2,errormsg);
          try
           TOleDB(FOpDBWait.FDBObj).FAdqSproc.ExecProc;
           except on e:exception do
           begin
              for i:=0 to TOleDB(FOpDBWait.FDBObj).FAdqSproc.Parameters.count-1 do
              begin
                  strtmp:=strtmp+string(TOleDB(FOpDBWait.FDBObj).FAdqSproc.Parameters[i].Value)+''',''';
              end;
              mainclass.writeerrorlog('数据校验失败:'+e.message+' sql:exec '+TOleDB(FOpDBWait.FDBObj).FAdqSproc.ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
           end;
          end;

        end;
        end;
    end
    else
    begin
      //
      exit;
    end;
  finally
  end;

  result:=True;
end;

procedure TSendData.WriteErrorLog(Str: String);
begin

end;

procedure TSendData.WriteLog(Str: String);
var
  tmpStr,
  tmpName: String;
  SystemTime: TSystemTime;
  fsm       : TextFile;
begin
  if gParam.IsLog=0 then
  Exit;

  if Str='' then Exit;
  tmpName := gParam.ExePath+'Sendlog\';

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
      tmpName := tmpName + Format('%.4d%.2d%.2d',[wYear,wMonth,wDay]) + '.txt';

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


end.
