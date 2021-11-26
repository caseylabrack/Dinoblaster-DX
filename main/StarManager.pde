class StarManager implements updateable, renderable, renderableScreen, nebulaEvents {

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

  void update () {
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
