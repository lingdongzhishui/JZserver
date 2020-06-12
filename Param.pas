unit Param;

interface

uses

   Windows, SysUtils, Classes, IniFiles,WinSock,SyncObjs,ADODB,ActiveX;
type

  TNodeInfo = class

    private

    FTables: TStringList;
    FNodeIP: string;
    FQueue: string;
    FTlqType: Byte;
    FAreaNo: Word;
    FRegionNo: Word;
    FRoadNo: Word;
    FStationNo: Integer;
    FNodeType : Byte;
    FSubStationno : Integer;
    FSubStationList : TStringList;
    FNodeName: string;
    function GetTables(Index: Integer): string;
    function GettbSource(Index: Integer): string;
    function GettbDest(Index: Integer): string;
    procedure PutTables(Index: Integer; Value: string);
    function GetCount: Integer;
    function GetNodeIP: string;
    function GetNodeName: string;
    //procedure SetSubStationList(value : string);
  public
    constructor Create;
    destructor  Destroy; override;
    procedure AddTable(Value: string);
    property Strings[Index: Integer]: string read GetTables write PutTables;
    property tbSource[Index: Integer]: string read GettbSource;
    property tbDest[Index: Integer]: string read GettbDest;
  published
    property NodeName:string read GetNodeName write FNodeName;
    property NodeIP: string read GetNodeIP write FNodeIP;
    property Queue: string read FQueue write FQueue;
    property TlqType:Byte read FTlqType write FTlqType;
    property Count: Integer read GetCount;
    property AreaNo: Word read FAreaNo write FAreaNo;
    property RegionNo: Word read FRegionNo write FRegionNo;
    property RoadNo: Word read FRoadNo write FRoadNo;
    property NodeType : Byte read FNodeType write FNodeType;
    property StationNo: Integer read FStationNo write FStationNO;
    property SubStationList: TStringList read FSubStationList write FSubStationList;
    property SubStationNo: Integer read FSubStationno write FSubStationno;
  end;

