unit main;

{$mode objfpc}{$H+}

interface

uses
  common, point, gcp, crs, CS4BaseTypes, CS4Shapes, CS4Tasks, Classes, SysUtils,
  Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ShellCtrls,
  CADSys4, Types, ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnDel: TButton;
    Button2: TButton;
    CAD:     TCADCmp2D;
    cmbPoints: TComboBox;
    cmbCRS: TComboBox;
    lvImages:      TListView;
    lvPoints: TListView;
    Panel1:  TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PRG:     TCADPrg2D;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    VP:      TCADViewport2D;
    Memo1:   TMemo;
    procedure btnDelClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure lvImagesDblClick(Sender: TObject);
    procedure Panel1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
    procedure VPMouseDown2D(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; WX, WY: TRealType; X, Y: integer);
  private
    pts:     T3DPointList;
    gcps:    TGCPList;
    fcrs:    TCRSList;
    fimg:    string;
    fheight: integer;
    fwidth:  integer;

    procedure Draw(const imgfn: string);
    procedure RefreshIMGList;
    procedure RefreshPointList;
    function ispointfile(const fn:string):boolean;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button2Click(Sender: TObject);
var
  i: integer;
  idx: integer;
begin
  memo1.Clear;
  memo1.Lines.Add(crs.GetCRSDef(cmbCRS.Text, self.fcrs));
  for i := 0 to length(gcps) - 1 do begin

    idx:=getpointindex(gcps[i].name, self.pts);
    if idx>=0 then begin
      memo1.Lines.Add('%0.3f,%0.3f,%0.3f,%0.2f,%0.2f,%s,%s',[
        pts[idx].x,
        pts[idx].y,
        pts[idx].z,
        gcps[i].px,
        gcps[i].height - gcps[i].py,
        extractfilename(gcps[i].img),
        pts[idx].name
      ]);
    end;

  end;
end;

procedure TForm1.btnDelClick(Sender: TObject);
var
  idx: integer;
begin
  // a kombóban lévő pont törlése a képről
  idx := GetCGPIndex(fimg, cmbPoints.Text, self.gcps);
  if idx >= 0 then begin
    delgcp(idx, self.gcps);
    Draw(fimg);
    RefreshIMGList;
    RefreshPointList;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  p: t3dpoint;
begin

  loadcrs('crs-defs.ini', fcrs);
  memo1.Lines.Add('crs=%d', [length(fcrs)]);
  cmbCRS.Clear;
  cmbCRS.Items.AddStrings(GetCRSIDList(fcrs));
  cmbCRS.Text := 'EPSG:23700';

  cad.Layers[0].Pen.Color := clred;
  cad.Layers[0].Pen.Width := 2;

  cad.Layers[1].Pen.Color := clred;
  cad.Layers[1].Pen.Width := 2;

  setlength(pts, 0);
  setlength(gcps, 0);

  p.Name := 'GCP1';
  p.x    := 584000;
  p.y    := 84000;
  p.z    := 123;
  addpoint(p, pts);

  p.Name := 'GCP2';
  p.x    := 585000;
  p.y    := 85000;
  p.z    := 456;
  addpoint(p, pts);

  cmbPoints.Items.AddStrings(GetPointlist(pts));
  cmbPoints.ItemIndex := 0;

end;

procedure TForm1.FormDropFiles(Sender: TObject; const FileNames: array of string);
var
  i: integer;
begin

  if (length(filenames)=1) and ispointfile(filenames[0]) then begin
    lvPoints.Clear;
    setlength(self.pts, 0);
    Load3DPoints(filenames[0], self.pts);
    for i:=0 to length(pts)-1 do with lvPoints.Items.Add do begin
      caption:=pts[i].name;
      subitems.Add('%0.3f', [ pts[i].x ] );
      subitems.Add('%0.3f', [ pts[i].y ] );
      subitems.Add('%0.3f', [ pts[i].z ] );
      subitems.Add('0');
    end;
    RefreshPointList;
    cmbPoints.Clear;
    cmbPoints.Items.AddStrings(GetPointlist(self.pts));
    if cmbPoints.Items.Count>0 then cmbPoints.ItemIndex:=0;
  end else begin
    lvImages.Clear;
    setlength(self.gcps, 0);
    for i := 0 to length(FileNames) - 1 do begin
      memo1.Lines.Add(extractfileext(filenames[i]));
      if lowercase(extractfileext(filenames[i])) <> '.jpg' then continue;
      with lvImages.Items.Add do begin
        Caption := filenames[i];
        subitems.Add(extractfilename(filenames[i]));
        subitems.Add('0');
      end;
    end;
  end;

