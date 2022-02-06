class TrexManager implements updateable, renderable, levelChangeEvent, gameFinaleEvent {

  EventManager events;
  Time time;  
  Earth earth;
  Trex trex;
  EggTrex egg;
  PlayerManager playerManager;
  ColorDecider currentColor;

  final int SPAWN_DELAY = 25;
  int spawnSchedule = -1;

  boolean finalePositioningTrex = false;
  final float FINALE_TREX_POSITIONING_LEADING = 60;

  TrexManager (EventManager e, Time t, Earth w, PlayerManager pm, ColorDecider c, int lvl) {
    events = e;
    time = t;
    earth = w;
    currentColor = c;
    playerManager = pm;

    events.levelChangeSubscribers.add(this);
    events.gameFinaleSubscribers.add(this);

    if (!settings.getBoolean("trexEnabled", true)) return;
    if (lvl==UIStory.CRETACEOUS) spawnSchedule = SPAWN_DELAY; //spawn();
  }

  void levelChangeHandle(int stage) {

    if (stage==UIStory.CRETACEOUS) spawnSchedule = SPAWN_DELAY; //spawn();
  }

  void finaleHandle() {
    // deactivate any t-rexs
    if (trex!=null) {
      trex.disable();
      if (trex.state == trex.STUNNED) {
        finalePositioningTrex = true;
      } else {
        events.dispatchFinaleTrexPositioned(utils.ZERO_VECTOR);
      }
    } else {
      println("no trex to position");
      events.dispatchFinaleTrexPositioned(utils.ZERO_VECTOR);
    }
  }

  void finaleClose() {}

  public void spawnTrex(PVector pos) {
    trex = new Trex(earth, playerManager, time, pos);
  }

  public void spawnTrex() {
    trex = new Trex(earth, playerManager, time, new PVector(0, -120));
  }

  void finaleTrexHandled(PVector _) {
  }
  void finaleImpact() {
    // make trex explode maybe
  }

  void update () {

    if (finalePositioningTrex) {
      float currentAngle = utils.angleOf(utils.ZERO_VECTOR, trex.globalPos());
      float targetAngle = utils.angleOf(utils.ZERO_VECTOR, new PVector(-HEIGHT_REF_HALF, -HEIGHT_REF_HALF));
      float diff = utils.signedAngleDiff(currentAngle, targetAngle);
      if (diff > 0 && diff < FINALE_TREX_POSITIONING_LEADING) {
        events.dispatchFinaleTrexPositioned(trex.globalPos());
        finalePositioningTrex = false;
      }
    }

    if (spawnSchedule > -1) {
      spawnSchedule--;
      if (spawnSchedule==0) {
        spawnSchedule = -1;
        egg = new EggTrex(earth, time, currentColor);
      }
    }

    if (egg!=null) {
      egg.update();
      if (egg.state==EggTrex.DONE) {
        spawnTrex(egg.localPos());
        egg = null;
      }
    }

    if (trex!=null) {
      trex.update();
      if (trex.state == Trex.DONE) {
        trex = null;
      }
    }
  }

  void render() {
    if (trex!=null) trex.render();
    if (egg!=null) egg.render();
  }
}

class EggTrex extends Entity implements updateable, renderable {

  Earth earth;
  Time time;
  ColorDecider currentColor;

  final float startY = 115;
  final static float EARTH_DIST_FINAL = 190;
  final float risingDuration = 1e3;
  final float idleDuration = 1e3;
  final float crackedDuration = 3e3;
  float startTime;
  float angle;

  final int WIGGLES_NUM = 3;
  int wiggleCount = 0;
  final float wiggleDuration = .5e3;
  final float WIGGLE_POWER_START = 90;
  float wigglePower;
  float uprightR;

  final static int RISING = 0;
  final static int WIGGLES = 1;
  final static int IDLE = 2;
  final static int CRACKED = 3;
  final static int DONE = 4;
  public int state = RISING;

  PImage model;

  EggTrex (Earth e, Time t, ColorDecider c) {
    earth = e;
    time = t;
    currentColor = c;

    model = assets.trexStuff.eggCracked;

    earth.addChild(this);

    angle = earth.getTarpitAngleDegrees() + 180;
    setPosition(new PVector(cos(radians(angle)), sin(radians(angle))));
    r = angle + 90;
    uprightR = r;

    startTime = time.getClock();
  }

