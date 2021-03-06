unit Uwork;

interface

uses
  Windows, Classes, SysUtils, IniFiles,SyncObjs,IdHashMessageDigest,DCPcrypt2, DCPblockciphers, DCPdes,ADODB;

type
   tmainclass = class(TComponent)
   public
    LogXHCS :TCriticalSection ;
    bdatabaseconnect:boolean;
    errorlist:tstringlist;
    nodeid:string;
    defaultkey:string;
    NetWorkID:string;
    TerminalID:string;
    bankid:string;
    bflagerrorlog,bflagdebuglog,bflagworklog:Boolean;
    SJMJSERVERIP,SJMJPORT:string;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ByteToHex(Src: Byte): String;
    function inttobigint(i_value:integer):integer;
    procedure WriteLog(Str: String);
    procedure WriteerrorLog(Str: String);
    function hextodec(value:string):string;
    procedure strtobyte(var aa:array of Byte;str:string;itype:Byte);
    procedure strdectobyte(var aa:array of Byte;str:string;itype:Byte);overload;
    function bytetostr(aa:array of Byte):string;
    function randstr(count:byte):string;
    function getmd5(strfile:string):string;overload;
    function getmd5(strfile:TStream):string;overload;
    function getfilemd5(strfile:string):string;
    function Encryptbcb(var key:array of byte;InData:array of byte; var OutData:array of byte):Boolean;
    function Decryptbcb(var key:array of byte;InData:array of byte; var OutData:array of byte):Boolean;
    function dbuftobuf(var indata:array of Byte ;var outdata:array of byte;index:integer):boolean;
    function arraytostr(arr:array of byte):string;
    function arraytostr1(arr:array of byte):string;
    function padl(mystr:string;mycount:integer;mychar:pchar):string;  //左补指定符到指定长度
    function padr(mystr:string;mycount:integer;mychar:pchar):string;  //左补指定符到指定长度
    function yxsj(str:string):string;
    function opendataset(qry:tadoquery;sqlstr:string):Boolean;
    function errorname(errorcode:string):string;
    function BytestoHexString(ABytes: array of byte; len: Integer): AnsiString;
  end;

  var
  mainclass:tmainclass;

  implementation
  function tmainclass.ByteToHex(Src: Byte): String;
  begin
    SetLength(Result, 2);
    asm
    MOV         EDI, [Result]
    MOV         EDI, [EDI]
    MOV         AL, Src
    MOV         AH, AL          // Save to AH
    SHR         AL, 4           // Output High 4 Bits
    ADD         AL, '0'
    CMP         AL, '9'
    JBE         @@OutCharLo
    ADD         AL, 'A'-'9'-1
    @@OutCharLo:
    AND         AH, $f
    ADD         AH, '0'
    CMP         AH, '9'
    JBE         @@OutChar
    ADD         AH, 'A'-'9'-1
    @@OutChar:
    STOSW
  end;
end;
constructor tmainclass.Create(AOwner: TComponent);
begin
    inherited;
    LogXHCS:=TCriticalSection.Create;
    errorlist:=Tstringlist.Create;
end;

destructor tmainclass.Destroy;
begin
   LogXHCS.Free;
   errorlist.Free;
  inherited;
end;

function tmainclass.inttobigint(i_value:Integer):integer;
var
I,strLength : Integer;  arr:Array of char;
    str:string;
    tmpstr:string;
begin
    str:=IntToHex(i_value,16);
    str:=Copy(str,9,8);
    for i:=4 downto 1 do
    begin
        tmpstr:=tmpstr+copy(str,i*2-1,2);
    end;
    str:=tmpstr;
    Result:=StrToInt(hextodec(str));

end;
Function tmainclass.HexToDec(Value:string):string;
CONST HEX : ARRAY['A'..'F'] OF INTEGER =
(10,11,12,13,14,15);
VAR
  str:String;
  i,i_value : integer;
