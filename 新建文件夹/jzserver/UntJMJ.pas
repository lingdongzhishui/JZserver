unit UntJMJ;

interface


uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ScktComp,Uwork;


const
  CARDPAY_BALACETYPE = '2';     //选择钱包或存折 2-钱包
  CARDPAY_LOADTYPE   = $32;     //圈存交易类型
  CARDPAY_KEYID      = $31; 	  //圈存密钥索引
  CARDPUR_KEYID      = $31; 	  //消费密钥索引
  CARDPUR_LOADTYPE   = $33;     //消费交易类型
  CARDPUR_ISSUERID   = 'C9BDCEF7C9BDCEF7';

  READTIMEOUT = 1;

  FIRSTISSUEDLLNAME  = 'ISSUE_CPU.dll';
  ISAMISSUEDLLNAME   = 'ISSUE_ISAM.dll';
  SECONDISSUEDLLNAME = 'UPDATE_CPU.dll';
  READ0019DLLNAME = 'CPU_READ0019.dll';
  READ0015DLLNAME = 'CPU_READ0015.dll';
type
   TCharAry1 = array [0..255] of char;
  //圈存参数
  TCardLoadPara = record
    CardId: array [0..15] of char;       //卡号 16位
    Balance: array [0..7] of char;          //卡片原有金额   8
    CardPayMoney: array [0..7] of char;     //充值金额       8
    TransNumber: array [0..3] of char;      //联机交易序号   4
    KeyVersion: array [0..1] of char;       //圈存密钥版本   2
    KeyAlgorithm: array [0..1] of char;     //圈存算法标识   2
    Rand: array [0..7] of char;             //随机数         8
    MAC1: array [0..7] of char;             //               8
    TerminalNo: array[0..11] of char;                     //终端编号       12
    DateStr:array[0..7] of char;
    TimeStr:array[0..5] of char;
  end;


  //消费
  TCardLoadPara11 = record
    CardId: array [0..15] of char;       //卡号 16位
    Balance: array [0..7] of char;          //卡片原有金额   8
    Cash: array [0..7] of char;             // 交易金额       8
    TransNumber: array [0..3] of char;      //联机交易序号   4
    KeyVersion: array [0..1] of char;       //圈存密钥版本   2
    KeyAlgorithm: array [0..1] of char;     //圈存算法标识   2
    Rand: array [0..7] of char;             //随机数         8
    MAC1: array [0..7] of char;             //               8
    TerminalChargeSerial: array [0..3] of char;                     //终端交易序列号
    TerminalNo: array [0..11] of char;
    //TerminalNo: String;
    CashDate:  array [0..7] of CHAr;       //终端交易日期
    CashTime:  array [0..5] of char;        //终端交易时间
  end;
  TOBUFX2 = record
    hth: array[0..7] of byte;       //卡号 16位
    rand: array [0..3] of byte;
    clxx:array[0..58] of byte;
    //TerminalNo: String;
  //  CashDate:  string;        //终端交易日期
  //  CashTime:  string;        //终端交易时间
  end;
  Tchecktac = record
    hth:string;       //卡号 16位
    money: integer;
    TerminalNo: String;
    onlinesn:string;
    CashDate:  string;        //终端交易日期
    CashTime:  string;        //终端交易时间
    Tac:string;
  end;


  function CalPurMAC1(CardLoadPara: TCardLoadPara11; EncrypIP, EncrypPort: string;var MAC:array of byte;  var ErrorStr: string): boolean;  // 计算mac1
  function CheckMAC1(CardLoadPara: TCardLoadPara; EncrypIP, EncrypPort: string; var ErrorStr: string): boolean; //
  function CalMAC2(CardLoadPara: TCardLoadPara; EncrypIP, EncrypPort: string;  var MAC2: array of byte; var ErrorStr: string): boolean;
