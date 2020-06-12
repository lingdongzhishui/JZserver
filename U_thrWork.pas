unit U_thrWork;

interface

uses
  Windows, SysUtils, Classes,IniFiles,ADODB,U_OpDB,DB, SyncObjs,
  ActiveX,DateUtils,Param,OleServer, ComObj,Math,StrUtils;

type

  TSendData = class(TThread)
  private

   {Private declarations}
    FDBConnectWriteLog:Boolean;
    FOpDBWait  : TOpDB;
    {����һ�����ݿ����}
    FOpDBETC  : TOpDB;
    FMessageID   : String;
    FtollProvinceId : String;
    FIssuerId : String;
    FStop        : Boolean;

  function GetETCTS_FREETD_OBUTR: Boolean;
  function GetETCTS_FREETD_tac: Boolean;
  function GetChargeData: Boolean;
  function GetEXPChargeData(jztable:String):Boolean;

  function ETCTS_FREETD_OBUTRTD(Messageid,tollProvinceId,IssuerId,strtablename:String; var trans_type:Integer): Boolean;
  function  ETCTS_FREETD_transaction(Messageid,tollProvinceId,IssuerId:String): Boolean;
  function etcts_tau: Boolean;
  function  jzmx(Messageid,tollProvinceId,IssuerId:String):Boolean;
  function  EXPjzmx(Messageid,tollProvinceId,IssuerId,jztable:String):Boolean;
  function  pkgtac(FMessageID:String;FtollProvinceId:String;FIssuerId:String;trans_type:Integer):Boolean;
  function  pkg(HeaderMessageid:String):Boolean;
  function  EXpkg(HeaderMessageid,jztable:String):Boolean;
  //����ETC����Ч��
  function jycard(cardid, exdate: string; var Iresult: Integer;
  var strres: string): boolean;

  procedure WriteLog(Str:String);

  procedure WriteErrorLog(Str:String);

  protected

  procedure Execute;Override;

 public

   constructor Create;

   destructor  Destroy;Override;

   //��ʼ����Դ
   function    InitSource:Boolean;

   //�ͷ���Դ
   function    FreeSource:Boolean;

published

   property  Stop: Boolean read FStop write FStop;

   property  MessageID : String read FMessageID;
   property  tollProvinceId : String read FtollProvinceId;
   property  IssuerId : String read FIssuerId;

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
  FDBConnectWriteLog:=True;
   if not InitSource then
     begin
      if FDBConnectWriteLog then
      WriteErrorLog('�����߳����ݿ����ӶϿ�');
      FDBConnectWriteLog:=False;
//      Continue;
     end;
  while not FStop do
  begin
   try
    try


     if FStop then
      Break;
        etcts_tau;    //�ϲ���ETC���ڽ���
//      GetETCTS_FREETD_tac;   //����TAC���ɵ�ETC�żܽ���
//      GetChargeData;    //T_TransactionOriginalMain_Other

//      GetETCTS_FREETD_OBUTR;  //���ڷ�TAC���ɵ�ETC�żܽ���

     //��չͣ����ETC���׼���
     {if not GetEXPChargeData('EATS_PTU') then
     begin
//      Sleep(10000);
//      Continue;
     end;
     //����վETC���׼���
     if not GetEXPChargeData('EATS_GSTU') then
     begin
//      Sleep(10000);
//      Continue;
     end;
     //������ETC���׼���
     if not GetEXPChargeData('EATS_SATU') then
     begin
      Sleep(10000);
      Continue;
     end;
     //����ETC���׼���
     if not GetEXPChargeData('EATS_MDTU') then
     begin
      Sleep(10000);
      Continue;
     end;}
    except
     on E:exception do
      WriteLog('ִ�м���'+e.Message);
    end;
    finally
//      FreeSource;
    end;
  end;
end;

function TSendData.FreeSource:Boolean;
begin
  try
    FOpDBWait.Free;
    FOpDBWait:=nil;

    FOpDBETC.Free;
    FOpDBETC:=nil;
    // WriteLog('�ͷ�����');
    except
    on E:Exception do
    WriteLog('�ͷ�����ʧ��'+e.Message);
  end;
  result:=True;
end;

//2.3.3���ڷ�tac��ETCͨ�м�¼��ETC�żܽ����������أ�������
function TSendData.GetETCTS_FREETD_OBUTR: Boolean;
var
  s,s_desc,strtab:string; trans_type:Integer;
begin
  Result:=False;

  // ���������
  s :='select top 1 MessageId,IssuerId,tollProvinceId,transaction_type from ETCTS_FREETD with (nolock) where ' +
      ' chargestate=0 and transaction_type!=1 and messageid%5=0 order by version ASC';

  if FOpDBWait.QuerySQL(s) then
  if not FOpDBWait.Query.IsEmpty then
  begin
    FMessageID:=FOpDBWait.Query.FieldByName('MessageId').AsString;
    FIssuerId:=FOpDBWait.Query.FieldByName('IssuerId').AsString;
    FtollProvinceId:=FOpDBWait.Query.FieldByName('tollProvinceId').AsString;
    trans_type:= FOpDBWait.Query.FieldByName('transaction_type').AsInteger;
    WriteLog('asc��ѯ��ɣ���ʼ����MessageId:'+FMessageID+'IssuerId:'+FIssuerId+'tollProvinceId:'+FtollProvinceId);
    if (trans_type=3) then
    begin
       strtab:='ETCTS_OBUTRTD_transaction';
    end else  if (trans_type=4) then
    begin
       strtab:='ETCTS_PICTRTD_transaction';
    end else if (trans_type=5) then
    begin
        strtab:='ETCTS_SIMTRTD_transaction';
    end;
    //��ϸ����
    if not ETCTS_FREETD_OBUTRTD(FMessageID,FtollProvinceId,FIssuerId,strtab,trans_type)  then
    begin
      writelog('����TAC����ʧ�ܣ�');
      exit;
    end;
    //����¼����
     if not pkgtac(FMessageID,FtollProvinceId,FIssuerId,trans_type)  then
    begin
      writelog('����ʧ�ܣ�');
      exit;
    end;
    result:=True;
  end;
end;

//2.3.2����TAC���ɵ�ETC�żܽ������أ�������
function TSendData.GetETCTS_FREETD_tac: Boolean;
var
  s,s_desc:string;
  trans_type:Integer;
begin
  Result:=False;

  // ���������
  s :='select top 1 MessageId,IssuerId,tollProvinceId,transaction_type from ETCTS_FREETD with (nolock) where ' +
      ' chargestate=0 and transaction_type=1 and messageid%5=4  order by version';      // ����
//   s :='select top 100 MessageId,IssuerId,tollProvinceId,transaction_type from ETCTS_FREETD with (nolock) where ' +
//      ' chargestate>0 and pkgstatus=0 and transaction_type=1  and messageid%5=0 order by version';      // ���
  if FOpDBWait.QuerySQL(s) then
  if not FOpDBWait.Query.IsEmpty then
  begin
      with FOpDBWait.Query do
      begin
        FOpDBWait.Query.First;
        while not  FOpDBWait.Query.eof do
        begin
            FMessageID:=FOpDBWait.Query.FieldByName('MessageId').AsString;
            FIssuerId:=FOpDBWait.Query.FieldByName('IssuerId').AsString;
            FtollProvinceId:=FOpDBWait.Query.FieldByName('tollProvinceId').AsString;
            trans_type:= FOpDBWait.Query.FieldByName('transaction_type').AsInteger;
             WriteLog('asc��ѯ��ɣ�ETCTS_FREETD��ʼ����MessageId:'+FMessageID+'trans_type:'+inttostr(trans_type)+'tollProvinceId:'+FtollProvinceId);
            //��ϸ����
            if not ETCTS_FREETD_transaction(FMessageID,FtollProvinceId,FIssuerId)  then
            begin
              writelog('����TAC����ʧ�ܣ�');
              exit;
            end;
            //����¼����

           { if not pkgtac(FMessageID,FtollProvinceId,FIssuerId,trans_type)  then
            begin
              writelog('����ʧ�ܣ�');
              exit;
            end;    }
            FOpDBWait.Query.Next;
        end;
      end;

    result:=True;
  end;
end;

function TSendData.GetChargeData: Boolean;
var
  s,s_desc:string;
begin
  Result:=False;
  
  // ���������
  s :='select top 1 * from T_TransactionOriginalMain_Other with (nolock) where ' +
      ' chargestate=0 and messageid%5=0 order by version ASC';

  if FOpDBWait.QuerySQL(s) then
  if not FOpDBWait.Query.IsEmpty then
  begin
    FMessageID:=FOpDBWait.Query.FieldByName('MessageId').AsString;
    FIssuerId:=FOpDBWait.Query.FieldByName('IssuerId').AsString;
    FtollProvinceId:=FOpDBWait.Query.FieldByName('tollProvinceId').AsString;
    WriteLog('asc��ѯ��ɣ���ʼ����MessageId:'+FMessageID+'T_TransactionOriginalMain_Other->tollProvinceId:'+FtollProvinceId);
    //��ϸ����
    if not jzmx(FMessageID,FtollProvinceId,FIssuerId)  then
    begin
      writelog('����ʧ�ܣ�');
      exit;
    end;
    //����¼����
     if not pkg(FMessageID)  then
    begin
      writelog('����ʧ�ܣ�');
      exit;
    end;
    result:=True;
  end;
end;

function TSendData.GetEXPChargeData(jztable:String): Boolean;
var
  s:string;
begin
  Result:=False;

  // ���������
  s :='select top 1 * from '+jztable+'_DOWN with (nolock)  where chargestate=0  order by version ASC';


  if FOpDBWait.QuerySQL(s) then
  if not FOpDBWait.Query.IsEmpty then
  begin
    FMessageID:=FOpDBWait.Query.FieldByName('MessageId').AsString;
    FIssuerId:=FOpDBWait.Query.FieldByName('IssuerId').AsString;
    FtollProvinceId:=FOpDBWait.Query.FieldByName('tollProvinceId').AsString;
    WriteLog('��ѯ��ɣ���ʼ����MessageId:'+FMessageID+'IssuerId:'+FIssuerId+'tollProvinceId:'+FtollProvinceId);
    //��ϸ����
    if not EXPjzmx(FMessageID,FtollProvinceId,FIssuerId,jztable)  then
    begin
      writelog('EXPjzmx����ʧ�ܣ�');
      exit;
    end;
    //����¼����
     if not EXpkg(FMessageID,jztable)  then
    begin
      writelog('EXpkg����ʧ�ܣ�');
      exit;
    end;
    result:=True;
  end;
end;


function TSendData.InitSource:Boolean;
var
  f: TiniFile;
  s: string;
  res:Integer;
  dbconnect:Boolean;
  etcconnect:Boolean;
begin
  Result:=False;
  FOpDBETC := TOpDB.Create(gParam.DBType);
  FOpDBWait:= TOpDB.Create(gParam.DBType);
  s := gParam.ExePath+'tlqServer.ini';
  f := TIniFile.Create(s);
  FMessageID :='0';
    try
      case gParam.DBType of
       3:
      begin
        s := 'Provider=SQLOLEDB.1;Password=%s;Persist Security Info=True;User ID=%s;' +
              'Initial Catalog=%s;Data Source=%s';
        FOpDBWait.ConnectionStr := Format(s,[gParam.DBPassword,gParam.DBUser,
              f.ReadString('DataBase', '������', ''),gParam.DBIP]);

        FOpDBETC.ConnectionStr:=Format(s,[gParam.ETCDBPassword,gParam.ETCDBUser,
              gParam.ETCDBNAME,gParam.ETCDBIP]);

      end;
      end;
      FreeAndNil(f);
    //  f.Free;
        if FOpDBWait.ConnectionStr <> '' then
          FOpDBWait.Connected := True
        else
          WriteLog('�������ݿ�δ����');
      if FOpDBETC.ConnectionStr <> '' then
          FOpDBETC.Connected := True
        else
          WriteLog('ETC���ݿ�δ����');

      dbconnect:=FOpDBWait.Connected;
      etcconnect:=FOpDBETC.Connected;
      if dbconnect and etcconnect then
      begin
        result:=True;
      end
      else
      begin
        WriteLog('�����'+FOpDBWait.ErrStr);
        WriteLog('ETC���ݿ�'+FOpDBETC.ErrStr);
        result:=False;
      end;
    except
      WriteLog('���ݿ������쳣'+FOpDBWait.ErrStr);
    end
end;


function TSendData.jycard(cardid, exdate: string;
  var Iresult: Integer; var strres: string): boolean;
var
  sSQL:String;
  icardtype:Integer;
  strvehplate:String;
  i,j,k:integer;
  res:string;
begin
   result:=False;
   // �жϿ���Ч��
   icardtype:=0;
   i:=0;
   {sSQL:=' SELECT TOP 1 VehiclePlateNo,21+cardtype as cardtype from ETCCardData  with (nolock)'
         +' WHERE CardID='+quotedstr(cardid) +'';

   if FOpDBETC.QuerySQL(sSQL) then
   begin
     if FOpDBETC.Query.IsEmpty then
     begin
       i:=Ceil(power(2,8-1));
       Iresult:=i;
       strres:='/���ݿ�����Ϣ��ѯ���޴˿���Ϣ'+sSQL;
     end
     else }
     begin
       sSQL:= 'SELECT TOP 1 VehiclePlateNo,21+cardtype as cardtype '
             +' from  ETCCardData with (nolock)  WHERE (CardID='+quotedstr(cardid) +' and IssueTime<='
             + QuotedStr(exdate) +'and (InvaliDate>='+QuotedStr(exdate) +'or ' +
             'InvaliDate is null)) ';
       if FOpDBETC.QuerySQL(sSQL) then
       begin
          if FOpDBETC.Query.IsEmpty then
          begin
            i:=i or Ceil(power(2,3-1));
            Iresult:=i;
           strres:=strres+'/���ݿ�����Ϣ��ѯ���ڹ涨��ʱ���ڲ����ڴ˿�,�˿���״̬�仯����:'+sSQL
          end;
        {  else
          begin
             icardtype:=FOpDBETC.Query.fieldbyname('cardtype').asinteger;
             if icardtype<>StrToInt(listcardtype) then
             begin
               i:=i or Ceil(power(2,15-1));
               Iresult:=i;
               strres:=strres+'/���ݿ�����Ϣ�Ŀ����ͱȶԲ��ԣ���������Ϊ��'+
               IntToStr(icardtype)+'��ˮ����Ϊ��'+ listcardtype;
             end;
          end;   }
      end
      else
      begin
        WriteLog(FOpDBETC.ErrStr);
        Exit;
      end;
    end;
   {end
   else
   begin
     WriteLog(FOpDBETC.ErrStr);
     Exit;
   end;     }
 result:=True;
 end;