  void update () {

    float progress;

    switch(state) {

    case RISING:
      progress = (time.getClock() - startTime) / risingDuration;
      if (progress < 1) {
        //float dist = utils.easeLinear(progress,startY,endY-startY,1);
        float t = utils.easeOutBounce(progress);
        //float t = utils.easeOutElastic(progress);
        float dist = startY + (EARTH_DIST_FINAL - startY) * t;
        x = cos(radians(angle)) * dist;
        y = sin(radians(angle)) * dist;
      } else {
        state = IDLE;
        startTime = time.getClock();
      }

      break;

    case IDLE:
      progress = (time.getClock() - startTime) / idleDuration;
      if (progress > 1) {
        if (wiggleCount < WIGGLES_NUM) {
          state = WIGGLES;
          assets.trexStuff.eggWiggle.play();
        } else {
          state = CRACKED;
          model = assets.trexStuff.eggBurst;
          assets.trexStuff.eggHatch.play();
        }
        startTime = time.getClock();
      }
      break;

    case WIGGLES:
      progress = (time.getClock() - startTime) / wiggleDuration;
      if (progress < 1) {
        wigglePower = utils.easeInQuad(progress, WIGGLE_POWER_START, 0 - WIGGLE_POWER_START, 1);
        r = uprightR + sin(time.getClock()) * wigglePower;
      } else {
        r = uprightR;
        wiggleCount++;        
        state = IDLE;
        startTime = time.getClock();
      }
      break;

    case CRACKED:
      progress = (time.getClock() - startTime) / crackedDuration;
      if (round(progress * 10) % 2 == 0) {
        model = assets.trexStuff.eggBurst;
      } else {
        model = assets.trexStuff.trexIdle;
      }
      if (progress > 1) {
        state = DONE;
      }
      break;
    }
  }

  void render() {
    pushStyle();
    tint(currentColor.getColor());
    simpleRenderImage(model);
    popStyle();
  }
}


class Trex extends Entity implements gameOverEvent, updateable, renderable {

  PImage model;
  PImage idle;
  PImage[] runFrames = new PImage[2];
  boolean visible = true;
  float runSpeed = .75;
  boolean chasing = true;
  float attackAngle = 110;
  final float HITBOX_ANGLE = 16;

  Earth earth;
  PlayerManager playerManager;
  Time time;

  boolean alive = true;
  final float TARPIT_BOTTOM_DIST = 110;
  float tarpitSink = 0;

  final static int WALKING = 0;
  final static int SINKING = 1;
  final static int DONE = 2;
  final static int STUNNED = 3;
  int state = WALKING;

  Trex (Earth _earth, PlayerManager pm, Time t, PVector pos) {
    earth = _earth; 
    playerManager = pm;
    time = t;
    idle = assets.trexStuff.trexIdle;//frames[0];
    runFrames[0] = assets.trexStuff.trexRun1;//frames[1];
    runFrames[1] = assets.trexStuff.trexRun2;//frames[2];
    model = idle;
    facing = -1;
    earth.addChild(this);
    setPosition(pos);
    r = utils.angleOf(new PVector(0, 0), localPos()) + 90;

    assets.trexStuff.rawr.play();
  }

  void gameOverHandle () {
    chasing = false;
  }

  void disable () {
    if (state == SINKING) return;
    state = STUNNED;
  }

  void update () {

    switch(state) {

    case WALKING:
      float playerDist = playerManager.player!=null ? utils.signedAngleDiff(r, playerManager.player.r) : 1e9;

      if (abs(playerDist) < HITBOX_ANGLE) {
        playerManager.roidImpactHandle(this.globalPos());
      }

      if (abs(playerDist) < attackAngle) {
        if (!chasing) { 
          assets.trexStuff.stomp.play(true);
        }
        chasing = true;
        facing = playerDist > 0 ? 1 : -1;
      } else {
        chasing = false;
        assets.trexStuff.stomp.stop_();
      }

      if (chasing) {
        model = runFrames[utils.cycleRangeWithDelay(runFrames.length, 12, frameCount)];
        if (model==runFrames[1]) earth.shake(2.5);
        setPosition(utils.rotateAroundPoint(localPos(), new PVector(0, 0), runSpeed * time.getTimeScale() * facing));
        dr += runSpeed * time.getTimeScale() * facing;
      } else {
        model = idle;
      }

      x += dx;
      y += dy;
      r += dr;

      dx = 0;
      dy = 0;
      dr = 0;

      if (earth.isInTarpit(localPos())) {
        state = SINKING;
        assets.trexStuff.stomp.stop_();
        //assets.trexStuff.sinking.play();
        assets.trexStuff.rawr.play();
      }

      break;

    case SINKING: 
      tarpitSink += time.getScaledElapsed() / Earth.TARPIT_SINK_DURATION;
      float sink = EggTrex.EARTH_DIST_FINAL - (EggTrex.EARTH_DIST_FINAL - TARPIT_BOTTOM_DIST) * tarpitSink;
      PVector tarpitAdjusted = new PVector(cos(radians(utils.angleOf(utils.ZERO_VECTOR, localPos()))) * sink, sin(radians(utils.angleOf(utils.ZERO_VECTOR, localPos()))) * sink);
      setPosition(tarpitAdjusted);

      if (tarpitSink > 1) state = DONE;
      break;

    case STUNNED:
      // do nothing but get hit by The Big One
      break;
    }
  }

  void render () {
    simpleRenderImage(model);
    //pushTransforms();
    //pushStyle();
    //noFill();
    //stroke(60,60,60);
    //strokeWeight(3);
    //circle(0, 0, HIT_RADIUS);
    //popStyle();
    //popMatrix();
  }
}
