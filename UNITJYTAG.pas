unit UNITJYTAG;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    edtCardid: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    edttotaltoll: TEdit;
    Label3: TLabel;
    EDTTerminalTransNo: TEdit;
    Label4: TLabel;
    edtterminalno: TEdit;
    EDTYEAR: TEdit;
    EDTTIME: TEdit;
    EDTTAC: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    TAC: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses UntJMJ, Uwork;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  fchecktac:Tchecktac;
  mac1:array[0..3] of byte;
  ip,errormsg,strtmp:String;
  port:string;
begin
    ip:='10.14.161.11';
    port:='8';
    Fillchar(fchecktac,SizeOf(Tchecktac),0);
    //卡号+金额+终端号+交易序列号,时间}
    fchecktac.hth:=edtcardid.text;
    fchecktac.money:=StrToInt(edttotaltoll.text);
    fchecktac.TerminalNo:=edtterminalno.text;
    fchecktac.onlinesn:=EDTTerminalTransNo.TEXT;
    fchecktac.CashDate:=EDTYEAR.TEXT;
    fchecktac.Cashtime:=EDTTIME.TEXT;
    fchecktac.Tac:=EDTTAC.TEXT;
    if not checktac(fchecktac,ip,port,
             mac1,errormsg)  then
    begin
           Application.MessageBox('取Tac值失败：','提示');
           Exit;
    end;
    strtmp:=mainclass.arraytostr(mac1);
    TAC.TEXT:=strtmp;
    if UpperCase(EDTTAC.text)<>strtmp then
    begin
     Application.MessageBox('TAC校验不过：','提示');
     Exit;
    end;
    Application.MessageBox('验证TAC完成','提示');
end;

end.