//ywlx 1:oub 系统信息 2:obu 车辆信息 3:0016文件 4:0015文件  5:TAC校验  终端编号(12)+终端序列号(4)+date(4)+time(3)
  function OBUFX2(OBUFX2:TOBUFX2;encrypip:string;encrypport:string;var MAC:array of byte;var errorstr:string;ywlx:integer):boolean;
  //消费

function checktac(checktac:Tchecktac;encrypip:string;encrypport:string;var MAC:array of byte;var errorstr:string):boolean;

implementation
//将16进制字符串转为Char存储
procedure HexStringtoChar(HexStr: string; var ResCharAry: TCharAry1);
var
  i: integer;
  TemStr: string;
  CharLen: integer;
begin
  CharLen := Round(Length(HexStr) div 2);
  FillChar(ResCharAry, SizeOf(ResCharAry), 0);
  SetLength(TemStr, 3);

  for i := 0 to CharLen - 1 do
  begin
    TemStr[1] := '$';
    TemStr[2] := HexStr[i * 2 + 1];
    TemStr[3] := HexStr[i * 2 + 2];
    ResCharAry[i] := Char(StrToInt(TemStr));
  end;
end;

//校验MAC1
function CheckMAC1(CardLoadPara: TCardLoadPara; EncrypIP, EncrypPort: string; var ErrorStr: string): boolean;
var
  ClientSocket: TClientSocket;
  CheckMac1Command: array [0..57] of char;  //校验指令
    CheckMac1CommandStr: array [0..315] of char;  //校验指令str
  CharAry1: TCharAry1;
  ResAry: array [0..255] of byte;
  i: integer;
  ReadBuf: boolean;
begin
  Result := false;

  ClientSocket := TClientSocket.Create(nil);
  try
    ClientSocket.Address := EncrypIP;
    ClientSocket.Port := StrToInt(EncrypPort);
    ClientSocket.ClientType := ctBlocking;
    try
      ClientSocket.Open;
    except
      ErrorStr := '连接加密机失败';
      exit;
    end;

    { 创建加密机MA1校验指令 }
    FillChar(CheckMac1Command, SizeOf(CheckMac1Command), 0);
    //长度(58个字节)
    CheckMac1Command[0] := char($00);
    CheckMac1Command[1] := char($38);
    //命令代码
    CheckMac1Command[2] := char($4D);
    CheckMac1Command[3] := char($56);
    //保留域
    CheckMac1Command[4] := char($00);
    //密钥区号
    CheckMac1Command[5] := char($00);
    //TVI
    CheckMac1Command[6] := char($20);
    CheckMac1Command[7] := char($00);
    CheckMac1Command[8] := char($05);
    //填充方式
    CheckMac1Command[9] := char($01);
    //MAC算法
    CheckMac1Command[10] := char($04);
    //离散次数
    CheckMac1Command[11] := char($01);
    //离散数据
    hextobin(CardLoadPara.CardId, CharAry1,8);
    CopyMemory(@CheckMac1Command[12], @CharAry1, 8);
    //随机数
    HexToBin(CardLoadPara.Rand, CharAry1,4);
    CopyMemory(@CheckMac1Command[20], @CharAry1, 4);
    //联机交易序号
    HexToBin(CardLoadPara.TransNumber, CharAry1, 2);
    CopyMemory(@CheckMac1Command[24], @CharAry1, 2);
    //8000
    CheckMac1Command[26] := Char($80);
    CheckMac1Command[27] := Char($00);
    //MAC长度
    CheckMac1Command[28] := Char($04);
    //MAC值
    HexToBin(CardLoadPara.MAC1, CharAry1,4);
    CopyMemory(@CheckMac1Command[29], @CharAry1, 4);
    //数据长度 （IV＋MAC数据）的长度
    CheckMac1Command[33] := Char($00);
    CheckMac1Command[34] := Char($17);
    //IV
    CheckMac1Command[35] := Char($00);
    CheckMac1Command[36] := Char($00);
    CheckMac1Command[37] := Char($00);
    CheckMac1Command[38] := Char($00);
    CheckMac1Command[39] := Char($00);
    CheckMac1Command[40] := Char($00);
    CheckMac1Command[41] := Char($00);
    CheckMac1Command[42] := Char($00);
    //上次卡余额
    HexToBin(CardLoadPara.Balance, CharAry1,4);
    CopyMemory(@CheckMac1Command[43], @CharAry1, 4);
    //充值金额
    hextobin(CardLoadPara.CardPayMoney, CharAry1,4);
    CopyMemory(@CheckMac1Command[47], @CharAry1, 4);
    //电子钱包圈存 交易类型
    CheckMac1Command[51] := Char($02);
    //终端编号
    HexToBin(CardLoadPara.TerminalNo,CharAry1,6);
    CopyMemory(@CheckMac1Command[52], @CharAry1, 6);
     bintohex(CheckMac1Command,CheckMac1CommandStr,sizeof(CheckMac1Command));

    {发送指令}
    try
      ClientSocket.Socket.SendBuf(CheckMac1Command, SizeOf(CheckMac1Command));
    except
      ErrorStr := '向加密机发送指令失败';
      exit;
    end;

    //获取结果
    ReadBuf := false;
    FillChar(ResAry, SizeOf(ResAry), 0);
    for i := 0 to READTIMEOUT * 10000000 do
    begin
      Application.ProcessMessages;
      if ClientSocket.Socket.ReceiveBuf(ResAry, SizeOf(ResAry)) > -1 then
      begin
        ReadBuf := true;
        break;
      end;
    end;

    if not ReadBuf then
    begin
      ErrorStr := '校验MAC1时没有收到加密机反馈信息';


      exit;
    end;

    //校验无误
    if not ((ResAry[4] = 48) and (ResAry[5] = 48)) then
    begin
      ErrorStr := '校验MAC1错误';
      mainclass.WriteLog('校验MAC1错误'+'原MAC1'+CardLoadPara.mac1+'加密机MAC:'+mainclass.arraytostr(ResAry));
      exit;
    end;

    Result := true;

  finally
    if ClientSocket.Active then ClientSocket.Close;
    ClientSocket.Free;
  end;

