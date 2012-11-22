//based on Stickmanetic by ?
import processing.opengl.*;
import ddf.minim.*;
import pbox2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

int sW = 800;
int sH = 600;
int sD = 700;
int fps = 60;

boolean debug = false;
boolean hideCursor = true;
boolean alphaMode = true;

// A reference to our box2d world
PBox2D box2d;

// An ArrayList of particles that will fall on the surface
ArrayList particles;

float noiseIter = 0.0;
int ballSize = 10;

Minim minim;
AudioInput adc;

int numBacteria = 100;
Bacterium[] bacteria = new Bacterium[numBacteria];
float tractorLimit = 100;


AnimSprite head;

Arm[] arm = new Arm[4];
Leg[] leg = new Leg[4];
Torso torso;

Hashtable<Integer, Skeleton> skels = new Hashtable<Integer, Skeleton>();

void setup() {
  Settings settings = new Settings("settings.txt");
  hint( ENABLE_OPENGL_4X_SMOOTH );
  if (hideCursor) noCursor();  
  size(sW, sH, GLConstants.GLGRAPHICS);    // use OPENGL rendering for bilinear filtering on texture
  frameRate(fps);
  smooth();
  head = new AnimSprite("horsebuyer", 12);
  head.playing = false;
  head.s = new PVector(0.8, 0.8);
  oscSetup();
  minim = new Minim(this);
  adc = minim.getLineIn( Minim.MONO, 512 );
  Arm armInit = new Arm();
  Leg legInit = new Leg();
  for (int i=0;i<arm.length;i++) {
    arm[i] = new Arm(armInit.frames);
    arm[i].makeTexture();
    //arm[i].debug = true;
    arm[i].p = new PVector(320, 240, 0);
    arm[i].index = int(random(arm[i].frames.length));
  }

  for (int i=0;i<leg.length;i++) {
    leg[i] = new Leg(legInit.frames);
    leg[i].makeTexture();
    //leg[i].debug = true;
    leg[i].p = new PVector(320, 240, 0);
    leg[i].index = int(random(leg[i].frames.length));
  }    
  torso = new Torso();
  torso.makeTexture();
  //torso.debug = true;
  torso.p = new PVector(320, 240, 0);

  Bacterium bacterium = new Bacterium();
  for (int i=0;i<bacteria.length;i++) {
    bacteria[i] = new Bacterium(bacterium.frames);
    bacteria[i].make3D(); //adds a Z axis and other features. You can also makeTexture to control individual vertices.
    bacteria[i].p = new PVector(random(sW), random(sH), random(sD)-(sD/2));
    bacteria[i].index = random(bacteria[i].frames.length);
    bacteria[i].r = 0;
    bacteria[i].t = new PVector(random(sW), random(sH), random(sD)-(sD/2));
    bacteria[i].s = new PVector(0.1,0.1);
  }

  // Initialize box2d physics and create the world
  box2d = new PBox2D(this);
  box2d.createWorld();
  // We are setting a custom gravity
  box2d.setGravity(0, -40);

  // Create the empty list
  particles = new ArrayList();
  setupGl();
  background(0);
}

void drawBone(float joint1[], float joint2[]) {
  if ((joint1[0] == -1 && joint1[1] == -1) || (joint2[0] == -1 && joint2[1] == -1))
    return;

  float dx = (joint2[0] - joint1[0]) * width;
  float dy = (joint2[1] - joint1[1]) * height;
  float steps = 2 * sqrt(pow(dx, 2) + pow(dy, 2)) / ballSize;
  float step_x = dx / steps / width;
  float step_y = dy / steps / height;

  for (int i=0; i<=steps; i++) {
    ellipse((joint1[0] + (i*step_x))*width, 
    (joint1[1] + (i*step_y))*height, 
    ballSize, ballSize);
  }
}


void draw() {
  //background(0);
  drawGl();
}

