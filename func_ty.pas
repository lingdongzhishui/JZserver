unit func_ty;
interface
uses
    StrUtils,stdctrls,DB, DBClient,Windows, Messages, SysUtils,  Classes, Graphics, Controls, Forms,
    Dialogs,Grids, DBGrids, Buttons, DBCtrls,printers,
    ExtCtrls,IniFiles,nb30,ComCtrls,winsock, registry,
adodb,mask,Variants,MemTableDataEh, DataDriverEh, MemTableEh,GridsEh, DBGridEh,  DBCtrlsEh, DBLookupEh, DBGridEhImpExp,
FileCtrl,provider,dbtables,math,shellapi,comlook,LogPubFunc; //Class TfcShapeBtn not found
type
 Time_Story  =   (ts_12,       {12 Сʱ��}
                          ts_24        {24 Сʱ��}
                           );

    Tarraychar=array of char;
    TProcedure = procedure(Test: string) of object;
   //**********************************************************************
    //�жϵĺ�
    //**********************************************************************
    function iif(str1:boolean;str2:string;str3:string):string;overload;
    function iif(str1:boolean;str2:integer;str3:integer):integer;overload;
    function iif(str1:boolean;str2:Currency;str3:Currency):Currency;overload;
    function iif(str1:boolean;str2:Tdatetime;str3:Tdatetime):Tdatetime;overload;
    function iif(str1:boolean;str2:double;str3:double):double;overload;
    //*************************************************************************
    function padl(mystr:string;mycount:integer;mychar:pchar):string;  //��ָ������ָ������
    function padr(mystr:string;mycount:integer;mychar:pchar):string;  //�Ҳ�ָ������ָ������
    function SubStrConut(mStr: string; mSub: string): Integer;  //ȡָ���ַ���ָ���ַ������ֵĴ���
    function substrpos(mstr:string;msub:string;irec:integer):integer;  //�����ַ����ڼ�������ָ�������е���ʼλ��
    function memline(mstr:string;sub_char:char;mlinecount:integer):string;  //ȡָ���ַ��ָ�ָ���ε��ַ���
    procedure cmbView(Sender: TObject; TabName, aName,bname: String);overload; //��comboboxbm������ֵ
    //********************************************************
    //��ʾ��Ϣ
    //*********************************************************
    function wait_(wind_info:integer):string;overload;
    function wait_(wind_info:Tdatetime):string;overload;
    function wait_(wind_info:string):string;overload;
    function wait_(wind_info,wind_pic:string):string;overload;
    function wait_(wind_info,wind_pic,wind_title:string):string;overload;
    function wait_(wind_info,wind_pic,wind_title,wind_But:string):string;overload;
    function wait_(wind_info,wind_pic,wind_title,wind_But:string;wind_Dbut:integer):string;overload;
    //****************************************************************************************************
    function  localIP:string;  //�õ�����IP
    function getRegString(Rootkey:HKEY;section,key:string):string;//ȡע����ָ����
    function getdir_(caption:string;root:widestring;out dir:string):boolean;  //�õ�Ŀ¼
    function getalldrivename():string; //�õ������ƶ��豸���̷�
    function getmovdrive():string;  //�õ��ƶ������̷�
    function DiskInDrive(Drive:   Char):   Boolean; ////����������Ƿ����
    function strtochar(str:string):Tarraychar;  //�ַ���ת��Ϊ����
    function IsDigit(S:String):Boolean;//�ж��Ƿ�С��
    function Check_re(str:string):string;  //�����滻����еķǷ��ַ�
    function HzPy(const AHzStr: string): string; stdcall; //�õ�ƴ����д
    Function gdx_( n0 :real) :String; stdcall;overload;  //�Ĵ�д
    function Delpath(AFilePath: String): Boolean; stdcall;  //ɾ���ļ���Ŀ¼
    function SetdisplaySize(X, Y: word): BOOL;    //����ϵͳ�ֱ���
    function date_fomat(date:Tdate):string;            //��ʽ������
    function time_(datetime:Tdatetime):string;     //��ʽ��ʱ��
    Procedure FileCopy( Const sourcefilename, targetfilename: String );
    function yxsj(intstr:string):string;
    procedure ExecuteRoutine(Obj: TObject; Name, Param: string);
    procedure execregsvr32(filename:string);
    procedure writetxt(filename:string;tstr:string);
    procedure SetTimeStory(const Story: Time_Story);
