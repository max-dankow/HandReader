unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ValEdit, Spin;

type
  TForm3 = class(TForm)
    lstNames: TValueListEditor;
    btn1: TButton;
    dlgSave1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;
  n:Integer;

implementation

uses Unit2;

{$R *.dfm}

procedure TForm3.FormCreate(Sender: TObject);
var i:Integer;
begin
    n:=TSpinEdit(Form2.PageControl1.Pages[Form2.SpinEdit1.Value-1].Controls[1]).Value;
  for i:=1 to n do
  lstNames.InsertRow(IntToStr(i),'Neuron Name',true);
end;


procedure SaveNewNet(FileName:string);
var f:text;
    i,j,k:integer;
begin
  Randomize;
  assign(f,FileName);
  rewrite(f);
  //���������� ����, ������� �������
  writeln(f,form2.SpinEdit1.Value);
  Writeln(f,TSpinEdit(Form2.PageControl1.Pages[0].Controls[1]).Value);
  for i:=0 to TSpinEdit(Form2.PageControl1.Pages[0].Controls[1]).Value-1 do
  begin
    Writeln(f,'');
    Writeln(f,0);
    //Writeln(f);
  end;
  for i:=1 to form2.SpinEdit1.Value-1 do
  begin
    //���������� �������� � i-�� ����
    writeln(f,TSpinEdit(Form2.PageControl1.Pages[i].Controls[1]).Value);
    for j:=0 to TSpinEdit(Form2.PageControl1.Pages[i].Controls[1]).Value-1 do
    begin
      //���������� �������� � j-�� ������
      if i=form2.SpinEdit1.Value-1
      then Writeln(f,form3.lstNames.cells[1,j+1])//���
      else Writeln(f);
      writeln(f,TSpinEdit(Form2.PageControl1.Pages[i-1].Controls[1]).Value);
      for k:=0 to TSpinEdit(Form2.PageControl1.Pages[i-1].Controls[1]).Value-1 do
      begin
        //���� �������� � � �� �������
        writeln(f,(random(81)-40)/100,' ')//���������� �������� �� writeln
      end;
      //Writeln(f);
    end;
  end;
  close(f);
end;

procedure SaveNetNormal(FileName:string);
//���������� ��������� ���� � ���������������� ����
var f:file;
    i,j,k,x:word;
    r:real;
    b:byte;
    s:string;
begin
  Randomize;
  assign(f,FileName);
  rewrite(f,1);
  //���������� ����, ������� ������� :byte
  b:=form2.SpinEdit1.Value;
  BlockWrite(f,b,SizeOf(b));

  //���������� ��������
  x:=TSpinEdit(Form2.PageControl1.Pages[0].Controls[1]).Value;
  BlockWrite(f,x,SizeOf(x));

  for i:=1 to form2.SpinEdit1.Value-1 do
  begin
    //���������� �������� � i-�� ����: word;
    x:=TSpinEdit(Form2.PageControl1.Pages[i].Controls[1]).Value;
    BlockWrite(f,x,SizeOf(x));

    for j:=0 to TSpinEdit(Form2.PageControl1.Pages[i].Controls[1]).Value-1 do
    begin
      if i=form2.SpinEdit1.Value-1
      then
        begin
          b:=length(form3.lstNames.cells[1,j+1]);//������ ����� :byte
          BlockWrite(f,b,SizeOf(b));

          s:=form3.lstNames.cells[1,j+1]; //���������� ���
          for k:=1 to Length(s) do
           BlockWrite(f,s[k],1);
        end;
      //���������� �������� � j-�� ������ :word
      x:=TSpinEdit(Form2.PageControl1.Pages[i-1].Controls[1]).Value;
      BlockWrite(f,x,SizeOf(x));
      
      for k:=0 to TSpinEdit(Form2.PageControl1.Pages[i-1].Controls[1]).Value-1 do
      begin
        //���� �������� � � �� ������� r:real
        r:=(random(81)-40)/100;
        BlockWrite(f,r,SizeOf(r));
      end;
    end;
  end;
  close(f);
end;

procedure TForm3.btn1Click(Sender: TObject);
begin
  dlgSave1.InitialDir:=GetCurrentDir+'\NNets';
  if dlgSave1.Execute
  then begin
        SaveNetNormal(dlgSave1.FileName);
        Form2.fQuit:=True;
        Form2.Enabled:=True;
        Form3.Close;
       end;
end;

end.