end;

//MAC2
function CalMAC2(CardLoadPara: TCardLoadPara; EncrypIP, EncrypPort: string;
  var MAC2: array of byte; var ErrorStr: string): boolean;
var
  ClientSocket: TClientSocket;
  CheckMac2Command: array [0..56] of char;  //校验指令
  CharAry1: TCharAry1;
  ResAry: array [0..255] of byte;
  i: integer;
  ReadBuf: boolean;
  DateStr, TimeStr: string;
  TemStr: string;
  TemResTac: array [0..8] of byte;
  ResErrorStr: array [0..255] of byte;
begin
  Result := false;

  ClientSocket := TClientSocket.Create(nil);
  try
    ClientSocket.Address := EncrypIP;
    ClientSocket.Port := StrToInt(EncrypPort);
    ClientSocket.ClientType := ctBlocking;
    try
      ClientSocket.Open;
    except
      ErrorStr := '连接加密机失败';
      exit;
    end;

    { 创建加密机MA1校验指令 }
    FillChar(CheckMac2Command, SizeOf(CheckMac2Command), 0);
    //长度(58个字节)
    CheckMac2Command[0] := char($00);
    CheckMac2Command[1] := char($37);
    //命令代码
    CheckMac2Command[2] := char($4D);
    CheckMac2Command[3] := char($47);
    //保留域
    CheckMac2Command[4] := char($00);
    //密钥区号
    CheckMac2Command[5] := char($00);
    //TVI
    CheckMac2Command[6] := char($20);
    CheckMac2Command[7] := char($00);
    CheckMac2Command[8] := char($05);
    //填充方式
    CheckMac2Command[9] := char($01);
    //MAC算法
    CheckMac2Command[10] := char($04);
    //返回MAC长度
    CheckMac2Command[11] := char($04);
    //离散次数
    CheckMac2Command[12] := char($01);
    //离散数据
    HexToBin(CardLoadPara.CardId, CharAry1,8);
    CopyMemory(@CheckMac2Command[13], @CharAry1, 8);
    //随机数
    HexToBin(PChar(string(CardLoadPara.Rand)), CharAry1,4);
    CopyMemory(@CheckMac2Command[21], @CharAry1, 4);
    //联机交易序号
    HexToBin(CardLoadPara.TransNumber, CharAry1,2);
    CopyMemory(@CheckMac2Command[25], @CharAry1, 2);
    //8000
    CheckMac2Command[27] := Char($80);
    CheckMac2Command[28] := Char($00);

    //数据长度 （IV＋MAC数据）的长度
    CheckMac2Command[29] := Char($00);
    CheckMac2Command[30] := Char($1A);
    //IV
    CheckMac2Command[31] := Char($00);
    CheckMac2Command[32] := Char($00);
    CheckMac2Command[33] := Char($00);
    CheckMac2Command[34] := Char($00);
    CheckMac2Command[35] := Char($00);
    CheckMac2Command[36] := Char($00);
    CheckMac2Command[37] := Char($00);
    CheckMac2Command[38] := Char($00);
    //充值金额
    HexToBin(PChar(@(CardLoadPara.CardPayMoney)), CharAry1,4);
    CopyMemory(@CheckMac2Command[39], @CharAry1, 4);
    //电子钱包圈存 交易类型
    CheckMac2Command[43] := Char($02);
    //终端编号
    HexToBin(CardLoadPara.TerminalNo, CharAry1,6);
    CopyMemory(@CheckMac2Command[44], @CharAry1, 6);
    //日期
    HexToBin(CardLoadPara.DateStr, CharAry1,4);
    CopyMemory(@CheckMac2Command[50], @CharAry1, 4);
    //时间
    HexToBin(CardLoadPara.TimeStr, CharAry1,3);
    CopyMemory(@CheckMac2Command[54], @CharAry1, 3);

    {发送指令}
    try
      ClientSocket.Socket.SendBuf(CheckMac2Command, SizeOf(CheckMac2Command));
    except
      ErrorStr := '向加密机发送指令失败';
      exit;
    end;

    //获取结果
    ReadBuf := false;
    FillChar(ResAry, SizeOf(ResAry), 0);
    for i := 0 to READTIMEOUT * 10000000 do
    begin
      Application.ProcessMessages;
      if ClientSocket.Socket.ReceiveBuf(ResAry, SizeOf(ResAry)) > -1 then
      begin
        ReadBuf := true;
        break;
      end;
    end;

    if not ReadBuf then
    begin
      ErrorStr := '计算MAC2时没有收到加密机反馈信息';
      exit;
    end;

    //计算无误
    if not ((ResAry[4] = 48) and (ResAry[5] = 48)) then
    begin
      ErrorStr := '计算MAC2失败';
      exit;
    end;

    //校验MAC2
    FillChar(MAC2, SizeOf(MAC2), 0);
    CopyMemory(@MAC2, @ResAry[6], 4);


    Result := true;
  finally
    if ClientSocket.Active then ClientSocket.Close;
    ClientSocket.Free;
  end;
