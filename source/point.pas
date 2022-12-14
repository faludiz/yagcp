unit point;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  T3DPoint=record
    x,y,z:double;
    name:string;
  end;

  T3DPointList=array of T3DPoint;

procedure Load3DPoints(const fn:string; var pts:T3DPointList);
function GetPointIndex(const name:string; const pts:T3DPointList):integer;
function AddPoint(const p:T3DPoint; var pts:T3DPointList):integer;
function GetPointlist(const pts:T3DPointList):tstringlist;

implementation

procedure Load3DPoints(const fn: string; var pts:T3DPointList);
var
  i:integer;
  lst,dat:tstringlist;
  p:t3dpoint;
begin
  lst:=tstringlist.Create;
  lst.LoadFromFile(fn);
  dat:=tstringlist.Create;
  for i:=0 to lst.Count-1 do begin
    dat.CommaText:=lst[i];
    if dat.Count<4 then continue;
    p:=default(t3dpoint);
    p.name:=dat[0];
    trystrtofloat(dat[1], p.x);
    trystrtofloat(dat[2], p.y);
    trystrtofloat(dat[3], p.z);
    addpoint(p, pts);
  end;
  lst.Free;
  dat.Free;
end;

function GetPointIndex(const name: string; const pts: T3DPointList):integer;
var
  i:integer;
begin
  result:=-1;
  for i:=0 to length(pts)-1 do if name=pts[i].name then begin
    result:=i;
    break;
  end;
end;

function AddPoint(const p: T3DPoint; var pts: T3DPointList): integer;
var
  idx:integer;
begin
  idx:=getpointindex(p.name, pts);
  if idx<0 then begin
    setlength(pts, length(pts)+1);
    idx:=length(pts)-1;
  end;
  pts[idx]:=p;
  result:=idx;
end;

function GetPointlist(const pts: T3DPointList): tstringlist;
var
  i:integer;
begin
  result:=tstringlist.Create;
  for i:=0 to length(pts)-1 do result.Add(pts[i].name);
  result.Sort;
end;

end.

