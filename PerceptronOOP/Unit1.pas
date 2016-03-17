unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,MyNeuroNets, Buttons, ExtCtrls, Spin, TeEngine, Series,
  TeeProcs, Chart, XPMan, ComCtrls;

type
  TForm1 = class(TForm)
    SaveDialog1: TSaveDialog;
    dlgOpenNeuroNet: TOpenDialog;
    btnNewNet: TButton;
    btnReadNet: TBitBtn;
    btnSaveNet: TButton;
    btnOpenPicture: TButton;
    dlgOpenBMP: TOpenDialog;
    img1: TImage;
    btnRecognize: TButton;
    lbl1: TLabel;
    btnTeach: TButton;
    Chart1: TChart;
    Series1: TBarSeries;
    trckbrDelta: TTrackBar;
    lblDelta: TLabel;
    trackBarAnswer: TTrackBar;
    lblAnswer: TLabel;
    btnMainTeach: TButton;
    lbl2: TLabel;
    lbl3: TLabel;
    btn1: TButton;
    xpmnfst1: TXPManifest;
    lblMissN: TLabel;
    seSKONormal: TSpinEdit;
    Label1: TLabel;
    lblTeachTime: TLabel;
    seKTime: TSpinEdit;
    procedure btnNewNetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnReadNetClick(Sender: TObject);
    procedure btnSaveNetClick(Sender: TObject);
    procedure btnOpenPictureClick(Sender: TObject);
    procedure btnRecognizeClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure trckbrDeltaChange(Sender: TObject);
    procedure trackBarAnswerChange(Sender: TObject);
    procedure btnMainTeachClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Perc:tPerceptron;
  Pic:tVector;
implementation

uses Unit2;

{$R *.dfm}
procedure TForm1.btnNewNetClick(Sender: TObject);
begin
  Form2:=TForm2.Create(Application);
  Form2.Caption:= 'Создание нейронной сети';
  Form2.Show;
  Form1.Enabled:=False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Caption:='Персептрон';
  lbl1.Caption:='Нет нейронной сети';
  Perc.Create;
  Pic.create;
  trckbrDelta.Position:=1;
  lblDelta.Caption:='1';

  trackBarAnswer.Visible:=False;
  lblAnswer.Caption:='';

  btnRecognize.Enabled:=False;
  btnTeach.Enabled:=False;
end;

procedure TForm1.btnReadNetClick(Sender: TObject);
begin
  dlgOpenNeuroNet.InitialDir:=GetCurrentDir+'\NNets';
  dlgOpenNeuroNet.FileName:='';
  if dlgOpenNeuroNet.Execute
  then
  begin
    Perc.Destroy;        // создание сети заново
    Perc.Create;
    Perc.ReadFromFileTypeless(dlgOpenNeuroNet.FileName);
    lbl1.Caption:=dlgOpenNeuroNet.FileName;
    lbl3.Caption:=Perc.GetInfo;
    btnOpenPicture.Enabled:=true;
    btnSaveNet.Enabled:=True;
    dlgOpenNeuroNet.FileName:='';
    trackBarAnswer.Min:=0;
    trackBarAnswer.Max:=Perc.l[Perc.nLayers-1].nNeurons-1;
    trackBarAnswer.Position:=0;
    trackBarAnswer.OnChange(@self);
    trackBarAnswer.Visible:=True;
  end;
end;

procedure TForm1.btnSaveNetClick(Sender: TObject);
begin
  SaveDialog1.InitialDir:=GetCurrentDir+'\NNets';
  if SaveDialog1.Execute
  then begin
         Perc.SaveNetToFile(SaveDialog1.FileName);
       end;
end;

procedure TForm1.btnOpenPictureClick(Sender: TObject);
begin
  dlgOpenBMP.InitialDir:=GetCurrentDir+'\Pictures';
  dlgOpenBMP.FileName:='';
  if dlgOpenBMP.Execute
  then begin
         Pic.Destroy;
         Pic.create;
         Pic.ReadFromPictureFile(dlgOpenBMP.FileName);
         if Pic.Size<>Perc.L[0].nNeurons
         then begin
            ShowMessage('Не подходящий размер изображения под выбранную нейронную сеть. Выборите подходящую сеть.');
         end
         else begin
                img1.Picture.loadfromfile(dlgOpenBMP.FileName);
                btnRecognize.Enabled:=True;
              end;
         dlgOpenBMP.FileName:='';
         //разрешить распознавать картинку
         btnRecognize.Enabled:=True;
         btnTeach.Enabled:=True;
       end;
