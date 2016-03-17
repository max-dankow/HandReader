unit MyNeuroNets;

interface
uses //Windows, Messages, SysUtils, Variants,Graphics,WinTypes,Classes;
    Windows,Graphics,SysUtils;

const
  cEadge=100;
  cDelta=1;
type
  tVector=object
            Size:LongInt;
            m:array of real;
            constructor create;
            procedure ReadFromPictureFile(FileName:string);
            destructor Destroy;virtual;
            procedure FillValue(NewValue:real);
            procedure ReadFromBitMap(Bmp:tBitMap);
            end;
  pLayer=^tLayer;
  tNeuron=object
            Name:string;
            OutN:Real;
            Delta:Real;
            nSinapse:word;
            owner:pLayer;
            Level:Integer;//����� ����, � ������� ��������� ������
            MyNumber:integer;
            w:array of Real;
            dw:array of Real;
            constructor Create(NewLevel:Integer;Master:Pointer);
            procedure InitWeight(NewSinapseNumber:integer);
            function Adder:Real;

            function ActivationEadge(x:Real):Real;
            function ActivationExp(x:Real):Real;

            destructor Destroy;virtual;
            procedure ReadFromFile(var f:text);
            procedure ReadFromFileTypeless(var f:file;fOut:boolean);
            procedure TeachDeltaRule(NeedOut:Real;var PicVector:tVector);

            procedure TeachBackPropOut(NeedOut:Real);
            procedure TeachBackPropHide;

            procedure SetOutValue(x:Real);

            //��������� Delta ��������� �����
            function CountDeltaOut(NeedOUt:Real):Real;
            function CountDeltaHide:Real;

            procedure Clear;
            procedure Refresh;

            procedure CountChange;
          end;
  pPerceptron=^tPerceptron;
  tLayer=object
            nNeurons:Word;
            owner:pPerceptron;
            Level:Integer;
            n:array of tNeuron;
            function SinapseTarget(X:integer):Real;
            constructor Create(NewLevel:Integer;Master:Pointer);
            destructor Destroy;virtual;
            procedure ReadFromFile(var f:text);
            procedure ReadFromFileTypeless(var f:file;fOut:boolean);
            procedure CopyFromVetor(var V:tVector);
            function CopyToVector:tVector;
            procedure Run;
            function CountSumForBackProp(NeuronPtr:integer):Real;
            procedure TeachBackPropOut(NeedOutV:tVector);
            function GetPrevLayerAddr:pLayer;
            procedure TeachBackPropHide;
            procedure Clear;
            procedure Refresh;
            procedure CountDeltaOut(NeedOut:tVector);
            procedure CountDeltaHide;
            procedure CountChange;
            function SKO(Need:tVector):Real;
            function GetMissNumber(Max:real; Need:tVector):longint;
            procedure MakeInput(NewNeurons:LongInt);
         end;
  tPerceptron=object
            nLayers:byte;
            L:array of tLayer;
            function SinapseTarget(sLevel,X:integer):Real;
            constructor Create;//������ ��������� ����
            procedure SaveNetToFile(FileName:string);
            destructor Destroy;virtual;
            procedure ReadFromFile(FileName:string);
            procedure ReadFromFileTypeless(FileName:string);
            function RecognizeVector(var Vect:tVector):tVector;//���������� ������������ ������ Vect
            procedure TeachBackProp(NeedOutV:tVector);//�������� ������� ��������� ��������������� ������
            function GetPrevLayerAddr(Sender:longint):pLayer;
            procedure Clear;
            procedure Refresh;
            procedure CountDelta(NeedOut:tVector);
            procedure CountChange;
            procedure TeachMain(NeedOut:tVector);
            function SKO(Need:tVector):Real;
            function GetInfo:string;
            function GetMissNumber(Max:real; Need:tVector):longint;
         end;
    tMass=array [0..1000] of TRGBTriple;
    pMass=^tMass;
var cEta:Real;//��������� �������� ��������
    bmpLine:pMass;
implementation

{***************************** tNeuron  ***************************************}

