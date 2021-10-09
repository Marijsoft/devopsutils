program devopsutils;

{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  princ in 'princ.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

  // ReportMemoryLeaksOnShutdown:=True;
end.