end;

//计算ＭＡＣ1
 function CalPurMAC1(CardLoadPara: TCardLoadPara11; EncrypIP, EncrypPort: string;var MAC:array of byte;  var ErrorStr: string): boolean;
var
  ClientSocket: TClientSocket;
  CheckMac1Command: array [0..157] of char;  //校验指令
  CheckMac1CommandStr: array [0..315] of char;  //校验指令str
  CharAry1: TCharAry1;
  ResAry: array [0..255] of byte;
  i: integer;
  ReadBuf: boolean;
  ResArychar: array [0..512] of char;
  ResAryStr:string;

  FJMJOBU_MACTmp:array [0..7] of char;

  TmpRand,TmpTransNumber,TmpTerminalChargeSerial,TmpTerminalNo,Tmpcashdate,Tmpcashtime:string;
begin
  Result := false;

  ClientSocket := TClientSocket.Create(nil);
  try
    ClientSocket.Address :=EncrypIP;
    ClientSocket.Port := StrToInt(EncrypPort);
    ClientSocket.ClientType := ctBlocking;
    try
      ClientSocket.Open;
    except
      ErrorStr := '连接加密机失败';
      exit;
    end;


    { 创建加密机MA1校验指令 }
    FillChar(CheckMac1Command, SizeOf(CheckMac1Command), 0);
    //长度(58个字节)
    CheckMac1Command[0] := char($00);
    CheckMac1Command[1] := char($37);
    //命令代码
    CheckMac1Command[2] := char($4D);
    CheckMac1Command[3] := char($47);
    //保留域
    CheckMac1Command[4] := char($00);
    //密钥区号
    CheckMac1Command[5] := char($00);
    //TVI
    CheckMac1Command[6] := char($A1);
    CheckMac1Command[7] := char($00);
    CheckMac1Command[8] := char($08);
    //填充方式
    CheckMac1Command[9] := char($01);
    //MAC算法
    CheckMac1Command[10] := char($04);
    //MAC长度
    CheckMac1Command[11] := Char($04);
    //离散次数
    CheckMac1Command[12] := char($01);
    //离散数据
    hextobin(CardLoadPara.CardId, CharAry1,8);
    CopyMemory(@CheckMac1Command[13], @CharAry1, 8);
    //随机数
    hextobin(CardLoadPara.Rand, CharAry1,4);
    CopyMemory(@CheckMac1Command[21], @CharAry1, 4);
    //联机交易序号
    hextobin(CardLoadPara.TransNumber, CharAry1,2);
    CopyMemory(@CheckMac1Command[25], @CharAry1, 2);
    //终端交易序列号
    hextobin(CardLoadPara.TerminalChargeSerial, CharAry1,2);
    CopyMemory(@CheckMac1Command[27], @CharAry1, 2);

    //数据长度 （IV＋MAC数据）的长度
    CheckMac1Command[29] := Char($00);
    CheckMac1Command[30] := Char($1A);
    //IV
    CheckMac1Command[31] := Char($00);
    CheckMac1Command[32] := Char($00);
    CheckMac1Command[33] := Char($00);
    CheckMac1Command[34] := Char($00);
    CheckMac1Command[35] := Char($00);
    CheckMac1Command[36] := Char($00);
    CheckMac1Command[37] := Char($00);
    CheckMac1Command[38] := Char($00);




   //交易余额    4
    hextobin(CardLoadPara.cash, CharAry1,4);
    CopyMemory(@CheckMac1Command[39], @CharAry1, 4);
    //交易类型标识    1
    CheckMac1Command[43] := Char($09);
    //终端编号         6
    HexToBin(CardLoadPara.TerminalNo, CharAry1,6);
    CopyMemory(@CheckMac1Command[44], @CharAry1, 6);
     //终端交易日期      4
    HexToBin(CardLoadPara.cashdate, CharAry1,4);
    CopyMemory(@CheckMac1Command[50], @CharAry1, 4);

    //终端交易时间      3
    HexToBin(CardLoadPara.cashtime, CharAry1,3);
    CopyMemory(@CheckMac1Command[54], @CharAry1, 3);

     bintohex(CheckMac1Command,CheckMac1CommandStr,sizeof(CheckMac1Command));

     bintohex(CheckMac1Command,CheckMac1CommandStr,sizeof(CheckMac1Command));

    {发送指令}
    try
      ClientSocket.Socket.SendBuf(CheckMac1Command, SizeOf(CheckMac1Command));
    except
      ErrorStr := '向加密机发送指失败';
      exit;
    end;

    //获取结果
    ReadBuf := false;
    FillChar(ResAry, SizeOf(ResAry), 0);
    for i := 0 to READTIMEOUT * 10000000 do
    begin
      Application.ProcessMessages;
      if ClientSocket.Socket.ReceiveBuf(ResAry, SizeOf(ResAry)) > -1 then
      begin
        ReadBuf := true;
        break;
      end;
    end;

    if not ReadBuf then
    begin
      ErrorStr := '校验MAC1时没有收到加密机反馈信息';
      exit;
    end;


     FillChar(ResArychar, SizeOf(ResArychar), 0);
    CopyMemory(@ResArychar, @ResAry, sizeof(ResAry));
    ResAryStr:=ResArychar;
    //校验无误
    if not ((ResAry[4] = 48) and (ResAry[5] = 48)) then
    begin
      ErrorStr := '计算MAC1错误';

      exit;
    end
    else
    begin
          FillChar(MAC, SizeOf(MAC), 0);
          CopyMemory(@MAC, @ResAry[6], 4);
    end;

    Result := true;
  finally
    if ClientSocket.Active then ClientSocket.Close;
    ClientSocket.Free;
  end;

