$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$src=@"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.IO;
public class SavoyRender {
 struct Scene { public string A,B,Key; public bool Light; public Scene(string a,string b,string k,bool l){A=a;B=b;Key=k;Light=l;} }
 static Scene[] S={
  new Scene("명동의 한복판,","사람의 마음을 잇다","마음",true),
  new Scene("1957년부터","명동을 지켜온 이름","1957",false),
  new Scene("도시가 바뀌어도","환대의 마음은 이어집니다","환대",true),
  new Scene("호텔은 공간이 아니라","사람이 만드는 경험","사람",false),
  new Scene("당신의 세심한 한 걸음이","누군가의 여행을 완성해요","완성해요",true),
  new Scene("전통의 깊이","× 새로운 감각","새로운",false),
  new Scene("사람을 좋아하는 당신,","사보이에서 펼칠 차례","차례",true),
  new Scene("명동의 다음 장면을","함께 만들래요?","함께",false)
 };
 static Color Blend(Color a,Color b,float k){return Color.FromArgb((int)(a.R+(b.R-a.R)*k),(int)(a.G+(b.G-a.G)*k),(int)(a.B+(b.B-a.B)*k));}
 static Color BG(Scene s){return s.Light?Color.FromArgb(247,242,228):Color.FromArgb(20,42,49);}
 static Color FG(Scene s){return s.Light?Color.FromArgb(24,46,50):Color.FromArgb(250,245,229);}
 static float Ease(float x){x=Math.Max(0,Math.Min(1,x));return x*x*(3-2*x);}
 static void RoundRect(Graphics g,Brush b,float x,float y,float w,float h,float r){using(GraphicsPath p=new GraphicsPath()){p.AddArc(x,y,r*2,r*2,180,90);p.AddArc(x+w-r*2,y,r*2,r*2,270,90);p.AddArc(x+w-r*2,y+h-r*2,r*2,r*2,0,90);p.AddArc(x,y+h-r*2,r*2,r*2,90,90);p.CloseFigure();g.FillPath(b,p);}}
 static void Leaf(Graphics g,float x,float y,float ang,float sc,Color fill){
  var st=g.Save();g.TranslateTransform(x,y);g.RotateTransform(ang);g.ScaleTransform(sc,sc);
  using(Brush b=new SolidBrush(fill))using(Pen p=new Pen(Color.FromArgb(130,255,255,255),2)){
   PointF[] a={new PointF(0,0),new PointF(-22,-27),new PointF(-19,-58),new PointF(2,-76),new PointF(22,-57),new PointF(24,-29)};
   g.FillPolygon(b,a);g.DrawLine(p,0,0,2,-68);g.DrawLine(p,1,-38,-13,-51);g.DrawLine(p,2,-28,15,-42);
  }g.Restore(st);
 }
 static void Txt(Graphics g,string s,float cx,float cy,float sz,string font,Color color,float scale){
  using(Font f=new Font(font,sz,FontStyle.Bold,GraphicsUnit.Pixel)) using(SolidBrush b=new SolidBrush(color)){
    SizeF z=g.MeasureString(s,f,4000,StringFormat.GenericTypographic);
    var st=g.Save();g.TranslateTransform(cx,cy);g.ScaleTransform(scale,scale);
    g.DrawString(s,f,b,-z.Width/2,-z.Height/2,StringFormat.GenericTypographic);g.Restore(st);
  }
 }
 static void HiTxt(Graphics g,string s,string key,float cx,float cy,float sz,string font,Color normal,Color hi,float scale){
   int ix=s.IndexOf(key,StringComparison.Ordinal);if(ix<0){Txt(g,s,cx,cy,sz,font,normal,scale);return;}
   using(Font f=new Font(font,sz,FontStyle.Bold,GraphicsUnit.Pixel)){
     string pre=s.Substring(0,ix),post=s.Substring(ix+key.Length);
     float wp=g.MeasureString(pre,f,4000,StringFormat.GenericTypographic).Width;
     float wk=g.MeasureString(key,f,4000,StringFormat.GenericTypographic).Width;
     float wq=g.MeasureString(post,f,4000,StringFormat.GenericTypographic).Width;
     float x=cx-(wp+wk+wq)/2;
     using(SolidBrush b=new SolidBrush(normal)){g.DrawString(pre,f,b,x,cy,StringFormat.GenericTypographic);g.DrawString(post,f,b,x+wp+wk,cy,StringFormat.GenericTypographic);}
     using(SolidBrush b=new SolidBrush(hi)){g.DrawString(key,f,b,x+wp,cy,StringFormat.GenericTypographic);}
   }
 }
 public static void RenderFrames(string dir){
  for(int n=0;n<720;n++){
   float t=n/24f;int si=(int)(t/4);if(si>7)si=7;
   float age=t-si*4;Scene sc=S[si];Color target=BG(sc);
   float trans=Ease(Math.Min(1,age/.32f));Color bg=si>0?Blend(BG(S[si-1]),target,trans):target;
   Color fg=FG(sc);Color accent=sc.Light?Color.FromArgb(220,98,46):Color.FromArgb(255,187,83);
   using(Bitmap bmp=new Bitmap(1280,720,PixelFormat.Format24bppRgb))using(Graphics g=Graphics.FromImage(bmp)){
    g.SmoothingMode=SmoothingMode.AntiAlias;g.TextRenderingHint=System.Drawing.Text.TextRenderingHint.AntiAliasGridFit;
    g.Clear(bg);
    bool light=sc.Light;
    // oversized moving typographic backdrop
    using(Font deco=new Font("Arial",220,FontStyle.Bold,GraphicsUnit.Pixel))using(SolidBrush db=new SolidBrush(Color.FromArgb(light?13:15,light?30:255,light?60:255,light?62:255))){
     g.DrawString(si==1||si==5?"57":"S",deco,db,25+(float)Math.Sin(t*1.3)*24,392);
    }
    // animated signal bars and editorial dot grid
    for(int q=0;q<16;q++){float x=28+q*18;float h=8+22*(.5f+.5f*(float)Math.Sin(t*5+q*.72));using(Brush b=new SolidBrush(Color.FromArgb(80,accent)))g.FillRectangle(b,x,677-h,7,h);}
    for(int q=0;q<38;q++){float x=(q*67+t*48)%1280;float y=114+(q%4)*137;using(Brush b=new SolidBrush(Color.FromArgb(45,accent)))g.FillEllipse(b,x,y,4,4);}
    using(Pen p=new Pen(Color.FromArgb(light?28:43,accent),2)) {g.DrawArc(p,950+(float)Math.Sin(t)*30,90,290,290,160,200);}
    Leaf(g,1120+(float)Math.Sin(t*1.6)*24,174+(float)Math.Cos(t*1.3)*24,18+(float)Math.Sin(t*2)*20,.85f,Color.FromArgb(170,accent));
    Leaf(g,177+(float)Math.Cos(t*1.25)*15,573+(float)Math.Sin(t*1.1)*14,-28+(float)Math.Sin(t)*14,.58f,Color.FromArgb(130,accent));
    // top identity
    using(Font brand=new Font("Arial",17,FontStyle.Bold,GraphicsUnit.Pixel))using(SolidBrush br=new SolidBrush(Color.FromArgb(205,fg))){
      g.DrawString("SAVOY HOTEL",brand,br,54,35);
      using(Font sub=new Font("Malgun Gothic",13,FontStyle.Regular,GraphicsUnit.Pixel))g.DrawString("MYEONGDONG  ·  SINCE 1957",sub,br,55,59);
    }
    using(Pen p=new Pen(Color.FromArgb(light?46:58,fg),1))g.DrawLine(p,54,87,1226,87);
    // message lines rise and scale to the beat; final card gets a stronger punch
    float e1=Ease(age/.34f);float e2=Ease((age-.38f)/.34f);
    float punch=1f+.055f*(float)Math.Sin(Math.Max(0,age)*Math.PI*2);
    float y1=305+(1-e1)*42;
    float y2=407+(1-e2)*48;
    int a1=(int)(255*e1),a2=(int)(255*e2);
    Color n1=Color.FromArgb(a1,fg);Color n2=Color.FromArgb(a2,fg);Color ah=Color.FromArgb(a2,accent);
    float s1=(si==1?62:43);
    HiTxt(g,sc.A,sc.Key,640,y1,s1,"Malgun Gothic",n1,Color.FromArgb(a1,accent),.92f+.08f*e1);
    HiTxt(g,sc.B,sc.Key,640,y2,si==7?82:68,"Malgun Gothic",n2,ah,(.76f+.24f*e2)*punch);
    // compact period marker
    for(int i=0;i<8;i++){using(Brush b=new SolidBrush(Color.FromArgb(si==i?255:65,si==i?accent:fg)))g.FillEllipse(b,596+i*13,548,7,7);}
    if(si==7){
      float cta=Ease((age-.55f)/.30f);
      string call="SAVOY HOTEL  ·  JOIN THE NEXT CHAPTER";
      Txt(g,call,640,600,23,"Arial",Color.FromArgb((int)(255*cta),fg),.88f+.12f*cta);
      using(Brush b=new SolidBrush(Color.FromArgb((int)(220*cta),accent)))RoundRect(g,b,527,632,226,4,2);
    }else{
      string call=si==0?"환대의 마음으로":si==1?"도시와 사람의 곁에서":si==2?"오래, 새롭게":si==3?"당신의 마음이":si==4?"일상을 특별하게":si==5?"전통과 감각을 잇는 곳":"YOUR STORY STARTS HERE";
      Txt(g,call,640,598,19,"Malgun Gothic",Color.FromArgb(150,fg),.96f);
    }
    // side accent block snaps with beat
    float bx=1210+((1-Ease(age/.22f))*32);
    using(Brush b=new SolidBrush(accent))g.FillRectangle(b,bx,273,6,119);
    string fn=Path.Combine(dir,"frame"+n.ToString("D4")+".png");bmp.Save(fn,ImageFormat.Png);
   }
  }
 }
 static uint rng=1234567;
 static double Noise(){rng=1664525*rng+1013904223;return ((rng>>8)&0xffffff)/8388607.5-1.0;}
 struct Ev {public double T,F,D,A;public int K;public Ev(double t,double f,double d,double a,int k){T=t;F=f;D=d;A=a;K=k;}}
 public static void MakeMusic(string path){
  const int sr=44100,total=sr*30;double[] l=new double[total],r=new double[total];var es=new System.Collections.Generic.List<Ev>();
  // bright four-chord loop, with an original plucked lead and buoyant bass
  double[][] ch=new double[][] {new double[]{261.63,329.63,392.00,493.88},new double[]{220.00,261.63,329.63,392.00},new double[]{174.61,220.00,261.63,329.63},new double[]{196.00,246.94,293.66,392.00}};
  double[] bass={130.81,110,87.31,98};double beat=.5;
  for(int b=0;b<60;b++){
    double t=b*beat;int bar=(int)(t/2)%4;
    es.Add(new Ev(t,bass[bar],.30,.20,1));
    if(b%2==0)for(int q=0;q<3;q++)es.Add(new Ev(t,ch[bar][q],.72,q==0?.060:.038,0));
    // off-beat melodic sparkle
    double[] lead={523.25,659.25,587.33,783.99,659.25,587.33,493.88,587.33};
    es.Add(new Ev(t+.25,lead[(b+(b/8))%8],.24,.070,2));
    // soft kick and handclap on backbeat
    if(b%2==0)es.Add(new Ev(t,55,.22,.42,3));
    else es.Add(new Ev(t,185,.14,.23,4));
    // shaker eighth-note
    es.Add(new Ev(t+.25,0,.055,.055,5));
  }
  foreach(Ev e in es){
   int st=(int)(e.T*sr), count=Math.Min((int)(e.D*sr),total-st);
   for(int j=0;j<count;j++){
    double u=(double)j/sr,env=Math.Min(1,u/.006)*Math.Exp(-4.8*u/e.D),v=0;
    if(e.K==3){double q=Math.Exp(-16*u);v=Math.Sin(2*Math.PI*(47+95*q)*u)*q;}
    else if(e.K==4){double z=Noise();v=(z*.67+Math.Sin(2*Math.PI*185*u)*.33)*Math.Exp(-24*u);}
    else if(e.K==5){v=Noise()*Math.Exp(-64*u);}
    else if(e.K==2){v=(Math.Sin(2*Math.PI*e.F*u)+.24*Math.Sin(4*Math.PI*e.F*u))*env;}
    else if(e.K==1){double f=e.F*Math.Pow(.5,Math.Min(1,u/.035));v=(Math.Sin(2*Math.PI*f*u)+.2*Math.Sin(4*Math.PI*f*u))*env;}
    else {v=(Math.Sin(2*Math.PI*e.F*u)+.23*Math.Sin(4*Math.PI*e.F*u)+.08*Math.Sin(6*Math.PI*e.F*u))*env;}
    double pan=e.K==2?((e.T*7%2)-1)*.5:(e.K==5?.35:-.18);
    l[st+j]+=v*e.A*Math.Sqrt((1-pan)*.5);r[st+j]+=v*e.A*Math.Sqrt((1+pan)*.5);
   }
  }
  using(FileStream fs=new FileStream(path,FileMode.Create,FileAccess.Write))using(BinaryWriter w=new BinaryWriter(fs)){
   w.Write(System.Text.Encoding.ASCII.GetBytes("RIFF"));w.Write((uint)(36+total*4));w.Write(System.Text.Encoding.ASCII.GetBytes("WAVE"));w.Write(System.Text.Encoding.ASCII.GetBytes("fmt "));w.Write((uint)16);w.Write((ushort)1);w.Write((ushort)2);w.Write((uint)sr);w.Write((uint)(sr*4));w.Write((ushort)4);w.Write((ushort)16);w.Write(System.Text.Encoding.ASCII.GetBytes("data"));w.Write((uint)(total*4));
   for(int i=0;i<total;i++){
    double fade=Math.Min(1,i/(double)(sr*.35))*Math.Min(1,(total-i)/(double)(sr*.9));
    double vl=Math.Tanh(l[i]*fade*1.2),vr=Math.Tanh(r[i]*fade*1.2);
    w.Write((short)(vl*32767));w.Write((short)(vr*32767));
   }
  }
 }
}
"@
Add-Type -TypeDefinition $src -ReferencedAssemblies System.Drawing
$work=Join-Path $env:TEMP 'savoy_kinetic_30'
if(Test-Path $work){Remove-Item -LiteralPath $work -Recurse -Force}
New-Item -ItemType Directory -Path $work|Out-Null
[ SavoyRender ]::RenderFrames($work)
[ SavoyRender ]::MakeMusic((Join-Path $work 'savoy-score.wav'))
$ff=(Resolve-Path '.\_ffmpeg\ffmpeg-9.0.2-essentials_build\bin\ffmpeg.exe').Path
& $ff -hide_banner -loglevel warning -y -framerate 24 -i "$work\frame%04d.png" -i "$work\savoy-score.wav" -vf "scale=1920:1080:flags=lanczos,format=yuv420p" -c:v libx264 -preset medium -crf 19 -r 24 -c:a aac -b:a 192k -shortest -movflags +faststart "사보이호텔_채용_키네틱타이포.mp4"
if($LASTEXITCODE -ne 0){throw "ffmpeg failed with code $LASTEXITCODE"}
$fp=Join-Path (Split-Path $ff) 'ffprobe.exe'
& $fp -v error -show_entries format=duration,size -show_entries stream=codec_name,width,height,avg_frame_rate,sample_rate,channels -of default=noprint_wrappers=1 "사보이호텔_채용_키네틱타이포.mp4"
& $ff -hide_banner -loglevel error -y -ss 29 -i "사보이호텔_채용_키네틱타이포.mp4" -frames:v 1 -update 1 "사보이호텔_미리보기.png"



