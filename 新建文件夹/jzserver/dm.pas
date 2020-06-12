unit dm;

interface

uses
  SysUtils, Classes, DB, ADODB;

type
  Tdmform = class(TDataModule)
    qrytmp: TADOQuery;
    ADOConnection1: TADOConnection;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmform: Tdmform;

implementation

{$R *.dfm}
 

end.
 