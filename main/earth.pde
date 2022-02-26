class Earth extends Entity {
  final static float DEFAULT_EARTH_ROTATION = 2.3;
  final static float EARTH_RADIUS = 167;

  final static int NORM = 0;
  final static int SHAKING = 1;
  int state = NORM;

  final static float VOLCANO_SHAKING_MAGNITUDE = 10;
  float shakingMag;

  float steadyXPosition = 0;
  float steadyYPosition = 0;

  //float shakeX = 0;
  //float shakeY = 0;

  void startShaking(float mag) {
    shakingMag = mag;
    state = SHAKING;
  }

  void move(float dt) {

    steadyXPosition += dx * dt;
    steadyYPosition += dy * dt;
    r += dr * dt;

    switch(state) {
    case NORM: 
      x = steadyXPosition;
      y = steadyYPosition;
      break;

    case SHAKING:
      x = steadyXPosition + cos(random(TWO_PI)) * random(VOLCANO_SHAKING_MAGNITUDE);
      y = steadyYPosition + sin(random(TWO_PI)) * random(VOLCANO_SHAKING_MAGNITUDE);
      break;
    }
  }

  void render() {
    simpleRenderImage();
  }
}

//class Earth extends Entity implements levelChangeEvent, gameFinaleEvent, updateable, renderable {

//  PImage model;

//  PGraphics tarpitDynamicMask;
//  final float TARPIT_AMPLITUDE = 20;
//  final float TARPIT_ARC = 45;
//  final float TARPIT_MARGIN = 5;
//  final static float TARPIT_SINK_DURATION = 4e3;
//  float tarpitArcStart;
//  float tarpitAngle;
//  boolean tarpitEnabled = false;

//  float shakeAngle;
//  boolean shake = false;
//  float shakeMag;

//  boolean shaking = false;
//  float shakingDur;
//  float shakingMag;
//  float shakingStart;
//  final float FINALE_SHAKING_MAG = 10;

//  boolean isFinale = false;
//  float finaleStartR, finaleTargetR, finaleStartTimer;

//  final static float DEFAULT_EARTH_ROTATION = 2.3;
//  final static float EARTH_RADIUS = 167;

//  final  int NORM = 0;
//  final  int FINALE = 1;
//  final int ZOOMING = 2;
//  int state = NORM;

//  Time time;
//  EventManager events;

//  Earth (Time t, EventManager e, int lvl) {
//    time = t;
//    events = e;

//    x = 0;
//    y = 0;
//    dx = 0;
//    dy = 0;
//    dr = settings.getFloat("earthRotationSpeed", DEFAULT_EARTH_ROTATION);

//    if (settings.getBoolean("earthIsPangea", false)) {
//      if (settings.getBoolean("earthIsWest", true)) {
//        model = assets.earthStuff.earthPangea1;
//      } else {
//        model = assets.earthStuff.earthPangea2;
//      }
//    } else {
//      if (settings.getBoolean("earthIsWest", true)) {
//        model = assets.earthStuff.earth;
//      } else {
//        model = assets.earthStuff.earth2;
//      }
//    }

//    tarpitArcStart = random(360-TARPIT_ARC);

//    int side = assets.earthStuff.earth.width; // square asset
//    tarpitDynamicMask = createGraphics(side, side, P2D);
//    tarpitDynamicMask.noSmooth();
//    tarpitDynamicMask.ellipseMode(CENTER);
//    tarpitDynamicMask.beginDraw();
//    tarpitDynamicMask.colorMode(HSB, 360, 100, 100, 1);
//    tarpitDynamicMask.noStroke();
//    tarpitDynamicMask.fill(0, 0, 0, 1);
//    tarpitDynamicMask.translate(side/2, side/2);
//    tarpitDynamicMask.beginShape();
//    tarpitDynamicMask.vertex(cos(radians(tarpitArcStart)) * (EARTH_RADIUS+100), sin(radians(tarpitArcStart)) * (EARTH_RADIUS+100));
//    tarpitDynamicMask.vertex(cos(radians(tarpitArcStart + TARPIT_ARC)) * (EARTH_RADIUS + 100), sin(radians(tarpitArcStart + TARPIT_ARC)) * (EARTH_RADIUS+100));    
//    tarpitDynamicMask.vertex(cos(radians(tarpitArcStart + TARPIT_ARC)) * (EARTH_RADIUS - 40), sin(radians(tarpitArcStart + TARPIT_ARC)) * (EARTH_RADIUS - 40));
//    tarpitDynamicMask.vertex(cos(radians(tarpitArcStart)) * (EARTH_RADIUS-40), sin(radians(tarpitArcStart)) * (EARTH_RADIUS-40));
//    tarpitDynamicMask.endShape();
//    tarpitDynamicMask.endDraw();
//    assets.earthStuff.mask.set("mask", tarpitDynamicMask);

