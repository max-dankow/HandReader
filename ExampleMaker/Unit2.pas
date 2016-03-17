unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, SpeechLib_TLB, OleServer;

type
  TForm2 = class(TForm)
    lblVolume: TLabel;
    trckBarVolume: TTrackBar;
    chkEnabled: TCheckBox;
    lblRate: TLabel;
    trckBarRate: TTrackBar;
    SpVoice1: TSpVoice;
    cbbTembr: TComboBox;
    btnTry: TButton;
    lblTembr: TLabel;
    btnOK: TButton;
    btnClose: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure cbbTembrChange(Sender: TObject);
    procedure btnTryClick(Sender: TObject);
    procedure trckBarVolumeChange(Sender: TObject);
    procedure trckBarRateChange(Sender: TObject);
    procedure chkEnabledClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  Voices:ISpeechObjectTokens;

implementation

uses Unit1;

{$R *.dfm}

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Form1.Enabled:=True;
end;

procedure TForm2.FormCreate(Sender: TObject);
var i:LongInt;
begin
  Voices:=SpVoice1.GetVoices('','');
  for i:=0 to Voices.Count - 1 do
   cbbTembr.Items.Add(Voices.Item(i).GetDescription(0));
  with VoiceSettings do
  begin
    cbbTembr.ItemIndex:=VoiceNumber;
    trckBarVolume.Position:=Volume;
    trckBarRate.Position:=Rate;
    chkEnabled.Checked:=Enabled;
  end;
  chkEnabledClick(@self);
end;

procedure TForm2.cbbTembrChange(Sender: TObject);
begin
    SpVoice1.Voice:=Voices.Item(cbbTembr.ItemIndex);
end;

procedure TForm2.btnTryClick(Sender: TObject);
begin
   SpVoice1.Speak('I will read this text for you.', SVSFlagsAsync);
end;

procedure TForm2.trckBarVolumeChange(Sender: TObject);
begin
  //VoiceSettings.Volume:=trckBarVolume.Position;
  SpVoice1.Volume:=trckBarVolume.Position;
end;

procedure TForm2.trckBarRateChange(Sender: TObject);
begin
//  VoiceSettings.Rate:=trckBarRate.Position;
  SpVoice1.Rate:=trckBarRate.Position;
end;

procedure TForm2.chkEnabledClick(Sender: TObject);
begin
  btnTry.Enabled:=chkEnabled.Checked;
  cbbTembr.Enabled:=chkEnabled.Checked;
  trckBarVolume.Enabled:=chkEnabled.Checked;
  trckBarRate.Enabled:=chkEnabled.Checked;
end;

procedure TForm2.btnOKClick(Sender: TObject);
begin
  with VoiceSettings do
  begin
    VoiceNumber:=cbbTembr.ItemIndex;
    Volume:=trckBarVolume.Position;
    Rate:=trckBarRate.Position;
    Enabled:=chkEnabled.Checked;
  end;
  Form2.Close;
end;

procedure TForm2.btnCloseClick(Sender: TObject);
begin
  Form2.Close;
end;

end.
