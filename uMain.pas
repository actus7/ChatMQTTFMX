unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Actions, System.StrUtils,
  FMX.Types, FMX.Controls, FMX.Graphics, FMX.Forms, FMX.Dialogs, FMX.TabControl,
  FMX.ActnList, FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit,
  FMX.Layouts, FMX.ListBox
  // Libs do Cliente MQTT
{$IFDEF MSWINDOWS}
    , QMqttClient, Winapi.Windows
{$ENDIF}
{$IFDEF POSIX}
    , TMS.MQTT.Global, TMS.MQTT.Client, Androidapi.JNI.Os // TJBuild
    , Androidapi.Helpers // StringToJString
{$ENDIF}
    ;

type
  TfrmMain = class(TForm)
    ActionList: TActionList;
    Sair: TPreviousTabAction;
    TitleAction: TControlAction;
    Sala: TNextTabAction;
    TopToolBar: TToolBar;
    btnBack: TSpeedButton;
    ToolBarLabel: TLabel;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    BottomToolBar: TToolBar;
    btnSala1: TButton;
    btnSala2: TButton;
    btnSala3: TButton;
    lbChat: TListBox;
    lblStatus: TLabel;
    Panel1: TPanel;
    edtMensagem: TEdit;
    btnEnviar: TButton;
    Panel2: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure TitleActionUpdate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure btnSala1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnEnviarClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnSala2Click(Sender: TObject);
    procedure btnSala3Click(Sender: TObject);
  private

{$IFDEF MSWINDOWS}
    FClient: TQMQTTMessageClient;
    procedure DoAfterPublished(ASender: TQMQTTMessageClient;
      const ATopic: String; const AReq: PQMQTTMessage);
    procedure DoClientConnected(ASender: TQMQTTMessageClient);
    procedure DoClientConnecting(ASender: TQMQTTMessageClient);
    procedure DoClientDisconnected(ASender: TQMQTTMessageClient);
    procedure DoClientError(ASender: TQMQTTMessageClient;
      const AErrorCode: Integer; const AErrorMsg: String);
    procedure DoRecvTopic(ASender: TQMQTTMessageClient; const ATopic: String;
      const AReq: PQMQTTMessage);
{$ENDIF}
{$IFDEF POSIX}
    FClient: TTMSMQTTClient;
    procedure ConnectedStatusChanged(ASender: TObject;
      const AConnected: Boolean; AStatus: TTMSMQTTConnectionStatus);
    procedure PublishReceived(ASender: TObject; APacketID: Word; ATopic: string;
      APayload: TArray<System.Byte>);
{$ENDIF}
    function GetLocalComputerName: string;
    procedure FormShow(Sender: TObject);
    procedure AddMessage(AMessage: string; AlignRight: Boolean);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

const
  ChatChannel = '/CHAT';

{$R *.fmx}

function TfrmMain.GetLocalComputerName: string;
{$IFDEF MSWINDOWS}
var
  c1: DWORD;
  arrCh: array [0 .. MAX_COMPUTERNAME_LENGTH] of Char;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  c1 := MAX_COMPUTERNAME_LENGTH + 1;
  if GetComputerName(arrCh, c1) then
    SetString(Result, arrCh, c1)
  else
    Result := '';
{$ENDIF}
{$IFDEF POSIX}
  Result := JStringToString(TJBuild.JavaClass.HOST);
{$ENDIF}
end;

procedure TfrmMain.TitleActionUpdate(Sender: TObject);
begin
  if Sender is TCustomAction then
  begin
    if TabControl1.ActiveTab <> nil then
      TCustomAction(Sender).Text := TabControl1.ActiveTab.Text
    else
      TCustomAction(Sender).Text := '';
  end;
end;

