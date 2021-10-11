unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, Unit2;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClick(Sender: TObject);
    procedure Draw;
    procedure FormPaint(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  b: TBitmap;
  needexit: boolean = false;
  pm: boolean = true; // plus/minus - движение вперед/назад
  sint,cost: array [0..360] of real;
  started: boolean = false; // чтобы не писалось Click... при выполнении сцены use in OnShow
  secondScene: integer = 0; // круг или сложная фигура

  sx,sy: integer;                  // use in Unit2
  P: Projection;                   // use in Unit2
  xnew,ynew,xold,yold: integer;    // use in Unit2
  x,y,z,a: real;                   // use in Unit2
  pma: boolean = true; //plus/minus for var A

  logfont: TLogFont;
  fonth: THandle;

implementation

{$R *.DFM}
 
function AngleToPi(x: integer): real;
begin
AngleToPi:=(Pi*x)/180;
end;


procedure TForm1.FormCreate(Sender: TObject);
var
 i: integer;
begin
  b := TBitMap.Create;
  b.pixelformat := pf24bit;
  b.width := Clientwidth;
  b.height := Clientheight;
  for i:= 0 to 360 do
    begin
    sint[i]:=sin(AngleToPi(i));
    cost[i]:=cos(AngleToPi(i));
    end;
  sx:=Form1.ClientWidth div 2;
  sy:=Form1.ClientHeight div 2-30;
  Randomize;
end;


procedure DrawLine(x,y,rad,ang,color: integer);
var
 curX,curY: integer;
begin
//ang:= ang mod 360;
curX:=x+Round(rad*cost[ang]);
curY:=y+Round(rad*sint[ang]);
b.Canvas.Pen.Color:=color;
b.Canvas.MoveTo(x,y);
b.Canvas.LineTo(curX,curY);
end;


procedure DrawPixel(x,y,rad,ang,color: integer);
var curX,curY: integer;
begin
//ang:= ang mod 360;
curX:=x+Round(rad*cost[ang]);
curY:=y+Round(rad*sint[ang]);
b.Canvas.Pixels[CurX,CurY]:=color;
end;


procedure TForm1.Draw;
var
  x,y,r,i,tmpAng: integer;
  angle: integer; //for koleso
  ang2: integer;  //vnutr
  ang3: integer;  //vnesh
  spAng: integer; //spiral
  CurColor: integer; //spiral color

  iteration: integer; //for paporotnic
  tp,xp,yp,pp: real;
  kp: Longint;
  rp: integer;

  //DC: TCanvas;

Procedure FillScreen(FillEllipse: boolean);
begin
b.Canvas.Pen.Color:=clBlack;
b.Canvas.Ellipse(x-52,y+52,x+52,y-52);
if FillEllipse then b.Canvas.FillRect(Rect(b.Width div 2-151,b.Height div 2-170,b.Width div 2+151,b.Height div 2+71));
end;


begin
started:=true;
ang3:=0;
ang2:=MaxInt-360;              //DC:= TCanvas.Create;
angle:=0;
spAng:=0;                    //DC.Handle:=GetDC(0);
r:=50;
x:=51;
y:=b.Height-51;
a:=0.01;
pma:=true;
CurColor:=0;

logFont.lfheight := 30;
logfont.lfwidth := 15;
FontH := createfontindirect(logfont);
SelectObject(b.canvas.handle, FontH);

b.Canvas.Brush.Color:=clBlack;
b.Canvas.FillRect(Rect(0,0,b.Width,b.Height));
Form1.canvas.draw(0, 0, b);

while not needexit do
  begin
  case SecondScene of
  0:begin
    FillScreen(true);
    for i:= 1 to 36 do                       //draw vnesh line
      begin
      tmpAng:=(ang3+10*i) mod 360;
      if Odd(i) then
      DrawLine(b.Width div 2+Round(50*cost[tmpAng]),b.Height div 2-50+Round(50*sint[tmpAng]),20,tmpAng,clYellow)
      else
        begin
        DrawLine(b.Width div 2+Round(50*cost[tmpAng]),b.Height div 2-50+Round(50*sint[tmpAng]),50,tmpAng,clYellow);
        b.Canvas.Pen.Color:=RGB(255,0,0);
        b.Canvas.Ellipse(b.Width div 2+Round(100*cost[tmpAng])-5,b.Height div 2-50+Round(100*sint[tmpAng])-5,b.Width div 2+Round(100*cost[tmpAng])+5,b.Height div 2-50+Round(100*sint[tmpAng])+5);
        end;
      end;
    b.Canvas.Pen.Color:=RGB(0,200,0);
    b.Canvas.Ellipse(b.Width div 2-50,b.Height div 2,b.Width div 2+50,b.Height div 2-100);
    for i:= 1 to 18 do              //draw vnurt line
      begin
      tmpAng:=(ang2+20*i) mod 360;
      DrawLine(b.Width div 2+Round(10*cost[tmpAng]),b.Height div 2-50+Round(10*sint[tmpAng]),30,tmpAng,clAqua);
      end;
    end;

  1:begin
    FillScreen(true);
    cdp(30,P);
    drawsurf;
    if pma then a:=a+0.01 else a:=a-0.01;
    if a>=2.4 then pma:= not pma;
    if a<=0.01 then pma:= not pma;
    end;

  2:begin
    FillScreen(false);
    rp:=25;
    xp:=1.0;
    yp:=0.0;

    for kp:= 1 to 15 do
      begin
      pp:= random;
      tp:=xp;
      if pp<=0.85 then
        begin
        xp:=0.85*xp+0.04*yp;
        yp:=-0.04*tp+0.85*yp+1.6;
        end
      else
      if pp<=0.92 then
        begin
        xp:=0.20*xp-0.26*yp;
        yp:=0.23*tp+0.22*yp+1.6;
        end
      else
      if pp<=0.99 then
        begin
        xp:=-0.15*xp+0.28*yp;
        yp:=0.26*tp+0.24*yp+0.44;
        end
      else
        begin
        xp:=0.0;
        yp:=0.16*yp;
        end;
      b.Canvas.Pixels[b.Width div 2 +round(rp*xp),b.Height div 2+70 -round(rp*yp)]:=clGreen;
      end;
    end;
  end;
  // end of If

  b.Canvas.Pen.Color:=clWhite;             //draw koleso
  b.Canvas.Ellipse(x-50,y+50,x+50,y-50);
  DrawLine(x,y,r,angle mod 360,clLime);
  DrawLine(x,y,r,(angle+120) mod 360,clLime);
  DrawLine(x,y,r,(angle+240) mod 360,clLime);

  SelectObject(b.canvas.handle, FontH);
  SetTextColor(b.canvas.handle, rgb(ang2,ang2,ang2));
  b.Canvas.TextOut(b.Width div 2-180, 0, 'Press space to next scene');

  case CurColor of
  0:begin
    DrawPixel(70,150,spAng div 20,spAng mod 360,Rgb(spAng,0,0));   //spiral's
    DrawPixel(b.Width-70,150,spAng div 20,(1260-spAng) mod 360,Rgb(spAng,0,0));
    end;
  2:begin
    DrawPixel(70,150,spAng div 20,spAng mod 360,Rgb(0,spAng,0));   //spiral's
    DrawPixel(b.Width-70,150,spAng div 20,(1260-spAng) mod 360,Rgb(0,spAng,0));
    end;
  1:begin
    DrawPixel(70,150,spAng div 20,spAng mod 360,Rgb(0,0,spAng));   //spiral's
    DrawPixel(b.Width-70,150,spAng div 20,(1260-spAng) mod 360,Rgb(0,0,spAng));
    end;
  end;

  Form1.canvas.draw(0, 0, b);
  Application.ProcessMessages;
  //Sleep(10);

  if x=Form1.ClientWidth-50 then pm:= not pm;
  if x=50 then pm:= not pm;
  if pm then begin inc(x); inc(angle); end else begin dec(x); dec(angle); end;
  dec(ang2);                  //изменение всех углов и координат
  inc(ang3);
  Inc(spAng);
  if spAng=1250 then
    begin                        //меняем цвет спирали и снова рисуем
    spAng:=0;
    CurColor:=(CurColor+1) mod 3;
    end;

  end;
DeleteObject(FontH);
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
 b.free;
end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 needexit:=true;
end;


procedure TForm1.FormClick(Sender: TObject);
begin
 Draw;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
if started then exit;

logFont.lfheight := 100;
logfont.lfwidth := 30;
logfont.lfweight := 750;
logFont.lfEscapement := -0;
logfont.lfcharset := 1;
logfont.lfoutprecision := out_tt_precis;
logfont.lfquality := draft_quality;
logfont.lfpitchandfamily := FF_Modern;
logfont.lfStrikeOut := 0;
logfont.lfUnderline := 0;
FontH := createfontindirect(logfont);
SelectObject(Form1.canvas.handle, FontH);
SetTextColor(Form1.canvas.handle, rgb(250, 0, 0));
SetBKmode(Form1.canvas.handle, transparent);
Form1.Canvas.TextOut(0, b.Height div 2-50, 'Click me to start!!!');
DeleteObject(FontH);

logFont.lfheight := 16;
logfont.lfwidth := 8;
fonth := createfontindirect(logfont);
SelectObject(Form1.canvas.handle, fonth);
SetTextColor(Form1.canvas.handle, rgb(0, 0, 200));
Form1.Canvas.TextOut(0, b.Height-16, 'Demo Project Copyright 2005 by Kargin Alex');
DeleteObject(FontH);
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
if Key=' ' then SecondScene:= (SecondScene+1) mod 3;
b.Canvas.Pen.Color:=clBlack;     // при смене режима очищаем центр экрана
b.Canvas.FillRect(Rect(b.Width div 2-151,b.Height div 2-170,b.Width div 2+151,b.Height div 2+71));
end;

end.