constructor tNeuron.Create(NewLevel:Integer;Master:Pointer);
begin
  nSinapse:=0;
  OutN:=0;
  owner:=Master;
  Level:=NewLevel;
  SetLength(w,0);
  SetLength(dw,0);
end;

procedure tNeuron.InitWeight(NewSinapseNumber:integer);
var i:integer;
begin
   setlength(w,NewSinapseNumber);
   nSinapse:=NewSinapseNumber;
   setlength(dw,NewSinapseNumber);
   for i:=0 to nSinapse-1 do
   begin
     w[i]:=0;
     dw[i]:=0;
   end;
end;

destructor tNeuron.Destroy;
begin
end;

procedure tNeuron.ReadFromFile(var f:text);
var i:Integer;
begin
   Readln(f,name);
   Readln(f,nSinapse);
   SetLength(w,nSinapse);
   SetLength(dw,nSinapse);
   for i:=0 to nSinapse-1 do
   begin
     readln(f,w[i]);
     dw[i]:=0;
   end;
end;

procedure tNeuron.ReadFromFileTypeless(var f:File;fOut:boolean);
var i:Integer;
    l:word;
    s:char;
begin
  if fOut
  then begin
         BlockRead(f,l,SizeOf(Byte));
         for i:=1 to l do
         begin
           BlockRead(f,s,1);
           Name:=Name+s;
         end;
       end;
   BlockRead(f,nSinapse,SizeOf(word));
   SetLength(w,nSinapse);
   SetLength(dw,nSinapse);
   for i:=0 to nSinapse-1 do
   begin
     BlockRead(f,w[i],SizeOf(real));
     dw[i]:=0;
   end;
end;

function tNeuron.Adder:Real;
var i:Integer;
begin
  result:=0;
  for i:=0 to nSinapse-1 do
  begin
    Result:=Result+w[i]*Owner^.SinapseTarget(i);
  end;
end;

function tNeuron.ActivationEadge(x:Real):Real;
begin
  if x>=cEadge
  then Result:=1
  else Result:=0;
end;

function tNeuron.ActivationExp(x:Real):Real;
begin
  Result:=1/(1+exp(-x));
end;

procedure tNeuron.TeachDeltaRule(NeedOut:Real;var PicVector:tVector);
var i:Integer;
begin
  for i:=0 to nSinapse-1 do
    w[i]:=w[i]+(NeedOut-OutN)*PicVector.m[i]*cDelta;
end;

procedure tNeuron.SetOutValue(x:Real);
begin
  OutN:=x;
end;

Function tNeuron.CountDeltaOut(NeedOut:Real):Real;
begin
  Result:=OutN*(1-OutN)*(NeedOut-OutN);
  Delta:=Result;
end;

Function tNeuron.CountDeltaHide:Real;
var Temp:pLayer;
begin
  Temp:=owner.GetPrevLayerAddr;
  Result:=OutN*(1-OutN)*(Temp^.CountSumForBackProp(MyNumber));
  Delta:=Result;
end;

procedure tNeuron.TeachBackPropOut(NeedOut:Real);
var i:integer;
    //lEta:single;
begin
  Delta:=CountDeltaOut(NeedOut);
  for i:=0 to nSinapse-1 do
   dw[i]:=w[i]+cEta*Delta*(Owner^.SinapseTarget(i));
end;

procedure tNeuron.TeachBackPropHide;
var i:integer;
begin
  Delta:=CountDeltaHide;
  for i:=0 to nSinapse-1 do
   dw[i]:=w[i]+cEta*Delta*(Owner^).SinapseTarget(i);
end;

procedure tNeuron.Clear;
var i:LongInt;
begin
  OutN:=0;
  delta:=0;
  for i:=0 to nSinapse-1 do
   dw[i]:=0;
end;

procedure tNeuron.Refresh;
var i:longint;
begin
  for i:=0 to nSinapse-1 do
  begin
    w[i]:=w[i]+dw[i];
  end;
end;

procedure tNeuron.CountChange;
var i:integer;
begin
  for i:=0 to nSinapse-1 do
   dw[i]:=cEta*Delta*(Owner^).SinapseTarget(i);