void drawMain() {
  if (alphaMode) {
    noStroke();
    fill(0, 50);
    rectMode(CORNER);
    rect(0, 0, width, height);
  }
  else {
    background(0);
  }

  for (Skeleton s: skels.values()) {
    s.addCollisionLine();

    if (debug) {
      //Head
      ellipse(s.headCoords[0]*width, 
      s.headCoords[1]*height + 10, 
      ballSize*5, ballSize*6);

      //Head to neck 
      drawBone(s.headCoords, s.neckCoords);
      //Center upper body
      //drawBone(lShoulderCoords, rShoulderCoords);
      drawBone(s.headCoords, s.rShoulderCoords);
      drawBone(s.headCoords, s.lShoulderCoords);
      drawBone(s.neckCoords, s.torsoCoords);
      //Right upper body
      drawBone(s.rShoulderCoords, s.rElbowCoords);
      drawBone(s.rElbowCoords, s.rHandCoords);
      //Left upper body
      drawBone(s.lShoulderCoords, s.lElbowCoords);
      drawBone(s.lElbowCoords, s.lHandCoords);
      //Torso
      //drawBone(rShoulderCoords, rHipCoords);
      //drawBone(lShoulderCoords, lHipCoords);
      drawBone(s.rHipCoords, s.torsoCoords);
      drawBone(s.lHipCoords, s.torsoCoords);
      //drawBone(lHipCoords, rHipCoords);
      //Right leg
      drawBone(s.rHipCoords, s.rKneeCoords);
      drawBone(s.rKneeCoords, s.rFootCoords);
      //  drawBone(rFootCoords, lHipCoords);
      //Left leg
      drawBone(s.lHipCoords, s.lKneeCoords);
      drawBone(s.lKneeCoords, s.lFootCoords);
      //  drawBone(lFootCoords, rHipCoords);
    }
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    //--
    leg[0].j1 = new PVector(s.rHipCoords[0]*width, s.rHipCoords[1]*height);
    leg[0].j2 = new PVector(s.rKneeCoords[0]*width, s.rKneeCoords[1]*height);
    leg[1].j1 = leg[0].j2;
    leg[1].j2 = new PVector(s.rFootCoords[0]*width, s.rFootCoords[1]*height);
    //--
    leg[2].j1 = new PVector(s.lHipCoords[0]*width, s.lHipCoords[1]*height);
    leg[2].j2 = new PVector(s.lKneeCoords[0]*width, s.lKneeCoords[1]*height);
    leg[3].j1 = leg[2].j2;
    leg[3].j2 = new PVector(s.lFootCoords[0]*width, s.lFootCoords[1]*height);
    //--
    arm[0].j1 = new PVector(s.rShoulderCoords[0]*width, s.rShoulderCoords[1]*height);
    arm[0].j2 = new PVector(s.rElbowCoords[0]*width, s.rElbowCoords[1]*height); 
    arm[1].j1 = arm[0].j2;
    arm[1].j2 = new PVector(s.rHandCoords[0]*width, s.rHandCoords[1]*height);
    //--
    arm[2].j1 = new PVector(s.lShoulderCoords[0]*width, s.lShoulderCoords[1]*height);
    arm[2].j2 = new PVector(s.lElbowCoords[0]*width, s.lElbowCoords[1]*height);
    arm[3].j1 = arm[2].j2;
    arm[3].j2 = new PVector(s.lHandCoords[0]*width, s.lHandCoords[1]*height);  

    //--
    torso.j1 = new PVector(s.neckCoords[0]*width, s.neckCoords[1]*height);
    torso.j2 = new PVector(s.torsoCoords[0]*width, 50+s.torsoCoords[1]*height);
    //--
    head.p = new PVector(s.headCoords[0]*width, s.headCoords[1]*height);
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    if (debug) {
      for (float j[]: s.allCoords) {
        ellipse(j[0]*width, j[1]*height, ballSize*2, ballSize*2);
      }
    } 
    s.body.createShape(s.edges);
  }

  torso.run();

  leg[0].run();
  leg[2].run();
  arm[0].run();
  arm[2].run();

  head.index = int(trackVolume(13, 75, 2));
  //head.run();
  leg[1].run();
  leg[3].run();
  arm[1].run();
  arm[3].run();

  //particles.add(new Particle(noise(noiseIter)*width,0,random(2,6)));
  particles.add(new Particle(head.p.x, head.p.y, random(2, 6)));
  noiseIter += 0.01;

  // We must always step through time!
  box2d.step();

  // Draw all particles
  for (int i = 0; i < particles.size(); i++) {
    Particle p = (Particle) particles.get(i);
    p.display();
  }

  // Particles that leave the screen, we delete them
  // (note they have to be deleted from both the box2d world and our list
  for (int i = particles.size()-1; i >= 0; i--) {
    Particle p = (Particle) particles.get(i);
    if (p.done()) {
      particles.remove(i);
    }
  }

  for (Skeleton s: skels.values()) {
    box2d.destroyBody(s.body);
    s.body = box2d.world.createBody(s.bd);
    s.edges = new EdgeChainDef();
    s.edges.setIsLoop(false);   // We could make the edge a full loop
    s.edges.friction = 0.1;    // How much friction
    s.edges.restitution = 1.3; // How bouncy
  }


  for (int i=0;i<bacteria.length;i++) {
    
    bacteria[i].run();

    if(dist(bacteria[i].p.x,bacteria[i].p.y,bacteria[i].p.z,bacteria[i].t.x,bacteria[i].t.y,bacteria[i].t.z)>50){
      noFill();
      strokeWeight(random(1, 5));
      stroke(255, 50, 0, random(1, 5));
      beginShape();
      vertex(bacteria[i].p.x, bacteria[i].p.y, bacteria[i].p.z);
      //vertex(mouseX, mouseY, 0);
      vertex(head.p.x,head.p.y, 0);
      endShape();
    }
  }
  imageMode(CORNER);
}

float trackVolume(float _scale, float _amp, float _floor) {
  float volumeLevel=0;  //must reset to 0 each frame before measuring
  for (int i = 0; i < adc.bufferSize() - 1; i++) {
    if ( abs(adc.mix.get(i)) > volumeLevel ) {
      volumeLevel = abs(adc.mix.get(i));
    }
  }
  float returnVal = (_scale * (volumeLevel * _amp))/_scale;
  if (returnVal>_floor) {
    if (returnVal > _scale) returnVal = _scale;
    return returnVal;
  }
  else {
    return 0;
  }
}

public void stop() {
  minim.stop();
  super.stop();
}

