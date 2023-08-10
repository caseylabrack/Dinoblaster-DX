class EggOvi extends Entity {

  boolean enabled = true;
  int cooldown;


  EggOvi (PImage model) {
    this.model = model;
  }

  void update () {
    if (!enabled) {
      cooldown--;
    }
    if (cooldown<0) {
      enabled = true;
    }
  }

  void touched () {
    enabled = false;
    cooldown = 100;
  }

  void render(color funkyColor) {
    if (!enabled) return;
    pushStyle();
    tint(funkyColor);
    simpleRenderImage();
    popStyle();
  }
}

class EggRescue extends Entity {

  color pcolor;
  int player;

  private float margin = 15;
  int hits = 0;
  float vm = 0;
  float dist;
  float angle;
  PImage[] eggFrames;
  final static float TIMEOUT_DUR = 1e3;
  float uprightR;

  boolean enabled = false;
  final static int RISING = 0;
  final static int IDLE = 1;
  final static int BOUNCING = 2;
  final static int BURST = 3;
  final static int DONE = 4;
  int state;
  float stateStart; // how long have I been in this state

  PImage playerModel;

  EggRescue (PImage[] eggFrames, int player, PImage playerModel) {
    this.eggFrames = eggFrames;
    model = eggFrames[0];
    this.player = player;
    this.playerModel = playerModel;
  }

  void update (float clock) {
    update(clock, false, false);
  }

  void update (float clock, boolean left, boolean right) {
    if (!enabled) return;

    r = uprightR;

    switch (state) {

    case RISING:
      float progress = (clock - stateStart) / EggHatch.RISING_DURATION;
      if (progress < 1) {
        //float dist = utils.easeLinear(progress,startY,endY-startY,1);
        float t = utils.easeOutBounce(progress);
        //float t = utils.easeOutElastic(progress);
        float dist = EggHatch.START_Y + (Player.DIST_FROM_EARTH - EggHatch.START_Y) * t;
        x = cos(radians(angle)) * dist;
        y = sin(radians(angle)) * dist;
      } else {
        state = IDLE;
        stateStart = clock;
      }
      break;

    case IDLE: 
      if (left != right) { // egg only rocks if given 1 direction
        r = uprightR + 45 * (left ? -1 : 1);
      } else {
        r = uprightR;
      }
      break;

    case BOUNCING:
      vm -= Player.bounceGravity;
      dist += vm; 

      if (dist < Player.DIST_FROM_EARTH) {
        state = IDLE;
        vm = 0;
        dist = Player.DIST_FROM_EARTH;
      }

      x = cos(radians(angle)) * dist;
      y = sin(radians(angle)) * dist;
      break;

    case BURST: 
      //if (clock - stateStart > TIMEOUT_DUR) {
      //  reset();
      //}
      break;

    case DONE:
      break;
    }
  }

  void render () {
    if (!enabled) return;
    if (state == BURST) {
      if (frameCount % 4 > 4 / 2) {
        pushStyle();
        tint(pcolor);
        pushTransforms();
        image(playerModel, 0, 0);
        image(model, 0, 0);
        popMatrix();
        popStyle();
      }
    } else {
      pushStyle();
      tint(pcolor);
      simpleRenderImage();
      popStyle();
    }
  }

  void startAnimation (float angle, float clock) {
    enabled = true;
    state = RISING;
    hits = 0;
    stateStart = clock;
    this.angle = angle;
    r = angle + 90;
    uprightR = r;
  }

  boolean isPassable () {
    return !enabled;
  }

  float getAngle () {
    return utils.angleOf(utils.ZERO_VECTOR, localPos());
  }

  boolean enabled () {
    return enabled;
  }

  float getArc() {
    return margin;
  }

  void bounce(float clock) {
    if (state==IDLE) {
      hits++;
      model = eggFrames[hits];

      if (hits <= 3) {
        //bounceStart = clock;
        stateStart = clock;
        vm = 10;
        angle = utils.angleOfOrigin(localPos());
        dist = Player.DIST_FROM_EARTH;
        state = BOUNCING;
      } else {
        state = BURST;
        stateStart = clock;
      }
    }
  }

