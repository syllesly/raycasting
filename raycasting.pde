import java.awt.Robot;
import java.awt.AWTException;
import java.util.Map;
import java.io.File;
import java.io.IOException;
Player player;
int[][] bMap;
int w;
int h;
float scl;
float lenseDist=1;
float lenseMult=3;
float lenseWidth=lenseDist*lenseMult;
float visionAngle;
color groundColor;
color roofColor;
boolean cursorLocked=true;
float rectWidth=5;
float collisionLength=0.05;
HashMap<String, Boolean> keys=new HashMap<String, Boolean>();
float frmRt=60;
PImage[] textures;
void settings() {
  //size((int) (displayHeight*1.5),(int) (displayHeight*0.75));
  fullScreen();
}
void setup() {
  textures=new PImage[4];
  for(int i=0;i<textures.length;i++) {
    textures[i]=loadImage("textures\\texture"+(i+1)+".jpg");
    textures[i].loadPixels();
  }
  loadMap();
  scl=(height/4)/h;
  player=new Player(1.5,1.5,0,0.03,0.001);
  visionAngle=PI/2;
  groundColor=color(140);
  roofColor=color(50,50,50);
  noCursor();
  noStroke();
}
void draw() {
  background(groundColor);
  noStroke();
  fill(roofColor);
  rect(0,0,width,height/2);
  player.oldX=player.x;
  player.oldY=player.y;
  if(keys.containsKey("d")) {
    player.x+=sin(player.facing-HALF_PI)*player.speed;
    player.y+=cos(player.facing-HALF_PI)*player.speed;
  }
  if(keys.containsKey("a")) {
    player.x+=sin(player.facing+HALF_PI)*player.speed;
    player.y+=cos(player.facing+HALF_PI)*player.speed;
  }
  if(keys.containsKey("w")) {
    player.x+=sin(player.facing)*player.speed;
    player.y+=cos(player.facing)*player.speed;
  }
  if(keys.containsKey("s")) {
    player.x-=sin(player.facing)*player.speed;
    player.y-=cos(player.facing)*player.speed;
  }
  if(player.collisionRay(0)<collisionLength ||player.collisionRay(PI)<collisionLength) {
    player.y=player.oldY;
  }
  if(player.collisionRay(HALF_PI)<collisionLength || player.collisionRay(HALF_PI*3)<collisionLength) {
    player.x=player.oldX;
  }
  if(keys.containsKey("r")) {
    player.x=1.5;
    player.y=1.5;
  }
  player.x=max(0,min(w-1,player.x));
  player.y=max(0,min(h-1,player.y));
  player.facing-=((float) (mouseX-width/2))*player.turnSpeed;
  if(!(player.x<0 || player.x>w || player.y<0 || player.y>h)) {
    if(bMap[(int) floor(player.x)][(int) floor(player.y)]==0) {
      float vx=0;
      float vy=0;
      for(float f=0;f<width;f+=rectWidth) {
        float l=map(f,0,width,-lenseWidth/2,lenseWidth/2);
        float endx = player.x+sin(player.facing)*lenseDist+sin(player.facing-HALF_PI)*l;
        float endy = player.y+cos(player.facing)*lenseDist+cos(player.facing-HALF_PI)*l;
        //point(endx*scl,endy*scl);
        float xi=floor(player.x);
        float yi=floor(player.y);
        boolean crossedBorder=false;
        String side="x";
        for(float i=0;i<w+h;i++) {
          if(xi<0 || yi<0 || xi>=w || yi>=h) {
            crossedBorder=true;
            break;
          }else if(bMap[(int) xi][(int) yi]>0) {
            break;
          }
          float dirx=endx-player.x;
          float diry=endy-player.y;
          float sidex=dirx>0?1:0;
          float sidey=diry>0?1:0;
          float dx=(xi+sidex)-player.x;
          float dy=(yi+sidey)-player.y;
          if(abs(diry*dx)<abs(dy*dirx)) {
            float hy=diry/dirx;
            vx=player.x+dx;
            vy=player.y+dx*hy;
            xi+=sidex*2-1;
            side="x";
          }else{
            float hx=dirx/diry;
            vx=player.x+dy*hx;
            vy=player.y+dy;
            yi+=sidey*2-1;
            side="y";
          }
        }
        if(!crossedBorder) {
          float light=2/max(pow(dist(player.x,player.y,vx,vy),1.15),2);
          float d=sin(player.facing)*(vx-player.x)+cos(player.facing)*(vy-player.y);
          float lineHeight=1/d*width/2/lenseMult;
          //rect(f,height/2-lineHeight/2,rectWidth,lineHeight);
          drawLine(f,lineHeight, side=="y"?vx-xi:vy-yi, light, bMap[(int) xi][(int) yi]-1);
        }
      }
    }
  }
  strokeWeight(1);
  stroke(0,0,0,80);
  for(int x=0;x<w;x++) {
    for(int y=0;y<h;y++) {
      int boxColor=bMap[x][y]==0?255:150;
      fill(boxColor,boxColor,boxColor,80);
      rect(x*scl,y*scl,scl,scl);
    }
  }
  fill(255,0,0,80);
  player.show();
  if(frameCount%60==0) {
    frmRt=frameRate;
  }
  fill(0,0,0);
  text(frmRt,10,height-20);
  if(cursorLocked) {
    try {
      Robot r=new Robot();
      r.mouseMove(width/2,0);
    }catch(AWTException e) {
      
    }
  }
}
void drawLine(float x, float he, float imX, float light, int texture) {
  for(float i=height/2-he/2;round(i)<=round(height/2+he/2)-1;i+=he/90) {
    color rectColor=textures[texture].pixels[((int) round(imX*(textures[texture].width-1)))+((int) round(map(i,height/2-he/2,height/2+he/2,0,textures[texture].height-1)))*textures[texture].width];
    fill(red(rectColor)*light,green(rectColor)*light,blue(rectColor)*light);
    rect(x,i,rectWidth+1,he/90+1);
  }
}
void loadMap() {
  String[] lines=loadStrings("map.txt");
  h=lines.length;
  w=lines[0].length();
  bMap=new int[w][h];
  for(int x=0;x<w;x++) {
    for(int y=0;y<h;y++) {
      bMap[x][y]=Character.getNumericValue(lines[y].charAt(x));
    }
  }
}
void keyTyped() {
  if(key=='c') {
    cursorLocked=!cursorLocked;
    if(cursorLocked) {
      noCursor();
    }else{
      cursor(ARROW);
    }
  }else{
    keys.put(key+"", true);
  }
}
void keyReleased() {
  if(key!='c') {
    if(keys.containsKey(key+"")) {
      keys.remove(key+"");
    }
  }
}