type

  TWorkParam = class
  private
    FDBName: string;
    FDBIP: string;
    FDBType: Byte;
    FNodeList: TList;
    FRvcPath: string;
    FSenPath: string;
    FLocalIP: string;
    FExePath: string;
    FDataQueue: string;
    FACKQueue : string;
    FWorkMod: Byte;
    FAreaNo: Word;
    FRegionNo: Word;
    FRoadNo: Word;
    FStationNo: Integer;
    FMessageID: Integer;
    FWaitTime: Integer;
    FIsLog: Integer;
    FIsBackup: Integer;
    FIsZip   : Integer;
    FGetThreadCount : Integer;
    FMonSvr : string;
    FMonPort : Integer;
    FDBUser : string;
    FDBPassword : string;
    FPackCount : Integer;
    //FSendMessageID : Integer;
    //FResponseMessageID : Integer;
    //FCSGetResponseMessageID : TCriticalSection;
    mMessage:TStringlist ;
    FSxOperatorId: String;
    FSxIssuerId: String;
    FSxServiceProviderId: string;
    FAreaOperatorId: String;
    FIsSign: Integer;
    FSignport: Integer;
    FSignhost: String;
    FETCDBName: string;
    FETCDBPassword: string;
    FETCDBIP: string;
    FETCDBUser: string;
    procedure ClearNodeList;
    function GetNode(Index: Integer): TNodeInfo;
    function GetCount: Integer;
    function GetLocalIP: string;
    procedure SetMessageID(const Value: Integer);
    //function GetResponseMsgID : Integer;
  public
  //
     CenterSend:Byte ;    //���ķ��͹���
     LogXHCS :TCriticalSection ;
     LogXH :integer;
     statLog:Byte ;
     StatOKCount,StatNoCount:Integer ;
     SleepTimeEx:integer;
     FSleepTime: Integer;//��Ϣ�ش�ʱ����
     FTransNumber:Integer;//��Ϣ�������

    constructor Create;
    destructor  Destroy; override;
    procedure   GetParam(FileName: string);
    property    Nodes[Index: Integer]: TNodeInfo read GetNode;

    procedure AddStatLog(ALog:string) ;
    procedure SaveLog;
    procedure AddOkCount;
    procedure AddNoCount;
  published
    //ETCDB
    property ETCDBName : string read FETCDBName write FETCDBName;
    property ETCDBIP   : string read FETCDBIP write FETCDBIP;
    property ETCDBUser : string read FETCDBUser;
    property ETCDBPassword : string read FETCDBPassword;


    property DBName: string read FDBName write FDBName;
    property DBIP  :   string read FDBIP write FDBIP;
    property DBType: Byte read FDBType write FDBType;
    property Count : Integer read GetCount;
    property RvcPath: string read FRvcPath;
    property LocalIP: string read GetLocalIP;
    property ExePath: string read FExePath;
    property DataQueue: string read FDataQueue;
    property ACKQueue: string read FACKQueue;
    property Queue: string read FACKQueue;
    property WorkMod: Byte read FWorkMod;
    property AreaNo: Word read FAreaNo;
    property RegionNo: Word read FRegionNo;
    property RoadNo: Word read FRoadNo;
    property StationNo: Integer read FStationNo;
    property MessageID: Integer read FMessageID write SetMessageID;
    property WaitTime: Integer read FWaitTime;
    property SleepTime: Integer read FSleepTime;
    property PackCount : Integer read FPackCount;
    property SenPath: string read FSenPath;

    property IsLog: Integer read FIsLog;
    property IsBackup: Integer read FIsBackup;
    property Iszip: Integer read FIsZip;
    {ǩ��������}
    property IsSign:Integer read FIsSign;//2014-10-21 ����ǩ������
    property Signhost:String read FSignhost;//ǩ������ַ
    property Signport:Integer read FSignport;//ǩ���� �˿�

    property GetThreadCount : Integer read FGetThreadCount;
    property MonSvr : string read FMonSvr;
    property MonPort : Integer read FMonPort;
    property DBUser : string read FDBUser;
    property DBPassword : string read FDBPassword;
    //ɽ���շѷ�
    property LocalSxServiceProviderId:string read FSxServiceProviderId;
    //ɽ�����з�
    property LocalSxIssuerId:String read FSxIssuerId;
    //ɽ����ַ�
    property LocalSxOperatorId:String read FSxOperatorId;
    //������ַ�
    property AreaOperatorId:String read FAreaOperatorId;
    
    //property ResponseMessageID : Integer read GetResponseMsgID;
  end;

  procedure Decrypt(const MiWen: Pchar; const MingWen: Pchar); StdCall; External 'Cryptogram.dll';

  function  GetACKQueName(const SrcNode : string) : string;

implementation

uses Uwork;

//��ȡ������Ϣ��������

function GetACKQueName(const SrcNode : string) : string;
var
  AckFileName : string;
  fAck : TIniFile;
begin
  AckFileName :='.\AckQueue.ini';
  Result := '';
  if FileExists(AckFileName) then
  begin
    fAck := TIniFile.Create(AckFileName);
    try
      Result := fAck.ReadString('',SrcNode,'');
    finally
      fAck.Free;
    end;
  end;
end;
{ TNodeInfo}

procedure TNodeInfo.AddTable(Value: string);
begin
  FTables.Add(Value);
end;

constructor TNodeInfo.Create;
begin
  FTables := TStringList.Create;
  FSubStationList := TStringList.Create;
  FSubStationno := 0;
  FSubStationList.Clear;
end;

destructor TNodeInfo.Destroy;
begin
  FTables.Free;
  FSubStationList.Free;
  inherited;
end;

function TNodeInfo.GetCount: Integer;
begin
  Result := FTables.Count;
end;

function TNodeInfo.GetNodeIP: string;
var
  inetIP: Integer;
  s : string;
begin
  Result := '';
  if Trim(FNodeIP) = '' then
    Exit;
  try
    inetIP := inet_addr(PChar(FNodeIP));
    s := IntToHex(inetIP, 8);
    Result := Copy(s,7,2)+ Copy(s,5,2) + Copy(s,3,2) + Copy(s,1,2);
  except
  end;
end;

function TNodeInfo.GetNodeName: string;
begin
  Result := FNodeName;