end;
function checktac(checktac:Tchecktac;encrypip:string;encrypport:string;
         var MAC:array of byte;var errorstr:string):boolean;
var
  ClientSocket: TClientSocket;
  CheckMac2Command: array [0..255] of char;  //校验指令
  CharAry1: TCharAry1;
  ResAry: array [0..255] of byte;
  i: integer;
  ReadBuf: boolean;
  DateStr, TimeStr: string;
  TemStr: string;
  TemResTac: array [0..8] of byte;
  ResErrorStr: array [0..255] of byte;
  arr:array[0..10] of Byte;
begin
  Result := false;
  ClientSocket:= TClientSocket.Create(nil);
  try
    ClientSocket.Address := EncrypIP; //加密机IP
    ClientSocket.Port := StrToInt(EncrypPort);//加密机端口
    ClientSocket.ClientType := ctBlocking;
    try
      ClientSocket.Open;
    except
      ErrorStr := '连接加密机失败';
      exit;
    end;

    FillChar(CheckMac2Command, SizeOf(CheckMac2Command), 0);
    //长度(58个字节)
    CheckMac2Command[0] := char($00);
    CheckMac2Command[1] := char($33);
    CheckMac2Command[2] := char($4D);
    CheckMac2Command[3] := char($47);
    //保留域
    CheckMac2Command[4] := char($00);
    //密钥区号
    CheckMac2Command[5] := char($00);
    CheckMac2Command[6] := char($A1);
    CheckMac2Command[7] := char($00);

    CheckMac2Command[8] := char($60);
    CheckMac2Command[9] := char($01);

    CheckMac2Command[10] := char($00);

