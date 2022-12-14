unit gcp;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type

  TGCP=record
    px,py:double;
    height:integer;
    width:integer;
    img:string;
    name:string;
  end;

  TGCPList = array of TGCP;

function GetCGPIndex(const img, name:string; const gcps: TGCPList):integer;
function AddGCP(const g:TGCP; var gcps: TGCPList):integer;
function GetGCPCount(const img:string; const gcps: TGCPList):integer;
function GetIMGCount(const pname:string; const gcps: TGCPList):integer;
procedure DelGCP(const idx:integer; var gcps: TGCPList);

implementation

function GetCGPIndex(const img, name: string; const gcps: TGCPList): integer;
var
  i:integer;
begin
  result:=-1;
  for i:=0 to length(gcps)-1 do if (img=gcps[i].img) and (name=gcps[i].name) then begin
    result:=i;
    break;
  end;
end;

function AddGCP(const g: TGCP; var gcps: TGCPList): integer;
var
  idx:integer;
begin
  idx:=GetCGPIndex(g.img, g.name, gcps);
  if idx<0 then begin
    setlength(gcps, length(gcps)+1);
    idx:=length(gcps)-1;
  end;
  gcps[idx]:=g;
  result:=idx;
end;

function GetGCPCount(const img: string; const gcps: TGCPList): integer;
var
  i:integer;
begin
  result:=0;
  for i:=0 to length(gcps)-1 do if img=gcps[i].img then inc(result);
end;

function GetIMGCount(const pname: string; const gcps: TGCPList): integer;
var
  i:integer;
begin
  result:=0;
  for i:=0 to length(gcps)-1 do if pname=gcps[i].name then inc(result);
end;

procedure DelGCP(const idx: integer; var gcps: TGCPList);
var
  i:integer;
begin
  for i:=idx to length(gcps)-2 do begin
    gcps[i]:=gcps[i+1];
  end;
  setlength(gcps, length(gcps)-1 );
end;



end.