//    PVector mypoint = new PVector(cos(radians(tarpitArcStart + TARPIT_ARC/2)), sin(radians(tarpitArcStart + TARPIT_ARC/2)));
//    tarpitAngle = utils.angleOf(new PVector(0, 0), mypoint);

//    if (lvl==UIStory.CRETACEOUS) {
//      tarpitEnabled = true;
//    }

//    events.levelChangeSubscribers.add(this);
//    events.gameFinaleSubscribers.add(this);
//  }

//  void shake (float _mag) {
//    shakeMag = _mag;
//    shake = true;
//  }

//  public void shakeContinous (float _dur, float _mag) {
//    shakingDur = _dur;
//    shakingMag = _mag;
//    shakingStart = time.getClock();
//    shaking = true;
//  }

//  void zoomAway () {
//    state = ZOOMING;
//  }

//  void update() {

//    switch(state) {

//    case NORM:
//      dx = 0 - x;
//      dy = 0 - y;

//      if (shake) {
//        shakeAngle = random(0, TWO_PI);
//        dx += cos(shakeAngle) * shakeMag;
//        dy += sin(shakeAngle) * shakeMag;
//        shakeMag *= .9;
//        if (shakeMag < .1) {
//          shakeMag = 0;
//          shake = false;
//        }
//      } 

//      if (shaking) {
//        shakeAngle = random(0, TWO_PI);
//        dx += cos(shakeAngle) * shakingMag;
//        dy += sin(shakeAngle) * shakingMag;
//        if (time.getClock() - shakingStart > shakingDur) {
//          shaking = false;
//        }
//      }

//      x += dx;// * time.getTimeScale();
//      y += dy;// * time.getTimeScale();
//      r += dr * time.getTimeScale();
//      break;

//    case FINALE:
//      float progress = (millis() - finaleStartTimer) / FinaleStuff.BIG_ONE_INCOMING_DURATION;
//      if (progress < 1) {
//        this.r = finaleStartR + (finaleTargetR - finaleStartR) * progress;
//      } else {
//        shakeAngle = random(0, TWO_PI);
//        x = cos(shakeAngle) * FINALE_SHAKING_MAG;
//        y = sin(shakeAngle) * FINALE_SHAKING_MAG;
//      }
//      break;

//    case ZOOMING:
//      x += dx;// * time.getTimeScale();
//      y += dy;// * time.getTimeScale();
//      r += dr * time.getTimeScale();
//      break;
//    }
//  }

//  void levelChangeHandle(int stage) {

//    if (stage==UIStory.CRETACEOUS) {
//      tarpitEnabled = true;
//    }
//  }

//  void finaleClose(){}
//  void finaleHandle() {
//  }

//  void finaleTrexHandled(PVector p) {
//    isFinale = true;
//    float diff = random(30, 60);
//    if (p != utils.ZERO_VECTOR) {
//      float finaleSlowdownStartAngle = utils.angleOf(utils.ZERO_VECTOR, p);
//      float targetAngle = utils.angleOf(utils.ZERO_VECTOR, new PVector(-HEIGHT_REFERENCE, -HEIGHT_REFERENCE));
//      diff = utils.signedAngleDiff(finaleSlowdownStartAngle, targetAngle);
//    }
//    finaleStartR = this.r;
//    finaleTargetR = this.r + diff;
//    finaleStartTimer = millis();
//    state = FINALE;
//  }

