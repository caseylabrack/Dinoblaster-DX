interface obstacle {
  float getAngle ();
  float getArc();
  boolean isPassable();
  boolean enabled();
  boolean bounce();
  void markBounce();
}

class VolcanoSystem {
  final static int MAX_VOLCANOS = 4;
  Volcano[] volcanos = new Volcano[MAX_VOLCANOS];
  final float volcanoSpacing = 45;
  boolean enabled = false;
  float lastSpawned = 0;
  final float spawnMin = 20e3;
  final float spawnMax = 100e3;
  float spawnSpacing;
  float countdownStart;
  boolean spawning = false;

  int volcanoIndex = 0;

  VolcanoSystem (PImage[] frames, PImage explodeFrame) {
    for (int i = 0; i < volcanos.length; i++) {
      volcanos[i] = new Volcano(frames, explodeFrame);
    }
  }

  void addVolcanos (Entity earth) {
    for (Volcano v : volcanos) earth.addChild(v);
  }

  void startCountdown () {
    enabled = true;
    spawnSpacing = 1000000e3;//random(spawnMin, spawnMax);
    countdownStart = millis();
    spawning = true;
  }

  boolean spawn () {
    Volcano v = volcanos[volcanoIndex++ % volcanos.length]; // pluck from circular array

    float angle;
    boolean valid;

    for (int i = 0; i < 2000; i++) { // use brute force to try to find a place where the volcano can spawn
      angle = random(359);
      valid = true;
      for (Volcano v2 : volcanos) {
        if (v2 == v || !v2.enabled) continue;
        if (utils.unsignedAngleDiff(angle, v2.angle) < volcanoSpacing) valid = false;
      }
      if (valid) {
        v.x = cos(radians(angle)) * Volcano.eruptStartDist;
        v.y = sin(radians(angle)) * Volcano.eruptStartDist;
        v.r = 0 + 90;//angle + 90;
        v.angle = 0;//angle;
        v.erupt();

        spawnSpacing = random(spawnMin, spawnMax);
        return true;
      }
    }

    return false;
  }

  void update(float clock, float dt) {
    if (!enabled) return;

    if (spawning) {
      if (millis() - countdownStart > spawnSpacing) {
        spawn();
        spawnSpacing = random(spawnMin, spawnMax);
        countdownStart = millis();
      }
    }

    for (Volcano v : volcanos) {
      v.update(clock, dt);
    }
  }

  void render (color funkyColor) {
    if (!enabled) return;
    for (Volcano v : volcanos) {
      v.render(funkyColor);
    }
  }

  void restart() {
    spawning = false;
    for (Volcano v : volcanos) {
      v.enabled = false;
    }
  }

  void shutdownVolcanos (float clock) {
    spawning = false;
    for (Volcano v : volcanos) {
      v.goExtinct(clock);
    }
  }
}

class Volcano extends Entity implements obstacle {
  final static int WAITING = -1;
  final static int DELAYING = 0;
  final static int ERUPTING = 1;
  final static int ACTIVE = 2;
  final static int ENDING = 3;
  final static int EXTINCT = 4;
  private int state = DELAYING;
  float stateStart;

  final float eruptPassablePeriod = 6e3;
  final static float ERUPT_DURATION = 7e3;
  final static float eruptStartDist = 125;
  final static float eruptEndDist = 190;

  public float angle;

  float endingStart;
  final float ENDING_DURATION = 4e3;
  final float endingEndDist = 150;
  final float extinctDist = 185;

  final float minMargin = 6;
  final float maxMargin = 25;
  private float margin;

  private final float minDuration = 35e3;
  private final float maxDuration = 70e3;
  private float activeDuration;

  private float flareAngle = 30;
  private float flareStart;
  private float flareDuration = 500;
  private boolean flareLeft = true;

  boolean enabled = false;

  PImage[] frames;
  PImage flareFrame;

  Volcano (PImage[] frames, PImage splosionFrame) {
    this.frames = frames;
    this.flareFrame = splosionFrame;
  }

  void erupt () {
    state = DELAYING;
    enabled = true;
    activeDuration = 500e3;//random(minDuration, maxDuration);
  }

  float getAngle () {
    return utils.angleOf(utils.ZERO_VECTOR, localPos());
  }

  float getArc() {
    return margin;
  }

  boolean isPassable() {
    return state==EXTINCT;
  }

  boolean enabled() {
    return enabled;
  }

  boolean bounce () {
    return false;
  }

  void markBounce() {
  }

  void goExtinct (float clock) {
    if (state != EXTINCT) {
      state = ENDING;
      stateStart = clock;
    }
  }

  void update (float clock, float dt) {
    if (!enabled) return;

    float progress, dist;

    switch(state) {  

    case DELAYING:
      state = ERUPTING;
      stateStart = clock;
      assets.volcanoStuff.rumble.play(true);
      break;

    case ERUPTING: 
      progress = (clock - stateStart) / ERUPT_DURATION;
      if (progress < 1) {
        dist = utils.easeInQuad(progress, eruptStartDist, eruptEndDist - eruptStartDist, 1);
        setPosition(new PVector(cos(radians(angle)) * dist, sin(radians(angle)) * dist));
        margin = map(progress, 0, 1, minMargin, maxMargin);
      } else {
        setPosition(new PVector(cos(radians(angle)) * eruptEndDist, sin(radians(angle)) * eruptEndDist));
        margin = maxMargin;
        stateStart = clock;
        flareStart = clock;
        state = ACTIVE;
        assets.volcanoStuff.rumble.stop_();
      }
      break;

    case ACTIVE:
      if (clock - flareStart > flareDuration) {
        flareStart = clock;
        flareLeft = !flareLeft;
        flareAngle = flareLeft ? -flareAngle : flareAngle;
      }
      if (clock - stateStart > activeDuration) {
        //goExtinct();
        stateStart = clock;
        state=ENDING;
      }
      break;

    case ENDING:
      progress = (clock - stateStart) / ENDING_DURATION;
      if (progress < 1) {
        dist = utils.easeLinear(progress, eruptEndDist, endingEndDist - eruptEndDist, 1);
        setPosition(cos(radians(angle)) * dist, sin(radians(angle)) * dist);
        x+=random(-5, 5);
        y+=random(-5, 5);
      } else {
        state = EXTINCT;
        setPosition(cos(radians(angle)) * extinctDist, sin(radians(angle)) * extinctDist);
      }
      break;
    }
  }

  void render (color funkyColor) {
    if (!enabled) return;

    pushTransforms();
    if (state != EXTINCT) {
      sb.image(frames[1], 0, 0); // shell
      sb.pushStyle();
      sb.tint(funkyColor);
      sb.image(frames[2], 0, 0); // lava
      sb.popStyle();
    } else {
      sb.image(frames[3], 0, 0); // husk
    }

    if (state==ACTIVE) {
      sb.pushStyle();
      sb.tint(funkyColor);      
      sb.rotate(radians(flareAngle));
      sb.translate(0, -75);
      sb.image(flareFrame, 0, 0);
      sb.popStyle();
    }
    sb.popMatrix();
  }
}
