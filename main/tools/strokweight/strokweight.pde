PShape ufo;

final int N = 10000;
PVector[] ps = new PVector[N];

float fr = 0;

void setup () {

  //size(900, 600, P2D);
  fullScreen(P2D);
  fill(0);
  stroke(255);
  ufo = loadShape("UFO.svg");
  ufo.disableStyle();
  imageMode(CENTER);

  textSize(30);
  textAlign(LEFT, TOP);

  for (int i = 0; i < N; i++) {
    ps[i] = new PVector(random(width), random(height), random(TWO_PI));
  }


  //strokeWeight(1.1);
}

void draw () {
  background(0);

  if (frameCount % 11 == 0) fr = frameRate;

  //ufo.scale(random(.9, 1.1));
//PVector p;

//for(int i = 0; i < N; i++) {
  for (PVector p : ps) {

      //p = ps[i];
    
    p.z += .01;

    shape(ufo, p.x + cos(p.z) * 10, p.y + sin(p.z) * 10, 200, 200);
  }

  pushStyle();
  noStroke();
  fill(0);
  rect(0, 0, 100, 50);
  fill(255);
  text(fr, 0, 0);
  popStyle();
}
