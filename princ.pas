unit princ;

interface

uses
        System.SysUtils, System.Types, System.UITypes, System.Classes,
        System.Variants,
        FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
        System.Net.URLClient, System.Net.HttpClient,
        System.Net.HttpClientComponent,
        FMX.TabControl, FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation,
        REST.Types,
        FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
        FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
        Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
        REST.Response.Adapter,
        REST.Client, Data.Bind.Components, Data.Bind.ObjectScope,
        FMX.Memo.Types,
        FMX.ScrollBox, FMX.Memo, System.Rtti, FMX.Grid.Style, Data.Bind.EngExt,
        FMX.Bind.DBEngExt, FMX.Bind.Grid, System.Bindings.Outputs,
        FMX.Bind.Editors,
        Data.Bind.Grid, Data.Bind.DBScope, FMX.Grid, FMX.TMSBaseControl,
        FMX.TMSGauge;

type
        TForm1 = class(TForm)
                GroupBox1: TGroupBox;
                Edit1: TEdit;
                ClearEditButton1: TClearEditButton;
                Button1: TButton;
                Button2: TButton;
                TabControl1: TTabControl;
                TabItem1: TTabItem;
                TabItem2: TTabItem;
                NetHTTPClient1: TNetHTTPClient;
                RESTClient1: TRESTClient;
                RESTRequest1: TRESTRequest;
                RESTResponse1: TRESTResponse;
                RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
                FDMemTable1: TFDMemTable;
                Memo1: TMemo;
                StringGrid1: TStringGrid;
                BindSourceDB1: TBindSourceDB;
                BindingsList1: TBindingsList;
                LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
                Button3: TButton;
                TabItem3: TTabItem;
                Label1: TLabel;
                Label2: TLabel;
                TMSFMXCircularGauge1: TTMSFMXCircularGauge;
                Label3: TLabel;
                TMSFMXCircularGauge2: TTMSFMXCircularGauge;
                Label4: TLabel;
                TMSFMXCircularGauge3: TTMSFMXCircularGauge;
                Label5: TLabel;
                TMSFMXCircularGauge4: TTMSFMXCircularGauge;
                Label6: TLabel;
                Label7: TLabel;
                procedure Button1Click(Sender: TObject);
                procedure RESTRequest1HTTPProtocolError
                  (Sender: TCustomRESTRequest);
                procedure Button2Click(Sender: TObject);
                procedure Button3Click(Sender: TObject);
                procedure RESTClient1HTTPProtocolError
                  (Sender: TCustomRESTClient);
        private
                { Private declarations }
        public
                { Public declarations }
        end;

var
        Form1: TForm1;

implementation