procedure TfrmMain.btnSala1Click(Sender: TObject);
begin
  if btnSala1.Tag = 0 then
  begin
{$IFDEF MSWINDOWS}
    if not Assigned(FClient) then
      FClient := TQMQTTMessageClient.Create(Self);
    FClient.Stop;
    FClient.ClientId := GetLocalComputerName;
    FClient.ServerHost := 'soldier.cloudmqtt.com';
    FClient.ServerPort := 10947;
    FClient.UserName := 'hakrzlyh';
    FClient.Password := 'xpG_ghvs8mVw';
    FClient.UseSSL := False;
    FClient.ProtocolVersion := pv3_1_1;
    FClient.PeekInterval := 15;

    FClient.BeforeConnect := DoClientConnecting;
    FClient.AfterConnected := DoClientConnected;
    FClient.AfterDisconnected := DoClientDisconnected;
    FClient.AfterPublished := DoAfterPublished;
    FClient.OnError := DoClientError;
    FClient.OnRecvTopic := DoRecvTopic;

    FClient.Subscribe([ChatChannel], qlMax1);
    FClient.Start;
{$ENDIF}
{$IFDEF POSIX}
    if not Assigned(FClient) then
      FClient := TTMSMQTTClient.Create(Self);
    FClient.ClientId := 'TesteAlex2019';
    FClient.BrokerHostName := 'soldier.cloudmqtt.com';
    FClient.BrokerPort := 10947;
    FClient.Credentials.UserName := 'hakrzlyh';
    FClient.Credentials.Password := 'xpG_ghvs8mVw';

    FClient.OnConnectedStatusChanged := ConnectedStatusChanged;
    FClient.OnPublishReceived := PublishReceived;

    FClient.Connect();
{$ENDIF}
  end
  else
  begin
{$IFDEF MSWINDOWS}
    FClient.Stop;
{$ENDIF}
{$IFDEF POSIX}
    FClient.Disconnect;
{$ENDIF}
    btnSala1.Tag := 0;
  end;
end;

procedure TfrmMain.btnSala2Click(Sender: TObject);
begin
  ShowMessage('Não implementado');
end;

procedure TfrmMain.btnSala3Click(Sender: TObject);
begin
  ShowMessage('Não implementado');
end;

procedure TfrmMain.btnBackClick(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
  FClient.Stop;
{$ENDIF}
{$IFDEF POSIX}
  FClient.Disconnect;
{$ENDIF}
end;

procedure TfrmMain.btnEnviarClick(Sender: TObject);
begin
  if Assigned(FClient) and (not Trim(edtMensagem.Text).IsEmpty) then
  begin
{$IFDEF MSWINDOWS}
    FClient.Publish(ChatChannel, GetLocalComputerName + ': ' + edtMensagem.Text,
      TQMQTTQoSLevel(0));
{$ENDIF}
{$IFDEF POSIX}
    FClient.Publish(ChatChannel, GetLocalComputerName + ': ' +
      edtMensagem.Text);
{$ENDIF}
    edtMensagem.Text := '';
    edtMensagem.SetFocus;
  end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FClient) then
  begin
{$IFDEF MSWINDOWS}
    FClient.Stop;
{$ENDIF}
{$IFDEF POSIX}
    FClient.Disconnect;
{$ENDIF}
    FClient.Free;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  { This defines the default active tab at runtime }
  TabControl1.First(TTabTransition.None);
end;

procedure TfrmMain.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if (Key = vkHardwareBack) and (TabControl1.TabIndex <> 0) then
  begin
    TabControl1.First;
    Key := 0;
  end;
end;

{$IFDEF MSWINDOWS}

procedure TfrmMain.DoClientConnecting(ASender: TQMQTTMessageClient);
begin
  lblStatus.Text := 'Status: Conectando em: ' + ASender.ServerHost + ':' +
    IntToStr(ASender.ServerPort);
end;

procedure TfrmMain.DoClientConnected(ASender: TQMQTTMessageClient);
begin
  lblStatus.Text := 'Status: Conectado em: ' + ASender.ServerHost + ':' +
    IntToStr(ASender.ServerPort);
  btnSala1.Tag := 1;
  lbChat.Enabled := True;
  edtMensagem.Enabled := True;
  btnEnviar.Enabled := True;
  edtMensagem.SetFocus;
  TabItem2.Enabled := True;
  TAction(ActionList.Actions[1]).Execute;
  btnBack.Visible := True;
  ToolBarLabel.Text := 'Conectado em: ' + ASender.ServerHost;