end;

function TNodeInfo.GetTables(Index: Integer): string;
begin
  if (Index<0) or (Index>=FTables.Count) then
  begin
    raise EStringListError.Create('List index out of bounds (' + IntToStr(Index)+')');
    Exit;
  end;
  Result := FTables.Strings[Index];
end;

function TNodeInfo.GettbDest(Index: Integer): string;
var
  s: string;
begin
  if (Index<0) or (Index>=FTables.Count) then
  begin
    raise EStringListError.Create('List index out of bounds (' + IntToStr(Index)+')');
    Exit;
  end;
  s := FTables.Names[Index];
  Result := FTables.Values[s];
//  Result := FTables.ValueFromIndex[Index];
end;

function TNodeInfo.GettbSource(Index: Integer): string;
begin
  if (Index<0) or (Index>=FTables.Count) then
  begin
    raise EStringListError.Create('List index out of bounds (' + IntToStr(Index)+')');
    Exit;
  end;
  Result := FTables.Names[Index];
end;

procedure TNodeInfo.PutTables(Index: Integer; Value: string);
begin
  if (Index<0) or (Index>=FTables.Count) then
  begin
    raise EStringListError.Create('List index out of bounds (' + IntToStr(Index)+')');
    Exit;
  end;
  FTables.Strings[Index] := Value;
end;

{ TWorkParam }

procedure TWorkParam.AddNoCount;
begin
try
  LogXHCS.Acquire ;
  try
  StatNoCount   :=  StatNoCount  + 1 ;
  finally
   LogXHCS.Release ;
  end;
except
end;
end;

procedure TWorkParam.AddOkCount;
begin
try
  LogXHCS.Acquire ;
  try
  StatOKCount   :=  StatOKCount  + 1 ;
  finally
   LogXHCS.Release ;
  end;
except
end;

end;

procedure TWorkParam.AddStatLog(ALog: string);
begin
 if statLog = 0 then Exit ;
try
  LogXHCS.Acquire ;
  try
   if mMessage.Count > 20 then
   begin
      SaveLog ;
      mMessage.Clear ;
   end;

  LogXH   :=  LogXH  + 1 ;
   mMessage.Add(intToStr(LogXH)+'.'+ALog);
  finally
   LogXHCS.Release ;
  end;
except
end;  

end;

procedure TWorkParam.ClearNodeList;
begin
  while FNodeList.Count>0 do
  begin
    TNodeInfo(FNodeList.Items[0]).Free;
    FNodeList.Delete(0);
  end;
end;

constructor TWorkParam.Create;
begin
  FNodeList := TList.Create;
  FExePath := ExtractFilePath(ParamStr(0));
  mMessage:=TStringlist.Create ;
  LogXHCS := TCriticalSection.Create ;
  LogXH := 0 ;
  StatOKCount :=0 ;
  StatNoCount := 0 ;
end;


destructor TWorkParam.Destroy;
begin
  ClearNodeList;
  FNodeList.Free;
  FreeAndNil(mMessage);
  FreeAndNil(LogXHCS);
  //SetMessageID(FMessageID);
  inherited;
end;

function TWorkParam.GetCount: Integer;
begin
  Result := FNodeList.Count;
end;

function TWorkParam.GetLocalIP: string;
var
  inetIP: Integer;
  s : string;
begin
  Result := '';
  if Trim(FLocalIP) = '' then
    Exit;
  try
    inetIP := inet_addr(PChar(FLocalIP));
    s := IntToHex(inetIP, 8);
    Result := Copy(s,7,2)+ Copy(s,5,2) + Copy(s,3,2) + Copy(s,1,2);
  except
  end;
end;

function TWorkParam.GetNode(Index: Integer): TNodeInfo;
begin
  if (Index<0) or (Index>=FNodeList.Count) then
  begin
    raise EListError.Create('List index out of bounds (' + IntToStr(Index)+')');
    Exit;
  end;
  Result := TNodeInfo(FNodeList.Items[Index]);
end;

procedure TWorkParam.GetParam(FileName: string);
var
  f: TIniFile;
  s, s1, s2,sMiwen: string;
  tmpList, tmpList1: TStringList;
  PUserName, PPassword: PChar;
  i, j: Integer;
  Node: TNodeInfo;
  tmpQry : TADOQuery;