//    procedure setcds(cds:Tquery);overload;    //����cds
//    function opencds(cds:tadoquery;str:string):boolean;overload;  //��cds
 function isdate(s:string):boolean;
    procedure gridsort(dbgrideh:Tdbgrideh);
 function SWR(r: real;i:integer): real;//��������λ
    function opencds(adoquery:TADOQuery;sqlstr:string;connstr:string):boolean;overload;
    function opencds(adoquery:TADOQuery;sqlstr:string;adocn:TADOConnection):boolean;overload;
    function opencds(adoquery:TADOQuery;sqlstr:string):boolean;overload;
    procedure setcds(adoquery:TADOQuery);
    function  com_arr_val(Sender:Tcomlook):string;
    function lqs_(sqlstr:string):string;
procedure gridtofile(title:string;dbgrid:Tdbgrideh);    

implementation
    function lqs_(sqlstr:string):string;
    begin
       { setcds(dmform.qrytmp);
        opencds(dmform.qrytmp,sqlstr);
        result:=dmform.qrytmp.Fields[0].AsString; }
    end;
function  com_arr_val(Sender:Tcomlook):string;
begin

    if sender.keyValue<>Null then
    begin
        result:=sender.KeyValue;
    end
    else
        result:='';
end;

procedure cmbView(Sender: TObject; TabName, aName,bname: String);
var
    ds:Tdatasource;
    strtmp:string;
    cds:Tadoquery;
begin
    cds:=Tadoquery.Create(TCOMLOOK(SENDER).Parent);
    ds:= Tdatasource.Create(TCOMLOOK(SENDER).Parent);
    ds.DataSet:=cds;
    opencds(cds,'select * from ' + TabName+' order by '+bname);
  with Tcomlook(sender) do
  begin
      ListSource:=ds;
      KeyField:=bname;
      ListField:=bname+';'+aname;
      KeyValue:=Null;
  end;
end;

//**************************************************
//����Tstring �����Ŀ�ĳ���
//**************************************************
    procedure setcds(adoquery:TADOQuery);
    begin
        // adoquery.Connection:=dmform.ADOConnection1;
    end;
function opencds(adoquery: TADOQuery; sqlstr: string):boolean;
begin
//    adoquery.ConnectionString:=g_sConnectionString;
 {    setcds(adoquery);
    result:=false;
    if not dmform.adoConnection1.Connected then
         dmform.adoConnection1.Connected:=true; }

    with adoquery do
    begin
        Close;
        sql.Text:=sqlstr;
        try
            open;
            result:=true;
        except
            ShowMessage('�����ݿ�ʧ��!!');
        end;

    end;


end;

function opencds(adoquery: TADOQuery; sqlstr: string;connstr:string):boolean;
begin
    adoquery.ConnectionString:=connstr;
    result:=false;
    with adoquery do
    begin
        Close;
        sql.Text:=sqlstr;
        try
            open;
            result:=true;
        except
            ShowMessage('�����ݿ�ʧ��!!');
        end;

    end;

end;
function opencds(adoquery: TADOQuery; sqlstr: string;adocn:TADOConnection):boolean;
begin
    if adocn.Connected then
        adoquery.Connection:=adocn
    else
    begin
        try
             adocn.Open;
        except

        wait_('���ݿ�����ʧ��!!!');
        exit;
        end;
    end;

    result:=false;
    with adoquery do
    begin
        Close;
        sql.Text:=sqlstr;
        try
            open;
            result:=true;
        except
            ShowMessage('�����ݿ�ʧ��!!');
        end;

    end;

end;

function SWR(r: real;i:integer): real;//��������λ

var
  s,s1,s2,s3,s4: string;
  j,h:integer;
  bflag1:boolean;
  label lab;

begin
    bflag1:=false;
    if r<0 then
    begin
        r:=abs(r);
        bflag1:=true;
    end;
  j:=AnsiPos('.',floattostr(r));
  if j=0 then
    begin
      if bflag1 then
          result:=r*-1
      else
      result := r;
    end
  else
    begin
      s:=AnsiLeftStr(floattostr(r),j);
      s1:=AnsiMidStr(floattostr(r),j+1,i+1);
      if Length(s1)<=i then
        begin
          s4:=s1;
          //result := strtofloat(s+s4);
          goto lab;
          exit;
        end;
      s2:=AnsiRightStr(s1,1);
      s3:=AnsiLeftStr(s1,i);
      if strtoint(s2)>=5 then
            begin
              h:=1;
              s4:='';
              while h<=i do
                begin
                  if strtoint(AnsiMidStr(s3,h,1))=0 then
                    begin
                      if h=i then
                        begin
                          s4:=s4+'1';
                        end;
                      s4:=s4+'0';
                    end
                  else
                    begin
                      if Length(inttostr(strtoint(s3)+1))>Length(inttostr(strtoint(s3))) then
                        begin
                          if s4<>'' then
                            begin
                              s4:=ansileftstr(s4,length(s4)-1)+inttostr(strtoint(s3)+1);
                              goto lab;
                            end
                          else
                            begin
                              s4:='';
                              s:=inttostr(strtoint(AnsiLeftStr(floattostr(r),j-1))+1);
                              goto lab;
                            end;
                        end
                      else
                        begin
                          s4:=s4+inttostr(strtoint(s3)+1);
                          goto lab;
                        end;
                    end;
                  h:=h+1;
                end;
            end
      else
        begin
          s4:=AnsiLeftStr(s1,i);
        end;