end;

procedure TForm1.lvImagesDblClick(Sender: TObject);
begin
  if lvImages.Items.Count > 0 then begin
    Draw(lvImages.ItemFocused.Caption);
    vp.ZoomToExtension;
  end;
end;

procedure TForm1.Panel1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
begin
  if wheeldelta < 0 then VP.ZoomOut
  else
    Vp.ZoomIn;
end;

procedure TForm1.VPMouseDown2D(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; WX, WY: TRealType; X, Y: integer);
var
  g:    tgcp;
  pidx: integer;
begin
  memo1.Lines.Add('btn=%d', [Ord(button)]);
  if button = mbLeft then prg.SuspendOperation(TCADPrgRealTimePan, nil);
  if button = mbRight then begin
    with Prg do begin
      SendUserEvent(CADPRG_ACCEPT);
      StopOperation;
    end;
    pidx := getpointindex(cmbPoints.Text, pts);
    if pidx >= 0 then begin
      g.Name   := cmbPoints.Text;
      g.px     := wx;
      g.py     := wy;
      g.img    := fimg;
      g.Height := fheight;
      g.Width  := fwidth;
      if fileexists(fimg) then begin
        addgcp(g, gcps);
        Draw(fimg);
        RefreshIMGList;
        RefreshPointList;
      end;
    end;
  end;
end;

procedure TForm1.Draw(const imgfn: string);
var
  pic: tpicture;
  obj: TBitmap2D;
  i:   integer;
begin
  memo1.Lines.Add('draw.begin');
  if not fileexists(imgfn) then begin
    memo1.Lines.Add('draw.exit');
    exit;
  end;
  cad.DeleteAllObjects;
  cad.CurrentLayer := 0;
  pic := tpicture.Create;
  pic.LoadFromFile(imgfn);
  fheight := pic.Bitmap.Height;
  fwidth  := pic.Bitmap.Width;
  obj     := TBitmap2D.Create(0, point2d(0, 0), point2d(pic.Bitmap.Width, pic.bitmap.Height),
    pic.Bitmap);
  cad.AddObject(0, obj);
  memo1.Lines.Add('image added');
  cad.CurrentLayer := 1;
  memo1.Lines.Add('gcpcount=%d', [length(gcps)]);

  for i := 0 to length(gcps) - 1 do begin

    memo1.Lines.Add('gcps[%d].img=%s, imgfn=%s', [i, gcps[i].img, imgfn]);

    if gcps[i].img = imgfn then begin
      ;

      cad.AddObject(1, tellipse2d.Create(1, point2d(
        gcps[i].px - 20, gcps[i].py - 20), point2d(gcps[i].px + 20, gcps[i].py + 20)));

      cad.AddObject(1, cs4shapes.TText2D.Create(1, rect2d(
        gcps[i].px + 30, gcps[i].py, gcps[i].px + 200, gcps[i].py + 40),
        40, gcps[i].Name));

      cad.AddObject(1, cs4shapes.TLine2D.Create(1, point2d(
        gcps[i].px - 60, gcps[i].py), point2d(gcps[i].px + 60, gcps[i].py)));

      cad.AddObject(1, cs4shapes.TLine2D.Create(1, point2d(
        gcps[i].px, gcps[i].py - 60), point2d(gcps[i].px, gcps[i].py + 60)));

      memo1.Lines.Add('gcp: img=%s, name=%s, x=%f, y=%f', [gcps[i].img,
        gcps[i].Name, gcps[i].px, gcps[i].py]);

    end;

  end;

  fimg := imgfn;

  vp.Refresh;

  memo1.Lines.Add('draw.end');

end;

procedure TForm1.RefreshIMGList;
var
  i: integer;
begin
  for i := 0 to lvImages.Items.Count - 1 do begin
    lvImages.Items[i].SubItems[1] := IntToStr(getgcpcount(lvImages.Items[i].Caption, gcps));
  end;
end;

procedure TForm1.RefreshPointList;
var
  i: integer;
begin
  for i := 0 to lvPoints.Items.Count - 1 do begin
    lvPoints.Items[i].SubItems[3] := IntToStr(getimgcount(lvPoints.Items[i].Caption, gcps));
  end;
end;

function TForm1.ispointfile(const fn:string): boolean;
begin
  result:=false;

  result:= lowercase( extractfileext(fn) ) = '.txt';
  result:= result or (lowercase( extractfileext(fn) ) = '.csv');

end;


end.
