PGraphics canvas;
PGraphics screen;

void setup () {
  size(1920, 1080, P2D);

  canvas = createGraphics(width, height, P2D);
  canvas.noSmooth();

  screen = createGraphics(width, height, P2D);
  screen.noSmooth();
}

void draw () {
  
  screen.beginDraw();
  screen.background(0);
  for (int i = 0; i < 100; i++) screen.circle(random(width), random(height), random(300));
  screen.endDraw();

  canvas.beginDraw();
  canvas.background(0);
  //PImage got = copy();//get();
  canvas.image(screen, 0, 0, width, height);
  canvas.endDraw();

  image(canvas, 0, 0);

  if (frameCount % 60 == 0) println(frameRate);
}