uses System.JSON;
{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
var
        jsontesto, infodominio: string;
begin
        TabControl1.SetActiveTabWithTransition(TabItem1, TTabTransition.Slide);
        if Edit1.Text.Contains('https://') then
                Edit1.Text := Edit1.Text.Remove(0, 8);
        Edit1.Text := Edit1.Text.Replace('/', '');
        infodominio := infodominio.Format
          ('http://ip-api.com/json/%s?fields=status,country,city,as,asname,hosting',
          [Edit1.Text]);
        jsontesto := NetHTTPClient1.Get(infodominio).ContentAsString();
        var
        JSONValue := TJSONObject.ParseJSONValue(jsontesto);
        Memo1.Lines.Clear;
        try
                if JSONValue is TJSONObject then
                begin
                        Memo1.Lines.add
                          ('Controllo: ' + JSONValue.GetValue<string>
                          ('status'));
                        Memo1.Lines.add('Nazione: ' + JSONValue.GetValue<string>
                          ('country'));
                        Memo1.Lines.add
                          ('Località: ' + JSONValue.GetValue<string>('city'));
                        Memo1.Lines.add
                          ('Società: ' + JSONValue.GetValue<string>('as'));
                        Memo1.Lines.add
                          ('Provider: ' + JSONValue.GetValue<string>('asname'));
                        Memo1.Lines.add('Hosting: ' + JSONValue.GetValue<string>
                          ('hosting'));
                end;
        finally
                JSONValue.Free;
        end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
        if Edit1.Text.Contains('https://') then
                Edit1.Text := Edit1.Text.Replace('https://', '');
        Edit1.Text := Edit1.Text.Replace('/', '');

        tthread.CreateAnonymousThread(
                procedure
                begin
                        RESTRequest1.Params.Items[0].Value := Edit1.Text;
                        RESTRequest1.Execute;
                        TabControl1.SetActiveTabWithTransition(TabItem2,
                          TTabTransition.Slide);

                end).Start;
        Button1.Enabled := true;
        Button2.Enabled := true;
        Button3.Enabled := true;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
        jsontesto, sito, s: string;
        JSONValue: TJSonValue;
const
        k = '&key=AIzaSyCh0v5ISSAstAbG1MTgdZjXMDIgPda49UI';
begin
if not (edit1.Text.Contains('https://')) then
Edit1.Text:='https://'+Edit1.Text;
        TabControl1.SetActiveTabWithTransition(TabItem3, TTabTransition.Slide);
        sito := 'https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url='
          + Edit1.Text + k;
        tthread.CreateAnonymousThread(
                procedure
                begin
                        Label7.Visible := true;
                        Button1.Enabled := false;
                        Button2.Enabled := false;
                        Button3.Enabled := false;
                end).Start;
        jsontesto := NetHTTPClient1.Get(sito).ContentAsString();
        JSONValue := TJSONObject.ParseJSONValue(jsontesto);
        try
                if JSONValue is TJSONObject then
                        s := JSONValue.GetValue<string>
                          ('lighthouseResult.audits.speed-index.displayValue');
        finally
                Label2.Text := s;
                JSONValue.DisposeOf;
        end;
        sito := sito.Format
          ('https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=%s&fields=lighthouseResult/categories/*/score&prettyPrint=false&strategy=mobile&category=performance&category=pwa&category=best-practices&category=accessibility&category=seo'
          + k, [Edit1.Text]);
        jsontesto := NetHTTPClient1.Get(sito).ContentAsString();
        JSONValue := TJSONObject.ParseJSONValue(jsontesto);
        try
                if JSONValue is TJSONObject then
                begin
                        var
                        a := JSONValue.GetValue<string>
                          ('lighthouseResult.categories.performance.score');
                        a := a.Replace('0.', '');
                        TMSFMXCircularGauge1.Value := a.ToInteger;
                        TMSFMXCircularGauge1.DisplayText := a;
                        var
                        b := JSONValue.GetValue<string>
                          ('lighthouseResult.categories.accessibility.score');
                        b := b.Replace('0.', '');
                        TMSFMXCircularGauge2.Value := b.ToInteger;
                        TMSFMXCircularGauge2.DisplayText := b;
                        var
                        c := JSONValue.GetValue<string>
                          ('lighthouseResult.categories.best-practices.score');
                        c := c.Replace('0.', '');
                        TMSFMXCircularGauge3.Value := c.ToInteger;
                        TMSFMXCircularGauge3.DisplayText := c;
                        var
                        d := JSONValue.GetValue<string>
                          ('lighthouseResult.categories.seo.score');
                        d := d.Replace('0.', '');
                        TMSFMXCircularGauge4.Value := d.ToInteger;
                        TMSFMXCircularGauge4.DisplayText := d;
                end;
        finally
                JSONValue.Free;
                                Label7.Visible := false;
                                Button1.Enabled := true;
                                Button2.Enabled := true;
                                Button3.Enabled := true;
       end;
end;

procedure TForm1.RESTClient1HTTPProtocolError(Sender: TCustomRESTClient);
begin
        ShowMessage
          ('Errore sconosciuto: mi dispiace emily ma ta pigli der culo!!!');
end;

procedure TForm1.RESTRequest1HTTPProtocolError(Sender: TCustomRESTRequest);
begin
        ShowMessage
          ('Errore sconosciuto: mi dispiace emily ma ta pigli der culo!!!');
end;

end.
