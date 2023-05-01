/**
 * Blur Filter
 * 
 * Change the default shader to apply a simple, custom blur filter.
 * 
 * Press the mouse to switch between the custom and default shader.
 */

PShader blur;
PGraphics canvas;
PGraphics blurred;

void setup() {
  size(640, 360, P2D);
  blur = loadShader("blur.glsl"); 
  stroke(255);
  rectMode(CENTER);
  noFill();
  strokeWeight(2);
  
  canvas = createGraphics(width, height, P2D);
  blurred = createGraphics(width, height, P2D);
  
  canvas.beginDraw();
  canvas.stroke(255);
  canvas.rectMode(CENTER);
  canvas.noFill();
  canvas.strokeWeight(2);
  println(this.g);
  
  frameRate(1);
  //noLoop();
}

void draw() {
  
  background(0);
  for(int i = 0; i < 100; i++) {
    circle(random(width), random(height), random(20));
  }
  //rect(mouseX, mouseY, 150, 150); 
  //ellipse(mouseX, mouseY, 100, 100);
  
  canvas.beginDraw();
  canvas.background(0);
  canvas.rect(mouseX, mouseY, 150, 150); 
  canvas.ellipse(mouseX, mouseY, 100, 100);
  canvas.endDraw();

  int ps = int(map(mouseX, 0, width, 1, 15));

  for (int i = 1; i < ps; i++) {
    blur.set("pass", i);
    filter(blur);
  }
  //  rect(mouseX, mouseY, 150, 150); 
  //ellipse(mouseX, mouseY, 100, 100);
  //canvas.shader(blur);
  //image(canvas, 0, 0);
}