end;

{************************** tLayer ********************************************}

constructor tLayer.Create(NewLevel:Integer;Master:Pointer);
begin
  Setlength(n,0);
  nNeurons:=0;
  Level:=NewLevel;
  owner:=Master;
end;

destructor tLayer.Destroy;
var i:integer;
begin
  for i:=0 to nNeurons-1 do
  n[i].Destroy;
end;

procedure tLayer.ReadFromFile(var f:text);
var i:Integer;
begin
   Readln(f,nNeurons);
   SetLength(n,nNeurons);
   for i:=0 to nNeurons-1 do
   begin
     n[i].Create(Level,@Self);
     n[i].MyNumber:=i;
     n[i].ReadFromFile(f);
   end;
end;

procedure tLayer.ReadFromFileTypeless(var f:File;fOut:Boolean);
var i:Integer;
begin
   BlockRead(f,nNeurons,SizeOf(Word));
   SetLength(n,nNeurons);
   for i:=0 to nNeurons-1 do
   begin
     n[i].Create(Level,@Self);
     n[i].MyNumber:=i;
     n[i].ReadFromFileTypeless(f,fOut);
   end;
end;

procedure tLayer.MakeInput(NewNeurons:LongInt);
var i:Integer;
begin
   nNeurons:=NewNeurons;
   SetLength(n,nNeurons);
   for i:=0 to nNeurons-1 do
   begin
     n[i].Create(Level,@Self);
     n[i].MyNumber:=i;
   end;
end;

function tLayer.SinapseTarget(X:integer):Real;
begin
  Result:=tPerceptron(owner^).SinapseTarget(Level,X);
end;

procedure tLayer.CopyFromVetor(var V:tVector);
var i:Integer;
begin
  for i:=0 to nNeurons-1 do
  n[i].SetOutValue(V.m[i]);
end;

function tLayer.CopyToVector:tVector;
var i:Integer;
begin
  Result.create;
  Result.Size:=nNeurons;
  SetLength(Result.m,Result.Size);
  for i:=0 to nNeurons-1 do
    Result.m[i]:=n[i].OutN;
end;

procedure tLayer.Run;
var i:Integer;
begin
  for i:=0 to nNeurons-1 do
    n[i].OutN:=n[i].ActivationExp(n[i].Adder);
end;

function tLayer.CountSumForBackProp(NeuronPtr:integer):Real;
var i:integer;
begin
  result:=0;
  for i:=0 to nNeurons-1 do
    Result:=Result+n[i].Delta*n[i].w[NeuronPtr];
end;

procedure tLayer.TeachBackPropOut(NeedOutV:tVector);
var i:integer;
begin
  for i:=0 to nNeurons-1 do
    n[i].TeachBackPropOut(NeedOutV.m[i]);
end;

procedure tLayer.TeachBackPropHide;
var i:integer;
begin
  for i:=0 to nNeurons-1 do
    n[i].TeachBackPropHide;
end;

function tLayer.GetPrevLayerAddr:pLayer;
begin
  Result:=owner^.GetPrevLayerAddr(Level);
end;

procedure tLayer.Clear;
var i:longint;
begin
  for i:=0 to nNeurons-1 do
   N[i].Clear;
end;

procedure tLayer.Refresh;
var i:LongInt;
begin
  for i:=0 to nNeurons-1 do
  n[i].Refresh;
end;

procedure tLayer.CountDeltaOut(NeedOut:tVector);
var i:longint;
begin
 for i:=0 to nNeurons-1 do
   n[i].CountDeltaOut(NeedOut.m[i]);
end;

procedure tLayer.CountDeltaHide;
var i:longint;
begin
  for i:=0 to nNeurons-1 do
   n[i].CountDeltaHide;
end;

Procedure tLayer.CountChange;
var i:longint;
begin
  for i:=0 to nNeurons-1 do
    n[i].CountChange;
end;