BEGIN
  i_value:=0;
  str:=value;
  FOR i := 1 TO Length(str) DO
    IF str[i]<'A' THEN
    i_value:=i_value* 16 + ORD(str[i])-48
  ELSE
    I_value:=i_value * 16 + HEX[str[i]];

  Result := IntToStr(i_value);

end;

procedure tmainclass.WriteerrorLog(Str: String);
var
  tmpStr,
  tmpName: String;
  SystemTime: TSystemTime;
  fsm       : TextFile;
begin
    if not bflagerrorlog then exit;
    LogXHCS.Acquire;
    try
  if Str='' then Exit;
  tmpName := ExtractFilePath(ParamStr(0))+'errlog\';   
  if not DirectoryExists(tmpName) then
  begin
    if IOResult = 0 then
      MkDir(tmpName);
  end;

  if DirectoryExists(tmpName) then
  begin
    GetLocalTime(SystemTime);
    with SystemTime do
      tmpName := tmpName + Format('%.4d%.2d%.2d',[wYear,wMonth,wDay]);

    with SystemTime do
      tmpStr := Format('%.2d:%.2d:%.2d_%.3d   ',[wHour, wMinute, wSecond, wMilliSeconds]);
    tmpStr := tmpStr + Str;
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
  finally
       LogXHCS.Release;
  end;
end;

procedure tmainclass.WriteLog(Str: String);
var
  tmpStr,
  tmpName: String;
  SystemTime: TSystemTime;
  fsm       : TextFile;
begin
    if not bflagworklog then exit;
  if Str='' then Exit;
  tmpName := ExtractFilePath(ParamStr(0))+'worklog\';
  if not DirectoryExists(tmpName) then
  begin
    if IOResult = 0 then
      MkDir(tmpName);
  end;
  if DirectoryExists(tmpName) then
  begin
    GetLocalTime(SystemTime);
    with SystemTime do
      tmpName := tmpName + Format('%.4d%.2d%.2d%.2d',[wYear,wMonth,wDay,wHour]);

    with SystemTime do
      tmpStr := Format('%.2d:%.2d:%.2d_%.3d   ',[wHour, wMinute, wSecond, wMilliSeconds]);
    tmpStr := tmpStr + Str;
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

procedure tmainclass.strtobyte(var aa: array of Byte; str: string;itype:byte);
var
    i,icount:integer;
    b1:string;
begin
    icount:=High(aa);
    for i:=0 to icount do
    begin
        b1:=Copy(str,i*itype+1,itype);
        if b1<>'' then
            aa[i]:=StrToInt((b1))
        else
            aa[i]:=0;
    end;
end;

function tmainclass.randstr(count: byte): string;
var
    i,i_list:integer;
begin
    result:='';
    for i:=1 to count do
    begin
        i_list:=1+random(9);
        result:=result+copy(inttostr(i_list),1,1);

    end;
end;

function tmainclass.bytetostr(aa: array of Byte):string;
var
    i,icount:integer;
    b1:string;
begin
    icount:=High(aa);
    for i:=0 to icount do
    begin

        if aa[i]>0 then
            b1:=IntToStr(aa[i])
        else
            b1:='00';
        Result:=result+b1;
    end;
end;

function tmainclass.getmd5(strfile:string):string;
var
  filemd5:TIdHashMessageDigest5;
begin
  filemd5:=TIdHashMessageDigest5.Create; //必须先初始化
  result:=filemd5.AsHex(filemd5.HashValue(strfile));
  filemd5.Free;
end;

function tmainclass.Encryptbcb(var key:array of byte;InData:array of byte; var OutData:array of byte): Boolean;
var
  Cipher: TDCP_3des;
  Block: array[0..7] of byte;
  Block1: array[0..7] of byte;
  aratmp:array[0..7]  of byte;
  i,j:integer;