lab:  if bflag1 then
         result := strtofloat(s+s4)*-1
      else
          result:=strtofloat(s+s4)   ;
    end;
end;

//********************************************************
//����dbgrideh������
//********************************************************
    procedure gridsort(dbgrideh:Tdbgrideh);
    var
        i:integer;
    begin
        for i:=0 to dbgrideh.Columns.Count-1 do
        begin
            with dbgrideh.Columns[i] do
            begin
                title.TitleButton:=true;
            end;
        end;
//        dbgrideh.OnTitleBtnClick:=DBGridEhTitleBtnClick;

    end;


//*****************************************************************//
//��ʱȡ������
//*****************************************************************//
procedure gridtofile(title:string;dbgrid:Tdbgrideh);
var
    ExpClass:TDBGridEhExportclass;
    Ext:String;
    savedlg:tsavedialog;
begin
    savedlg:=tsavedialog.Create(nil);
    savedlg.Filter:='Text files (*.txt)|*.TXT|Comma separated values (*.csv)|*.CSV|HT' +
    'ML file (*.htm)|*.HTM|Rich Text Format (*.rtf)|*.RTF|Microsoft E' +
    'xcel Workbook (*.xls)|*.XLS';
    savedlg.FilterIndex:=5;
    SaveDlg.FileName := title;
    SaveDlg.DefaultExt := 'xls';
    if SaveDlg.Execute then    begin
        case SaveDlg.FilterIndex of
            1: begin ExpClass := TDBGridEhExportAsText; Ext := 'txt'; end;
            2: begin ExpClass := TDBGridEhExportAsCSV; Ext := 'csv'; end;
            3: begin ExpClass := TDBGridEhExportAsHTML; Ext := 'htm'; end;
            4: begin ExpClass := TDBGridEhExportAsRTF; Ext := 'rtf'; end;
            5: begin ExpClass := TDBGridEhExportAsXLS; Ext := 'xls'; end;
        else
             ExpClass := nil; Ext := '';
        end;
        if ExpClass <> nil then    begin
           if UpperCase(Copy(SaveDlg.FileName,Length(SaveDlg.FileName)-2,3)) <> UpperCase(Ext) then
               SaveDlg.FileName := SaveDlg.FileName + '.' + Ext;
           SaveDBGridEhToExportFile(ExpClass,dbgrid,SaveDlg.FileName,true);        end;
    end;
    Savedlg.Destroy;
end;


//**************************************
//ִ��sql���
//***************************************
//**************************************
//ִ��sql���
//***************************************


//****************************************************
//����cds������
//****************************************************

function isdate(s:string):boolean;
begin
result:=true;
try
    strtodate(s);
except
    result:=false;
end;
end;

    function txttosql(filename:string):Tstringlist;
var
    sqlstr1:Tstringlist;
      SqlStr,Tmp:string;
      F:TextFile;
begin
    sqlstr1:=Tstringlist.Create;
    assignfile(F,filename);
    reset(f);
    Repeat
        Readln(F,tmp);
        sqlstr1.Append(tmp);
    Until   eof(F);
    closefile(F);
    result:=sqlstr1;
end;
procedure SetTimeStory(const Story: Time_Story);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  {���ø�����Ϊ  HKEY_CURRENT_USER}
  Reg.RootKey := HKEY_CURRENT_USER;
  {������   '\Control Panel\International'}
  Reg.OpenKey('\Control Panel\International', False);
  Try   {д������}
    Case Story of
      ts_12:    {12 Сʱ��}
        begin
          Reg.WriteString('iTime', '0');
          Reg.WriteString('iTimePrefix', '1');
          Reg.WriteString('sTimeFormat', 'tt h:mm:ss');
        end;
      ts_24:    {24 Сʱ��}
        begin
          Reg.WriteString('iTime', '1');
          Reg.WriteString('iTimePrefix', '0');
          Reg.WriteString('sTimeFormat', 'HH:mm:ss');
        end;
    end;
  Finally;
    Reg.CloseKey;       {�ر�����}
    Reg.Free;
  end;