//        CopyMemory(@CheckMac2Command[36], @checktac.clxx, 17);
//        mainclass.strdectobyte11(@CheckMac2Command[36],checktac.hth,2,8);






    //命令代码
    //TVI





    //填充方式
    //MAC算法

    //返回MAC长度
    CheckMac2Command[11] := char($04);
    //离散次数
    CheckMac2Command[12] := char($01);
    //离散数据
//    HexToBin(PChar(CardLoadPara.CardId), CharAry1,8);
        mainclass.strdectobyte(arr,checktac.hth,2);

    CopyMemory(@CheckMac2Command[13], @arr, 8);
    CheckMac2Command[21] := char($00);
    CheckMac2Command[22] := char($1E);





    //随机数
    //HexToBin(PChar(string(CardLoadPara.Rand)), CharAry1,4);

        CheckMac2Command[23] := Char($00);
        CheckMac2Command[24] := Char($00);
        CheckMac2Command[25] := Char($00);
        CheckMac2Command[26] := Char($00);
        CheckMac2Command[27] := Char($00);
        CheckMac2Command[28] := Char($00);
        CheckMac2Command[29] := Char($00);
        CheckMac2Command[30] := Char($00);
        mainclass.strdectobyte(arr,PChar(inttohex(checktac.money,8)),2);
        CopyMemory(@CheckMac2Command[31],@arr, 4);
        CheckMac2Command[35] := Char($9);

       mainclass.strdectobyte(arr,checktac.TerminalNo,2);
       CopyMemory(@CheckMac2Command[36], @arr, 6);
       mainclass.strdectobyte(arr,checktac.onlinesn,2);
       CopyMemory(@CheckMac2Command[42], @arr, 4);
       mainclass.strdectobyte(arr,checktac.CashDate,2);
       CopyMemory(@CheckMac2Command[46], @arr, 4);
       mainclass.strdectobyte(arr,checktac.CashTime,2);
       CopyMemory(@CheckMac2Command[50], @arr, 3);


    try
      ClientSocket.Socket.SendBuf(CheckMac2Command, SizeOf(CheckMac2Command));
    except
      ErrorStr := '向加密机发送指令失败';
      exit;
    end;

    //获取结果
    ReadBuf := false;
    FillChar(ResAry, SizeOf(ResAry), 0);
    for i := 0 to READTIMEOUT * 10000000 do
    begin
      Application.ProcessMessages;
      if ClientSocket.Socket.ReceiveBuf(ResAry, SizeOf(ResAry)) > -1 then
      begin
        ReadBuf := true;
       break;
      end;
    end;

    if not ReadBuf then
    begin
      ErrorStr := '计算MAC时没有收到加密机反馈信息';
      exit;
    end;

    //计算无误
    if not ((ResAry[4] = 48) and (ResAry[5] = 48)) then
    begin
      ErrorStr := '计算MAC失败';
      exit;
    end;

    //校验MAC2
    FillChar(MAC, SizeOf(MAC), 0);
    CopyMemory(@MAC, @ResAry[6], 4);


    Result := true;
  finally
    if ClientSocket.Active then ClientSocket.Close;
    ClientSocket.Free;
  end;

