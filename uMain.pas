unit uMain;

interface

uses
   uComportWork_SimplePark,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private

    { Private declarations }
  public
   gCOM : TComport_FND;
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
//
   gCOM := TComport_FND.Create(SpinEdit1.Value, 9600, 'N', 8, 1);
   Button1.Enabled := False;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
//
   gCOM.Send_MicOnOff(CheckBox1.Checked, CheckBox2.Checked);

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
   gCOM.RequestStatus;
end;

end.
