class ZoomStar {

  float x;
  float y;
  float z;
  float pz;

  ZoomStar(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.pz = z;
  }
}

class StarsSystem {

  ArrayList<ZoomStar> zoomStars = new ArrayList<ZoomStar>();
  final float zoomSpeedFinal = 17;
  final static float zoomSpeedupDuration = 6e3;
  float zoomSpeedupStart;

  final static float DEFAULT_HYPERSPACE_DURATION = 15e3;
  PVector[] stars = new PVector[800];
  float r = 2000;
  float a = 0;//PI/2;
  float pa = a;
  final float defaultStarSpeed = TWO_PI / (360 * 40);
  final float hyperspaceStarSpeed = defaultStarSpeed * 5;
  float starSpeed = defaultStarSpeed;

  final static int SPINNING = 0;
  final static int HYPERSPACE = 1;
  final static int ZOOMING = 2;
  int state = SPINNING;

  boolean isZooming = false;

  void spawnSomeStars() {
    int k = 0;
    for (int j = 0; j < 360; j+= 9) {
      for (int i = 0; i < 20; i++) {
        stars[k] = new PVector(cos(a+j) * r + random(-width/2, width/2), sin(a+j)*r + random(-height/2, height/2));
        k++;
      }
    }
  }

  void setHyperspace (boolean h) {
    starSpeed = h ? hyperspaceStarSpeed : defaultStarSpeed;
    state = h ? HYPERSPACE : SPINNING;
  }

  //void spin (float dt) {
  //  pa = a;
  //  a += starSpeed * dt;
  //}

  void update (float dt) {
    if (isZooming) {
      float progress = (millis() - zoomSpeedupStart) / zoomSpeedupDuration;
      //float zoomSpeed = progress < 1 ? progress * zoomSpeedFinal : zoomSpeedFinal;

      //float zoomSpeed = progress < 1 ? progress * zoomSpeedFinal : zoomSpeedFinal;
      float zoomSpeed = progress < 1 ? utils.easeInQuad(progress, 0, zoomSpeedFinal, 1) : zoomSpeedFinal;

      for (ZoomStar zoomer : zoomStars) {
        zoomer.pz = zoomer.z;
        zoomer.z -= zoomSpeed; //map(millis(), zoomSpeedupStart, zoomSpeedupStart + zoomSpeedupDuration, 0, 18);
        if (zoomer.z < zoomSpeed) {
          zoomer.x = random(-HEIGHT_REF_HALF, HEIGHT_REF_HALF);
          zoomer.y = random(-HEIGHT_REF_HALF, HEIGHT_REF_HALF);
          zoomer.z = HEIGHT_REF_HALF;
          zoomer.pz = zoomer.z;
        }
      }
    } else {
      pa = a;
      a += starSpeed * dt;
    }
  }

  float xShiftThisFrame() {
    return cos(a) * r - cos(pa) * r;
  }

  float yShiftThisFrame() {
    return sin(a) * r - sin(pa) * r;
  }

  PVector lookAhead(float lead, float rOffset) {
    PVector virtualHere = new PVector(cos(a) * r, sin(a) * r);
    PVector virtualThere = new PVector(cos(a + radians(lead)) * (r + rOffset), sin(a + radians(lead)) * (r + rOffset));
    return virtualThere.sub(virtualHere);
  }

  //void zooming() {

  //float progress = (millis() - zoomSpeedupStart) / zoomSpeedupDuration;
  ////float zoomSpeed = progress < 1 ? progress * zoomSpeedFinal : zoomSpeedFinal;

  ////float zoomSpeed = progress < 1 ? progress * zoomSpeedFinal : zoomSpeedFinal;
  //float zoomSpeed = progress < 1 ? utils.easeInQuad(progress, 0, zoomSpeedFinal, 1) : zoomSpeedFinal;

  //for (ZoomStar zoomer : zoomStars) {
  //  zoomer.pz = zoomer.z;
  //  zoomer.z -= zoomSpeed; //map(millis(), zoomSpeedupStart, zoomSpeedupStart + zoomSpeedupDuration, 0, 18);
  //  if (zoomer.z < zoomSpeed) {
  //    zoomer.x = random(-HEIGHT_REF_HALF, HEIGHT_REF_HALF);
  //    zoomer.y = random(-HEIGHT_REF_HALF, HEIGHT_REF_HALF);
  //    zoomer.z = HEIGHT_REF_HALF;
  //    zoomer.pz = zoomer.z;
  //  }
  //}
  //}

  void startZooming () {
    isZooming = true;
    zoomSpeedupStart = millis();

    float x = cos(a) * r;
    float y = sin(a) * r;

    for (int i = 0; i < stars.length; i++) {
      if (abs(stars[i].x - x) < width && abs(stars[i].y - y) < height) {
        float starX = stars[i].x - x;
        float starY = stars[i].y - y;
        float zoomZ = random(HEIGHT_REF_HALF);
        float zX = (starX / HEIGHT_REF_HALF) * zoomZ;
        float zY = (starY / HEIGHT_REF_HALF) * zoomZ;
        zoomStars.add(new ZoomStar(zX, zY, zoomZ));
      }
    }
  }

  void render(color currentColor) {

    if (isZooming) {
      pushMatrix();
      pushStyle();
      stroke(0, 0, 100, 1);
      //stroke(currentColor.getColor());
      strokeWeight(assets.STROKE_WIDTH + 1.5);
      for (ZoomStar z : zoomStars) {
        float x1 = (z.x / z.z) * HEIGHT_REF_HALF;
        //float x1 = map(z.x/z.z, 0, 1, 0, HEIGHT_REF_HALF);
        float y1 = map(z.y/z.z, 0, 1, 0, HEIGHT_REF_HALF);
        float x2 = map(z.x/z.pz, 0, 1, 0, HEIGHT_REF_HALF);
        float y2 = map(z.y/z.pz, 0, 1, 0, HEIGHT_REF_HALF);
        line(x1, y1, x2, y2);
      }
      popStyle();
      popMatrix();
    } else {
      float x = cos(a) * r;
      float y = sin(a) * r;
      float x2 = cos(a-(starSpeed * 6)) * r;
      float y2 = sin(a-(starSpeed * 6)) * r;

      pushStyle();
      for (int i = 0; i < stars.length; i++) {
        pushMatrix();
        if (abs(stars[i].x - x) < width && abs(stars[i].y - y) < height) {
          if (state == HYPERSPACE) {
            strokeWeight(4);
            fill(currentColor);
            if (i % 6 == 0) {
              stroke(currentColor);
              line(stars[i].x - x, stars[i].y - y, stars[i].x - x2, stars[i].y - y2);
            } else {
              noStroke();
              translate(stars[i].x - x, stars[i].y - y);
              rotate(PI/4);
              square(0, 0, 4);
            }
          } else {
            noStroke();
            fill(0, 0, 100);
            translate(stars[i].x - x, stars[i].y - y);
            rotate(PI/4);
            square(0, 0, 3);
          }
        }
        popMatrix();
      }
      popStyle();
    }
  }

  void restart() {
    zoomStars.clear();
    isZooming = false;
  }
}