begin
    result:=false;
    try
    Cipher:= TDCP_3des.Create(nil);
    try
    Cipher.Init(Key,Sizeof(Key)*8,nil);
    aratmp[1]:=$0;
    aratmp[2]:=$0;
    aratmp[3]:=$0;
    aratmp[4]:=$0;
    aratmp[5]:=$0;
    aratmp[6]:=$0;
    aratmp[7]:=$0;
    aratmp[0]:=$0;
    Cipher.SetIV(aratmp);
    FillChar(OutData,SizeOf(outdata),0);
    i:=High(indata) mod 8;
    if i=0 then i:=8;
    for j:=0 to length(indata) div 8 do
    begin
       // 判断最后一组
       if j=Length(InData) div 8 then
       begin
         i:=length(indata) mod 8;
         Move(indata[j*8],Block1,i);
         //Move(indata[j*8]+i,Block1,8-i);
         FillChar(Block1[i],8-i,Byte(8-i));
       end
       else
         Move(indata[j*8],Block1,8);
        if j>0 then
          XorBlock(Block1,Block,8)
        else
          XorBlock(Block1,aratmp,8);
      Cipher.Encryptecb(Block1,Block);

      Move(Block,OutData[j*8],8);
    end;
    finally
    Cipher.Free;
    end;

    except

    end;
    result:=true;
end;

function tmainclass.Decryptbcb(var key:array of byte; InData: array of byte;
  var OutData: array of byte): Boolean;
var
  Cipher: TDCP_3des;
  Block: array[0..7] of byte;
  Block1: array[0..7] of byte;
  aratmp:array[0..7] of byte;
  i,j:integer;
begin

    result:=false;
    try

    Cipher:= TDCP_3des.Create(nil);
    try
    Cipher.Init(Key,Sizeof(Key)*8,nil);
    aratmp[1]:=$0;
    aratmp[2]:=$0;
    aratmp[3]:=$0;
    aratmp[4]:=$0;
    aratmp[5]:=$0;
    aratmp[6]:=$0;
    aratmp[7]:=$0;
    aratmp[0]:=$0;
    Cipher.SetIV(aratmp);
    FillChar(OutData,length(OutData),0);
    for j:=0 to Length(indata) div 8-1 do
    begin
      Move(InData[j*8],Block1,8);
      Cipher.Decryptecb(Block1,Block);
      if j>0 then
          XorBlock(Block,indata[(j-1)*8],8)              
      else
          XorBlock(Block,aratmp,8);



           Move(Block,outdata[j*8],8);
//      Move(Block1,outdata[j*8],8);

    end;
//    i:=Length(outdata)-outdata[High(outdata)];


    finally
    Cipher.Free;
    end;
//    setlength(OutData,80);
    except

    end;
    result:=true;
end;

function tmainclass.dbuftobuf(var indata:array of byte; var outdata:array of byte;index:integer): boolean;
var
    i:integer;
begin
    for i:=0 to Length(indata)-1 do
    begin
        outdata[index+i]:=indata[i];
    end;
end;

function tmainclass.arraytostr(arr: array of byte): string;
var i:integer;
begin
    result:='';
    for i:=0 to High(arr) do
    begin
        result:=result+inttohex(arr[i],2);
    end;
end;

function tmainclass.padl(mystr: string; mycount: integer;
  mychar: pchar): string;
var
    padl_i:integer;
    str_tmp:string;
begin
     if length(mystr)<mycount then
     str_tmp:='';
     begin
         for padl_i:=0 to mycount-length(mystr)-1 do
         begin
             str_tmp:=str_tmp+mychar;
         end;
     end;
     result:=str_tmp+mystr;
end;

function tmainclass.yxsj(str: string): string;
begin
    if str='' then

        Result:='0'
    else
        result:=trim(str);
end;

function tmainclass.opendataset(qry:tadoquery;sqlstr: string): Boolean;
begin
    with qry do
    begin
        close;
        sql.text:=sqlstr;
        try
            open;
        except
            self.WriteerrorLog(sqlstr);
        end;
    end;