function TSendData.ETCTS_FREETD_OBUTRTD(Messageid,tollProvinceId,IssuerId,strtablename:String; var trans_type:Integer): Boolean;
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

    {*ETC����Ч��2016-02-05*}
    cardid,exdate,listcardtype: string;
    Iresult: Integer;
    strres: string;
begin
 result:=False;
 jzresult:=0;
 {��ѯ��ϸѭ������}
 try
//   WriteLog('��ѯδ���˰���ϸ��ˮ');
   strtmp:= 'select tollProvinceId,IssuerId,MessageId,Id,etcCardId,transtime,fee,obuid,vehicleType from  '+strtablename+' with (nolock) '
            +'where  Messageid='+ Messageid +' AND  tollProvinceId='+tollProvinceId+' and IssuerId='+IssuerId
            +' and ChargeState=0 ';
   WriteLog('��ѯδ���˰���ϸ��ˮstrtmp:'+strtmp);
   if FOpDBWait.QuerySQL(strtmp) then
   begin
    if not FOpDBWait.Query.IsEmpty then
    begin
      with FOpDBWait.Query do
      begin
        FOpDBWait.Query.First;
        while not  FOpDBWait.Query.eof do
        begin
           cardid:= FOpDBWait.Query.fieldbyname('etcCardId').AsString;
           if (Length(cardid)=0) then
           begin
              jzresult:=0;  //ETC����Ϊ��ʱ��ʱ������֤
           end else
           begin
               //ִ��������֤
               with TOleDB(FOpDBWait.FDBObj).FAdqSproc do
               begin
                  close;
                  errorid:=-1;
                  //��֤ȡ�����ӷ������Ŀ���֤����Ϊ����ֱ����
                  ProcedureName:='proc_checkjzjg';
                  Parameters.Clear;
                  Parameters.CreateParameter('@tollProvinceId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('tollProvinceId').AsString);
                  Parameters.CreateParameter('@strcardno',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('etcCardId').AsString);
                  Parameters.CreateParameter('@exDate',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('transtime').AsString);
                  Parameters.CreateParameter('@MessageId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('MessageId').AsString);
                  Parameters.CreateParameter('@trans_type',ftinteger,pdInput,7,trans_type);    //����TAC
                  Parameters.CreateParameter('@vehicleType',ftinteger,pdInput,7,FOpDBWait.Query.fieldbyname('vehicleType').AsInteger);    //����
                  Parameters.CreateParameter('@obuid',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('obuid').AsString);
                  Parameters.CreateParameter('@Id',ftstring,pdInput,40,FOpDBWait.Query.fieldbyname('Id').AsString);
                  Parameters.CreateParameter('@Result',ftinteger,pdoutput,7,jzresult);
                  Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
                  Parameters.CreateParameter('@errormsg',ftstring,pdInputOutput,512,errormsg);
                  try
                     for i:=0 to Parameters.count-1 do
                     begin
                       strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                     end;
                     mainclass.writeerrorlog('��ʼ��֤:'+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
                     //mainclass.writeerrorlog('ʱ��'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                     ExecProc;
                     mainclass.writeerrorlog('��֤��ɣ�'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                     i:=parameters.ParamByName('@Result').Value;
                     jzresult:=jzresult or i;
                     errormsg:=parameters.ParamByName('@errormsg').Value;
                  except on e:exception do
                  begin
                    for i:=0 to Parameters.count-1 do
                    begin
                        strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                    end;
                    mainclass.writeerrorlog('����У��ʧ��:'+e.message+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
                  end;
                  end;
                end;
            
           end;
            {����ETC���ݿ⿪ʼ��֤}

            with TOleDB(FOpDBWait.FDBObj).FAdqSproc do
            begin
                close;
                errorid:=-1;
                ProcedureName:='proc_jzjg';
                Parameters.Clear;
                Parameters.CreateParameter('@tollProvinceId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('tollProvinceId').AsString);
                Parameters.CreateParameter('@IssuerId',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('IssuerId').AsString);
                Parameters.CreateParameter('@MessageId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('MessageId').AsString);
                Parameters.CreateParameter('@Id',ftstring,pdInput,50,FOpDBWait.Query.fieldbyname('Id').AsString);
                Parameters.CreateParameter('@trans_type',ftinteger,pdInput,7,trans_type);    //���ڿ�ƥ�����ͼ��
                Parameters.CreateParameter('@fee',ftinteger,pdInput,7,FOpDBWait.Query.fieldbyname('fee').AsInteger);    //���׽��
                Parameters.CreateParameter('@Result',ftinteger,pdInput,7,jzresult);
                Parameters.CreateParameter('@strtable',ftstring,pdInput,20,'ETCTS_FREETD');
                Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
                Parameters.CreateParameter('@errormsg',ftstring,pdInputoutput,512,errormsg);
             try
                WriteLog('ִ�п�ʼ���ɼ��˽��'+cardid);
                // mainclass.writeerrorlog('���ɼ��˽����ʼʱ��'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                ExecProc;
                WriteLog('ִ�п�ʼ���ɼ��˽�����');
                //mainclass.writeerrorlog('���ɼ��˽������ʱ��'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                except on e:exception do
                begin
                    strtmp:='';
                    for i:=0 to Parameters.count-1 do
                    begin
                        strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                    end;
                    mainclass.writeerrorlog('����У��ʧ��:'+e.message+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
                end;
               end;
             end;
            FOpDBWait.Query.next;
            //�¸���ϸ
        end; //eof
      end;
     writelog('У����ɰ��ţ�'+MESSAGEID);
    end; //��δ������ϸ

    begin
       strtmp:= 'update ETCTS_FREETD set ChargeState=1 '
            +'where  Messageid='+ Messageid +' AND  tollProvinceId='+tollProvinceId+' and IssuerId='+IssuerId
            +' and ChargeState=0 and transaction_type='+inttostr(trans_type)+' ';
     FOpDBWait.ExecSQL(strtmp) ;

    end;
   end;
   finally

   end;
 result:=true;
end;

function TSendData.ETCTS_FREETD_transaction(Messageid,tollProvinceId,IssuerId:String): Boolean;
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

    {*ETC����Ч��2016-02-05*}
    cardid,exdate,listcardtype: string;
    Iresult: Integer;
    strres: string;
begin
 result:=False;
 jzresult:=0;
 {��ѯ��ϸѭ������}
 try
   strtmp:= 'select tollProvinceId,IssuerId,MessageId,Id,etcCardId,fee,terminalNo,terminalTransNo,transtime,TAC,transfee,obuid,vehicleType from  ETCTS_FREETD_transaction with (nolock) '
            +'where  Messageid='+ Messageid +' AND  tollProvinceId='+tollProvinceId+' and IssuerId='+IssuerId
            +' and ChargeState=0 ';
   WriteLog('��ѯδ���˰���ϸ��ˮstrtmp:'+strtmp);
   if FOpDBWait.QuerySQL(strtmp) then
   begin
    if not FOpDBWait.Query.IsEmpty then
    begin
      with FOpDBWait.Query do
      begin
        FOpDBWait.Query.First;
        while not  FOpDBWait.Query.eof do
        begin
//            WriteLog('��ʼ��֤TAC');
            {jzresult:=0;
            Fillchar(fchecktac,SizeOf(Tchecktac),0);
            //����+���+�ն˺�+�������к�,ʱ��}
            fchecktac.hth:=RightStr(FieldByName('etcCardId').asstring,16);
            fchecktac.money:=FieldByName('fee').AsInteger;
            fchecktac.TerminalNo:=fieldbyname('terminalNo').AsString;
            fchecktac.onlinesn:=fieldbyname('terminalTransNo').AsString;
            fchecktac.CashDate:=formatdatetime('yyyymmdd',fieldbyname('transtime').asdatetime);
            fchecktac.Cashtime:=formatdatetime('hhmmss',fieldbyname('transtime').AsDateTime);
            fchecktac.Tac:=fieldbyname('TAC').asstring;
           // ע�⣺���Բ��˼��ܻ������Σ�����ʱ���20160204
           //��֤Tac

          { try
             if not checktac(fchecktac,mainclass.SJMJSERVERIP,mainclass.SJMJPORT,
               mac1,errormsg)  then
             begin
               writelog('ȡTacֵʧ�ܣ�'+errormsg);
               Exit;
             end;
           except on e:exception do
           begin
             WriteErrorLog('TacУ��ʧ��'+e.Message);
           end;
           end;
           strtmp:=mainclass.arraytostr(mac1);
           if UpperCase(FieldByName('tac').AsString)<>strtmp then
           begin
             jzresult:=1;
             errormsg:='��ˮTAC��'+UpperCase(FieldByName('tac').AsString)+'���ܻ�TAC��'+strtmp;
             writelog('TACУ�鲻��'+errormsg);
           end
           else  jzresult:=0;}
           //����۷ѽ���뽻�׽�һ�£�����OBU״̬�仯
          { if FieldByName('fee').AsInteger>FieldByName('transfee').AsInteger then
            begin
              jzresult:=3;
            end
           else  jzresult:=0; }

//            WriteLog('��֤TAC���');

           jzresult:=0;

           //ִ��������֤
           with TOleDB(FOpDBWait.FDBObj).FAdqSproc do
           begin
              close;
              errorid:=-1;
              //��֤ȡ�����ӷ������Ŀ���֤����Ϊ����ֱ����
              ProcedureName:='proc_checkjzjg';
              Parameters.Clear;
              Parameters.CreateParameter('@tollProvinceId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('tollProvinceId').AsString);
              Parameters.CreateParameter('@strcardno',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('etcCardId').AsString);
              Parameters.CreateParameter('@exDate',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('transtime').AsString);
              Parameters.CreateParameter('@MessageId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('MessageId').AsString);
              Parameters.CreateParameter('@trans_type',ftinteger,pdInput,7,1);    //����TAC
              Parameters.CreateParameter('@vehicleType',ftinteger,pdInput,7,FOpDBWait.Query.fieldbyname('vehicleType').AsInteger);    //����
              Parameters.CreateParameter('@obuid',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('obuid').AsString);
              Parameters.CreateParameter('@Id',ftstring,pdInput,40,FOpDBWait.Query.fieldbyname('Id').AsString);
              Parameters.CreateParameter('@Result',ftinteger,pdoutput,7,jzresult);
              Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
              Parameters.CreateParameter('@errormsg',ftstring,pdInputOutput,512,errormsg);
              try
                strtmp:='';
                 for i:=0 to Parameters.count-1 do
                 begin
                   strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                 end;

                 //mainclass.writeerrorlog('ʱ��'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                 ExecProc;
//                 mainclass.writeerrorlog('��֤��ɣ�'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                 i:=parameters.ParamByName('@Result').Value;
                 jzresult:=jzresult or i;
                 errormsg:=parameters.ParamByName('@errormsg').Value;
              except on e:exception do
              begin
                  mainclass.writeerrorlog('��ʼ��֤:'+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
              end;
              end;
            end;
            {����ETC���ݿ⿪ʼ��֤}

            with TOleDB(FOpDBWait.FDBObj).FAdqSproc do
            begin
                close;
                errorid:=-1;
                ProcedureName:='proc_jzjg';
                Parameters.Clear;
                Parameters.CreateParameter('@tollProvinceId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('tollProvinceId').AsString);
                Parameters.CreateParameter('@IssuerId',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('IssuerId').AsString);
                Parameters.CreateParameter('@MessageId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('MessageId').AsString);
                Parameters.CreateParameter('@Id',ftstring,pdInput,50,FOpDBWait.Query.fieldbyname('Id').AsString);
                Parameters.CreateParameter('@trans_type',ftinteger,pdInput,7,1);    //����TAC
                Parameters.CreateParameter('@fee',ftinteger,pdInput,7,FOpDBWait.Query.fieldbyname('fee').AsInteger);    //���׽��
                Parameters.CreateParameter('@Result',ftinteger,pdInput,7,jzresult);
                Parameters.CreateParameter('@strtable',ftstring,pdInput,20,'ETCTS_FREETD');
                Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
                Parameters.CreateParameter('@errormsg',ftstring,pdInputoutput,512,errormsg);
             try
//                WriteLog('ִ�п�ʼ���ɼ��˽��');
                // mainclass.writeerrorlog('���ɼ��˽����ʼʱ��'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                ExecProc;
//                WriteLog('ִ�п�ʼ���ɼ��˽�����');
                //mainclass.writeerrorlog('���ɼ��˽������ʱ��'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                except on e:exception do
                begin
                    strtmp:='';
                    for i:=0 to Parameters.count-1 do
                    begin
                        strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                    end;
                    mainclass.writeerrorlog('����У��ʧ��:'+e.message+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
                end;
               end;
             end;
            FOpDBWait.Query.next;
            //�¸���ϸ
        end; //eof
      end;

    end;
      begin
         strtmp:= 'update a set ChargeState=1 from ETCTS_FREETD a with (nolock)'
              +'where  Messageid='+ Messageid +' AND  tollProvinceId='+tollProvinceId+' and IssuerId='+IssuerId
              +' and chargestate=0 and transaction_type=1 ';
          FOpDBWait.ExecSQL(strtmp) ;
      end;
     writelog('У����ɰ��ţ�'+MESSAGEID);
   end;
   finally

   end;
 result:=true;
end;

//����վETC�������ݼ���
function TSendData.etcts_tau: Boolean;
var
    arr:array[0..16] of Byte;
    fchecktac:Tchecktac;
    mac1:array[0..3] of byte;
    errorid:integer;
    errormsg:string;
    strtmp:string;
    imoney,transFee,fee,vehicleType:integer;
    jzresult:integer;
    i:integer;
    TerminalTransNo:string;
    exdate:TDateTime;
    
    tac,cardid,id,tollProvinceId,passId,terminalno: string;
    Iresult: Integer;
    strres: string;
begin
 result:=False;
 jzresult:=0;
 {��ѯ��ϸѭ������}
 try
//   WriteLog('��ѯδ���˰���ϸ��ˮ');
   strtmp:= 'select top 1000  * from  ETCTS_EXITETCTD a with (nolock) where a.jzstatus=0 order by a.version ';

   if FOpDBWait.QuerySQL(strtmp) then
   begin
    if not FOpDBWait.Query.IsEmpty then
    begin
      with FOpDBWait.Query do
      begin
        FOpDBWait.Query.First;
        while not  FOpDBWait.Query.eof do
        begin
            tac:= FOpDBWait.Query.fieldbyname('tac').AsString;
            id:=FOpDBWait.Query.fieldbyname('Id').AsString;
            TerminalTransNo :=  FOpDBWait.Query.fieldbyname('TerminalTransNo').AsString;
            cardid:=FOpDBWait.Query.Fieldbyname('cardid').asString;
            exdate:=FOpDBWait.Query.fieldbyname('extime').asdatetime;
            tollProvinceId:=FOpDBWait.Query.fieldbyname('tollProvinceId').AsString;
            passId:= FOpDBWait.Query.fieldbyname('passId').AsString;
            transFee:= FOpDBWait.Query.FieldByName('transFee').AsInteger;
            fee:= FOpDBWait.Query.FieldByName('fee').AsInteger;
            terminalno:= FOpDBWait.Query.fieldbyname('terminalno').AsString ;
            vehicleType:= FOpDBWait.Query.fieldbyname('vehicleType').AsInteger;

            {jzresult:=0;
            Fillchar(fchecktac,SizeOf(Tchecktac),0);
            //����+���+�ն˺�+�������к�,ʱ��}
            fchecktac.hth:=RightStr(cardid,16);
            fchecktac.money:=transFee;  //����ʱӦ�����ܽ��׽�TAC ��֤ʱʹ�á�
            fchecktac.TerminalNo:=terminalno;
            fchecktac.onlinesn:=TerminalTransNo;
            fchecktac.CashDate:=formatdatetime('yyyymmdd',exdate);
            fchecktac.Cashtime:=formatdatetime('hhmmss',exdate);
            fchecktac.Tac:=fieldbyname('tac').asstring;
           // ע�⣺���Բ��˼��ܻ������Σ�����ʱ���20160204
           //��֤Tac
           try
             if not checktac(fchecktac,mainclass.SJMJSERVERIP,mainclass.SJMJPORT,
               mac1,errormsg)  then
           except on e:exception do
           begin
             WriteErrorLog('TacУ��ʧ��'+e.Message);
           end;
           end;
           strtmp:=mainclass.arraytostr(mac1);
           if UpperCase(FieldByName('tac').AsString)<>strtmp then
           begin
             jzresult:=1;
             errormsg:='��ˮTAC��'+UpperCase(tac)+'���ܻ�TAC��'+strtmp;
             writelog('ETCTS_EXITETCTD->TACУ�鲻��'+errormsg);
           end
           else  jzresult:=0;

//            WriteLog('��֤TAC���');

           //ִ��������֤
           with TOleDB(FOpDBWait.FDBObj).FAdqSproc do
           begin
              close;
              errorid:=-1;
              //��֤ȡ�����ӷ������Ŀ���֤����Ϊ����ֱ����
              ProcedureName:='proc_checkjzjg';
              Parameters.Clear;
              Parameters.CreateParameter('@tac',ftString,pdInput,20,tac);
              Parameters.CreateParameter('@cardid',ftstring,pdInput,20,cardid);
              Parameters.CreateParameter('@extime',ftstring,pdInput,20,formatdatetime('yyyy-mm-dd hh:mm:ss',exdate));
              Parameters.CreateParameter('@terminalTransNo',ftString,pdInput,20,TerminalTransNo);
              Parameters.CreateParameter('@transfee',ftinteger,pdInput,7,fee);
              Parameters.CreateParameter('@vehicleType',ftinteger,pdInput,7,vehicleType);    //����
              Parameters.CreateParameter('@obuid',ftstring,pdInput,20,'');
              Parameters.CreateParameter('@Id',ftstring,pdInput,40,id);
              Parameters.CreateParameter('@Result',ftinteger,pdoutput,7,jzresult);
              Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
              Parameters.CreateParameter('@errormsg',ftstring,pdInputOutput,512,errormsg);
              try
                 for i:=0 to Parameters.count-1 do
                 begin
                   strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                 end;
//                 mainclass.writeerrorlog('��ʼ��֤:'+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
//                 mainclass.writeerrorlog('ʱ��'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                 ExecProc;
//                 mainclass.writeerrorlog('��֤��ɣ�'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                 i:=parameters.ParamByName('@Result').Value;
                 jzresult:=jzresult or i;
                 errormsg:='';
              except on e:exception do
              begin
                for i:=0 to Parameters.count-1 do
                begin
                    strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                end;
                mainclass.writeerrorlog('����У��ʧ��:'+e.message+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
              end;
              end;
            end;
            {����ETC���ݿ⿪ʼ��֤}

            Iresult:=0;
            strres:='';
            if not jycard(cardid,formatdatetime('yyyy-mm-dd hh:mm:ss',exdate),Iresult,strres)  then
            begin
              WriteLog('��֤ETC����Ч��ʧ��');
              exit;
            end;
            i:=Iresult;
            jzresult:=jzresult or i;
            errormsg:=errormsg+strres;
            writelog('ETC����Ч����֤���');

            with TOleDB(FOpDBWait.FDBObj).FAdqSproc do
            begin
                close;
                errorid:=-1;
                ProcedureName:='proc_jzjg';
                Parameters.Clear;
                Parameters.CreateParameter('@tollProvinceId',ftString,pdInput,20,tollProvinceId);
                Parameters.CreateParameter('@passId',ftstring,pdInput,50,passId);
                Parameters.CreateParameter('@MessageId',ftString,pdInput,20,'0');
                Parameters.CreateParameter('@Id',ftstring,pdInput,50,id);
                Parameters.CreateParameter('@trans_type',ftinteger,pdInput,7,6);    //�°汾�ϲ�����ڽ���
                Parameters.CreateParameter('@fee',ftinteger,pdInput,7,fee);    //���ڼ��˺Ͳ�ֵĽ��
                Parameters.CreateParameter('@Result',ftinteger,pdInput,7,jzresult);
                Parameters.CreateParameter('@strtable',ftstring,pdInput,20,'other');
                Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
                Parameters.CreateParameter('@errormsg',ftstring,pdInputoutput,512,errormsg);
                try
//                WriteLog('ִ�п�ʼ���ɼ��˽��');
                // mainclass.writeerrorlog('���ɼ��˽����ʼʱ��'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                ExecProc;
//                WriteLog('ִ�п�ʼ���ɼ��˽�����');
                //mainclass.writeerrorlog('���ɼ��˽������ʱ��'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                except on e:exception do
                begin
                    strtmp:='';
                    for i:=0 to Parameters.count-1 do
                    begin
                        strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                    end;
                    mainclass.writeerrorlog('����У��ʧ��:'+e.message+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
                end;
               end;
               writelog('���ڽ��׼�����ɣ�id='+ id);
            end;
        
            FOpDBWait.Query.next;   //�¸���ϸ
        end; //eof
        end; 
      end;
    end; //��δ������ϸ


   finally

   end;
 result:=true;
end;

function TSendData.jzmx(Messageid,tollProvinceId,IssuerId:String): Boolean;
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

    {*ETC����Ч��2016-02-05*}
    cardid,exdate,listcardtype: string;
    Iresult: Integer;
    strres: string;
begin
 result:=False;
 jzresult:=0;
 {��ѯ��ϸѭ������}
 try
   WriteLog('��ѯδ���˰���ϸ��ˮ');
   strtmp:= 'select * from  T_TransactionOriginal_other with (nolock) '
            +'where  Messageid='+ Messageid +' AND  tollProvinceId='+tollProvinceId+' and IssuerId='+IssuerId
            +' and ChargeState=0 ';

   if FOpDBWait.QuerySQL(strtmp) then
   begin
    if not FOpDBWait.Query.IsEmpty then
    begin
      with FOpDBWait.Query do
      begin
        FOpDBWait.Query.First;
        while not  FOpDBWait.Query.eof do
        begin
//            WriteLog('��ʼ��֤TAC');
            {jzresult:=0;
            Fillchar(fchecktac,SizeOf(Tchecktac),0);
            //����+���+�ն˺�+�������к�,ʱ��}
            fchecktac.hth:=RightStr(FieldByName('etccardid').asstring,16);
            fchecktac.money:=FieldByName('Fee').AsInteger;
            fchecktac.TerminalNo:=fieldbyname('terminalno').AsString;
            fchecktac.onlinesn:=fieldbyname('TerminalTransNo').AsString;
            fchecktac.CashDate:=formatdatetime('yyyymmdd',fieldbyname('exTime').asdatetime);
            fchecktac.Cashtime:=formatdatetime('hhmmss',fieldbyname('exTime').AsDateTime);
            fchecktac.Tac:=fieldbyname('tac').asstring;
           // ע�⣺���Բ��˼��ܻ������Σ�����ʱ���20160204
           //��֤Tac
         {  try
             if not checktac(fchecktac,mainclass.SJMJSERVERIP,mainclass.SJMJPORT,
               mac1,errormsg)  then
           except on e:exception do
           begin
             WriteErrorLog('TacУ��ʧ��'+e.Message);
           end;
           end;
           strtmp:=mainclass.arraytostr(mac1);
           if UpperCase(FieldByName('tac').AsString)<>strtmp then
           begin
             jzresult:=1;
             errormsg:='��ˮTAC��'+UpperCase(FieldByName('tac').AsString)+'���ܻ�TAC��'+strtmp;
             writelog('T_TransactionOriginal_other->TACУ�鲻��'+errormsg);
           end
           else  jzresult:=0;
           }
//            WriteLog('��֤TAC���');

           jzresult:=0;

           //ִ��������֤
           with TOleDB(FOpDBWait.FDBObj).FAdqSproc do
           begin
              close;
              errorid:=-1;
              //��֤ȡ�����ӷ������Ŀ���֤����Ϊ����ֱ����
              ProcedureName:='proc_checkjzjg';
              Parameters.Clear;
              Parameters.CreateParameter('@tollProvinceId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('tollProvinceId').AsString);
              Parameters.CreateParameter('@strcardno',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('etcCardId').AsString);
              Parameters.CreateParameter('@exDate',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('extime').AsString);
              Parameters.CreateParameter('@MessageId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('MessageId').AsString);
              Parameters.CreateParameter('@trans_type',ftinteger,pdInput,7,2);    //ETC ˢ��
              Parameters.CreateParameter('@vehicleType',ftinteger,pdInput,7,FOpDBWait.Query.fieldbyname('exvehicleType').AsInteger);    //����
              Parameters.CreateParameter('@obuid',ftstring,pdInput,20,'');
              Parameters.CreateParameter('@Id',ftstring,pdInput,40,FOpDBWait.Query.fieldbyname('Id').AsString);
//              Parameters.CreateParameter('@strtable',ftstring,pdInput,10,strtablename);
              Parameters.CreateParameter('@Result',ftinteger,pdoutput,7,jzresult);
              Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
              Parameters.CreateParameter('@errormsg',ftstring,pdInputOutput,512,errormsg);
              try
                 for i:=0 to Parameters.count-1 do
                 begin
                   strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                 end;
//                 mainclass.writeerrorlog('��ʼ��֤:'+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
                 //mainclass.writeerrorlog('ʱ��'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                 ExecProc;
//                 mainclass.writeerrorlog('��֤��ɣ�'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                 i:=parameters.ParamByName('@Result').Value;
                 jzresult:=jzresult or i;
                 errormsg:='';
              except on e:exception do
              begin
                for i:=0 to Parameters.count-1 do
                begin
                    strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                end;
                mainclass.writeerrorlog('����У��ʧ��:'+e.message+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
              end;
              end;
            end;
            {����ETC���ݿ⿪ʼ��֤}
            cardid:=FOpDBWait.Query.Fieldbyname('etccardid').asString;
            exdate:=formatdatetime('yyyy-mm-dd hh:mm:ss',fieldbyname('extime').asdatetime);
            Iresult:=0;
            strres:='';
            if not jycard(cardid,exdate,Iresult,strres)  then
            begin
              WriteLog('��֤ETC����Ч��ʧ��');
              exit;
            end;
            i:=Iresult;
            jzresult:=jzresult or i;
            errormsg:=errormsg+strres;
            writelog('ETC����Ч����֤���');

            with TOleDB(FOpDBWait.FDBObj).FAdqSproc do
            begin
                close;
                errorid:=-1;
                ProcedureName:='proc_jzjg';
                Parameters.Clear;
                Parameters.CreateParameter('@tollProvinceId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('tollProvinceId').AsString);
                Parameters.CreateParameter('@IssuerId',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('IssuerId').AsString);
                Parameters.CreateParameter('@MessageId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('MessageId').AsString);
                Parameters.CreateParameter('@Id',ftstring,pdInput,40,FOpDBWait.Query.fieldbyname('Id').AsString);
                Parameters.CreateParameter('@trans_type',ftinteger,pdInput,7,2);    //ETCˢ������
                Parameters.CreateParameter('@fee',ftinteger,pdInput,7,FOpDBWait.Query.fieldbyname('fee').AsInteger);    //���׽��
                Parameters.CreateParameter('@Result',ftinteger,pdInput,7,jzresult);
                Parameters.CreateParameter('@strtable',ftstring,pdInput,20,'other');
                Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
                Parameters.CreateParameter('@errormsg',ftstring,pdInputoutput,512,errormsg);
             try
//                WriteLog('ִ�п�ʼ���ɼ��˽��');
                // mainclass.writeerrorlog('���ɼ��˽����ʼʱ��'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                ExecProc;
//                WriteLog('ִ�п�ʼ���ɼ��˽�����');
                //mainclass.writeerrorlog('���ɼ��˽������ʱ��'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                except on e:exception do
                begin
                    strtmp:='';
                    for i:=0 to Parameters.count-1 do
                    begin
                        strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                    end;
                    mainclass.writeerrorlog('����У��ʧ��:'+e.message+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
                end;
               end;
             end;
            FOpDBWait.Query.next;
            //�¸���ϸ
        end; //eof
      end;
     writelog('У����ɰ��ţ�'+MESSAGEID);
    end; //��δ������ϸ

    begin
       strtmp:= 'update T_TransactionOriginalmain_other set ChargeState=1 '
            +'where  Messageid='+ Messageid +' AND  tollProvinceId='+tollProvinceId+' and IssuerId='+IssuerId
            +' and ChargeState=0 ';
     FOpDBWait.ExecSQL(strtmp) ;
     writelog('ETCˢ�����׼�����ɣ�Messageid='+ Messageid);
    end;
   end;
   finally

   end;
 result:=true;
end;

function TSendData.EXPjzmx(Messageid,tollProvinceId,IssuerId,jztable:String): Boolean;
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


    {*ETC����Ч��2016-02-05*}
    cardid,exdate,listcardtype: string;
    Iresult: Integer;
    strres: string;
begin
 result:=False;
 jzresult:=0;
 {��ѯ��ϸѭ������}
 try
//   WriteLog('��ѯδ���˰���ϸ��ˮ');
   strtmp:= 'select * from  '+jztable+'_Transaction_DOWN with (nolock)'
            +'where  Messageid='+ Messageid +' AND  tollProvinceId='+tollProvinceId+' and IssuerId='+IssuerId
            +' and ChargeState=0 ';

   if FOpDBWait.QuerySQL(strtmp) then
   begin
    if not FOpDBWait.Query.IsEmpty then
    begin
      with FOpDBWait.Query do
      begin
        FOpDBWait.Query.First;
        while not  FOpDBWait.Query.eof do
        begin
//            WriteLog('��ʼ��֤TAC');
            {jzresult:=0;
            Fillchar(fchecktac,SizeOf(Tchecktac),0);
            //����+���+�ն˺�+�������к�,ʱ��}
            fchecktac.hth:=RightStr(FieldByName('cardid').asstring,16);
            fchecktac.money:=FieldByName('Fee').AsInteger;
            fchecktac.TerminalNo:=fieldbyname('terminalno').AsString;
            fchecktac.onlinesn:=fieldbyname('TerminalTransNo').AsString;
            fchecktac.CashDate:=formatdatetime('yyyymmdd',fieldbyname('Date').asdatetime);
            fchecktac.Cashtime:=formatdatetime('hhmmss',fieldbyname('Time').AsDateTime);
            fchecktac.Tac:=fieldbyname('tac').asstring;
           // ע�⣺���Բ��˼��ܻ������Σ�����ʱ���20160204
           //��֤Tac

           if not checktac(fchecktac,mainclass.SJMJSERVERIP,mainclass.SJMJPORT,
             mac1,errormsg)  then
           begin
             writelog('ȡ��չTacֵʧ�ܣ�'+errormsg);
             Exit;
           end;
           strtmp:=mainclass.arraytostr(mac1);
           if UpperCase(FieldByName('tac').AsString)<>strtmp then
           begin
             jzresult:=1;
             errormsg:='TAC��չУ�鲻��';
             writelog('��չTACУ�鲻��');
           end
           else  jzresult:=0;
//            WriteLog('��֤��չTAC���');

//           jzresult:=0;

           //ִ��������֤
           with TOleDB(FOpDBWait.FDBObj).FAdqSproc do
           begin
              close;
              errorid:=-1;
              //��֤ȡ�����ӷ������Ŀ���֤����Ϊ����ֱ����
              ProcedureName:='proc_EXPcheckjzjg_nolj';
              Parameters.Clear;
              Parameters.CreateParameter('@tollProvinceId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('tollProvinceId').AsString);
              Parameters.CreateParameter('@IssuerId',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('IssuerId').AsString);
              Parameters.CreateParameter('@MessageId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('MessageId').AsString);
              Parameters.CreateParameter('@Id',ftstring,pdInput,40,FOpDBWait.Query.fieldbyname('Id').AsString);
              Parameters.CreateParameter('@strtable',ftstring,pdInput,10,jztable);
              Parameters.CreateParameter('@Result',ftinteger,pdoutput,7,jzresult);
              Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
              Parameters.CreateParameter('@errormsg',ftstring,pdInputOutput,512,errormsg);
              try
                 for i:=0 to Parameters.count-1 do
                 begin
                   strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                 end;
                 //mainclass.writeerrorlog('��ʼ��֤:'+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
                 //mainclass.writeerrorlog('ʱ��'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                 ExecProc;
                 //mainclass.writeerrorlog('��֤��ɣ�'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                 i:=parameters.ParamByName('@Result').Value;
                 jzresult:=jzresult or i;
                 errormsg:=parameters.ParamByName('@errormsg').Value;
              except on e:exception do
              begin
                for i:=0 to Parameters.count-1 do
                begin
                    strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                end;
                mainclass.writeerrorlog('������չУ��ʧ��:'+e.message+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
              end;
              end;
            end;
            {����ETC���ݿ⿪ʼ��֤}
            cardid:=FOpDBWait.Query.Fieldbyname('cardid').asString;
            exdate:=formatdatetime('yyyy-mm-dd hh:mm:ss',fieldbyname('date').asdatetime);
            Iresult:=0;
            strres:='';
            if not jycard(cardid,exdate,Iresult,strres)  then
            begin
              WriteLog('��֤��չETC����Ч��ʧ��');
              exit;
            end;
            i:=Iresult;
            jzresult:=jzresult or i;
            errormsg:=errormsg+strres;
//            writelog('ETC����չ��֤���');

            with TOleDB(FOpDBWait.FDBObj).FAdqSproc do
            begin
                close;
                errorid:=-1;
                ProcedureName:='proc_EXPjzjg';
                Parameters.Clear;
                Parameters.CreateParameter('@tollProvinceId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('tollProvinceId').AsString);
                Parameters.CreateParameter('@IssuerId',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('IssuerId').AsString);
                Parameters.CreateParameter('@MessageId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('MessageId').AsString);
                Parameters.CreateParameter('@Id',ftstring,pdInput,40,FOpDBWait.Query.fieldbyname('Id').AsString);
                Parameters.CreateParameter('@Result',ftinteger,pdInput,7,jzresult);
                Parameters.CreateParameter('@strtable',ftstring,pdInput,10,jztable);
                Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
                Parameters.CreateParameter('@errormsg',ftstring,pdInput,512,errormsg);
             try
                //WriteLog('ִ�п�ʼ���ɼ��˽��');
                // mainclass.writeerrorlog('���ɼ��˽����ʼʱ��'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                ExecProc;
                //WriteLog('ִ�п�ʼ���ɼ��˽�����');
                //mainclass.writeerrorlog('���ɼ��˽������ʱ��'+formatDateTime('yyyy-mm-dd hh:mm:ss',now));
                except on e:exception do
                begin
                    strtmp:='';
                    for i:=0 to Parameters.count-1 do
                    begin
                        strtmp:=strtmp+string(Parameters[i].Value)+''',''';
                    end;
                    mainclass.writeerrorlog('������չУ��ʧ��:'+e.message+' sql:exec '+ProcedureName+''''+copy(strtmp,1,Length(strtmp)-2));
                end;
               end;
             end;
            FOpDBWait.Query.next;
            //�¸���ϸ
        end; //eof
      end;
//     writelog('У����չ��ɰ��ţ�'+MESSAGEID);
    end //��δ������ϸ
    else
    begin
       strtmp:= 'update '+jztable+'_DOWN set ChargeState=3 '
            +'where  Messageid='+ Messageid +' AND  tollProvinceId='+tollProvinceId+' and IssuerId='+IssuerId
            +' and ChargeState=0 ';
     FOpDBWait.ExecSQL(strtmp) ;
     writelog('��չ������ϸ����Ϊ�գ�Messageid='+ Messageid +' AND  tollProvinceId='+tollProvinceId+' and IssuerId='+IssuerId);
    end;
   end
   else
   begin
     writelog('ִ����չ��ѯ��ϸʧ��!');
   end;
   finally

   end;
 result:=true;
end;


function TSendData.pkgtac(FMessageID:String;FtollProvinceId:String;FIssuerId:String;trans_type:Integer): Boolean;
var
  i,errorid:integer;
  errormsg:string;
  strtmp,strtmp1:string;
  strtable:string;
begin
  result:=False;
  try

                if (trans_type=1)then
                begin
                   strtable:='tac';
                end else if(trans_type=3)then
                begin
                   strtable:='obu';
                end else if (trans_type=4)then
                begin
                   strtable:='pic';
                end else if (trans_type=5)then
                begin
                   strtable:='sim';
                end;
              with  TOleDB(FOpDBWait.FDBObj).FAdqSproc  do
              begin
                errorid:=-1;
                Close;
//                WriteLog('��ʼ���ɼ��˽��'+FMessageID);
                ProcedureName:='proc_sendjzjg';
                Parameters.Clear;
                Parameters.CreateParameter('@MessageId',ftString,pdInput,20,FMessageID);
                Parameters.CreateParameter('@tollProvinceId',ftString,pdInput,20,FtollProvinceId);
                Parameters.CreateParameter('@IssuerId',ftstring,pdInput,20,FIssuerId);
                Parameters.CreateParameter('@strtable',ftstring,pdInput,10,strtable);
                Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
                Parameters.CreateParameter('@errormsg',ftstring,pdoutput,2,errormsg);
                try
                 TOleDB(FOpDBWait.FDBObj).FAdqSproc.ExecProc;

                 WriteLog('proc_sendjzjg���FMessageID:'+FMessageID);
                 except on e:exception do
                  begin
                    for i:=0 to TOleDB(FOpDBWait.FDBObj).FAdqSproc.Parameters.count-1 do
                    begin
                        strtmp1:=strtmp1+string(TOleDB(FOpDBWait.FDBObj).FAdqSproc.Parameters[i].Value)+''',''';
                    end;
                    mainclass.writeerrorlog('����У��ʧ��:'+e.message+' sql:exec '+TOleDB(FOpDBWait.FDBObj).FAdqSproc.ProcedureName+''''+copy(strtmp1,1,Length(strtmp1)-2));
                  end;
                end;

              end;

  finally
  end;

  result:=True;
end;

function TSendData.pkg(HeaderMessageid:String): Boolean;
var
  i,errorid:integer;
  errormsg:string;
  strtmp,strtmp1:string;
  strtable:string;
begin
  result:=False;
  try
//    WriteLog('��ѯԭʼ����');
    strtmp:=  'select * from  T_TransactionOriginal_other with (nolock)'
            +'where  Messageid='+ Messageid +' AND  tollProvinceId='+tollProvinceId+' and IssuerId='+IssuerId
            +' and ChargeState<>0';
    if FOpDBWait.QuerySQL(strtmp) then
    begin
      if not FOpDBWait.Query.IsEmpty then
      begin
        FOpDBWait.Query. First;
        with  TOleDB(FOpDBWait.FDBObj).FAdqSproc  do
        begin
          errorid:=-1;
          Close;
          //WriteLog('��ʼ���ɼ��˽��');
          ProcedureName:='proc_sendjzjg';
          Parameters.Clear;
          Parameters.CreateParameter('@MessageId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('MessageId').AsString);
          Parameters.CreateParameter('@tollProvinceId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('tollProvinceId').AsString);
          Parameters.CreateParameter('@IssuerId',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('IssuerId').AsString);
          Parameters.CreateParameter('@strtable',ftstring,pdInput,10,'other');
          Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
          Parameters.CreateParameter('@errormsg',ftstring,pdoutput,2,errormsg);
          try
           TOleDB(FOpDBWait.FDBObj).FAdqSproc.ExecProc;
           //WriteLog('ִ��proc_sendjzjg���ɼ��˽�����');
           except on e:exception do
           begin
              for i:=0 to TOleDB(FOpDBWait.FDBObj).FAdqSproc.Parameters.count-1 do
              begin
                  strtmp1:=strtmp1+string(TOleDB(FOpDBWait.FDBObj).FAdqSproc.Parameters[i].Value)+''',''';
              end;
              mainclass.writeerrorlog('����У��ʧ��:'+e.message+' sql:exec '+TOleDB(FOpDBWait.FDBObj).FAdqSproc.ProcedureName+''''+copy(strtmp1,1,Length(strtmp1)-2));
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

function TSendData.EXpkg(HeaderMessageid,jztable:String): Boolean;
var
  i,errorid:integer;
  errormsg:string;
  strtmp,strtmp1:string;
begin
  result:=False;
  try
//    WriteLog('��ѯͣ������չԭʼ����');
    strtmp:=  'select * from  '+jztable+'_Transaction_DOWN with (nolock)'
            +'where  Messageid='+ Messageid +' AND  tollProvinceId='+tollProvinceId+' and IssuerId='+IssuerId
            +' and ChargeState<>0';
    if FOpDBWait.QuerySQL(strtmp) then
    begin
      if not FOpDBWait.Query.IsEmpty then
      begin
        FOpDBWait.Query. First;
        with  TOleDB(FOpDBWait.FDBObj).FAdqSproc  do
        begin
          errorid:=-1;
          Close;
          //WriteLog('��ʼ����ͣ�������˽��');
          ProcedureName:='proc_sendjzjg';
          Parameters.Clear;
          Parameters.CreateParameter('@MessageId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('MessageId').AsString);
          Parameters.CreateParameter('@tollProvinceId',ftString,pdInput,20,FOpDBWait.Query.fieldbyname('tollProvinceId').AsString);
          Parameters.CreateParameter('@IssuerId',ftstring,pdInput,20,FOpDBWait.Query.fieldbyname('IssuerId').AsString);
          Parameters.CreateParameter('@strtable',ftstring,pdInput,10,jztable);
          Parameters.CreateParameter('@errorno',ftstring,pdoutput,10,errorid);
          Parameters.CreateParameter('@errormsg',ftstring,pdoutput,2,errormsg);
          try
           TOleDB(FOpDBWait.FDBObj).FAdqSproc.ExecProc;
           //WriteLog('ִ��proc_sendjzjg����ͣ�������˽�����');
           except on e:exception do
           begin
              for i:=0 to TOleDB(FOpDBWait.FDBObj).FAdqSproc.Parameters.count-1 do
              begin
                  strtmp1:=strtmp1+string(TOleDB(FOpDBWait.FDBObj).FAdqSproc.Parameters[i].Value)+''',''';
              end;
              mainclass.writeerrorlog('ͣ������չ����У��ʧ��:'+e.message+' sql:exec '+TOleDB(FOpDBWait.FDBObj).FAdqSproc.ProcedureName+''''+copy(strtmp1,1,Length(strtmp1)-2));
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

  //Ŀ¼�����Ե��ж�
  if not DirectoryExists(tmpName) then
  begin
    if IOResult = 0 then
      MkDir(tmpName);
  end;
  //Ŀ¼����,�ļ����������½�,�ļ����������.
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
