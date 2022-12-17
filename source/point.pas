unit point;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  T3DPoint = record
    x, y, z: double;
    Name:    string;
  end;

  T3DPointList = array of T3DPoint;

procedure Load3DPoints(const fn: string; var pts: T3DPointList);
function GetPointIndex(const Name: string; const pts: T3DPointList): integer;
function AddPoint(const p: T3DPoint; var pts: T3DPointList): integer;
function GetPointlist(const pts: T3DPointList): TStringList;

implementation

procedure Load3DPoints(const fn: string; var pts: T3DPointList);
var
  i: integer;
  lst, dat: TStringList;
  p: t3dpoint;
begin
  lst := TStringList.Create;
  lst.LoadFromFile(fn);
  dat := TStringList.Create;
  for i := 0 to lst.Count - 1 do begin
    dat.CommaText := lst[i];
    if dat.Count < 4 then continue;
    p      := default(t3dpoint);
    p.Name := dat[0];
    trystrtofloat(dat[1], p.x);
    trystrtofloat(dat[2], p.y);
    trystrtofloat(dat[3], p.z);
    if getpointindex(p.Name, pts) < 0 then addpoint(p, pts);
  end;
  lst.Free;
  dat.Free;
end;

function GetPointIndex(const Name: string; const pts: T3DPointList): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to length(pts) - 1 do if Name = pts[i].Name then begin
      Result := i;
      break;
    end;
end;

function AddPoint(const p: T3DPoint; var pts: T3DPointList): integer;
var
  idx: integer;
begin
  idx := getpointindex(p.Name, pts);
  if idx < 0 then begin
    setlength(pts, length(pts) + 1);
    idx := length(pts) - 1;
  end;
  pts[idx] := p;
  Result   := idx;
end;

function GetPointlist(const pts: T3DPointList): TStringList;
var
  i: integer;
begin
  Result := TStringList.Create;
  for i := 0 to length(pts) - 1 do Result.Add(pts[i].Name);
  Result.Sort;
end;

end.
