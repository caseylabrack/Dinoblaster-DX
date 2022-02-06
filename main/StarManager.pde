class StarManager implements updateable, renderable, renderableScreen, nebulaEvents, gameFinaleEvent {

  ArrayList<ZoomStar> zoomStars = new ArrayList<ZoomStar>();
  final float zoomSpeedFinal = 17;
  final static float zoomSpeedupDuration = 6e3;
  float zoomSpeedupStart;

  PVector[] stars = new PVector[800];
  float r = 2000;
  float a = 0;//PI/2;
  final float defaultStarSpeed = TWO_PI / (360 * 40);
  float starSpeed = defaultStarSpeed;

  PVector hypercubePos;
  boolean hypercubeActive = false;
  final float hypercubeLead = 17;
  final float hypercubeOffset = -150;
  final static float DEFAULT_HYPERSPACE_DURATION = 15e3;
  float hyperspaceDuration;
  float hyperspaceStart;
  Hypercube hypercube;
  boolean hyperspace = false;
  IntList hyperspaceSpawns = new IntList();
  boolean hypercubesEnabled;

  boolean isFinale = false;

  ColorDecider currentColor;
  Time time;
  EventManager events;

  StarManager (ColorDecider _color, Time t, EventManager evs, int lvl) {

    currentColor = _color;
    time = t;
    events = evs;

    int k = 0;
    for (int j = 0; j < 360; j+= 9) {
      for (int i = 0; i < 20; i++) {
        stars[k] = new PVector(cos(a+j) * r + random(-width/2, width/2), sin(a+j)*r + random(-height/2, height/2));
        k++;
      }
    }

    evs.nebulaStartSubscribers.add(this);
    evs.gameFinaleSubscribers.add(this);

    hyperspaceDuration = settings.getFloat("hyperspaceDuration", DEFAULT_HYPERSPACE_DURATION) * 1e3;
    hypercubesEnabled = settings.getBoolean("hypercubesEnabled", true);

    if (lvl==UIStory.TRIASSIC) {
      int i = int(random(5, 80));
      //int i = 1; // DEBUG: hypercube on start
      while (i < 80) {
        hyperspaceSpawns.append(i);
        //i += int(random(30, 80));
        i += int(random(80, 80));
      }
    }
  }

  void nebulaStartHandle() {
    hyperspace = true;
    starSpeed = defaultStarSpeed * 5;
    hyperspaceStart = millis();
  }

  void nebulaStopHandle() {
  }
  void finaleClose() {}

  void finaleHandle() {
    //isFinale = true;
    //zoomSpeedupStart = millis();

    //float x = cos(a) * r;
    //float y = sin(a) * r;

    //for (int i = 0; i < stars.length; i++) {
    //  if (abs(stars[i].x - x) < width && abs(stars[i].y - y) < height) {
    //    float starX = stars[i].x - x;
    //    float starY = stars[i].y - y;
    //    float zoomZ = random(HEIGHT_REF_HALF);
    //    float zX = (starX / HEIGHT_REF_HALF) * zoomZ;
    //    float zY = (starY / HEIGHT_REF_HALF) * zoomZ;
    //    zoomStars.add(new ZoomStar(zX, zY, zoomZ));
    //  }
    //}
  }

  void startZooming () {
    isFinale = true;
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

  void finaleTrexHandled(PVector _) {
  }

  void finaleImpact() {
  }

  void update () {

    //if (mousePressed) {
    //  isFinale = true;
    //  //zoomSpeedupStart = millis();

    //  float x = cos(a) * r;
    //  float y = sin(a) * r;

    //  for (int i = 0; i < stars.length; i++) {
    //    if (abs(stars[i].x - x) < width && abs(stars[i].y - y) < height) {
    //      float starX = stars[i].x - x;
    //      float starY = stars[i].y - y;
    //      float zoomZ = random(HEIGHT_REF_HALF);
    //      float zX = (starX / HEIGHT_REF_HALF) * zoomZ;
    //      float zY = (starY / HEIGHT_REF_HALF) * zoomZ;
    //      zoomStars.add(new ZoomStar(zX, zY, zoomZ));
    //    }
    //  }
    //}

    if (isFinale) {

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

      return;
    }

    a += starSpeed * time.getTimeScale();

    if (!hypercubesEnabled) return;

    if (hyperspaceSpawns.size()!=0) {
      if (time.getClock() > hyperspaceSpawns.get(0) * 1000) {
        if (hyperspaceSpawns.size() >= 1) hyperspaceSpawns.remove(0);
        hypercubeActive = true;
        hypercube = new Hypercube(currentColor, time);
        hypercubePos = new PVector(cos(a + radians(hypercubeLead)) * (r + hypercubeOffset), sin(a + radians(hypercubeLead)) * (r + hypercubeOffset));
      }
    }

    if (hyperspace) {
      if (millis() - hyperspaceStart > hyperspaceDuration) {
        hyperspace = false;
        hypercubeActive = false;
        starSpeed = defaultStarSpeed;
        events.dispatchNebulaEnded();
      }
    }
  }

  PVector hypercubePosition () {
    return hypercubeActive ? new PVector(hypercubePos.x - cos(a) * r, hypercubePos.y - sin(a) * r) : new PVector(Float.MAX_VALUE, Float.MAX_VALUE);
  }

  void render () {

    if (isFinale) {
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
          if (hyperspace) {
            strokeWeight(4);
            fill(currentColor.getColor());
            if (i % 6 == 0) {
              stroke(currentColor.getColor());
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

      if (hypercubeActive) {
        pushMatrix();
        translate(hypercubePos.x - x, hypercubePos.y - y);
        hypercube.update();
        popMatrix();
      }
    }
  }
}

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