end;

procedure TForm1.btnRecognizeClick(Sender: TObject);
var temp:tVector;
    i:Integer;
    max:real;
begin
    temp.create;
    temp.FillValue(0);
    temp:=Perc.RecognizeVector(Pic);
    Series1.Clear;
    max:=temp.m[0];
    for i:=0 to temp.size-1 do
    begin
      if temp.m[i]>max
      then max:=temp.m[i];
    end;
    for i:=0 to temp.size-1 do
    begin
      if temp.m[i]>=max
      then series1.Add(Round(temp.m[i]*100),Perc.l[Perc.nlayers-1].n[i].Name,clGreen)
      else series1.Add(Round(temp.m[i]*100),Perc.l[Perc.nlayers-1].n[i].Name,clRed)
    end;
    temp.Destroy;
end;

procedure TForm1.Button1Click(Sender: TObject);
var temp,tempOut:tVector;
    i:Integer;
begin
    temp.create;
    tempOut.create;

    Perc.Clear;
    //распознавание сетью Perc вектора Pic, результат в Temp
    //temp.FillValue(0);
    temp:=Perc.RecognizeVector(Pic);
    cEta:={se1.Value}trckbrDelta.Position/100;
    //выводим результат в гистограмму
    Series1.Clear;
    for i:=0 to temp.size-1 do
      Series1.Add(Round(temp.m[i]*1000),Perc.l[Perc.nlayers-1].n[i].Name,clRed);
    //формирование TempOut - вектора необходимого результата
    tempOut.create;
    tempout.Size:=temp.size;
    SetLength(tempout.m,tempOut.size);
    tempOut.FillValue(0.1);
    TempOut.m[trackBarAnswer.Position]:=0.9;
    //Обучение Сети Perc

    //Perc.TeachBackProp(TempOut);
    Perc.TeachMain(tempOut);
    //Perc.Refresh;

    //повторно распознать
    btnRecognize.Click;

    temp.Destroy;
    tempOut.Destroy;
end;

procedure TForm1.trckbrDeltaChange(Sender: TObject);
begin
lblDelta.Caption:=inttostr(trckbrDelta.Position);
end;

procedure TForm1.trackBarAnswerChange(Sender: TObject);
begin
  if (Perc.nLayers>1)and(Perc.l[Perc.nLayers-1].nNeurons>0)
  then lblAnswer.Caption:=Perc.l[Perc.nLayers-1].n[trackBarAnswer.position].Name;
end;

procedure LoadPic(Name:string);
begin
   Pic.Destroy;
   Pic.create;
   Pic.ReadFromPictureFile(Name);
   if Pic.Size<>Perc.L[0].nNeurons
   then begin
      ShowMessage('Не подходящий размер изображения под выбранную нейронную сеть. Выберите подходящую сеть.');
   end
   else begin
          form1.img1.Picture.loadfromfile(Name);
          Form1.btnRecognize.Enabled:=True;
        end;
end;

function GetNumber(s:string):LongInt;
var x,y:LongInt;
    temp:string;
begin
  x:=Pos('_',s);
  y:=Pos('.',s);
  temp:=Copy(s,x+1,y-x-1);
  if temp[1] in ['A'..'Z']
  then result:=ord(temp[1])-ord('A')  //если это буква алфавита
  else result:=StrToInt(temp)         //если это цифра
end;

procedure TForm1.btnMainTeachClick(Sender: TObject);
var temp,tempOut:tVector;
    i,m,e:Integer;
    sko:Single;
    SearchResult:tSearchRec;
    Time,CurrentTime:cardinal;