end;
    procedure writetxt(filename:string;tstr:string);
var
    Afilepath:string;
    file_:Textfile;
begin
    Afilepath:=extractfilepath(filename);
    if Not DirectoryExists(Afilepath) then
        if not CreateDir(Afilepath) then
            raise Exception.Create('Cannot create '+Afilepath);
    assignfile(file_,filename);
    if FileExists(filename) then
    begin
        try
            reset(file_);
            append(file_);
        except
        end;
    end
    else
    begin
        try
            rewrite(file_);
            append(file_);
        except
        end;
    end;
    writeln(file_,tstr);
    close(file_);

end;
procedure   execregsvr32(filename:string);
  var   winpath:   pchar;
  begin
      getmem(winpath,255);
      GetWindowsDirectory(winpath,255);
      ShellExecute(0,'open',pchar('regsvr32.EXE'),pchar(filename+' -s '),'',SW_HIDE);
      freemem(winpath);
  end;


//****************************************************
//��̬���ù���
//****************************************************
  procedure ExecuteRoutine(Obj: TObject; Name, Param: string);
  var
    PMethod: TMethod;
    AProcedure: TProcedure;
  begin
    PMethod.Data := Pointer(Obj);
    PMethod.Code := Obj.MethodAddress(Name);
    if Assigned(PMethod.Code) then
    begin
      AProcedure := TProcedure(PMethod);
      AProcedure(Param);
    end;
  end;

//****************************************************
//ת��������
//******************************************************
    function yxsj(intstr:string):string;
    begin
        if intstr='' then
            result:='0'
        else
            result:=intstr;
    end;
//***************************************************************
//�����ļ�
//****************************************************************
Procedure FileCopy( Const sourcefilename, targetfilename: String );
var
  NewFile: TFileStream;
  OldFile: TFileStream;
begin
    OldFile := TFileStream.Create(sourcefilename, fmOpenRead or fmShareDenyWrite);
    try
      NewFile := TFileStream.Create(targetfilename, fmCreate or fmShareDenyRead);

      try
        NewFile.CopyFrom(OldFile, OldFile.Size);
      finally
        FreeAndNil(NewFile);
      end;
    finally
      FreeAndNil(OldFile);
    end;

end;

//*****************************************************************
//��ʽ��ʱ��
//**********************************************************
    function time_(datetime:Tdatetime):string;
    var
        strtmp:string;
    begin
        result:=FormatDateTime('yyyy��mm��dd�� tt',datetime);
    end;
//**********************************************************
//��ʽ������
//**********************************************************
    function date_fomat(date:Tdate):string;
    var
        strtmp:string;
    begin
        result:=FormatDateTime('yyyy��mm��dd��',date);
    end;
//***********************************************************
//����ϵͳ�ֱ���
//***********************************************************
function SetdisplaySize(X, Y: word): BOOL;
var
  lpDevMode: TDeviceMode;
begin
  Result := EnumDisplaySettings(nil, 0, lpDevMode);
  if Result then
  begin
    lpDevMode.dmFields := DM_PELSWIDTH Or DM_PELSHEIGHT;
    lpDevMode.dmPelsWidth := X;
    lpDevMode.dmPelsHeight := Y;
    Result := ChangeDisplaySettings(lpDevMode, 0) = DISP_CHANGE_SUCCESSFUL;
  end;