//  void finaleImpact() {
//    dr = 0;
//  }

//  boolean isInTarpit (PVector pos) {

//    if (!tarpitEnabled) return false;

//    float tangle = utils.angleOf(utils.ZERO_VECTOR, pos);
//    float diff = utils.unsignedAngleDiff(tarpitAngle, tangle);
//    return diff < TARPIT_ARC / 2 - TARPIT_MARGIN;
//  }

//  float getTarpitAngleDegrees () {
//    return tarpitAngle;
//  }

//  void render () {

//    if (tarpitEnabled) shader(assets.earthStuff.mask);
//    simpleRenderImage(model);
//    if (tarpitEnabled) resetShader();

//    if (!tarpitEnabled) return;

//    pushTransforms();
//    pushStyle();
//    strokeWeight(assets.STROKE_WIDTH);
//    stroke(0, 0, 100, 1);
//    fill(0, 0, 0, 1);
//    beginShape();

//    // tarpit surface
//    float arcDist = EARTH_RADIUS - 10;
//    vertex(cos(radians(tarpitArcStart)) * (arcDist), sin(radians(tarpitArcStart)) * (arcDist));
//    float x, y;
//    float amp = 4;
//    float step = 6;
//    float phase = 1.822;
//    for (int i = (int)tarpitArcStart+(int)step; i < tarpitArcStart + TARPIT_ARC - step; i+=step) {
//      x = cos(radians(i)) * (arcDist);
//      y = sin(radians(i)) * (arcDist);
//      x += cos(i * phase + time.getClock()/500) * amp;
//      y += sin(i * phase + time.getClock()/500) * amp;
//      //circle(x, y, 2);
//      vertex(x, y);
//    }
//    vertex(cos(radians(tarpitArcStart + TARPIT_ARC)) * (arcDist), sin(radians(tarpitArcStart + TARPIT_ARC)) * (arcDist));

//    // tarpit floor
//    float cx = cos(radians(tarpitArcStart + TARPIT_ARC/2)) * (arcDist * .75);
//    float cy = sin(radians(tarpitArcStart + TARPIT_ARC/2)) * (arcDist * .75);
//    float offset = tarpitArcStart + TARPIT_ARC * 2;
//    for (int i = 0; i < 200; i+=35) { 
//      vertex(cx + cos(radians(i + offset)) * 60, cy + sin(radians(i + offset)) * 60);
//    }
//    endShape(CLOSE);

//    // tarpit doodads
//    float ang = tarpitArcStart + TARPIT_ARC - 8;
//    float d = (EARTH_RADIUS - 65) + (floor(sin(radians(0) + time.getClock()/1e3)) * 5); // bob up and down in a square wave
//    pushMatrix();
//    translate(cos(radians(ang)) * d, sin(radians(ang)) * d);
//    rotate(radians(tarpitArcStart + 200));
//    image(assets.earthStuff.doodadHead, 0, 0);
//    popMatrix();

//    ang = tarpitArcStart + 15;
//    d = (EARTH_RADIUS - 85) + (floor(sin(radians(60) + time.getClock()/1e3)) * 5); // bob up and down in a square wave
//    pushMatrix();
//    translate(cos(radians(ang)) * d, sin(radians(ang)) * d);
//    rotate(radians(tarpitArcStart + 90));
//    image(assets.earthStuff.doodadRibs, 0, 0);
//    popMatrix();

//    ang = tarpitArcStart + 10;
//    d = (EARTH_RADIUS - 55) + (floor(sin(radians(120) + time.getClock()/1e3)) * 5); // bob up and down in a square wave
//    pushMatrix();
//    translate(cos(radians(ang)) * d, sin(radians(ang)) * d);
//    rotate(radians(tarpitArcStart + 180));
//    image(assets.earthStuff.doodadBone, 0, 0);
//    popMatrix();

//    popMatrix();
//    popStyle();
//  }
//}
