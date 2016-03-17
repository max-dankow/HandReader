unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,  StdCtrls, ExtCtrls, directshow9, ActiveX, Jpeg, WinInet, IniFiles,
  ComCtrls, MyNeuroNets, TeeProcs, TeEngine, Chart, Series, MPlayer, math,
  OleServer, Spin, SpeechLib_TLB, FileCtrl, Menus, ShellAPI;

const cEdge=0.0;
type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    Timer1: TTimer;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    image1: TImage;
    image3: TImage;
    btnSaveFrame: TButton;
    trackBarNeuron: TTrackBar;
    image4: TImage;
    grpSaveExample: TGroupBox;
    txt1: TStaticText;
    seExampleNumber: TSpinEdit;
    txt2: TStaticText;
    lblNeuronNumber: TLabel;
    grpImageOptions: TGroupBox;
    txt4: TStaticText;
    txt5: TStaticText;
    Label7: TLabel;
    Button4: TButton;
    panel1: TPanel;
    btnStart: TButton;
    function CreateGraph: HResult;
    function Initializ: HResult;
    function CaptureBitmap: HResult;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnSaveFrameClick(Sender: TObject);
    procedure trackBarNeuronChange(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ListClick(Sender: TObject);
    procedure btnSoundClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;
  tMass=array [0..1000] of TRGBTriple;
  pMass=^tMass;
  tQuickBMP=array[0..1000,0..1000] of tColor;
  tAvg=record
        m:array[0..10]of tVector;
        Sum:array of Extended;
        Current:integer;
       end;
  tVoiceSettings=record  // ��������� ������
                   Enabled:Boolean;
                   Volume:Byte;     //���������
                   Rate:ShortInt;   //�������� ����
                   VoiceNumber:Byte;//����� ������
                 end;
var
  Form1: TForm1;
  VoiceSettings:tVoiceSettings;
  AVG:tAVG;
  IniFile: TIniFile;
  DeviceName:OleVariant;
  PropertyName:IPropertyBag;
  fPrev:Boolean;
  pDevEnum:ICreateDEvEnum;
  pEnum:IEnumMoniker;
  pMoniker:IMoniker;
  Current:Word;//����� �������� ������� ��� ����������
  Perc:tPerceptron;//������������ ����������
  Pic:tVector;//�������� ��� �������������
  Delta:LongInt;//���������� ������������ ��������
  fMove:Boolean;//����������� ������ ������� ��� ���
  cPunkEadge:LongInt;//������� ������
  DxM,DyM:longint;//����������� �������� ����
  RecognizeResult:LongInt;//��������� ������������� ��� -1
  cDelta:integer;
  MArray1: array of IMoniker; //��� ������ ���������, �� �������
                              //�� ����� ����� �������� ���������� �������
  //����������
  FGraphBuilder:        IGraphBuilder;
  FCaptureGraphBuilder: ICaptureGraphBuilder2;
  FMux:                 IBaseFilter;
  FSink:                IFileSinkFilter;
  FMediaControl:        IMediaControl;
  FVideoWindow:         IVideoWindow;
  FVideoCaptureFilter:  IBaseFilter;
  FAudioCaptureFilter:  IBaseFilter;
  //������� ������ �����������
  FVideoRect:           TRect;

  FBaseFilter:          IBaseFilter;
  FSampleGrabber:       ISampleGrabber;
  MediaType:            AM_MEDIA_TYPE;
  bmpLine:pMass;
  Qbmp,qBMPResult,LastQBMP,qBMPTemp:tQuickBMP;
  GraphicCounter:longint;
  fAnyPixels:boolean;
  
procedure VoiceApplyChanges(SpVoice:tSpVoice;Settings:tVoiceSettings);

implementation

uses Unit2, DateUtils;

{$R *.dfm}

Function RGBtoColor(Color:TRGBTriple):TColor;
begin
  Result:=tColor(RGB(Color.rgbtRed,Color.rgbtGreen,Color.rgbtBlue));
end;

procedure Binarize(Bitmap: TBitmap);
var X, Y: Integer;
begin
  fAnyPixels:=false;
  for X := 0 to Bitmap.Height - 1 do
  begin
    bmpLine:=Bitmap.ScanLine[x];
    for Y := 0 to Bitmap.Width - 1 do
    begin
      If (bmpLine[y].rgbtRed<Form1.TrackBar1.Position)
          and (bmpLine[y].rgbtGreen<Form1.TrackBar2.Position)
          and (bmpLine[y].rgbtBlue<Form1.TrackBar3.Position)
      then Begin
                bmpLine[y].rgbtBlue:=0;
                bmpLine[y].rgbtRed:=0;
                bmpLine[y].rgbtGreen:=0;
           End
      else Begin
                bmpLine[y].rgbtBlue:=255;
                bmpLine[y].rgbtRed:=255;
                bmpLine[y].rgbtGreen:=255;
           End;
    end;
  end;
end;

function CountArea(sx,sy:LongInt;var pic:TBitmap):LongInt;
const MaxQ=10000;
var q:array[0..MaxQ]of record x,y:LongInt; end;
    l,h,t,x,y:LongInt;
  procedure PutQ(x,y:LongInt);
  begin
     if l=MaxQ
     then ShowMessage('������� �����������')
     else begin
            h:=(h+1) mod MaxQ;
            Inc(l);
            q[h].x:=x;
            q[h].y:=y;
          end;
  end;
  procedure GetQ(var x,y:LongInt);
  begin
     if l=0
     then ShowMessage('������� empty')
     else begin
            dec(l);
            x:=q[t].x;
            y:=q[t].y;
            t:=(t+1) mod MaxQ;
          end;
  end;
  function Exist(x,y:longint;pic:TBitmap;var r:longint):boolean;
  begin
      Result:=(x>0)and(y>0)and(x<pic.Height)and(y<pic.Width)
             and(Qbmp[x,y]=clBlack);
      if Result
      then begin
            PutQ(x,y);
            Qbmp[x,y]:=clRed;
            Inc(r);
           end;
end;
begin
  t:=1;
  l:=0;
  h:=0;
  PutQ(sx,sy);
  Result:=0;
  repeat
    GetQ(x,y);
    Exist(x+1,y,pic,result);
    Exist(x-1,y,pic,result);
    Exist(x,y+1,pic,result);
    Exist(x,y-1,pic,result);
  until l=0;
end;

function FillBlue(sx,sy:LongInt;var x1,y1,x2,y2:LongInt;var pic:TBitmap):LongInt;
const MaxQ=10000;
var q:array[0..MaxQ]of record x,y:LongInt; end;
    l,h,t,x,y:LongInt;
  procedure PutQ(x,y:LongInt);
  begin
     if l=MaxQ
     then ShowMessage('������� �����������')
     else begin
            h:=(h+1) mod MaxQ;
            Inc(l);
            q[h].x:=x;
            q[h].y:=y;
          end;
  end;
  procedure GetQ(var x,y:LongInt);
  begin
     if l=0
     then ShowMessage('������� �����')
     else begin
            dec(l);
            x:=q[t].x;
            y:=q[t].y;
            t:=(t+1) mod MaxQ;
          end;
  end;
  function Exist(x,y:longint;pic:TBitmap):boolean;
  begin
    result:=(x>0)and(y>0)and(y<pic.Width)and(x<pic.Height)and(Qbmp[x,y]=clred);
    if Result
    then begin
          PutQ(x,y);
          Qbmp[x,y]:=clBlue;
         end;
  end;
begin
  t:=1;
  l:=0;
  h:=0;
  PutQ(sx,sy);
  Result:=0;
  x1:=MaxLongint;
  x2:=-1;
  y1:=MaxLongint;
  y2:=-1;
  repeat
    GetQ(x,y);
    //if (pic.Canvas.Pixels[x+1,y]=clWhite)or(pic.Canvas.Pixels[x-1,y]=clWhite)or
    //(pic.Canvas.Pixels[x,y+1]=clWhite)or(pic.Canvas.Pixels[x,y-1]=clWhite)
    //then Form1.image4.Canvas.Pixels[x,y]:=clRed;
    
    if x>x2
    then x2:=x;

    if x<x1
    then x1:=x;

    if y>y2
    then y2:=y;

    if y<y1
    then y1:=y;

    Exist(x+1,y,pic);
    Exist(x-1,y,pic);
    Exist(x,y+1,pic);
    Exist(x,y-1,pic);
  until l=0;
end;

procedure MakeThumbNail(src, dest: tBitmap);
 const
  FThumbSize = 150;
 type
   PRGB24 = ^TRGB24;
   TRGB24 = packed record
     B: Byte;
     G: Byte;
     R: Byte;
   end;
 var
   x, y, ix, iy: integer;
   x1, x2, x3: integer;

   xscale, yscale: single;
   iRed, iGrn, iBlu, iRatio: Longword;
   p, c1, c2, c3, c4, c5: tRGB24;
   pt, pt1: pRGB24;
   iSrc, iDst, s1: integer;
   i, j, r, g, b, tmpY: integer;

   RowDest, RowSource, RowSourceStart: integer;
   w, h: integer;
   dxmin, dymin: integer;
   ny1, ny2, ny3: integer;
   dx, dy: integer;
   lutX, lutY: array of integer;

begin
   if src.PixelFormat <> pf24bit then src.PixelFormat := pf24bit;
   if dest.PixelFormat <> pf24bit then dest.PixelFormat := pf24bit;
   w := Dest.Width;
   h := Dest.Height;

   if (src.Width <= FThumbSize) and (src.Height <= FThumbSize) then
   begin
     dest.Assign(src);
     exit;
   end;

   iDst := (w * 24 + 31) and not 31;
   iDst := iDst div 8; //BytesPerScanline
   iSrc := (Src.Width * 24 + 31) and not 31;
   iSrc := iSrc div 8;

   xscale := 1 / (w / src.Width);
   yscale := 1 / (h / src.Height);

   // X lookup table
  SetLength(lutX, w);
   x1 := 0;
   x2 := trunc(xscale);
   for x := 0 to w - 1 do
   begin
     lutX[x] := x2 - x1;
     x1 := x2;
     x2 := trunc((x + 2) * xscale);
   end;

   // Y lookup table
  SetLength(lutY, h);
   x1 := 0;
   x2 := trunc(yscale);
   for x := 0 to h - 1 do
   begin
     lutY[x] := x2 - x1;
     x1 := x2;
     x2 := trunc((x + 2) * yscale);
   end;

   dec(w);
   dec(h);
   RowDest := integer(Dest.Scanline[0]);
   RowSourceStart := integer(Src.Scanline[0]);
   RowSource := RowSourceStart;
   for y := 0 to h do
   begin
     dy := lutY[y];
     x1 := 0;
     x3 := 0;
     for x := 0 to w do
     begin
       dx:= lutX[x];
       iRed:= 0;
       iGrn:= 0;
       iBlu:= 0;
       RowSource := RowSourceStart;
       for iy := 1 to dy do
       begin
         pt := PRGB24(RowSource + x1);
         for ix := 1 to dx do
         begin
           iRed := iRed + pt.R;
           iGrn := iGrn + pt.G;
           iBlu := iBlu + pt.B;
           inc(pt);
         end;
         RowSource := RowSource - iSrc;
       end;
       iRatio := 65535 div (dx * dy);
       pt1 := PRGB24(RowDest + x3);
       pt1.R := (iRed * iRatio) shr 16;
       pt1.G := (iGrn * iRatio) shr 16;
       pt1.B := (iBlu * iRatio) shr 16;
       x1 := x1 + 3 * dx;
       inc(x3,3);
     end;
     RowDest := RowDest - iDst;
     RowSourceStart := RowSource;
   end;

   if dest.Height < 3 then exit;

   // Sharpening... 
   s1 := integer(dest.ScanLine[0]);
   iDst := integer(dest.ScanLine[1]) - s1;
   ny1 := Integer(s1);
   ny2 := ny1 + iDst;
   ny3 := ny2 + iDst;
   for y := 1 to dest.Height - 2 do
   begin
     for x := 0 to dest.Width - 3 do
     begin
       x1 := x * 3;
       x2 := x1 + 3;
       x3 := x1 + 6;

       c1 := pRGB24(ny1 + x1)^;
       c2 := pRGB24(ny1 + x3)^;
       c3 := pRGB24(ny2 + x2)^;
       c4 := pRGB24(ny3 + x1)^;
       c5 := pRGB24(ny3 + x3)^;

       r := (c1.R + c2.R + (c3.R * -12) + c4.R + c5.R) div -8;
       g := (c1.G + c2.G + (c3.G * -12) + c4.G + c5.G) div -8;
       b := (c1.B + c2.B + (c3.B * -12) + c4.B + c5.B) div -8;

       if r < 0 then r := 0 else if r > 255 then r := 255;
       if g < 0 then g := 0 else if g > 255 then g := 255;
       if b < 0 then b := 0 else if b > 255 then b := 255;

       pt1 := pRGB24(ny2 + x2);
       pt1.R := r;
       pt1.G := g;
       pt1.B := b;
     end;
     inc(ny1, iDst);
     inc(ny2, iDst);
     inc(ny3, iDst);
   end;
end;

procedure MakeQuickBMP(Bitmap:TBitmap);
var X,Y:longint;
begin
  for X := 0 to Bitmap.Height - 1 do
  begin
    bmpLine:=Bitmap.ScanLine[x];
    for Y:=0 to Bitmap.Width - 1 do
     Qbmp[x,y]:=RGBtoColor(bmpLine[y]);
  end;
end;

procedure ReturneBMP(var Qbmp:tQuickBMP;Bitmap:TBitmap;Sx,Sy:longint);
var X,Y:longint;
begin
  Bitmap.Height:=Sx;
  Bitmap.Width:=Sy;
  for X := 0 to Bitmap.Height - 1 do
  begin
    bmpLine:=Bitmap.ScanLine[x];
    for Y:=0 to Bitmap.Width - 1 do
    begin
     bmpLine[y].rgbtRed:=GetRValue(Qbmp[x,y]);
     bmpLine[y].rgbtBlue:=GetBValue(Qbmp[x,y]);
     bmpLine[y].rgbtGreen:=GetGValue(Qbmp[x,y]);
    end;
  end;
end;

procedure Search(Pic:TBitmap);
const SizeX=120;
      SizeY=120;
var x,y,t,maxM,mx,my,x1,x2,y1,y2,dx,dy:Longint;
    i:longint;
    a:array[0..100]of Double;
begin
   MakeQuickBMP(Pic);

   mx:=0;
   my:=0;
   MaxM:=-1;
   for X := 0 to Pic.Height - 1 do
   for Y := 0 to Pic.Width - 1 do
   begin
     if Qbmp[x,y]=clBlack
     then
     begin
       t:=CountArea(x,y,Pic);

       if t>MaxM
       then begin
              MaxM:=t;
              mx:=x;
              my:=y;
            end;
       end;
   end;
   //DxM:=0;
   //DyM:=0;
   for x:=0 to sizeX-1 do
     for y:=0 to sizey-1 do
      qBMPResult[X, Y]:=clWhite;
   if MaxM>cPunkEadge
   then
   begin
       FillBlue(mx,my,x1,y1,x2,y2,pic);

       dx:=(SizeX-(x2-x1))div 2;
       if dx<0
       then dx:=0;
       dy:=(Sizey-(y2-y1))div 2;
       if dy<0
       then dy:=0;
       //Form1.img1.Picture.Bitmap:=pic;
       for x:=x1 to x2 do                   //������� �������
       begin
         Qbmp[x,y1]:=clGreen;
         Qbmp[x,y2]:=clGreen;
       end;
       for y:=y1 to y2 do
       begin
         Qbmp[x1,y]:=clGreen;
         Qbmp[x2,y]:=clGreen;
       end;

       ReturneBMP(Qbmp,Pic,Pic.Height,Pic.Width);

       for X := x1 to x2 do
       for Y := y1 to y2 do
       begin
         if Qbmp[X, Y]=clBlue
         then qBMPResult[X-x1+dx, Y-y1+dy]:=clBlack
         else qBMPResult[X-x1+dx, Y-y1+dy]:=clWhite;
         fAnyPixels:=fAnyPixels or (qBMPResult[X-x1+dx, Y-y1+dy]=clBlack);
       end;

       Form1.image3.Picture.Bitmap:=Pic;
       ReturneBMP(qBMPResult,Pic,SizeX,SizeY);
  end;
  ReturneBMP(qBMPResult,Pic,SizeX,SizeY);

  //Form1.image3.Picture.Bitmap:=Form1.imagePrev.Picture.Bitmap;
  //LastQBMP:=copy()
  Delta:=0;
  if fPrev
  then
  begin
  for x:=0 to SizeX-1 do
    for y:=0 to Sizey-1 do
    begin
     if  LastQBMP[x,y]<>qBMPResult[x,y]//(LastQBMP[x,y]=clWhite)and(qBMPResult[x,y]=clBlack)
     then begin
            //Form1.image3.Canvas.Pixels[x,y]:=clGray;
            Inc(delta);
          end;
     {if  (LastQBMP[x,y]=clBlack)and(qBMPResult[x,y]=clWhite)
     then begin
            //Form1.image3.Canvas.Pixels[x,y]:=clGray;
            dec(delta);
          end;}
     LastQBMP[x,y]:=qBMPResult[x,y];
     end;
  end;
  if not fAnyPixels
  then
  begin
    RecognizeResult:=-1;
    if AVG.Current<>0
    then
    begin
      FillChar(AVG.Sum,SizeOf(AVG.Sum),0);
      AVG.Current:=0;
    end;
  end;
  form1.Refresh;

end;

function TForm1.Initializ: HResult;
begin
//������� ������ ��� ������������ ���������
Result:=CoCreateInstance(CLSID_SystemDeviceEnum, NIL, CLSCTX_INPROC_SERVER,
IID_ICreateDevEnum, pDevEnum);
if Result<>S_OK then EXIT;

//������������� ��������� Video
Result:=pDevEnum.CreateClassEnumerator(CLSID_VideoInputDeviceCategory, pEnum, 0);
if Result<>S_OK then EXIT;
//�������� ������ � ������ ���������
setlength(MArray1,0);
//������� ������ �� ������ ���������
while (S_OK=pEnum.Next(1,pMoniker,Nil)) do
begin
setlength(MArray1,length(MArray1)+1); //����������� ������ �� �������
MArray1[length(MArray1)-1]:=pMoniker; //���������� ������� � ������
Result:=pMoniker.BindToStorage(NIL, NIL, IPropertyBag, PropertyName); //������� ������� ���������� � ������� �������� IPropertyBag
if FAILED(Result) then Continue;
Result:=PropertyName.Read('FriendlyName', DeviceName, NIL); //�������� ��� ����������
if FAILED(Result) then Continue;
//��������� ��� ���������� � ������
Listbox1.Items.Add(DeviceName);
end;

//�������������� ����� ��������� ��� ������� �����
//�������� �� ����� ������
if ListBox1.Count=0 then
   begin
      ShowMessage('������ �� ����������');
      Result:=E_FAIL;;
      Exit;
   end;
Listbox1.ItemIndex:=0;
//���� ��� ��
Result:=S_OK;
end;

function TForm1.CreateGraph:HResult;
begin
//������ ����
  FVideoCaptureFilter  := NIL;
  FVideoWindow         := NIL;
  FMediaControl        := NIL;
  FSampleGrabber       := NIL;
  FBaseFilter          := NIL;
  FCaptureGraphBuilder := NIL;
  FGraphBuilder        := NIL;

//������� ������ ��� ����� ��������
Result:=CoCreateInstance(CLSID_FilterGraph, NIL, CLSCTX_INPROC_SERVER, IID_IGraphBuilder, FGraphBuilder);
if FAILED(Result) then EXIT;
// ������� ������ ��� ���������
Result:=CoCreateInstance(CLSID_SampleGrabber, NIL, CLSCTX_INPROC_SERVER, IID_IBaseFilter, FBaseFilter);
if FAILED(Result) then EXIT;
//������� ������ ��� ����� �������
Result:=CoCreateInstance(CLSID_CaptureGraphBuilder2, NIL, CLSCTX_INPROC_SERVER, IID_ICaptureGraphBuilder2, FCaptureGraphBuilder);
if FAILED(Result) then EXIT;

// ��������� ������ � ����
Result:=FGraphBuilder.AddFilter(FBaseFilter, 'GRABBER');
if FAILED(Result) then EXIT;
// �������� ��������� ������� ���������
Result:=FBaseFilter.QueryInterface(IID_ISampleGrabber, FSampleGrabber);
if FAILED(Result) then EXIT;

  if FSampleGrabber <> NIL then
  begin
    // ������������� ������ ������ ��� ������� ���������
    ZeroMemory(@MediaType, sizeof(AM_MEDIA_TYPE));

    with MediaType do
    begin
      majortype  := MEDIATYPE_Video;
      subtype    := MEDIASUBTYPE_RGB24;
      formattype := FORMAT_VideoInfo;
    end;

    FSampleGrabber.SetMediaType(MediaType);

    // ������ ����� �������� � ����� � ��� ����, � ������� ���
    // �������� ����� ������
    FSampleGrabber.SetBufferSamples(TRUE);

    // ���� �� ����� ���������� ��� ��������� �����
    FSampleGrabber.SetOneShot(FALSE);
  end;

//������ ���� ��������
Result:=FCaptureGraphBuilder.SetFiltergraph(FGraphBuilder);
if FAILED(Result) then EXIT;

//����� ��������� ListBox - ��
if Listbox1.ItemIndex>=0 then
           begin
              //�������� ���������� ��� ������� ����� �� ������ ���������
              MArray1[Listbox1.ItemIndex].BindToObject(NIL, NIL, IID_IBaseFilter, FVideoCaptureFilter);
              //��������� ���������� � ���� ��������
              FGraphBuilder.AddFilter(FVideoCaptureFilter, 'VideoCaptureFilter'); //�������� ������ ����� �������
           end;

//������, ��� ������ ����� �������� � ���� ��� ������ ����������
Result:=FCaptureGraphBuilder.RenderStream(@PIN_CATEGORY_PREVIEW, nil, FVideoCaptureFilter ,FBaseFilter  ,nil);
if FAILED(Result) then EXIT;

//�������� ��������� ���������� ����� �����
Result:=FGraphBuilder.QueryInterface(IID_IVideoWindow, FVideoWindow);
if FAILED(Result) then EXIT;
//������ ����� ���� ������
FVideoWindow.put_WindowStyle(WS_CHILD or WS_CLIPSIBLINGS);
//����������� ���� ������ ��  Panel1
FVideoWindow.put_Owner(Panel1.Handle);
//������ ������� ���� �� ��� ������
FVideoRect:=Panel1.ClientRect;
FVideoWindow.SetWindowPosition(FVideoRect.Left,FVideoRect.Top, FVideoRect.Right - FVideoRect.Left,FVideoRect.Bottom - FVideoRect.Top);
//���������� ����
FVideoWindow.put_Visible(TRUE);

//����������� ��������� ���������� ������
Result:=FGraphBuilder.QueryInterface(IID_IMediaControl, FMediaControl);
if FAILED(Result) then Exit;
//��������� ����������� ��������� � ��������
FMediaControl.Run();
end;

function TForm1.CaptureBitmap: HResult;
var
  bSize: integer;
  pVideoHeader: TVideoInfoHeader;
  MediaType: TAMMediaType;
  BitmapInfo: TBitmapInfo;
  Buffer: Pointer;
  tmp: array of byte;
  Bitmap: TBitmap;

 begin

  // ��������� �� ���������
  Result := E_FAIL;

  // ����  ����������� ��������� ������� ��������� �����������,
  // �� ��������� ������
  if FSampleGrabber = NIL then EXIT;

  // �������� ������ �����
    Result := FSampleGrabber.GetCurrentBuffer(bSize, NIL);
    if (bSize <= 0) or FAILED(Result) then EXIT;
  // ������� �����������
  Bitmap := TBitmap.Create;
  try
  // �������� ��� ����� ������ �� ����� � ������� ���������
  ZeroMemory(@MediaType, sizeof(TAMMediaType));
  Result := FSampleGrabber.GetConnectedMediaType(MediaType);
  if FAILED(Result) then EXIT;

    // �������� ��������� �����������
    pVideoHeader := TVideoInfoHeader(MediaType.pbFormat^);
    ZeroMemory(@BitmapInfo, sizeof(TBitmapInfo));
    CopyMemory(@BitmapInfo.bmiHeader, @pVideoHeader.bmiHeader, sizeof(TBITMAPINFOHEADER));

    Buffer := NIL;

    // ������� ��������� �����������
    Bitmap.Handle := CreateDIBSection(0, BitmapInfo, DIB_RGB_COLORS, Buffer, 0, 0);

    // �������� ������ �� ��������� �������
    SetLength(tmp, bSize);

    try
      // ������ ����������� �� ����� ������ �� ��������� �����
      FSampleGrabber.GetCurrentBuffer(bSize, @tmp[0]);

      // �������� ������ �� ���������� ������ � ���� �����������
      CopyMemory(Buffer, @tmp[0], MediaType.lSampleSize);

      //�������� ����������� �� canvas image1
      image1.Picture.Bitmap:=Bitmap;

    except

      // � ������ ���� ���������� ��������� ���������
      Result := E_FAIL;
    end;
  finally
    // ����������� ������
    SetLength(tmp, 0);
    Bitmap.Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
//����� �������� ������� Web-������
var
  StreamConfig: IAMStreamConfig;
  PropertyPages: ISpecifyPropertyPages;
  Pages: CAUUID;
Begin
  // ���� ����������� ��������� ������ � �����, �� ��������� ������
  if FVideoCaptureFilter = NIL then EXIT;
  // ������������� ������ �����
  FMediaControl.Stop;
  try
    // ���� ��������� ���������� �������� ������ ��������� ������
    // ���� ��������� ������, �� ...
    if SUCCEEDED(FCaptureGraphBuilder.FindInterface(@PIN_CATEGORY_CAPTURE,
      @MEDIATYPE_Video, FVideoCaptureFilter, IID_IAMStreamConfig, StreamConfig)) then
    begin
      // ... �������� ����� ��������� ���������� ���������� ������� ...
      // ... �, ���� �� ������, �� ...
      if SUCCEEDED(StreamConfig.QueryInterface(ISpecifyPropertyPages, PropertyPages)) then
      begin
        // ... �������� ������ ������� �������
        PropertyPages.GetPages(Pages);
        PropertyPages := NIL;

        // ���������� �������� ������� � ���� ���������� �������
        OleCreatePropertyFrame(
           Handle,
           0,
           0,
           PWideChar(ListBox1.Items.Strings[listbox1.ItemIndex]),
           1,
           @StreamConfig,
           Pages.cElems,
           Pages.pElems,
           0,
           0,
           NIL
        );

        // ����������� ������
        StreamConfig := NIL;
        CoTaskMemFree(Pages.pElems);
      end;
    end;

  finally
    // ��������������� ������ �����
    FMediaControl.Run;
  end;
end;

procedure VoiceApplyChanges(SpVoice:tSpVoice;Settings:tVoiceSettings);
begin
  with Settings do
  begin
      SpVoice.Rate:=Rate;
      SpVoice.Volume:=Volume;
      SpVoice.Voice:=Voices.Item(VoiceNumber);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i:longint;
begin
    //��������� ��������� �� ini �����
    CoInitialize(nil);// ���������������� OLE COM
    //�������� ��������� ������ � ������������� ��������� ������� ����� � �����
    if FAILED(Initializ) then
        Begin
          ShowMessage('��������! ��������� ������ ��� �������������');
          Exit;
        End;
    //��������� ��������� ������ ���������
    if Listbox1.Count>0 then
        Begin
            //���� ����������� ��� ������ ���������� �������,
            //�� �������� ��������� ���������� ����� ��������
            if FAILED(CreateGraph) then
                Begin
                  ShowMessage('��������! ��������� ������ ��� ���������� ����� ��������');
                  Exit;
                End;
        end else
                Begin
                  ShowMessage('��������! ������ �� ����������.');
                  //Application.Terminate;
                End;
      Current:=0;
      fPrev:=False;
      Pic.create;
      Perc.Create;
      RecognizeResult:=-1;
      fMove:=False;
      DoubleBuffered := true;
      trackBarNeuron.OnChange(@Self);

end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
        // ����������� ������
        pEnum := NIL;
        pDevEnum := NIL;
        pMoniker := NIL;
        PropertyName := NIL;
        DeviceName:=Unassigned;
        CoUninitialize;// ������������������ OLE COM
end;


procedure Invert(BitMap:TBitmap);
var x,y:longint;
    Temp:TRGBTriple;
begin
  for X := 0 to Bitmap.Height - 1 do
  begin
    bmpLine:=Bitmap.ScanLine[x];
    for Y := 0 to (Bitmap.Width) div 2 do
    begin
      temp:=bmpLine[y];
      bmpLine[y]:=bmpLine[Bitmap.Width-y-1];
      bmpLine[Bitmap.Width-y-1]:=temp;
      //bmpLine[y].rgbtRed:=0;
      //bmpLine[y].rgbtBlue:=0;
    end;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
Var dest:tbitmap;
begin
     //��������� ���� ���������� ��� ������� �����������
     if Listbox1.Count=0 then
         Begin
           //ShowMessage('��������! ������ �� ����������.');
           Exit;
         End;
     //������ ����
     if FAILED(CaptureBitmap) then
         Begin
           //ShowMessage('��������! ��������� ������ ��� ��������� �����������');
           Exit;
         End;
     //form1.Image1.Picture.Bitmap.LoadFromFile('C:\Documents and Settings\2013\������� ����\HandReader\bmp.bmp');
     dest:=tbitmap.Create;
     dest.Width:=160;
     dest.Height:=120;

     //Invert(form1.Image1.Picture.Bitmap);

     MakeThumbNail(form1.Image1.Picture.Bitmap, dest);
     form1.Image1.Picture.Bitmap:=dest;
     dest.Destroy;
     image4.Picture.Bitmap:=Image1.Picture.Bitmap;
     Binarize(form1.Image1.Picture.Bitmap);

     Search(form1.Image1.Picture.Bitmap);
     Refresh;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  
  //Timer2.Enabled:=not Timer2.Enabled;
end;


procedure TForm1.btnSaveFrameClick(Sender: TObject);
begin
  image1.Picture.Bitmap.SaveToFile(IntToStr(seExampleNumber.Value)+'_'+lblNeuronNumber.Caption+'.bmp');
  if trackBarNeuron.Position=trackBarNeuron.Max
  then begin
        trackBarNeuron.Position:=trackBarNeuron.Min;
        seExampleNumber.Value:=seExampleNumber.Value+1;
       end
  else trackBarNeuron.Position:=trackBarNeuron.Position+1;
end;

procedure MoveAVG;
var i:integer;
begin
  for i:=0 to AVG.m[0].Size-1 do
   AVG.Sum[i]:=AVG.Sum[i]-AVG.m[0].m[i];
  //AVG.m[0].Destroy;
  for i:=0 to 9 do
  begin
    AVG.m[i]:=AVG.m[i+1];
  end;
end;

procedure TForm1.trackBarNeuronChange(Sender: TObject);
begin
  lblNeuronNumber.Caption:=chr(trackBarNeuron.Position+ord('A'));
end;

procedure TForm1.Button4Click(Sender: TObject);
var s:string;
begin
  s:='';
  SelectDirectory(s,s,s);
  ShowMessage(s);
  SetCurrentDir(s);
end;

procedure TForm1.ListClick(Sender: TObject);
begin
//  SpVoice1.Voice:=Voices.Item(List.ItemIndex);
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
  CreateGraph;
end;

procedure TForm1.btnSoundClick(Sender: TObject);
begin
  Form2:=TForm2.Create(Application);
  Form2.Caption:= '��������� �����';
  Form2.Show;
  Form1.Enabled:=False;
end;

procedure TForm1.btnStartClick(Sender: TObject);
begin
  Timer1.Enabled:=not Timer1.Enabled;
end;

end.