begin
  CoInitialize(nil);
  tmpList  := TStringList.Create;
  tmpList1 := TStringList.Create;
  f := TIniFile.Create(FileName);
  PUserName := StrAlloc(16);
  PPassword := StrAlloc(16);

  FETCDBName := f.ReadString('DataBase', 'ETC������', 'dbcenter');
  FETCDBIP   := f.ReadString('DataBase', 'ETC���ݿ�IP', '10.14.161.2');
  FETCDBUser := f.ReadString('DataBase', 'ETC�û���', 'sa');
  FETCDBPassword :=f.ReadString('DataBase', 'ETC����', 'thunis');

  FDBName := f.ReadString('DataBase', '���ݿ�����', '');
  FDBIP := f.ReadString('DataBase', '���ݿ�IP', '');
  sMiwen := f.ReadString('DataBase','�û���','sa');
  Decrypt(PChar(sMiwen),PUserName);
  FDBUser := string(PUserName);
  sMiwen := f.ReadString('DataBase','����','thunis');
  Decrypt(PChar(sMiwen),PPassword);
  FDBPassword := string(PPassword);
  s := UpperCase(f.ReadString('DataBase', '���ݿ�����', 'MSSQL'));
  if s='MSSQL' then
    FDBType := 3;
  if s='ORACLE' then
    FDBType := 2;
  if s='DB2' then
    FDBType := 1;

  mainclass.SJMJSERVERIP:=f.ReadString('JMJ','serverip','10.14.161.11');
  mainclass.SJMJPORT:=f.ReadString('JMJ','port','8');
  mainclass.bflagworklog:=f.ReadBool('NodeInformation','����������־',true);
  mainclass.bflagdebuglog:=f.ReadBool('NodeInformation','����������־',true);
  mainclass.bflagerrorlog:=f.ReadBool('NodeInformation','����������־',true);


  FRvcPath  := f.ReadString('Option', '�����ļ�Ŀ¼', '');
  FLocalIP  := f.ReadString('Option', '����IP', '127.0.0.1');
  //���ն���
  FDataQueue := f.ReadString('Option', '���ݶ�������', '');
  FACKQueue := f.ReadString('Option', '������������', '');
  FWorkMod := f.ReadInteger('Option', '����ģʽ', 1);
  FAreaNo := f.ReadInteger('Option', 'ʡ���ı��', 1);
  FRegionNo := f.ReadInteger('Option', 'Ƭ�����', 0);
  FRoadNo := f.ReadInteger('Option', '·�α��', 0);
  FStationNo := f.ReadInteger('Option', '���', 0);
  FMessageID := f.ReadInteger('Option', '��Ϣ���', 1);

  FSleepTime := f.ReadInteger('Option', '��Ϣ�ط�ʱ����', 10);
  FTransNumber:= f.ReadInteger('Option', '��Ϣ�ط�����', 3);

  SleepTimeEx := f.ReadInteger('Option', 'traninterval', 1);

  FWaitTime := f.ReadInteger('Option', 'Ӧ��ʱʱ��', 5);
  FSenPath  := f.ReadString('Option', '�����ļ�Ŀ¼', '');
  FIsLog    := f.ReadInteger('Option', '�Ƿ�д��־', 0);
  FIsBackup := f.ReadInteger('Option', '�Ƿ񱸷�', 0);
  FIsZip    := f.ReadInteger('Option', '�Ƿ�ѹ��', 1);

  FIsSign   := f.ReadInteger('Option', '�Ƿ�ǩ��', 0);//2014-10-21
  FSignhost := f.ReadString('Option', 'ǩ����ַ', '10.14.6.4');//ǩ������ַ
  FSignport:=f.ReadInteger('Option', 'ǩ���˿�', 20001);//ǩ���� �˿�

  FGetThreadCount := f.ReadInteger('Option', '��ȡ�߳���', 0);
  FMonSvr := f.ReadString('Option','���IP','127.0.0.1');
  FMonPort := f.ReadInteger('Option','��ض˿�',9090);
  FPackCount := f.ReadInteger('Option','����¼��',1000);                        

  //cd add 2011-6-9 ���ӿ������ķ���
  CenterSend := f.ReadInteger('Option','���ķ���',1);
  statLog := f.ReadInteger('Option','ͳ����־',0);
  //f.WriteInteger('Option', '��Ϣ���1', 1);
  //FSendMessageID := f.ReadInteger('Option','������ϢID',0);
  //FResponseMessageID :=
  FSxServiceProviderId:=f.ReadString('LocalInfo','ɽ����·�շѷ�','');
  //ɽ�����з�
  FSxIssuerId:=f.ReadString('LocalInfo','ɽ�����з�','');
  //ɽ����ַ�
  FSxOperatorId :=f.ReadString('LocalInfo','ɽ����ַ�','');
  //������ַ�
  FAreaOperatorId:=f.ReadString('areaInfo','������ַ�','9999999901020001');

  f.ReadSections(tmpList);
  for i:=0 to tmpList.Count-1 do
  begin
    s := UpperCase(tmpList.Strings[i]);
    if Pos('�ڵ�', s)>0 then
    begin
      Node := TNodeInfo.Create;
      tmpList1.Clear;
      f.ReadSectionValues(s, tmpList1);

      for j:=0 to tmpList1.Count-1 do
      begin
        s1 := tmpList1.Names[j];
        if s1='�ڵ�IP' then
          Node.NodeIP := tmpList1.Values[s1];
        if s1='�ڵ�����' then
          Node.NodeType := StrToIntDef(tmpList1.Values[s1], 0);
        if s1='�ڵ�����' then
          Node.NodeName:=tmpList1.Values[s1];
        if s1='���Ͷ�������' then
          Node.Queue := tmpList1.Values[s1];
        if s1='��������' then
          Node.TlqType := StrToIntDef(tmpList1.Values[s1],0);
     end;
      FNodeList.Add(Node);
    end;
  end;
  StrDispose(PUserName);
  StrDispose(PPassword);
  f.Free;
  tmpList.Free;
  tmpList1.Free;
  CoUnInitialize;