begin
 cEta:=trckbrDelta.Position/100;
 Time:=GetTickCount;
 repeat
    sko:=0;
    if FindFirst('*.bmp',faAnyFile,SearchResult)=0
    then
    begin
      e:=0;
      cEta:=cEta-cEta*(seKTime.Value/100);
      trckbrDelta.Position:=round(cEta*100);
      repeat
            LoadPic(SearchResult.Name);
            label1.caption:=SearchResult.Name;

            temp.create;
            tempOut.create;
            Perc.Clear;
            //распознавание сетью Perc вектора Pic, результат в Temp
            //temp.FillValue(0);
            temp:=Perc.RecognizeVector(Pic);
            //cEta:=trckbrDelta.Position/100;
            //выводим результат в гистограмму
            Series1.Clear;
            m:=0;
            for i:=0 to temp.size-1 do
            begin
              if Round(temp.m[m]*1000)<Round(temp.m[i]*1000)
              then m:=i;
              //Series1.Add(Round(temp.m[i]*1000),Perc.l[Perc.nlayers-1].n[i].Name,clRed);
            end;  
            //формирование TempOut - вектора необходимого результата
            tempOut.create;
            tempout.Size:=temp.size;
            SetLength(tempout.m,tempOut.size);
            tempOut.FillValue(0);
            TempOut.m[GetNumber(SearchResult.Name)]:=1;
            sko:=sko+perc.SKO(tempOut);
            e:=e+Perc.GetMissNumber(temp.m[m],tempOut);
            //Обучение Сети Perc

            //Perc.TeachBackProp(TempOut);
            Perc.TeachMain(tempOut);
            //Perc.Refresh;

            //повторно распознать
            btnRecognize.Click;

            temp.Destroy;
            tempOut.Destroy;

            CurrentTime:=GetTickCount-Time;
            lblTeachTime.Caption:=inttostr(((CurrentTime)mod 1000))+'ms';
            CurrentTime:=CurrentTime div 1000;
            lblTeachTime.Caption:=inttostr(((CurrentTime)mod 60))+'s '+lblTeachTime.Caption;
            CurrentTime:=CurrentTime div 60;
            lblTeachTime.Caption:=inttostr(((CurrentTime)mod 60))+'m '+lblTeachTime.Caption;
            CurrentTime:=CurrentTime div 60;
            lblTeachTime.Caption:=inttostr(((CurrentTime)))+'h '+lblTeachTime.Caption;

            Form1.Refresh;
            Application.ProcessMessages;
      until (FindNext(SearchResult)<>0);
      lblMissN.Caption:=IntToStr(e);
      lbl2.Caption:=inttostr(round(100*sko/2));
      Form1.Refresh;
      FindClose(SearchResult);
    end;
  until round(100*sko/2)<=form1.seSKONormal.Value;
  ShowMessage('Обучение успешно завершено. Прошедшее время - '+lblTeachTime.Caption);
end;
procedure TForm1.btn1Click(Sender: TObject);
var temp,tempOut:tVector;
    i,m,e:Integer;
    sko:Single;
    SearchResult:tSearchRec;
begin
    sko:=0;
    if FindFirst('*.bmp',faAnyFile,SearchResult)=0
    then
    begin
      e:=0;
      repeat
            LoadPic(SearchResult.Name);
            label1.caption:=SearchResult.Name;

            temp.create;
            tempOut.create;
            Perc.Clear;
            //распознавание сетью Perc вектора Pic, результат в Temp
            temp.FillValue(0);
            temp:=Perc.RecognizeVector(Pic);
            //cEta:={se1.Value}trckbrDelta.Position/100;
            //выводим результат в гистограмму
            Series1.Clear;
            m:=0;
            for i:=0 to temp.size-1 do
            begin
              if Round(temp.m[m]*1000)<Round(temp.m[i]*1000)
              then m:=i;
              //Series1.Add(Round(temp.m[i]*1000),Perc.l[Perc.nlayers-1].n[i].Name,clRed);
            end;
            //формирование TempOut - вектора необходимого результата
            tempOut.create;
            tempout.Size:=temp.size;
            SetLength(tempout.m,tempOut.size);
            tempOut.FillValue(0);
            TempOut.m[Getnumber(SearchResult.Name)]:=1;
            //btnRecognize.Click;
            sko:=sko+perc.SKO(tempOut);
            if Perc.GetMissNumber(temp.m[m],tempOut)>0
            then begin
                   e:=e+Perc.GetMissNumber(temp.m[m],tempOut);
                   btnRecognize.Click;
                   Form1.Refresh;
                   sleep(3000);
                 end;

            //Обучение Сети Perc

            //Perc.TeachBackProp(TempOut);
            //Perc.TeachMain(tempOut);
            //Perc.Refresh;

            //повторно распознать
            //btnRecognize.Click;

            temp.Destroy;
            tempOut.Destroy;
            Form1.Refresh;
            Application.ProcessMessages;
            Form1.Refresh;
      until FindNext(SearchResult)<>0;
      lblMissN.Caption:=IntToStr(e);
      lbl2.Caption:=inttostr(round(100*sko/2));
      FindClose(SearchResult);
    end;
end;

end.
