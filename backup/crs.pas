unit crs;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TCRS=record
    id:string;
    def:string;
  end;

  TCRSList = array of TCRS;

procedure LoadCRS(const fn:string; var lst:TCRSList);
function GetCRSIndex(const id:string; const lst:TCRSList):integer;
function GetCRSDef(const id:string; const lst:TCRSList):string;
function GetCRSIDList(const lst:TCRSList):tstringlist;
function AddCRS(const c:tcrs; var lst:TCRSList):integer;

implementation

uses
  inifiles;

procedure LoadCRS(const fn: string; var lst: TCRSList);
var
  ini:tinifile;
  sec:tstringlist;
  def:string;
  i:integer;
  c:tcrs;
const
  sss = 'CRS-Defs';
begin
  ini:=tinifile.Create(fn);
  sec:=tstringlist.Create;
  ini.ReadSection(sss,sec);
  for i:=0 to sec.Count-1 do begin
    def:=ini.ReadString(sss, sec[i], '');
    if def<>'' then begin
      c.id:=sec[i];
      c.def:=def;
      addcrs(c, lst);
    end;
  end;
  sec.Free;
  ini.Free;
end;

function GetCRSIndex(const id: string; const lst:TCRSList): integer;
var
  i:integer;
begin
  result:=-1;
  for i:=0 to length(lst)-1 do if upcase(id)=upcase(lst[i].id) then begin
    result:=i;
    break;
  end;
end;

function GetCRSDef(const id: string; const lst: TCRSList): string;
var
  idx:integer;
begin
  result:='';
  idx:=GetCRSIndex(id, lst);
  if idx>=0 then result:=lst[idx].def;
end;

function GetCRSIDList(const lst: TCRSList): tstringlist;
var
  i:integer;
begin
  result:=tstringlist.Create;
  for i:=0 to length(lst)-1 do result.Add(lst[i].id);
  result.Sort;
end;

function AddCRS(const c: tcrs; var lst: TCRSList): integer;
var
  idx:integer;
begin
  idx:=GetCRSIndex(c.id, lst);
  if idx<0 then begin
    setlength(lst, length(lst) + 1);
    idx:=length(lst)-1;
  end;
  lst[idx]:=c;
  result:=idx;
end;

end.