end;


procedure TWorkParam.SaveLog;
var ADir:string;
    AFileName,ALogFileName:string;
    F:TextFile ;
    AString:string;
    HasError:Integer;
begin
     if mMessage.Count = 0 then Exit ;
     mMessage.Add('���ɹ���'+inttostr(self.StatOKCount) + '��ʧ�ܣ�'+inttostr(self.StatNoCount))  ;
      HasError := 0 ;
       AString := mMessage.Text ;
       if  AString = '' then Exit ;
      //�������ڣ��������������ݣ��Զ�����Ŀ¼
      ADir := ExePath+
       '\statLog\'+FormatDateTime('yyyymmdd',Now) ;
       //���Ŀ¼�Ƿ����
       if not DirectoryExists(ADir) then
        begin
           ForceDirectories(ADir);
        end;
      AFileName := ADir+'\'+ FormatDateTime('yyyymmddhh',Now)+'.txt' ;

      System.AssignFile(F,AFileName);
      try
        try
      IF not FileExists(AFileName) then
       begin
         system.Rewrite(F);
         System.Writeln(F,'ͳ����־�ļ���') ;
       end;
       System.Append(F);
       System.Writeln(F,AString);
       Flush(F);  { ensures that the text was actually written to file }
       except
         HasError := 1 ;
       end;
      finally
       CloseFile(F);
       end;
 try
     if HasError = 1 then
      begin
             ALogFileName := ADir+'\'+ FormatDateTime('yyyy-mm-dd-hh-mm-ss',now) + '��־Error.txt' ;
             mMessage.SaveToFile(ALogFileName);
      end;       
 except

 end;

end;

procedure TWorkParam.SetMessageID(const Value: Integer);
var
  f: TIniFile;
  s: string;
begin
  s := ExtractFilePath(ParamStr(0)) + 'tlqServer.ini';;
  f := TIniFile.Create(s);
  f.WriteInteger('Option', '��Ϣ���', Value);
  f.Free;
  FMessageID := Value;
end;

end.
