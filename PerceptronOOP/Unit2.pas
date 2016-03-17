unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Spin, Grids, ValEdit;

type
  TForm2 = class(TForm)
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    PageControl1: TPageControl;
    btnCreateNNet: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpinEdit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCreateNNetClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    fQuit:Boolean;
  end;

var
  Form2: TForm2;

implementation

uses Unit1, Unit3;

{$R *.dfm}


procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Form1.enabled:=true;
end;

procedure TForm2.SpinEdit1Change(Sender: TObject);
var T: TTabSheet;
    P: TPageControl;
begin
  p:=PageControl1;
  T := TTabSheet.Create(P);
  if SpinEdit1.Value>p.PageCount
  then begin
  with T do
  begin
    Caption := 'Выходной слой';
    PageControl := P;
  end;
  P.Pages[p.PageCount-2].Caption:=IntToStr(p.PageCount-2)+' слой';

  with tSpinEdit.create(application) do
  begin
    Parent := P.Pages[p.PageCount-1];
    Left := 150;
    Top := 40;
  end;
  TSpinEdit(p.Pages[p.PageCount-1].Controls[0]).Value:=1;
  TSpinEdit(p.Pages[p.PageCount-1].Controls[0]).MinValue:=1;
  TSpinEdit(p.Pages[p.PageCount-1].Controls[0]).MaxValue:=MaxInt;

  with tLabel.create(application) do
  begin
    Parent := P.Pages[p.PageCount-1];
    caption:='Количество нейронов';
    Left := 10;
    Top := 40;
  end;
  end
  else begin
         p.pages[p.PageCount-1].Hide;
         p.pages[p.PageCount-1].Destroy;
         p.Pages[p.PageCount-1].Caption:= 'Выходной слой';
       end;
end;



procedure TForm2.FormCreate(Sender: TObject);
var T: TTabSheet;
    P: TPageControl;
begin
  p:=PageControl1;
  fQuit:=False;
  T := TTabSheet.Create(P);
  with T do
  begin
    Caption := 'Входной слой';
    PageControl := P;
  end;


  with tSpinEdit.create(application) do
  begin
    Parent := P.Pages[p.PageCount-1];
    Left := 150;
    Top := 40;
  end;
  TSpinEdit(p.Pages[p.PageCount-1].Controls[0]).Value:=1;
  TSpinEdit(p.Pages[p.PageCount-1].Controls[0]).MinValue:=1;
  TSpinEdit(p.Pages[p.PageCount-1].Controls[0]).MaxValue:=MaxInt;

  with tLabel.create(application) do
  begin
    Parent := P.Pages[p.PageCount-1];
    caption:='Количество нейронов';
    Left := 10;
    Top := 40;
  end;


  p:=PageControl1;
  T := TTabSheet.Create(P);

  with T do
  begin
    Caption := 'Выходной слой';
    PageControl := P;
  end;


  with tSpinEdit.create(application) do
  begin
    Parent := P.Pages[p.PageCount-1];
    Left := 150;
    Top := 40;
  end;
  TSpinEdit(p.Pages[p.PageCount-1].Controls[0]).Value:=1;
  TSpinEdit(p.Pages[p.PageCount-1].Controls[0]).MinValue:=1;
  TSpinEdit(p.Pages[p.PageCount-1].Controls[0]).MaxValue:=MaxInt;

  with tLabel.create(application) do
  begin
    Parent := P.Pages[p.PageCount-1];
    caption:='Количество нейронов';
    Left := 10;
    Top := 40;
  end;
end;

procedure TForm2.btnCreateNNetClick(Sender: TObject);
begin
  Form3:=TForm3.Create(Application);
  Form3.Caption:= 'Создание нейронной сети';
  Form3.Show;
end;

procedure TForm2.FormActivate(Sender: TObject);
begin
  if fQuit
  then Close;
end;

end.