end;

function tmainclass.errorname(errorcode: string): string;
var
    i_error,i:integer;

begin
    i_error:=StrToInt(errorcode);
    case i_error of
       0:result:='成功';
        10:result:='快通卡查询错误';
        11:result:='快通卡已列入黑名单';
        12:result:='快通卡已挂失';
        13:result:='快通卡已注销';
        14:result:='密码不符';
        15:result:='该卡不需要延期';
        16:result:='快通卡不可用';
        17:result:='余额不足';
        20:result:='银行账户不存在';
        21:result:='签约关系已存在';
        22:result:='签约关系不存在';
        23:result:='停止代理';
        24:result:='银行账户状态有误';
        25:result:='流水号重复';
        26:result:='金额不符';
        27:result:='记录数不符';
        30:result:='密钥申请失败';
        31:result:='银行发行失败';
        32:result:='流水号不存在';
        33:result:='发票打印失败';
        34:result:='发票重打印失败';
        35:result:='发票号重复';
        36:result:='充值发票重打印票号重复';
        37:result:='终端不存在';
        38:result:='终端不可用';
        39:result:='终端未签到';
        40:result:='不满足一车一卡';
        41:result:='快通卡已发行';
        42:result:='快通卡加入黑名单失败';
        43:result:='用户证件不符';
        44:result:='被补卡的原卡号不存在';
        45:result:='联名卡补发失败';
        46:result:='MD5校验不通过';
        47:result:='解密错误';
        48:result:='未找到指定文件';
        49:result:='此流水已经打印，请使用重打功能';
        50:result:='没有需要打印的数据';
        51:result:='时间不对,不能打印';
        90:result:='签到失败';
        91:result:='充值失败';
        92:result:='对账文件解析失败';
        93:result:='冲正失败';
        94:result:='未获取加密因子';
        95:result:='MAC1校验错误';
        96:result:='MAC计算失败!!';
        99:result:='其它错误';

     end;
     errorcode:=result;
end;

function tmainclass.padr(mystr: string; mycount: integer;
  mychar: pchar): string;
var
    padl_i:integer;
    str_tmp:string;
begin
     if length(mystr)<mycount then
     str_tmp:='';
     begin
         for padl_i:=0 to mycount-length(mystr)-1 do
         begin
             str_tmp:=str_tmp+mychar;
         end;
     end;
     result:=mystr+str_tmp;
end;


function tmainclass.BytestoHexString(ABytes: array of byte;
  len: Integer): AnsiString;
begin
  SetLength(Result, len*2);
  BinToHex(@ABytes[0], PAnsiChar(Result), len);
end;
function tmainclass.getmd5(strfile: TStream): string;
var
    filemd5:TIdHashMessageDigest5;

begin
    filemd5:=TIdHashMessageDigest5.Create; //必须先初始化
    result:=filemd5.AsHex(filemd5.HashValue(strfile));
    filemd5.Free;
end;

function tmainclass.getfilemd5(strfile:string): string;
var
    filestream:TStream;
begin
    filestream:=TfileStream.Create(strfile,fmOpenRead);
    result:=getmd5(filestream);

end;

function tmainclass.arraytostr1(arr: array of byte): string;
var i:integer;
begin
    result:='';
    for i:=0 to High(arr) do
    begin
        result:=result+char(arr[i]);
    end;
end;

procedure tmainclass.strdectobyte(var aa: array of Byte; str: string;
  itype: Byte);
var
    i,icount:integer;
    b1:string;
begin
    icount:=High(aa);
    for i:=0 to icount do
    begin
        b1:=Copy(str,i*itype+1,itype);
        if b1<>'' then
            aa[i]:=StrToInt('0x'+b1)
        else
            aa[i]:=0;
    end;
end;
initialization
    mainclass:=tmainclass.Create(nil);
finalization
    mainclass.Free;

end.
