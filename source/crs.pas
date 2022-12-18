unit crs;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TCRS = record
    id:  string;
    def: string;
  end;

  TCRSList = array of TCRS;

procedure LoadCRS(var lst: TCRSList);
function GetCRSIndex(const id: string; const lst: TCRSList): integer;
function GetCRSDef(const id: string; const lst: TCRSList): string;
function GetCRSIDList(const lst: TCRSList): TStringList;
function AddCRS(const c: tcrs; var lst: TCRSList): integer;

implementation

uses
  inifiles, lcltype;

procedure LoadCRS(var lst: TCRSList);
var
  ini: tinifile;
  res: TResourceStream;
  sec: TStringList;
  def: string;
  i:   integer;
  c:   tcrs;
const
  sss = 'CRS-DEFS';
begin
  res := TResourceStream.Create(HInstance, sss, RT_RCDATA);
  ini := tinifile.Create(res);
  sec := TStringList.Create;
  ini.ReadSection(sss, sec);
  for i := 0 to sec.Count - 1 do begin
    def := ini.ReadString(sss, sec[i], '');
    if def <> '' then begin
      c.id  := sec[i];
      c.def := def;
      addcrs(c, lst);
    end;
  end;
  sec.Free;
  ini.Free;
  res.Free;
end;

function GetCRSIndex(const id: string; const lst: TCRSList): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to length(lst) - 1 do if id = lst[i].id then begin
    Result := i;
    break;
  end;
end;

function GetCRSDef(const id: string; const lst: TCRSList): string;
var
  idx: integer;
begin
  Result := '';
  idx    := GetCRSIndex(id, lst);
  if idx >= 0 then Result := lst[idx].def;
end;

function GetCRSIDList(const lst: TCRSList): TStringList;
var
  i: integer;
begin
  Result := TStringList.Create;
  for i := 0 to length(lst) - 1 do Result.Add(lst[i].id);
end;

function AddCRS(const c: tcrs; var lst: TCRSList): integer;
var
  idx: integer;
begin
  idx := GetCRSIndex(c.id, lst);
  if idx < 0 then begin
    setlength(lst, length(lst) + 1);
    idx := length(lst) - 1;
  end;
  lst[idx] := c;
  Result   := idx;
end;

end.
