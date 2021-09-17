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

class StarManager implements updateable, renderable, renderableScreen, nebulaEvents, gameFinaleEvent {

  ArrayList<ZoomStar> zoomStars = new ArrayList<ZoomStar>();
  final float zoomSpeedFinal = 17;
  final float zoomSpeedupDuration = 5e3;
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
  final float HYPERSPACE_DURATION = 15e3;
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

    hypercubesEnabled = settings.getBoolean("hypercubesEnabled", true);

    if (lvl==UIStory.TRIASSIC) {
      int i = int(random(5, 80));
      while (i < 80) {
        hyperspaceSpawns.append(i);
        i += int(random(30, 80));
      }
    }

    for (int i = 0; i < 100; i++) {
      zoomStars.add(new ZoomStar(random(-HEIGHT_REF_HALF, HEIGHT_REF_HALF), random(-HEIGHT_REF_HALF, HEIGHT_REF_HALF), random(HEIGHT_REF_HALF)));
    }
  }

  void nebulaStartHandle() {
    hyperspace = true;
    starSpeed = defaultStarSpeed * 5;
    hyperspaceStart = millis();
  }

  void nebulaStopHandle() {
  }

  void finaleHandle() {
    isFinale = true;
    zoomSpeedupStart = millis();
  }

  void update () {

    if (isFinale) {

      float progress = (millis() - zoomSpeedupStart) / zoomSpeedupDuration;
      //float zoomSpeed = progress < 1 ? progress * zoomSpeedFinal : zoomSpeedFinal;

      //float zoomSpeed = progress < 1 ? progress * zoomSpeedFinal : zoomSpeedFinal;
      float zoomSpeed = progress < 1 ? utils.easeOutExpo(progress,0,zoomSpeedFinal,1) : zoomSpeedFinal;

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

      //float x = cos(a) * r;
      //float y = sin(a) * r;

      //for (int i = 0; i < stars.length; i++) {
      //  if (abs(stars[i].x - x) < width && abs(stars[i].y - y) < height) {
      //    zoomStars.add(new ZoomStar());
      //  }
      //}


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
      if (millis() - hyperspaceStart > HYPERSPACE_DURATION) {
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
      stroke(currentColor.getColor());
      strokeWeight(assets.STROKE_WIDTH);
      for (ZoomStar z : zoomStars) {
        float x1 = map(z.x/z.z,  0, 1, 0, HEIGHT_REF_HALF);
        float y1 = map(z.y/z.z,  0, 1, 0, HEIGHT_REF_HALF);
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
