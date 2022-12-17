unit main;

{$mode objfpc}{$H+}

interface

uses
  point, gcp, crs, CS4BaseTypes, CS4Shapes, CS4Tasks, Classes, SysUtils,
  Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ShellCtrls,
  CADSys4, Types, ComCtrls;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnDel: TButton;
    btnGCPList: TButton;
    btnReset: TButton;
    btnLoadImages: TButton;
    brnLoadPoints: TButton;
    CAD: TCADCmp2D;
    cmbPoints: TComboBox;
    cmbCRS: TComboBox;
    imlSmall: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    lvImages: TListView;
    lvPoints: TListView;
    odImages: TOpenDialog;
    odPoints: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PRG: TCADPrg2D;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    VP:  TCADViewport2D;
    LOG: TMemo;
    procedure btnDelClick(Sender: TObject);
    procedure btnGCPListClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnLoadImagesClick(Sender: TObject);
    procedure brnLoadPointsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure lvImagesDblClick(Sender: TObject);
    procedure lvPointsClick(Sender: TObject);
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

    function GetImageIndex(const fn: string): integer;
    procedure LoadImages(const files: TStringList);
    procedure LoadPoints(const fn: string);
    procedure Draw(const imgfn: string);
    procedure RefreshIMGList;
    procedure RefreshPointList;
    function ispointfile(const fn: string): boolean;

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.btnGCPListClick(Sender: TObject);
var
  i:   integer;
  idx: integer;
begin
  LOG.Clear;
  LOG.Lines.Add(crs.GetCRSDef(cmbCRS.Text, self.fcrs));
  for i := 0 to length(gcps) - 1 do begin

    idx := getpointindex(gcps[i].Name, self.pts);
    if idx >= 0 then begin
      LOG.Lines.Add('%0.3f'#9'%0.3f'#9'%0.3f'#9'%0.2f'#9'%0.2f'#9'%s'#9'%s', [
        pts[idx].x, pts[idx].y, pts[idx].z, gcps[i].px,
        gcps[i].Height - gcps[i].py, extractfilename(gcps[i].img),
        pts[idx].Name]);
    end;

  end;
end;

procedure TfrmMain.btnResetClick(Sender: TObject);
begin
  //reset
  setlength(self.gcps, 0);
  setlength(self.pts, 0);
  lvImages.Clear;
  lvPoints.Clear;
  cmbPoints.Clear;
  Log.Clear;
  Cad.DeleteAllObjects;
end;

procedure TfrmMain.btnLoadImagesClick(Sender: TObject);
var
  i: integer;
begin
  if odImages.Execute then begin
    for i := 0 to odImages.Files.Count - 1 do with lvImages.Items.Add do begin
        Caption := extractfilename(odImages.Files[i]);
        subitems.Add(odImages.Files[i]);
        subitems.Add('0');
        imageindex := 1;
      end;
  end;
end;

procedure TfrmMain.brnLoadPointsClick(Sender: TObject);
begin
  // pontok be
  if odPoints.Execute then begin
    LoadPoints(odPoints.FileName);
    RefreshPointList;
  end;
end;

procedure TfrmMain.btnDelClick(Sender: TObject);
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

procedure TfrmMain.FormCreate(Sender: TObject);
begin

  loadcrs(fcrs);
  LOG.Lines.Add('crs=%d', [length(fcrs)]);
  cmbCRS.Clear;
  cmbCRS.Items.AddStrings(GetCRSIDList(fcrs));
  cmbCRS.Text := 'EPSG:23700';

  cad.Layers[0].Pen.Color := clred;
  cad.Layers[0].Pen.Width := 2;

  cad.Layers[1].Pen.Color := clred;
  cad.Layers[1].Pen.Width := 2;

  setlength(pts, 0);
  setlength(gcps, 0);

  cmbPoints.Items.AddStrings(GetPointlist(pts));
  cmbPoints.ItemIndex := 0;

end;

procedure TfrmMain.FormDropFiles(Sender: TObject; const FileNames: array of string);
var
  files: TStringList;
begin

  if (length(filenames) = 1) and ispointfile(filenames[0]) then begin
    LoadPoints(filenames[0]);
    RefreshPointList;
    cmbPoints.Clear;
    cmbPoints.Items.AddStrings(GetPointlist(self.pts));
    if cmbPoints.Items.Count > 0 then cmbPoints.ItemIndex := 0;
  end else begin
    files := TStringList.Create;
    files.AddStrings(filenames);
    loadimages(files);
    files.Free;
    RefreshIMGList;
  end;

end;

procedure TfrmMain.lvImagesDblClick(Sender: TObject);
begin
  if lvImages.Items.Count > 0 then begin
    Draw(lvImages.ItemFocused.subitems[0]);
    vp.ZoomToExtension;
  end;
end;

procedure TfrmMain.lvPointsClick(Sender: TObject);
begin
  if lvPoints.ItemIndex >= 0 then begin
    cmbPoints.Text := lvPoints.Items[lvPoints.ItemIndex].Caption;
  end;
