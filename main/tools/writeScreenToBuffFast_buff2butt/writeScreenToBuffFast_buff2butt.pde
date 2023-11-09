PGraphics canvas;
PGraphics screen;

PShader blur;

void setup () {
  size(1920, 1080, P2D);

  screen = createGraphics(width, height, P2D);
  screen.noSmooth();

  canvas = createGraphics(width/8, height/8, P2D);
  canvas.noSmooth();

  blur = loadShader("blur.glsl");

  screen.beginDraw();
  screen.background(0);
  for (int i = 0; i < 100; i++) screen.circle(random(width), random(height), random(300));
  screen.endDraw();
}

void draw () {

  background(0);

  canvas.beginDraw();
  canvas.image(screen, 0, 0, canvas.width, canvas.height);
  for (int i = 0; i < 10; i++) canvas.filter(blur);
  canvas.endDraw();

  image(screen, 0, 0);
  if (mousePressed) {
    blendMode(SCREEN);
    image(canvas, 0, 0, width, height);
  }
  //if (frameCount % 60 == 0) println(frameRate);
  fill(255, 0, 0);
  text(frameRate, 100, 100);
}
