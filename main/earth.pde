class Earth extends Entity {
  final static float DEFAULT_EARTH_ROTATION = 2.3;
  final static float EARTH_RADIUS = 167;

  float targetRotationRate = DEFAULT_EARTH_ROTATION;

  final static int NORM = 0;
  final static int SHAKING = 1;
  int state = NORM;

  PShader pixelMask;
  PGraphics tarpitDynamicMask;
  final float TARPIT_AMPLITUDE = 20;
  final static float TARPIT_ARC = 45;
  final static float TARPIT_SINK_DURATION = 4e3;
  float tarpitArcStart;
  float tarpitAngle;
  boolean tarpitEnabled = false;
  final static float TARPIT_SINK_RATE = 2;

  final static float VOLCANO_SHAKING_MAGNITUDE = 10;
  boolean shakeMomentary = false;
  float shakeDuration;
  boolean shakeContinuous = false;
  float shakeMagnitude;
  float shakeStart;

  float steadyXPosition = 0;
  float steadyYPosition = 0;

  Earth (PShader pixelMask) {
    this.pixelMask = pixelMask;

    int side = assets.earthStuff.earth.width; // square asset
    //tarpitDynamicMask = createGraphics(width, height, P2D);
    tarpitDynamicMask = createGraphics(side, side, P2D);
    tarpitDynamicMask.noSmooth();
    tarpitDynamicMask.ellipseMode(CENTER);
    tarpitDynamicMask.colorMode(HSB, 360, 100, 100, 1);
    tarpitDynamicMask.noStroke();
    tarpitDynamicMask.fill(0, 0, 0, 1);
  }

  // start an earth quake, with magnitude, duration, and (scaled) start time
  // specify only magnitude to keep shaking indefinitely
  // cannot start a momentary shake while an indefinite shake is active
  // pass magnitude of zero to stop all shaking, momentary or continuous
  void shake (float mag, float dur, float clock) {
    if (mag == 0) {
      shakeContinuous = false;
      shakeMomentary = false;
      return;
    }

    shakeMagnitude = mag;
    if (dur==0) { // shake continuously
      shakeContinuous = true;
      shakeMomentary = false;
    } else {
      if (!shakeContinuous) { // do a momentary shake, but only if we're not shaking continuously already
        shakeMomentary = true;
        shakeDuration = dur;
        shakeStart = clock;
      }
    }
  }

  void shake(float mag) {
    shake(mag, 0, 0);
  }

  void move(float dt, float clock) {

    steadyXPosition += dx * dt;
    steadyYPosition += dy * dt;
    r += dr * dt;

    x = steadyXPosition;
    y = steadyYPosition;

    if (shakeContinuous) {
      x += cos(random(TWO_PI)) * random(shakeMagnitude);
      y += sin(random(TWO_PI)) * random(shakeMagnitude);
    } else if (shakeMomentary) {
      float progress = (clock - shakeStart) / shakeDuration;
      if (progress < 1) {
        float t = 1 - progress;
        //float t = 1 - utils.easeOutExpoT(progress);
        x += cos(random(TWO_PI)) * (shakeMagnitude * t);
        y += sin(random(TWO_PI)) * (shakeMagnitude * t);
      } else {
        shakeMomentary = false;
      }
    }
  }

  void spawnTarpit () {
    tarpitEnabled = true;

    tarpitArcStart = random(360-TARPIT_ARC);

    int side = assets.earthStuff.earth.width; // square asset
    tarpitDynamicMask.beginDraw();
    tarpitDynamicMask.clear();
    //tarpitDynamicMask.fill(100);
        //tarpitDynamicMask.translate(width/2, height/2);
    tarpitDynamicMask.translate(side/2, side/2);
    tarpitDynamicMask.beginShape();
    tarpitDynamicMask.vertex(cos(radians(tarpitArcStart)) * (EARTH_RADIUS+100), sin(radians(tarpitArcStart)) * (EARTH_RADIUS+100));
    tarpitDynamicMask.vertex(cos(radians(tarpitArcStart + TARPIT_ARC)) * (EARTH_RADIUS + 100), sin(radians(tarpitArcStart + TARPIT_ARC)) * (EARTH_RADIUS+100));    
    tarpitDynamicMask.vertex(cos(radians(tarpitArcStart + TARPIT_ARC)) * (EARTH_RADIUS - 40), sin(radians(tarpitArcStart + TARPIT_ARC)) * (EARTH_RADIUS - 40));
    tarpitDynamicMask.vertex(cos(radians(tarpitArcStart)) * (EARTH_RADIUS-40), sin(radians(tarpitArcStart)) * (EARTH_RADIUS-40));
    tarpitDynamicMask.endShape();
    tarpitDynamicMask.endDraw();
    assets.earthStuff.mask.set("mask", tarpitDynamicMask);

    PVector mypoint = new PVector(cos(radians(tarpitArcStart + TARPIT_ARC/2)), sin(radians(tarpitArcStart + TARPIT_ARC/2)));
    tarpitAngle = utils.angleOf(new PVector(0, 0), mypoint);
  }

  public void setStuckInTarpit (tarpitSinkable sinker) {
    if (!tarpitEnabled || !sinker.sinkingEnabled()) return;
    sinker.setInTarpit(utils.unsignedAngleDiff(sinker.angleOnEarth(), tarpitAngle) < TARPIT_ARC/2 - sinker.nudgeMargin());
  }

  void render(float clock) {

    if (tarpitEnabled) sb.shader(pixelMask);
    simpleRenderImage();
    if (tarpitEnabled) sb.resetShader();

    if (!tarpitEnabled) return;

    pushTransforms();
    sb.pushStyle();
    sb.strokeWeight(assets.STROKE_WIDTH);
    sb.stroke(0, 0, 100, 1);
    //sb.noFill();
    sb.fill(0, 0, 0, 1);
    sb.beginShape();

    // tarpit surface
    float arcDist = EARTH_RADIUS - 10;
    sb.vertex(cos(radians(tarpitArcStart)) * (arcDist), sin(radians(tarpitArcStart)) * (arcDist));
    float x, y;
    float amp = 4;
    float step = 6;
    float phase = 1.822;
    for (int i = (int)tarpitArcStart+(int)step; i < tarpitArcStart + TARPIT_ARC - step; i+=step) {
      x = cos(radians(i)) * (arcDist);
      y = sin(radians(i)) * (arcDist);
      x += cos(i * phase + clock/500) * amp;
      y += sin(i * phase + clock/500) * amp;
      sb.vertex(x, y);
    }
    sb.vertex(cos(radians(tarpitArcStart + TARPIT_ARC)) * (arcDist), sin(radians(tarpitArcStart + TARPIT_ARC)) * (arcDist));

    // tarpit floor
    float cx = cos(radians(tarpitArcStart + TARPIT_ARC/2)) * (arcDist * .75);
    float cy = sin(radians(tarpitArcStart + TARPIT_ARC/2)) * (arcDist * .75);
    float offset = tarpitArcStart + TARPIT_ARC * 2;
    for (int i = 0; i < 200; i+=35) { 
      sb.vertex(cx + cos(radians(i + offset)) * 60, cy + sin(radians(i + offset)) * 60);
    }
    sb.endShape(CLOSE);

     //tarpit doodads
    float ang = tarpitArcStart + TARPIT_ARC - 8;
    float d = (EARTH_RADIUS - 65) + (floor(sin(radians(0) + clock/1e3)) * 5); // bob up and down in a square wave
    sb.pushMatrix();
    sb.translate(cos(radians(ang)) * d, sin(radians(ang)) * d);
    sb.rotate(radians(tarpitArcStart + 200));
    sb.image(assets.earthStuff.doodadHead, 0, 0);
    sb.popMatrix();

    ang = tarpitArcStart + 15;
    d = (EARTH_RADIUS - 85) + (floor(sin(radians(60) + clock/1e3)) * 5); // bob up and down in a square wave
    sb.pushMatrix();
    sb.translate(cos(radians(ang)) * d, sin(radians(ang)) * d);
    sb.rotate(radians(tarpitArcStart + 90));
    sb.image(assets.earthStuff.doodadRibs, 0, 0);
    sb.popMatrix();

    ang = tarpitArcStart + 10;
    d = (EARTH_RADIUS - 55) + (floor(sin(radians(120) + clock/1e3)) * 5); // bob up and down in a square wave
    sb.pushMatrix();
    sb.translate(cos(radians(ang)) * d, sin(radians(ang)) * d);
    sb.rotate(radians(tarpitArcStart + 180));
    sb.image(assets.earthStuff.doodadBone, 0, 0);
    sb.popMatrix();

    sb.popMatrix();
    sb.popStyle();
  }

  void restart() {
    tarpitEnabled = false;
    shakeContinuous = false;
    shakeMomentary = false;
    steadyXPosition = 0;
    steadyYPosition = 0;
    dx = 0;
    dy = 0;
    x = 0;
    y = 0;
    dr = targetRotationRate;
  }
}