end;

procedure TfrmMain.Panel1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
begin
  if wheeldelta < 0 then VP.ZoomOut
  else
    Vp.ZoomIn;
end;

procedure TfrmMain.VPMouseDown2D(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; WX, WY: TRealType; X, Y: integer);
var
  g:    tgcp;
  pidx: integer;
begin
  LOG.Lines.Add('btn=%d', [Ord(button)]);
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

function TfrmMain.GetImageIndex(const fn: string): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to lvImages.Items.Count - 1 do if fn = lvImages.Items[i].SubItems[0] then begin
      Result := i;
      break;
    end;
end;

procedure TfrmMain.LoadImages(const files: TStringList);
var
  i: integer;
begin
  for i := 0 to files.Count - 1 do begin
    if (self.GetImageIndex(files[i]) < 0) and
      (lowercase(extractfileext(files[i])) = '.jpg') then begin
      with lvImages.Items.Add do begin
        Caption := extractfilename(files[i]);
        subitems.Add(files[i]);
        subitems.Add('0');
        imageindex := 1;
      end;
    end;
  end;
end;

procedure TfrmMain.LoadPoints(const fn: string);
var
  i: integer;
begin
  load3dpoints(fn, self.pts);
  lvPoints.Clear;
  for i := 0 to length(pts) - 1 do with lvPoints.Items.Add do begin
      Caption := pts[i].Name;
      subitems.Add('%0.3f', [pts[i].x]);
      subitems.Add('%0.3f', [pts[i].y]);
      subitems.Add('%0.3f', [pts[i].z]);
      subitems.Add('0');
      imageindex := 0;
    end;
end;

procedure TfrmMain.Draw(const imgfn: string);
var
  pic: tpicture;
  obj: TBitmap2D;
  i:   integer;
begin
  LOG.Lines.Add('draw.begin');
  if not fileexists(imgfn) then begin
    LOG.Lines.Add('draw.exit');
    exit;
  end;
  cad.DeleteAllObjects;
  cad.CurrentLayer := 0;
  pic := tpicture.Create;
  pic.LoadFromFile(imgfn);
  fheight := pic.Bitmap.Height;
  fwidth  := pic.Bitmap.Width;
  obj     := TBitmap2D.Create(0, point2d(0, 0),
    point2d(pic.Bitmap.Width, pic.bitmap.Height), pic.Bitmap);
  cad.AddObject(0, obj);
  LOG.Lines.Add('image added');
  cad.CurrentLayer := 1;
  LOG.Lines.Add('gcpcount=%d', [length(gcps)]);

  for i := 0 to length(gcps) - 1 do begin

    LOG.Lines.Add('gcps[%d].img=%s, imgfn=%s', [i, gcps[i].img, imgfn]);

    if gcps[i].img = imgfn then begin

      cad.AddObject(1, tellipse2d.Create(1, point2d(
        gcps[i].px - 20, gcps[i].py - 20), point2d(gcps[i].px + 20, gcps[i].py + 20)));

      cad.AddObject(1, cs4shapes.TText2D.Create(1, rect2d(
        gcps[i].px + 30, gcps[i].py, gcps[i].px + 200, gcps[i].py + 40),
        40, gcps[i].Name));

      cad.AddObject(1, cs4shapes.TLine2D.Create(1, point2d(
        gcps[i].px - 60, gcps[i].py), point2d(gcps[i].px + 60, gcps[i].py)));

      cad.AddObject(1, cs4shapes.TLine2D.Create(1, point2d(
        gcps[i].px, gcps[i].py - 60), point2d(gcps[i].px, gcps[i].py + 60)));

      LOG.Lines.Add('gcp: img=%s, name=%s, x=%f, y=%f',
        [gcps[i].img, gcps[i].Name, gcps[i].px, gcps[i].py]);

    end;

  end;

  fimg := imgfn;

  vp.Refresh;

  LOG.Lines.Add('draw.end');

end;

procedure TfrmMain.RefreshIMGList;
var
  i: integer;
begin
  for i := 0 to lvImages.Items.Count - 1 do begin
    lvImages.Items[i].SubItems[1] :=
      IntToStr(getgcpcount(lvImages.Items[i].SubItems[0], gcps));
  end;
end;

procedure TfrmMain.RefreshPointList;
var
  i: integer;
  c: integer;
begin
  for i := 0 to lvPoints.Items.Count - 1 do begin
    lvPoints.Items[i].SubItems[3] :=
      IntToStr(getimgcount(lvPoints.Items[i].Caption, gcps));
  end;
  c := cmbPoints.ItemIndex;
  cmbPoints.Clear;
  cmbPoints.Items.AddStrings(getpointlist(self.pts));
  if c < cmbPoints.Items.Count then cmbPoints.ItemIndex := c;
end;

function TfrmMain.ispointfile(const fn: string): boolean;
begin
  Result := False;
  Result := lowercase(extractfileext(fn)) = '.txt';
  Result := Result or (lowercase(extractfileext(fn)) = '.csv');
end;


end.
