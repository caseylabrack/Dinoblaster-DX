interface obstacle {
  float getAngle ();
  float getArc();
  boolean isPassable();
  boolean enabled();
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
    spawnSpacing = random(spawnMin, spawnMax);
    countdownStart = millis();
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
        v.r = angle + 90;
        v.angle = angle;
        v.erupt();

        spawnSpacing = random(spawnMin, spawnMax);
        return true;
      }
    }

    return false;
  }

  void update(float clock, float dt) {
    if (!enabled) return;

    if (millis() - countdownStart > spawnSpacing) {
      spawn();
      spawnSpacing = random(spawnMin, spawnMax);
      countdownStart = millis();
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
    activeDuration = random(minDuration, maxDuration);
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

  void update (float clock, float dt) {
    if (!enabled) return;

    float progress, dist;

    switch(state) {  

    case DELAYING:
      state = ERUPTING;
      stateStart = clock;
      //assets.volcanoStuff.rumble.play(true);
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
      image(frames[1], 0, 0); // shell
      pushStyle();
      tint(funkyColor);
      image(frames[2], 0, 0); // lava
      popStyle();
    } else {
      image(frames[3], 0, 0); // husk
    }

    if (state==ACTIVE) {
      pushStyle();
      tint(funkyColor);      
      rotate(radians(flareAngle));
      translate(0, -75);
      image(flareFrame, 0, 0);
      popStyle();
    }
    popMatrix();
  }
}

//class VolcanoManager implements levelChangeEvent, updateable, renderable {

//  ArrayList<Volcano> volcanos = new ArrayList<Volcano>();
//  Time time;
//  Earth earth;
//  ColorDecider currentColor;

//  final float volcanoSpacing = 45;
//  boolean enabled = false;
//  float lastSpawned = 0;
//  final float spawnMin = 20e3;
//  final float spawnMax = 100e3;
//  float spawnSpacing;

//  VolcanoManager(EventManager events, Time t, ColorDecider _c, Earth e, int lvl) {

//    time = t;
//    earth = e;
//    currentColor = _c;

//    if (settings.getBoolean("volcanosEnabled", true)) {
//      if (lvl==UIStory.JURASSIC) {
//        spawn();
//        enabled = true;
//      }

//      events.levelChangeSubscribers.add(this);
//    }
//  }

//  void update () {
//    for (Volcano v : volcanos) v.update();
//    if (enabled && time.getClock() - lastSpawned > spawnSpacing) {
//      spawn();
//    }
//  }

//  void render () {
//    for (Volcano v : volcanos) v.render();
//  }

//  void levelChangeHandle(int stage) {

//    switch(stage) {

//    case UIStory.JURASSIC:
//      spawn();
//      enabled = true;
//      break;

//    case UIStory.CRETACEOUS:
//      enabled = false;
//      for (Volcano v : volcanos) v.goExtinct();
//      break;
//    }
//  }

//  void spawn () {

//    float angle;
//    boolean valid;

//    for (int i = 0; i < 2000; i++) { // use brute force to try to find a place where the volcano can spawn
//      angle = random(360);
//      valid = true;
//      for (Volcano v : volcanos) {
//        if (utils.unsignedAngleDiff(angle, v.angle) < volcanoSpacing) valid = false;
//      }
//      if (valid) {
//        volcanos.add(new Volcano(time, earth, currentColor, angle));
//        lastSpawned = time.getClock();
//        spawnSpacing = random(spawnMin, spawnMax);
//        earth.shakeContinous(Volcano.ERUPT_DURATION, 3);
//        return;
//      }
//    }
//    println("couldn't place volcano");
//  }
//}

//class Volcano extends Entity {

//  final static int DELAYING = 0;
//  final static int ERUPTING = 1;
//  final static int ACTIVE = 2;
//  final static int ENDING = 3;
//  final static int EXTINCT = 4;
//  private int state = DELAYING;

//  final float eruptPassablePeriod = 6e3;
//  final static float ERUPT_DURATION = 7e3;
//  final static float eruptStartDist = 125;
//  final static float eruptEndDist = 190;
//  float eruptStart;

//  float angle;

//  float endingStart;
//  final float ENDING_DURATION = 4e3;
//  final float endingEndDist = 150;
//  final float extinctDist = 185;

//  final float maxMargin = 25;
//  private float margin;

//  private final float avgDuration = 50e3;
//  private final float durationVariation = 20e3;
//  private float activeDuration;
//  private float activeStart;

//  private float flareAngle = 30;
//  private float flareStart;
//  private float flareDuration = 500;
//  private boolean flareLeft = true;

//  float playerRunspeed;

//  Time time;
//  ColorDecider currentColor;

//  Volcano (Time t, Earth earth, ColorDecider _c, float _angle) {
//    angle = _angle;
//    time = t;
//    currentColor = _c;

//    playerRunspeed = settings.getFloat("playerSpeed", 5);

//    x = earth.x + cos(radians(angle)) * eruptStartDist;
//    y = earth.y + sin(radians(angle)) * eruptStartDist; 
//    earth.addChild(this);
//    r = angle + 90;

//    activeDuration = avgDuration + random(-durationVariation, durationVariation);
//  }

//  void update () {

//    float progress, dist;

//    switch(state) {

//    case DELAYING:
//      state = ERUPTING;
//      eruptStart = time.getClock();
//      assets.volcanoStuff.rumble.play(true);
//      break;

//    case ERUPTING: 
//      progress = (time.getClock() - eruptStart) / ERUPT_DURATION;
//      if (progress < 1) {
//        dist = utils.easeInQuad(progress, eruptStartDist, eruptEndDist - eruptStartDist, 1);
//        setPosition(new PVector(cos(radians(angle)) * dist, sin(radians(angle)) * dist));
//        margin = utils.easeLinear(progress, playerRunspeed, maxMargin - playerRunspeed, 1);
//        //margin = utils.easeLinear(progress, Player.runSpeed, maxMargin - Player.runSpeed, 1);
//      } else {
//        setPosition(new PVector(cos(radians(angle)) * eruptEndDist, sin(radians(angle)) * eruptEndDist));
//        margin = maxMargin;
//        activeStart = time.getClock();
//        flareStart = time.getClock();
//        state = ACTIVE;
//        assets.volcanoStuff.rumble.stop_();
//      }
//      break;

//    case ACTIVE:
//      if (time.getClock() - flareStart > flareDuration) {
//        flareStart = time.getClock();
//        flareLeft = !flareLeft;
//        flareAngle = flareLeft ? -flareAngle : flareAngle;
//      }
//      if (time.getClock() - activeStart > activeDuration) {
//        goExtinct();
//      }
//      break;

//    case ENDING:
//      progress = (time.getClock() - endingStart) / ENDING_DURATION;
//      if (progress < 1) {
//        dist = utils.easeLinear(progress, eruptEndDist, endingEndDist - eruptEndDist, 1);
//        setPosition(new PVector(cos(radians(angle)) * dist, sin(radians(angle)) * dist));
//        x+=random(-5, 5);
//        y+=random(-5, 5);
//      } else {
//        state = EXTINCT;
//        setPosition(new PVector(cos(radians(angle)) * extinctDist, sin(radians(angle)) * extinctDist));
//      }
//      break;
//    }
//  }

//  public void goExtinct () {
//    endingStart = time.getClock();
//    if (state != EXTINCT) state = ENDING;
//  }

//  float getCurrentMargin () {
//    return margin;
//  }

//  public boolean passable () {
//    return state==EXTINCT || time.getClock() - eruptStart < eruptPassablePeriod;
//  }

//  void render () {
//    pushMatrix();
//    pushStyle();

//    PVector trans = globalPos();
//    translate(trans.x, trans.y);
//    rotate(radians(globalRote()));

//    if (state==ERUPTING || state==ACTIVE || state==ENDING) {
//      image(assets.volcanoStuff.volcanoFrames[1], 0, 0);
//      tint(currentColor.getColor());
//      image(assets.volcanoStuff.volcanoFrames[2], 0, 0);
//    } else {
//      image(assets.volcanoStuff.volcanoFrames[3], 0, 0);
//    }

//    if (state==ACTIVE) {
//      rotate(radians(flareAngle));
//      translate(0, -75);
//      image(assets.roidStuff.explosionFrames[0], 0, 0);
//    }

//    popStyle();
//    popMatrix();
//  }
//} 