end;
function OBUFX2(OBUFX2:TOBUFX2;encrypip:string;encrypport:string;var MAC:array of byte;var errorstr:string;ywlx:integer):boolean;
var
  ClientSocket: TClientSocket;
  CheckMac2Command: array [0..255] of char;  //校验指令
  CharAry1: TCharAry1;
  ResAry: array [0..255] of byte;
  i: integer;
  ReadBuf: boolean;
  DateStr, TimeStr: string;
  TemStr: string;
  TemResTac: array [0..8] of byte;
  ResErrorStr: array [0..255] of byte;
begin
  Result := false;
  ClientSocket := TClientSocket.Create(nil);
  try
    ClientSocket.Address := EncrypIP;
    ClientSocket.Port := StrToInt(EncrypPort);
    ClientSocket.ClientType := ctBlocking;
    try
      ClientSocket.Open;
    except
      ErrorStr := '连接加密机失败';
      exit;
    end;

    FillChar(CheckMac2Command, SizeOf(CheckMac2Command), 0);
    //长度(58个字节)
    CheckMac2Command[0] := char($00);
    case ywlx of
    0:
    begin


    end;
    1:
    begin
        CheckMac2Command[1] := char($49);
        CheckMac2Command[6] := char($A1);
        CheckMac2Command[8] := char($14);
        CheckMac2Command[10] := char($03);
        CheckMac2Command[22] := char($34);
        CheckMac2Command[35] := Char($2B);
        CheckMac2Command[33] := Char($81);

         CopyMemory(@CheckMac2Command[36], @OBUFX2.clxx, 39);
    end;
    2:
    begin
        CheckMac2Command[1] := char($5D);
        CheckMac2Command[6] := char($A1);
        CheckMac2Command[8] := char($15);
        CheckMac2Command[10] := char($03);
        CheckMac2Command[22] := char($48);
        CheckMac2Command[35] := Char($3F);
        CheckMac2Command[33] := Char($81);

        CopyMemory(@CheckMac2Command[36], @OBUFX2.clxx, 59);
    end;
    3:
    begin
        CheckMac2Command[1] := char($59);
        CheckMac2Command[6] := char($20);
        CheckMac2Command[8] := char($02);
        CheckMac2Command[10] := char($03);
        CheckMac2Command[22] := char($44);
        CheckMac2Command[35] := Char($3B);
        CheckMac2Command[33] := Char($96);
        CopyMemory(@CheckMac2Command[36], @OBUFX2.clxx, 55);
    end;
    4:
    begin
        CheckMac2Command[1] := char($4D);
        CheckMac2Command[6] := char($20);
        CheckMac2Command[8] := char($04);
        CheckMac2Command[10] := char($03);
        CheckMac2Command[22] := char($38);
        CheckMac2Command[35] := Char($2F);
        CheckMac2Command[33] := Char($95);

        CopyMemory(@CheckMac2Command[36], @OBUFX2.clxx, 43);
    end;
    5:  //TAC计算
    begin
        CheckMac2Command[1] := char($33);
        CheckMac2Command[6] := char($A1);
        CheckMac2Command[8] := char($60);
        CheckMac2Command[10] := char($00);
        CheckMac2Command[22] := char($1E);
        CheckMac2Command[35] := Char($9);
        CopyMemory(@CheckMac2Command[36], @OBUFX2.clxx, 17);
    end;
    end;



    //命令代码
    CheckMac2Command[2] := char($4D);
    CheckMac2Command[3] := char($47);
    //保留域
    CheckMac2Command[4] := char($00);
    //密钥区号
    CheckMac2Command[5] := char($00);
    //TVI

    CheckMac2Command[7] := char($00);




    //填充方式
    CheckMac2Command[9] := char($01);
    //MAC算法

    //返回MAC长度
    CheckMac2Command[11] := char($04);
    //离散次数
    CheckMac2Command[12] := char($01);
    //离散数据
