class Limb extends AnimSprite{
 
  PVector j1,j2;
  float ease = 50;
  boolean landscape = false;
  
Limb(String _name, int _fps){
   super(_name, _fps);
   init(); 
 }

Limb(String _name, int _fps, int _tdx, int _tdy, int _etx, int _ety){
   super(_name, _fps, _tdx, _tdy, _etx, _ety);
   init(); 
 }
 
 Limb(PImage[] _name, int _fps){
   super(_name, _fps);
   init();
 }
 
 void init(){
   super.init();
   p = new PVector(sW/2,sH/2,0);
   j1 = new PVector(p.x-(frames[0].width/2),p.y);
   j2 = new PVector(p.x+(frames[0].width/2),p.y); 
 }
 
 void update(){
   
   if(landscape){
   vertices[0] = projToVert(new PVector(j1.x,j1.y-(frames[0].height/2)),p);
   vertices[3] = projToVert(new PVector(j1.x,j1.y+(frames[0].height/2)),p);
   //--
   vertices[1] = projToVert(new PVector(j2.x,j2.y-(frames[0].height/2)),p);
   vertices[2] = projToVert(new PVector(j2.x,j2.y+(frames[0].height/2)),p);
   }else{
   vertices[0] = projToVert(new PVector(j1.x-(frames[0].width/2),j1.y),p);
   vertices[3] = projToVert(new PVector(j1.x+(frames[0].width/2),j1.y),p);
   //--
   vertices[1] = projToVert(new PVector(j2.x-(frames[0].width/2),j2.y),p);
   vertices[2] = projToVert(new PVector(j2.x+(frames[0].width/2),j2.y),p);
   }
   
   super.update();
 }
 
 void draw(){
   super.draw();
   if(debug){
     ellipseMode(CENTER);
     noStroke();
     fill(0,255,0,100);
     ellipse(j1.x,j1.y,10,10);
     fill(255,0,0,100);
     ellipse(j2.x,j2.y,10,10);
   }
 }
 
 void run(){
   update();
   draw();
 }
  
}