  void reset() {
    hits = 0;
    model = eggFrames[hits];
    enabled = false;
  }

  void spawn () {
    state = DONE;
    hits = 0;
    model = eggFrames[hits];
    enabled = false;
  }
}

class EggHatch extends Entity {
  final static float START_Y = 115;
  final static float EARTH_DIST_FINAL = 190;
  final static float RISING_DURATION = 1e3;
  final float idleDuration = 1e3;
  final float crackedDuration = 3e3;
  float startTime;
  float angle;
  boolean enabled = false;

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

  PImage modelCracked;
  PImage modelBurst;
  PImage trex;

  EggHatch (PImage modelCracked, PImage modelBurst, PImage trex) {
    this.modelCracked = modelCracked;
    this.modelBurst = modelBurst;
    this.trex = trex;
  }

  void startAnimation (float angle, float clock) {
    enabled = true;
    model = modelCracked;
    startTime = clock;
    state = RISING;
    this.angle = angle;
    r = angle + 90;
    uprightR = r;
    wiggleCount = 0;
  }

  void update (float clock) {
    if (!enabled) return;

    float progress;

    switch(state) {

    case RISING:
      progress = (clock - startTime) / RISING_DURATION;
      if (progress < 1) {
        //float dist = utils.easeLinear(progress,startY,endY-startY,1);
        float t = utils.easeOutBounce(progress);
        //float t = utils.easeOutElastic(progress);
        float dist = START_Y + (EARTH_DIST_FINAL - START_Y) * t;
        x = cos(radians(angle)) * dist;
        y = sin(radians(angle)) * dist;
      } else {
        state = IDLE;
        startTime = clock;
      }
      break;

    case IDLE:
      progress = (clock - startTime) / idleDuration;
      if (progress > 1) {
        if (wiggleCount < WIGGLES_NUM) {
          state = WIGGLES;
          assets.trexStuff.eggWiggle.play();
        } else {
          state = CRACKED;
          model = modelBurst;//assets.trexStuff.eggBurst;
          assets.trexStuff.eggHatch.play();
        }
        startTime = clock;
      }
      break;

    case WIGGLES:
      progress = (clock - startTime) / wiggleDuration;
      if (progress < 1) {
        wigglePower = utils.easeInQuad(progress, WIGGLE_POWER_START, 0 - WIGGLE_POWER_START, 1);
        r = uprightR + sin(clock) * wigglePower;
      } else {
        r = uprightR;
        wiggleCount++;        
        state = IDLE;
        startTime = clock;
      }
      break;

    case CRACKED:
      progress = (clock - startTime) / crackedDuration;
      if (round(progress * 10) % 2 == 0) {
        model = modelBurst;
      } else {
        model = trex;
      }
      if (progress > 1) {
        state = DONE;
      }
      break;
    }
  }

  void render(color funkyColor) {
    if (!enabled) return;
    pushStyle();
    tint(funkyColor);
    simpleRenderImage();
    popStyle();
  }

  void reset () {
    enabled = false;
    state = RISING;
  }
}

class Trex extends Entity implements tarpitSinkable {
  boolean visible = true;
  final static float DEFAULT_RUNSPEED = .25;
  float runSpeed = DEFAULT_RUNSPEED;
  boolean chasing = true;
  final static float DEFAULT_ATTACK_ANGLE = 110;
  float attackAngle = DEFAULT_ATTACK_ANGLE;
  final static float BOUNDING_ARC = 16;
  final static float BOUNDING_ARC_TARPIT_NUDGE = 6;

  boolean alive = true;
  final float TARPIT_BOTTOM_DIST = 120;
  float tarpitSink = 0;

  final static int WALKING = 0;
  final static int SINKING = 1;
  final static int DONE = 2;
  final static int STUNNED = 3;
  final static int HEAD = 4;
  int state = WALKING;
  boolean enabled = false;
  boolean inTarpit = false;

  boolean isStomping = false;

  PImage idle;
  PImage[] runFrames = new PImage[2];
  PImage head;
  SoundPlayable stompSound;
  SoundPlayable rawr;