function tLayer.SKO(need:tVector):Real;
var i:LongInt;
begin
  Result:=0;
  for i:=0 to nNeurons-1 do
  result:=result+sqr(need.m[i]-n[i].OutN);
end;

function tLayer.GetMissNumber(Max:real; Need:tVector):LongInt;
var i:LongInt;
begin
  Result:=0;
  for i:=0 to nNeurons-1 do
  if ((Need.m[i]>0.8)and(n[i].OutN<Max))//or((Need.m[i]<0.8)and(n[i].OutN>=Max))
  then begin
        Inc(Result);
        Exit;
       end;
end;

{***************************** tPerceptron ************************************}

constructor tPerceptron.Create;
begin
  nLayers:=0;
  setlength(l,0);
end;

destructor tPerceptron.Destroy;
var i:integer;
begin
  for i:=0 to nLayers-1 do
  l[i].Destroy;
end;

procedure tPerceptron.SaveNetToFile(FileName:string);
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
  b:=nLayers;
  BlockWrite(f,b,SizeOf(b));

  //���������� ��������
  x:=l[0].nNeurons;
  BlockWrite(f,x,SizeOf(x));

  for i:=1 to nLayers-1 do
  begin
    //���������� �������� � i-�� ����: word;
    x:=l[i].nNeurons;
    BlockWrite(f,x,SizeOf(x));

    for j:=0 to l[i].nNeurons-1 do
    begin
      if i=nLayers-1
      then
        begin
          b:=length(l[i].n[j].Name);//������ ����� :byte
          BlockWrite(f,b,SizeOf(b));

          s:=l[i].n[j].Name; //���������� ���
          for k:=1 to Length(s) do
           BlockWrite(f,s[k],1);
        end;
      //���������� �������� � j-�� ������ :word
      x:=l[i].n[j].nSinapse;
      BlockWrite(f,x,SizeOf(x));
      
      for k:=0 to l[i].n[j].nSinapse-1 do
      begin
        //���� �������� � � �� ������� r:real
        r:=l[i].n[j].w[k];
        BlockWrite(f,r,SizeOf(r));
      end;
    end;
  end;
  close(f);
end;
{begin
  assign(f,FileName);
  rewrite(f);
  //���������� ����, ������� �������
  writeln(f,nLayers);
  writeln(f,l[0].nNeurons);
  for i:=0 to l[0].nNeurons-1 do
  begin
    Writeln(f,'nill');
    Writeln(f,0);
    //Writeln(f);
  end;
  for i:=1 to nLayers-1 do
  begin
    //���������� �������� � i-�� ����
    writeln(f,l[i].nNeurons);
    for j:=0 to l[i].nNeurons-1 do
    begin
      //���������� �������� � j-�� ������
      writeln(f,l[i].n[j].name);
      writeln(f,l[i].n[j].nSinapse);
      for k:=0 to l[i].n[j].nSinapse-1 do
      begin
        //���� �������� � � �� �������
        writeln(f,l[i].n[j].w[k]);
      end;
    end;
  end;
  close(f);
end; }


procedure tPerceptron.ReadFromFile(FileName:string);
var i:Integer;
    f:Text;
begin
  Assign(f,FileName);
  Reset(f);
  Readln(f,nLayers);
  SetLength(l,nLayers);
  for i:=0 to nLayers-1 do
  begin
    l[i].Create(i,@Self);
    l[i].ReadFromFile(f);
  end;
  Close(f);
end;

procedure tPerceptron.ReadFromFileTypeless(FileName:string);
var i:Integer;
    f:File;
    x:word;
begin
  Assign(f,FileName);
  Reset(f,1);
  BlockRead(f,nLayers,SizeOf(Byte));
  BlockRead(f,x,SizeOf(word));
  SetLength(l,nLayers);
  l[0].Create(0,@Self);
  l[0].MakeInput(x);
  for i:=1 to nLayers-1 do
  begin
    l[i].Create(i,@Self);
    l[i].ReadFromFileTypeless(f,i=nLayers-1);
  end;
  Close(f);
end;

function tPerceptron.SinapseTarget(sLevel,X:integer):Real;
begin
   Result:=l[sLevel-1].n[X].OutN;