end;
//***********************************************************
//ɾ���ļ���Ŀ¼
//***********************************************************
function Delpath(AFilePath: String): Boolean; stdcall;
var
    i: integer;
    fpath: String;
    PathList: TStringList;
    procedure DelFile(AFilePath: String);
    var
        fpath: String;
        srec: TSearchRec;
    begin
        if Not DirectoryExists(AFilePath) then
            Exit;

        PathList.Add(AFilePath);
        fpath := AFilePath + '\*.*';
        if 0 = FindFirst(fpath, faAnyFile, srec) then
        begin
            if (srec.Name<>'.')and(srec.Name<>'..') then
            begin
                if (srec.Attr and faDirectory)=faDirectory then
                begin
                    DelFile(AFilePath + '\' + srec.Name);
                end
                else DeleteFile(AFilePath + '\' + srec.Name);
            end;

            while FindNext(srec)=0 do
            begin
                if (srec.Name<>'.')and(srec.Name<>'..') then
                    if (srec.Attr and faDirectory)=faDirectory then
                        DelFile(AFilePath + '\' + srec.Name)
                else
                    DeleteFile(AFilePath + '\' + srec.Name);
            end;
        end;
            FindClose(srec);
    end;
begin
    Result := False;
    if Not DirectoryExists(AFilePath) then
    begin
        Result := True;
        Exit;
    end;
    PathList := TStringList.Create;
    fpath := AFilePath;
    if fpath[length(fpath)] = '\' then
        fpath := Copy(fpath, 1, length(fpath)-1);
    DelFile(fpath);
    if PathList.Count > 0 then
        for i:=PathList.Count-1 downto 0 do
            RmDir(pathlist.Strings[i]);

    if Not DirectoryExists(AFilePath) then
        Result := True;
end;

//************************************************
//���������ڽ�С��ʮ����Ԫ��Сд���ת��Ϊ��д
//************************************************

Function gdx_( n0 :real) :String; stdcall;
Const
    c= '��Ҽ��������½��ƾ���ֽ�Ԫʰ��Ǫ��ʰ��Ǫ��ʰ��Ǫ��';
var
    L,i,n, code :integer; Z :boolean; s,s1,s2 :string;
begin
    try
       s:= FormatFloat( '0.00', n0);
       L:= Length( s);
       Z:= n0<1;
       For i:= 1 To L-3 do
       begin
         Val( Copy( s, L-i-2, 1), n, code);
         s1:=IIf( (n=0) And (Z Or (i=9) Or (i=5) Or (i=1)), '', Copy( c, n*2+1, 2))
               + IIf( (n=0) And ((i<>9) And (i<>5) And (i<>1) Or Z And (i=1)), '',
               Copy( c, (i+13)*2-1, 2))+ s1;
         Z:= (n=0);
       end;
       Z:= False;
       For i:= 1 To 2 do
       begin
         Val( Copy( s, L-i+1, 1), n, code);
         s2:= IIf( (n=0) And ((i=1) Or (i=2) And (Z Or (n0<1))), '', Copy( c, n*2+1, 2))
                + IIf( (n>0), Copy( c,(i+11)*2-1, 2), IIf( (i=2) Or Z, '', '��'))+ s2;
         Z:= (n=0);
       end;
       For i:= 1 To Length( s1) do
         If Copy(s1, i, 4) = '����' Then Delete(s1,i+2,2);
       gdx_:= IIf(n0=0, '��', s1+s2);
    except
    end;
End;
{Function gdx_( int :integer) :String;
begin
    case int of
       1:result:='һ';
       2:result:='��';
       3:result:='��';
       4:result:='��';
       5:result:='��';
       6:result:='��';
       7:result:='��';
       8:result:='��';
       9:result:='��';
       10:result:='ʮ';
       11:result:='ʮһ';
       12:result:='ʮ��';

    end;
End;
}
//************************************************
//�õ�����ƴ����д
//***************************************************
function HzPy(const AHzStr: string): string; stdcall;
const
    ChinaCode: array[0..25, 0..1] of Integer = ((1601, 1636), (1637, 1832), (1833, 2077),
    (2078, 2273), (2274, 2301), (2302, 2432), (2433, 2593), (2594, 2786), (9999, 0000),
    (2787, 3105), (3106, 3211), (3212, 3471), (3472, 3634), (3635, 3722), (3723, 3729),
    (3730, 3857), (3858, 4026), (4027, 4085), (4086, 4389), (4390, 4557), (9999, 0000),
    (9999, 0000), (4558, 4683), (4684, 4924), (4925, 5248), (5249, 5589));
var
    i, j, HzOrd: integer;
begin
    i := 1;
    RESULT:='';
    while i <= Length(AHzStr) do
    begin
        if (AHzStr[i] >= #160) and (AHzStr[i + 1] >= #160) then
        begin
            HzOrd := (Ord(AHzStr[i]) - 160) * 100 + Ord(AHzStr[i + 1]) - 160;
            for j := 0 to 25 do
            begin
                if (HzOrd >= ChinaCode[j][0]) and (HzOrd <= ChinaCode[j][1]) then
                begin
                    Result := Result + char(byte('A') + j);
                    break;
                end;
            end;
            Inc(i);
        end
        else
           Result := Result + AHzStr[i];
        Inc(i);
    end;
end;
//********************************************************
//�����滻����еķǷ��ַ�
//********************************************************
function  Check_re(str:string):string;//����滻����еķǷ��ַ�
begin
  result:=StringReplace(str,'''','''''',[rfReplaceAll]);
end;
//********************************************************
//�ж��Ƿ�Ϊ������
//********************************************************


function IsDigit(S:String):Boolean;
var
    i,j:integer;
    h:integer;
begin
    Result:=True;
    j:=0 ;
    h:=0;
    for i:=1 to length(s) do
    begin
        if not (s[i] in ['0'..'9','.','-'])then
            Result:=False;
        if (s[i]='.')  Then

            j:=j+1;
        if (s[i]='-') then
           h:=h+1;
    end;
    if (j>1) or (h>1) then
        Result:=False;
//    if (s[1]='.') or (s[length(s)]='.') then
//        Result:=False;
    s:=copy(s,1, pos('.', S)-1);
    j:=0;
{
    for i:=1 to length(s) do
    begin
        if s[I]='0' then
            j:=j+1;
    end;
    if j>1 then
        Result:=False;
}        
end;
//*****************************************************
//�ַ���ת��Ϊ����
//******************************************************
    function strtochar(str:string):Tarraychar;
    var
        i_strtochar,i_strtocharcount:integer;
    begin
        i_strtocharcount:=length(str);
        setlength(result,i_strtocharcount);
        for i_strtochar:=1 to i_strtocharcount do
        begin
            result[pred(i_strtochar)]:=str[i_strtochar];
        end;
    end;
//*****************************************************
// ����������Ƿ����
//*****************************************************
function   DiskInDrive(Drive:   Char):   Boolean;
var
    ErrorMode:   word;
begin
    if   Drive   in   ['a'..'z']   then   Dec(Drive,   $20);
    if   not   (Drive   in   ['A'..'Z'])   then
        raise   EConvertError.Create('Not   a   valid   drive   ID');
        ErrorMode   :=   SetErrorMode(SEM_FailCriticalErrors);
    try
  {   drive   1   =   a,   2   =   b,   3   =   c,   etc.   }
        if   DiskSize(Ord(Drive)   -   $40)   =   -1   then
             Result   :=   False
        else
            Result   :=   True;
    finally
  {   restore   old   error   mode   }
         SetErrorMode(ErrorMode);
    end;
end;
//*****************************************************
//�õ������ƶ��豸���̷�
//*****************************************************
    function getmovdrive():string;
    var
        i_getdir:integer;
        str_drivename:string;
        str_drivetype:string;
        str_movdrive:string;
    begin
        str_drivename:=getalldrivename();
        for i_getdir:=0 to SubStrConut(str_drivename,'\') do
        begin
            str_drivetype:=memline(str_drivename,'\',i_getdir);
            if getdrivetype(pchar(str_drivetype))=2 then
            begin
                if DiskIndrive(str_drivetype[1]) then
                begin
                    str_movdrive:=str_movdrive+str_drivetype;
                end;
            end;
        end;
        result:=str_movdrive;
    end;
//*****************************************************
//�õ������̷�
//*****************************************************
    function getalldrivename():string;
    var
        drivename:array of char;
        i:integer;
        ilen:integer;
        str:string;
    begin
        setlength(drivename,255);
        ilen:=getlogicaldrivestrings(255,pchar(drivename));
        for i:=0 to ilen-1 do
        begin
            if drivename[i]<>#0 then
            begin
                str:=str+drivename[i];
            end;
        end;
        result:=str;
    end;
//*****************************************************
//�õ�Ŀ¼
//*****************************************************
    function getdir_(caption:string;root:widestring;out dir:string):boolean;
  begin
    if selectDirectory(caption ,root ,dir) then
       //t_Dir����ѡ���Ŀ¼
        result:=true
    else
        result:=false;

  end ;



//*****************************************************
//ȡע�����Ϣ
//*****************************************************
   function getRegString(Rootkey:HKEY;section,key:string):string;
   var
       reg_tmp:Tregistry;
   begin
        reg_tmp:=Tregistry.Create;
        reg_tmp.RootKey:=Rootkey;
        reg_tmp.OpenKey(section,false);
        result:=reg_tmp.ReadString(key);
        reg_tmp.Free;
   end;


//*****************************************************
//��ʾ��Ϣ
//*****************************************************
    function wait_(wind_info:integer):string;overload;
    begin
        application.MessageBox(pchar(inttostr(wind_info)),'ϵͳ������',mb_ok+MB_ICONASTERISK);
        result:='N';

    end;
    function wait_(wind_info:Tdatetime):string;overload;
    var
        wait_tmp:string;
    begin
        application.MessageBox(pchar(datetimetostr(wind_info)),'ϵͳ������',mb_ok+MB_ICONASTERISK);
        result:='N';
    end;

    function wait_(wind_info:string):string;overload;
    begin
        application.MessageBox(pchar(wind_info),'ϵͳ������',mb_ok+MB_ICONASTERISK);
        result:='N';
    end;
    function wait_(wind_info,wind_pic:string):string;overload;
    var
        wait_pic:integer;
    begin
        if wind_pic='?' then

            wait_pic:=MB_ICONQUESTION;
        if wind_pic='X' then
            wait_pic:=MB_ICONHAND;
        if wind_pic='!' then
            wait_pic:=MB_ICONEXCLAMATION;
        if wind_pic='I' then
            wait_pic:=MB_ICONASTERISK;
        if wind_pic='U' then
            wait_pic:=MB_USERICON;
        if wind_pic='' then
            wait_pic:=MB_ICONASTERISK;
        application.MessageBox(pchar(wind_info),'ϵͳ������',mb_ok+wait_pic);
        result:='N';
    end;

    function wait_(wind_info,wind_pic,wind_title:string):string;overload;
    var
        wait_pic:integer;
    begin
        if wind_title='' then
            wind_title:='ϵͳ������';
        if wind_pic='?' then
            wait_pic:=MB_ICONQUESTION;
        if wind_pic='X' then
            wait_pic:=MB_ICONHAND;
        if wind_pic='!' then
            wait_pic:=MB_ICONEXCLAMATION;
        if wind_pic='I' then
            wait_pic:=MB_ICONASTERISK;
        if wind_pic='U' then
            wait_pic:=MB_USERICON;
        if wind_pic='' then
            wait_pic:=MB_ICONASTERISK;
        application.MessageBox(pchar(wind_info),pchar(wind_title),mb_ok+wait_pic);
        result:='N';
    end;
    function wait_(wind_info,wind_pic,wind_title,wind_but:string):string;overload;
    var
        wait_but:integer;
        but_retu:integer;
        wait_pic:integer;
    begin
        if wind_but='O' then
            wait_but:=MB_OK;
        if wind_but='YN' then
            wait_but:=MB_YESNO;
        if wind_but='OC' then
            wait_but:=MB_OKCANCEL;
        if wind_but='ARI' then
            wait_but:=MB_ABORTRETRYIGNORE;
        if wind_but='YNC' then
            wait_but:=MB_YESNOCANCEL;
        if wind_but='RC' then
            wait_but:=MB_RETRYCANCEL;
        if wind_title='' then
            wind_title:='ϵͳ������';
        if wind_pic='?' then
            wait_pic:=MB_ICONQUESTION;
        if wind_pic='X' then
            wait_pic:=MB_ICONHAND;
        if wind_pic='!' then
            wait_pic:=MB_ICONEXCLAMATION;
        if wind_pic='I' then
            wait_pic:=MB_ICONASTERISK;
        if wind_pic='U' then
            wait_pic:=MB_USERICON;
        if wind_pic='' then
            wait_pic:=MB_ICONASTERISK;
        but_retu:=application.MessageBox(pchar(wind_info),pchar(wind_title),wait_but+wait_pic);
        if but_retu=1 then
            result:='O';
        if but_retu=2 then
            result:='C';
        if but_retu=3 then
            result:='A';
        if but_retu=4 then
            result:='R';
        if but_retu=5 then
            result:='I';
        if but_retu=6 then
            result:='Y';
        if but_retu=7 then
            result:='N';
    end;
    function wait_(wind_info,wind_pic,wind_title,wind_but:string;wind_Dbut:integer):string;overload;
    var
        wait_pic:integer;
        wait_but:integer;
        wait_Dbut:integer;
        but_retu:integer;
    begin
        if wind_but='O' then
            wait_but:=MB_OK;
        if wind_but='YN' then
            wait_but:=MB_YESNO;
        if wind_but='OC' then
            wait_but:=MB_OKCANCEL;
        if wind_but='ARI' then
            wait_but:=MB_ABORTRETRYIGNORE;
        if wind_but='YNC' then
            wait_but:=MB_YESNOCANCEL;
        if wind_but='RC' then
            wait_but:=MB_RETRYCANCEL;
        if wind_title='' then
            wind_title:='ϵͳ������';
        if wind_pic='?' then
            wait_pic:=MB_ICONQUESTION;
        if wind_pic='X' then
            wait_pic:=MB_ICONHAND;
        if wind_pic='!' then
            wait_pic:=MB_ICONEXCLAMATION;
        if wind_pic='I' then
            wait_pic:=MB_ICONASTERISK;
        if wind_pic='U' then
            wait_pic:=MB_USERICON;
        if wind_pic='' then
            wait_pic:=MB_ICONASTERISK;
        if wind_Dbut=1 then
            wait_Dbut:=MB_DEFBUTTON1;
        if wind_Dbut=2 then
            wait_Dbut:=MB_DEFBUTTON2;
        if wind_Dbut=3 then
            wait_Dbut:=MB_DEFBUTTON3;

        but_retu:=application.MessageBox(pchar(wind_info),pchar(wind_title),wait_but+wait_pic+wait_Dbut);
        if but_retu=1 then
            result:='O';
        if but_retu=2 then
            result:='C';
        if but_retu=3 then
            result:='A';
        if but_retu=4 then
            result:='R';
        if but_retu=5 then
            result:='I';
        if but_retu=6 then
            result:='Y';
        if but_retu=7 then
            result:='N';
    end;

//****************************************************
//��ȡ����IP
//****************************************************
function LocalIP:string;//��ñ�����ip��ַ
type
    TaPInAddr = array [0..10] of PInAddr;
    PaPInAddr = ^TaPInAddr;
var
    phe  : PHostEnt;
    pptr : PaPInAddr;
    Buffer : array [0..63] of char;
    I    : Integer;
    GInitData      : TWSADATA;
BEGIN
    WSAStartup($101, GInitData);
    Result := '';
    GetHostName(Buffer, SizeOf(Buffer));
    phe :=GetHostByName(buffer);
    IF phe = nil THEN Exit;
    pptr := PaPInAddr(Phe^.h_addr_list);
    I := 0;
    while pptr^[I] <> nil do BEGIN
      result:=StrPas(inet_ntoa(pptr^[I]^));
      Inc(I);
    END;
    WSACleanup;
END;
//*******************************************
//ȡ�ַ����ĵ�N��
//******************************************
function memline(mstr:string;sub_char:char;mlinecount:integer):string;
var
    I_tmp:integer;
    I_tmp1:integer;
begin
    I_tmp:=substrpos(mstr,sub_char,mlinecount+1);
    I_tmp1:=substrpos(mstr,sub_char,mlinecount);
    if mlinecount=0 then
    begin
        result:=copy(mstr,0,iif((I_tmp=0) and (substrconut(mstr,sub_char)=0),length(mstr),I_tmp-1));
    end
    else
    begin
        if substrconut(mstr,sub_char)=mlinecount then
        begin
            result:=copy(mstr,i_tmp1+1,length(mstr)-i_tmp1);
        end
        else
        begin
            result:=copy(mstr,I_tmp1+1,i_tmp-I_tmp1-1);
        end;
    end;
end;
//****************************************
//�����ַ����ڼ�������ָ�������е���ʼλ��
//****************************************
function substrpos(mstr,msub:string;irec:integer):integer;
var
    substrpos_Ctmp:integer;
    int_tmp:integer;
    i:integer;
begin
    substrpos_ctmp:=0;
    for i:=0 to length(mstr) do
    begin
//        int_tmp:=0;
        if substrpos_ctmp>=irec then
           break;
        if copy(mstr,i,1)=msub then
        begin
            int_tmp:=i;
            substrpos_ctmp:=substrpos_ctmp+1;
        end;
    end;
    result:=int_tmp;
end;
//******************************
//�������ַ�������ָ���ִ��еĴ���
//*********************************
function substrconut(mstr,msub:string):integer;
begin
    result:=(length(mstr)-length(stringreplace(mstr,msub,'',[rfreplaceall]))) div length(msub);
end;
//*****************************************************************//
//ѡ����
//*****************************************************************//
function iif(str1: boolean; str2, str3: integer): integer;
begin
    if str1=true then
    begin
        result:=str2;
    end
    else
    begin
        result:=str3;
    end;
end;
function iif(str1: boolean; str2, str3: Currency): Currency;
begin
    if str1=true then
    begin
        result:=str2;
    end
    else
    begin
        result:=str3;
    end;
end;
function iif(str1: boolean; str2, str3: string): string;
begin
    if str1=true then
    begin
        result:=str2;
    end
    else
    begin
        result:=str3;
    end;
end;

function iif(str1: boolean; str2, str3: double): double;
begin
    if str1=true then
    begin
        result:=str2;
    end
    else
    begin
        result:=str3;
    end;
end;

function iif(str1: boolean; str2, str3: Tdatetime): Tdatetime;
begin
    if str1=true then
    begin
        result:=str2;
    end
    else
    begin
        result:=str3;
    end;
end;
//*****************************************************************//
//���ַ�������
//*****************************************************************//
function padl(mystr:string;mycount:integer;mychar:pchar):string;
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
//*****************************************************************//
//�Ҳ��ַ�������
//*****************************************************************//
function padr(mystr:string;mycount:integer;mychar:pchar):string;
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
end.
