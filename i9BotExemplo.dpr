program i9BotExemplo;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  i9Bot in 'i9Bot.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  //Application.CreateForm(TDMWhatsApp, DMWhatsApp);
  Application.Run;
end.