end;

procedure TfrmMain.DoClientDisconnected(ASender: TQMQTTMessageClient);
begin
  lblStatus.Text := 'Status: Cliente desconectado.';
  lbChat.Enabled := False;
  lbChat.Clear;
  edtMensagem.Enabled := False;
  btnEnviar.Enabled := False;
  TAction(ActionList.Actions[0]).Execute;
  btnBack.Visible := False;
  ToolBarLabel.Text := 'Delphi Chat MQTT';
  btnSala1.Tag := 0;
end;

procedure TfrmMain.DoAfterPublished(ASender: TQMQTTMessageClient;
  const ATopic: String; const AReq: PQMQTTMessage);
begin
  lblStatus.Text := 'Status: Mensagem Enviada.';
  edtMensagem.Text := '';
end;

procedure TfrmMain.DoClientError(ASender: TQMQTTMessageClient;
  const AErrorCode: Integer; const AErrorMsg: String);
begin
  lblStatus.Text := 'Erro: ' + AErrorMsg + ' (' + IntToStr(AErrorCode) + ')';
end;

procedure TfrmMain.DoRecvTopic(ASender: TQMQTTMessageClient;
  const ATopic: String; const AReq: PQMQTTMessage);
begin
  AddMessage(AReq.TopicText, Trim(SplitString(AReq.TopicText, ':')[0]) <>
    GetLocalComputerName);
  { MyString := Pstring(Listbox1.Items[n]); Dispose(MyString); Listbox1.Items[n].Delete; }
end;
{$ENDIF}
{$IFDEF POSIX}

procedure TfrmMain.ConnectedStatusChanged(ASender: TObject;
  const AConnected: Boolean; AStatus: TTMSMQTTConnectionStatus);
begin
  case AStatus of
    csConnecting:
      begin
        lblStatus.Text := 'Status: Conectando em: ' + FClient.BrokerHostName +
          ':' + IntToStr(FClient.BrokerPort);
      end;
    csConnected:
      begin
        FClient.Subscribe(ChatChannel);
        lblStatus.Text := 'Status: Conectado em: ' + FClient.BrokerHostName +
          ':' + IntToStr(FClient.BrokerPort);
        ToolBarLabel.Text := 'Conectado em: ' + FClient.BrokerHostName;
        btnSala1.Tag := 1;
        lbChat.Enabled := True;
        edtMensagem.Enabled := True;
        btnEnviar.Enabled := True;
        edtMensagem.SetFocus;
        TabItem2.Enabled := True;
        TAction(ActionList.Actions[1]).Execute;
        btnBack.Visible := True;
      end;
    csNotConnected:
      begin
        lblStatus.Text := 'Status: Cliente desconectado.';
        lbChat.Enabled := False;
        lbChat.Clear;
        edtMensagem.Enabled := False;
        btnEnviar.Enabled := False;
        TAction(ActionList.Actions[0]).Execute;
        btnBack.Visible := False;
        ToolBarLabel.Text := 'Delphi Chat MQTT';
        btnSala1.Tag := 0;
      end;
  end;
end;

procedure TfrmMain.PublishReceived(ASender: TObject; APacketID: Word;
  ATopic: string; APayload: TArray<System.Byte>);
var
  msg: string;
begin
  msg := TEncoding.UTF8.GetString(APayload);
  AddMessage(msg, Trim(SplitString(msg, ':')[0]) <> GetLocalComputerName);
end;
{$ENDIF}

procedure TfrmMain.AddMessage(AMessage: string; AlignRight: Boolean);
var
  li: Tlistboxitem;
begin
  li := Tlistboxitem.Create(Self);
  li.StyledSettings := li.StyledSettings - [TStyledSetting.Other];
  li.Text := AMessage;
  li.Height := 22;
  li.VertTextAlign := TTextAlign.Trailing;

  if AlignRight then
    li.TextAlign := TTextAlign.Trailing
  else
    li.TextAlign := TTextAlign.Leading;

  lbChat.AddObject(li);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  btnSala1.SetFocus;
end;

end.