//    HexToBin(PChar(CardLoadPara.CardId), CharAry1,8);
    CopyMemory(@CheckMac2Command[13], @OBUFX2.hth, 8);
    CheckMac2Command[21] := char($00);





    //随机数
    //HexToBin(PChar(string(CardLoadPara.Rand)), CharAry1,4);
    if ywlx in [1,2,3,4] then
    begin
        CopyMemory(@CheckMac2Command[23], @OBUFX2.Rand, 4);
        CheckMac2Command[31] := Char($04);
        CheckMac2Command[32] := Char($D6);
        CheckMac2Command[34] := Char($00);
    end;
    if ywlx=5 then
    begin
        CheckMac2Command[23] := Char($00);
        CheckMac2Command[24] := Char($00);
        CheckMac2Command[25] := Char($00);
        CheckMac2Command[26] := Char($00);
        CopyMemory(@CheckMac2Command[31], @OBUFX2.Rand, 4);
    end;
    CheckMac2Command[27] := Char($00);
    CheckMac2Command[28] := Char($00);
    CheckMac2Command[29] := Char($00);
    CheckMac2Command[30] := Char($00);




    try
      ClientSocket.Socket.SendBuf(CheckMac2Command, SizeOf(CheckMac2Command));
    except
      ErrorStr := '向加密机发送指令失败';
      exit;
    end;

    //获取结果
    ReadBuf := false;
    FillChar(ResAry, SizeOf(ResAry), 0);
    for i := 0 to READTIMEOUT * 10000000 do
    begin
      Application.ProcessMessages;
      if ClientSocket.Socket.ReceiveBuf(ResAry, SizeOf(ResAry)) > -1 then
      begin
        ReadBuf := true;
       break;
      end;
    end;

    if not ReadBuf then
    begin
      ErrorStr := '计算MAC时没有收到加密机反馈信息';
      exit;
    end;

    //计算无误
    if not ((ResAry[4] = 48) and (ResAry[5] = 48)) then
    begin
      ErrorStr := '计算MAC失败';
      exit;
    end;

    //校验MAC2
    FillChar(MAC, SizeOf(MAC), 0);
    CopyMemory(@MAC, @ResAry[6], 4);


    Result := true;
  finally
    if ClientSocket.Active then ClientSocket.Close;
    ClientSocket.Free;
  end;

end;
end.
 