  Trex (PImage idle, PImage head, PImage runFrame1, PImage runFrame2, SoundPlayable stompSound, SoundPlayable rawr) {
    this.idle = idle;
    this.head = head;
    runFrames[0] = runFrame1;
    runFrames[1] = runFrame2;
    this.stompSound = stompSound;
    this.rawr = rawr;
    model = this.idle;
    facing = -1;
  }

  boolean isDeadly () {
    return enabled && state==WALKING;
  }
  
  void handleUnpaused () {
    if(!enabled || state!=WALKING) return;
    if(chasing) stompSound.play(true);
  }

  void update(float dt, float scaledElapsed, targetable target1, targetable target2) {
    if (!enabled) return;

    switch(state) {

    case WALKING:
      isStomping = false;

      float myang = utils.angleOfOrigin(localPos());
      float ang1 = target1.isTargettable() ? utils.unsignedAngleDiff(myang,utils.angleOfOrigin(target1.position())) : 361;
      float ang2 = target2.isTargettable() ? utils.unsignedAngleDiff(myang,utils.angleOfOrigin(target2.position())) : 361;
      targetable target = ang1 < ang2 ? target1 : target2;

      if (target.isTargettable()) {
        float targetAngle = utils.angleOf(utils.ZERO_VECTOR, target.position());
        float myAngle = utils.angleOf(utils.ZERO_VECTOR, localPos());

        float diff = utils.signedAngleDiff(myAngle, targetAngle);

        if (abs(diff) < attackAngle) {

          if (!chasing) {
            stompSound.play(true);
          }
          chasing = true;
          facing = diff > 0 ? 1 : -1;
        } else {
          chasing = false;
        }
      } else {
        chasing = false;
      }

      if (chasing) {
        boolean edgeflag = model==runFrames[1] || model==idle;
        model = runFrames[utils.cycleRangeWithDelay(runFrames.length, 8, frameCount)];
        isStomping = model == runFrames[0] && edgeflag; // detect the leading edge of the change from one frame to the other (so you stomp only once per run cycle)
        setPosition(utils.rotateAroundPoint(localPos(), utils.ZERO_VECTOR, runSpeed * dt * facing));
      } else {
        model = idle;
        stompSound.stop_();
      }

      r = utils.angleOf(utils.ZERO_VECTOR, localPos()) + 90;
      break;

    case SINKING: 
      tarpitSink += scaledElapsed / Earth.TARPIT_SINK_DURATION;
      float sink = EggHatch.EARTH_DIST_FINAL - (EggHatch.EARTH_DIST_FINAL - TARPIT_BOTTOM_DIST) * tarpitSink;
      PVector tarpitAdjusted = new PVector(cos(radians(utils.angleOf(utils.ZERO_VECTOR, localPos()))) * sink, sin(radians(utils.angleOf(utils.ZERO_VECTOR, localPos()))) * sink);
      setPosition(tarpitAdjusted);
      model = runFrames[utils.cycleRangeWithDelay(runFrames.length, 8, frameCount)];

      if (tarpitSink > 1) {
        state = HEAD;
        model = head;
      }
      break;

    case HEAD:
      break;

    case STUNNED:
      // do nothing but get hit by The Big One
      break;
    }
  }

  void render() {
    if (!enabled) return;
    simpleRenderImage();
  }

  void restart() {
    enabled = false;
  }

  float angleOnEarth () {
    return r - 90;
  }

  float nudgeMargin () {
    return BOUNDING_ARC_TARPIT_NUDGE;
  }

  void setInTarpit (boolean inTarpit) {
    if (!this.inTarpit && inTarpit) { // set once
      this.inTarpit = true;
      state = SINKING;
      stompSound.stop_();
      rawr.play();
      isStomping = false;
    }
  }

  boolean sinkingEnabled () {
    return enabled && state == WALKING;
  }

  void stun () {
    if (state == WALKING) {
      state = STUNNED;
      model = idle;
      stompSound.stop_();
    }
  }

  void vanish() {
    if (state == STUNNED) {
      enabled = false;
    }
  }
}
