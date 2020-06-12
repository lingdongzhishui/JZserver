unit COMLOOK;

interface

uses
SysUtils, Classes, Controls, StdCtrls, Mask, DBCtrlsEh, DBLookupEh,Variants,db,TypInfo;

type
  TCOMLOOK = class(TDBLookupComboboxEh)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
   constructor Create(AOwner: TComponent); override;
   procedure CloseUp(Accept: Boolean); override;
   procedure DoExit; override;
   procedure change; override;
   procedure doenter; override;
   procedure DropDown; override;
   procedure keypress(var key:char); override;
   destructor Destroy; override;
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('gjf', [TCOMLOOK]);
end;

{ TCOMLOOK }

procedure TCOMLOOK.change;
var
    i:integer;
    strtmp:string;
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
begin
    //DBLookupComboboxEh1.DataSource.DataSet;
//    listsource.DataSet:=Nil;
  inherited;
    with ListSource.DataSet do
    begin
        if trim(Text)='' then
        begin
            exit;
        end;

            for i:=0 to  FieldCount-1 do
            begin
//                strtmp:=GetEnumName(TypeInfo(TfieldType),integer(ListSource.DataSet.fields[i].DataType));
                if (ListSource.DataSet.fields[i].DataType = ftString) or (ListSource.DataSet.fields[i].DataType = ftwidestring) then
                    strtmp:=strtmp+iif(strtmp<>'',' or ','')+Fields[i].FieldName +' like ''%'+uppercase(trim(Text))+'%'''
                           +' or '+Fields[i].FieldName +' like ''%'+lowercase(trim(Text))+'%'''   ;
{                try
                    strtoint(text);
                    strtmp:=self.KeyField+'='+text;
                except

                end;
}                
            end;


            Filter:=strtmp;
        Filtered:=true;
    end;



end;

procedure TCOMLOOK.CloseUp(Accept: Boolean);
begin
  inherited;
    if (KeyValue=Null) then
    begin
       Text:=''
    end;
    if listsource<>nil then
        ListSource.DataSet.Filtered:=FALSE;
end;

constructor TCOMLOOK.Create(AOwner: TComponent);
begin
  inherited;
    DropDownBox.AutoDrop := True;
    DropDownBox.Width := 200;
    style:=csDropDownEh;
    keyvalue:=Null;
    text:='';
end;

destructor TCOMLOOK.Destroy;
begin

  inherited;
end;

procedure TCOMLOOK.doenter;
begin
  inherited;

end;

procedure TCOMLOOK.DoExit;
begin
  inherited;

end;

procedure TCOMLOOK.DropDown;
begin
  inherited;

end;

procedure TCOMLOOK.keypress(var key: char);
begin
  inherited;
//    if (selstart=0) and (key<>#13) then text:='';
    if KeyValue<>Null then
    begin
        KeyValue:=Null;
    end;
end;

end.
