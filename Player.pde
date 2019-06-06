class Player {
  public float x;
  public float y;
  public float facing;
  public float speed;
  public float turnSpeed;
  public float oldX;
  public float oldY;
  public Player(float getX, float getY, float getFacing, float getSpeed, float getTurnSpeed) {
    x=getX;
    oldX=getX;
    y=getY;
    oldY=getY;
    facing=getFacing;
    speed=getSpeed;
    turnSpeed=getTurnSpeed;
  }
  public void show() {
    beginShape();
    vertex(x*scl+sin(facing+HALF_PI)*scl/4,y*scl+cos(facing+HALF_PI)*scl/4);
    vertex(x*scl+sin(facing)*scl/3.5,y*scl+cos(facing)*scl/3.5);
    vertex(x*scl+sin(facing-HALF_PI)*scl/4,y*scl+cos(facing-HALF_PI)*scl/4);
    bezierVertex(x*scl+sin(facing-HALF_PI)*scl/4,y*scl+cos(facing-HALF_PI)*scl/4,x*scl+sin(facing+PI)*scl/2,y*scl+cos(facing+PI)*scl/2,x*scl+sin(facing+HALF_PI)*scl/4,y*scl+cos(facing+HALF_PI)*scl/4);
    endShape();
  }
  public float collisionRay(float angle) {
    float endx = x+sin(facing+angle);
    float endy = y+cos(facing+angle);
    //point(endx*scl,endy*scl);
    float vx=x;
    float vy=y;
    float xi=floor(x);
    float yi=floor(y);
    for(float i=0;i<w+h;i++) {
      if(xi<0 || yi<0 || xi>=w || yi>=h) {
        break;
      }else if(bMap[(int) xi][(int) yi]==1) {
        break;
      }
      float dirx=endx-x;
      float diry=endy-y;
      float sidex=dirx>0?1:0;
      float sidey=diry>0?1:0;
      float dx=(xi+sidex)-x;
      float dy=(yi+sidey)-y;
      if(abs(diry*dx)<abs(dy*dirx)) {
        float hy=diry/dirx;
        vx=x+dx;
        vy=y+dx*hy;
        xi+=sidex*2-1;
      }else{
        float hx=dirx/diry;
        vx=x+dy*hx;
        vy=y+dy;
        yi+=sidey*2-1;
      }
    }
    return dist(x,y,vx,vy);
  }
}