end;

function tPerceptron.RecognizeVector(var Vect:tVector):tVector;
var i:Integer;
begin
  l[0].CopyFromVetor(Vect);
  for i:=1 to nLayers-1 do
    l[i].Run;
  Result.create;
  Result:=l[nLayers-1].CopyToVector;
end;

procedure tPerceptron.TeachBackProp(NeedOutV:tVector);
var i:integer;
begin
  l[nLayers-1].TeachBackPropOut(NeedOutV);
  for i:=nLayers-2 downto 1 do
    l[i].TeachBackPropHide;
end;

function tPerceptron.GetPrevLayerAddr(Sender:longint):pLayer;
begin
  if Sender=nLayers-1
  then Result:=nil
  else Result:=addr(l[Sender+1]);
end;

Function tPerceptron.GetMissNumber(Max:real; Need:tVector):LongInt;
begin
  Result:=l[nLayers-1].GetMissNumber(Max,Need);
end;

procedure tPerceptron.Clear;
var i:longint;
begin
  for i:=0 to nLayers-1 do
   L[i].Clear; 
end;

procedure tPerceptron.Refresh;
var i:LongInt;
begin
  for i:=0 to nLayers-1 do
   l[i].Refresh;
end;

procedure tPerceptron.CountDelta(NeedOut:tVector);
var i:longint;
begin
  l[nLayers-1].CountDeltaOut(NeedOut);
  for i:=nLayers-2 downto 1 do
    l[i].CountDeltaHide;
end;

procedure tPerceptron.TeachMain(NeedOut:tVector);
begin
  CountDelta(NeedOut);
  CountChange;
  Refresh;
end;

procedure tPerceptron.CountChange;
var i:longint;
begin
  for i:=0 to nLayers-1 do
    l[i].CountChange;
end;

function tPerceptron.SKO(Need:tVector):Real;
begin
  Result:=l[nLayers-1].SKO(Need);
end;

function tPerceptron.GetInfo:string;
var i:longint;
begin
  result:='';
  for i:=0 to nLayers-1 do
  begin
    if i=nlayers-1
    then result:=result+inttostr(l[i].nNeurons)
    else result:=result+inttostr(l[i].nNeurons)+' - ';
  end;
end;
{***************************** tVector *********************************}

constructor tVector.create;
begin
  Size:=0;
  SetLength(m,Size);
end;

procedure tVector.ReadFromPictureFile(FileName:string);
var bmp:TBitmap;
    x,y,i,j:Integer;
begin
  bmp:=TBitmap.Create;
  bmp.LoadFromFile(FileName);
  bmp.Monochrome:=True;
  bmp.Mask(clBlack);
  y:=bmp.Height;
  x:=bmp.Width;
  Size:=x*y;
  setlength(m,Size);
  for i:=0 to X-1 do
  begin
    for j:=0 to Y-1 do
    begin
      if   bmp.Canvas.Pixels[i,j]=clBlack
      then m[i*x+j]:=1
      else m[i*x+j]:=0;
    end;
  end;
  bmp.Free;
end;

destructor tVector.Destroy;
begin
end;

procedure tVector.FillValue(NewValue:real);
var i:longint;
begin
  for i:=0 to Size-1 do
  m[i]:=NewValue;
end;

Function RGBtoColor(Color:TRGBTriple):TColor;
begin
  Result:=tColor(RGB(Color.rgbtRed,Color.rgbtGreen,Color.rgbtBlue));
end;

procedure tVector.ReadFromBitMap(Bmp:TBitmap);
var i,j,k:longint;
begin
  Size:=Bmp.Height*Bmp.Width;
  SetLength(m,Size);
  k:=0;
  for i:=0 to Bmp.Height-1 do
   bmpLine:=BMP.ScanLine[i];
   for j:=0 to Bmp.Width-1 do
    begin
      if RGBtoColor(bmpLine[j])=clBlack
      then m[k]:=1
      else m[k]:=0;
      inc(k);
    end;  
end;

end.