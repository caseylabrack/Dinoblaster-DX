interface abductable {
  PShape getModel ();
  PVector getPosition();
  float getRote();
  int getFacing();
  boolean canBeAbducted();
  color getTint();
  int getID();
}

class UFO extends Entity {

  final static int IDLE = -1;
  final static int INTO_VIEW = 0;
  final static int APPROACHING = 1;
  final static int CIRCLING = 2;
  final static int SCANNING = 3;
  final static int SNATCHING = 4;
  final static int LEAVING = 5;
  final static int DONE = 6;
  int state = IDLE;

  final static int initialDist = 600;
  final static int initialSpeed = 3;
  final static float initialRotate = .5;

  final float startScale = 4;
  final static float endScale = .5;

  final static float NORMAL_SIZE = 64;
  final float startDist = 530;
  final static float finalDist = 300;
  final float approachTime = 5e3;
  float startState;

  final float circlingMaxSpeed = 3;
  float speed = circlingMaxSpeed;
  final float circlingTime = 2e3;

  float spawnCountDown;
  boolean countingDown = true;

  final float scanningStartDelay = 1e3;
  final float scanningTransitioning = 2e3;
  final float scanningPause = 1e3;
  final static float maxBeamWidth = 15;
  float beamWidth = 0;
  float beamAngle = 0;
  boolean beamEnabled = false;

  final float scanDuration = scanningStartDelay + scanningTransitioning + scanningPause + scanningTransitioning + 2e3;

  final float snatchMargin = 10;

  final static float snatchDuration = 3e3;

  Entity abductedGuy = new Entity();
  PVector snatchStartPos = new PVector();
  color abducteeColor;

  boolean enabled = false;

  UFO (PShape model) {
    modelVector = model;
  }

  void restart () {
    enabled = false;
    state = IDLE;
    beamEnabled = false;
    abductedGuy.identity();
  }

  void startCountDown () {
    spawnCountDown = 2e3;//random(5, 90) * 1000;
    enabled = true;
  }

  void windDown() {
    countingDown = false;
  }

  void pauseCountDown () {
    if (state!=IDLE) {
      state = LEAVING;
      beamEnabled = false;
    }
    countingDown = false;
  }

  void resumeCountDown () {
    countingDown = true;
  }

  // return the ID of a player abducted this tick, or -1
  int update (float clock, float dt, PVector earth, abductable[] as) {
    if (!enabled) return -1;

    float progress, angle, dist;
    int snatched = -1;

    switch(state) {

    case IDLE:
      if (countingDown) spawnCountDown -= (1e3/60) * dt;
      if (spawnCountDown < 0) {
        angle = random(0, 360);
        x = cos(angle) * initialDist;
        y = sin(angle) * initialDist;
        scale = startScale;
        state = INTO_VIEW;
      }
      break;

    case INTO_VIEW:
      dist = dist(x, y, 0, 0);
      if (dist > startDist) {
        angle = (float)Math.atan2(y, x);
        x = cos(angle) * (dist - initialSpeed * dt);
        y = sin(angle) * (dist - initialSpeed * dt);
        setPosition(utils.rotateAroundPoint(globalPos(), utils.ZERO_VECTOR, initialRotate * -1 * dt));
      } else {
        state = APPROACHING;
        startState = clock;
      }
      break;

    case APPROACHING:
      progress = (clock - startState)  / approachTime;
      if (progress < 1) {
        scale = utils.easeInOutExpo(progress * 100, startScale, endScale - startScale, 100);
        setPosition(utils.rotateAroundPoint(globalPos(), earth, (progress * circlingMaxSpeed + initialRotate) * -1 * dt));
        angle = (float)Math.atan2(y, x);
        dist = utils.easeOutQuad(progress, startDist, -(startDist - finalDist), 1);
        x = cos(angle) * dist;
        y = sin(angle) * dist;
      } else {
        state = CIRCLING;
        startState = clock;
      }
      break;

    case CIRCLING:
      progress = (clock - startState)  / circlingTime;
      if (progress < 1) {
        setPosition(utils.rotateAroundPoint(globalPos(), earth, utils.easeOutQuad((1 - progress), initialRotate, circlingMaxSpeed + initialRotate, 1) * -1 * dt));
      } else {
        startState = clock;
        state = SCANNING;
      }
      break;

    case SCANNING:
      float scantime = clock - startState;

      if (scantime < scanDuration) {

        // warming up tractor beam
        if (scantime > scanningStartDelay && scantime < scanningStartDelay + scanningTransitioning) {
          beamWidth = utils.easeInExpo((scantime - scanningStartDelay)/scanningTransitioning, 0, maxBeamWidth, 1);
          beamAngle = degrees(atan2(0 - y, 0 - x));
          beamEnabled = true;
        }

        // tractor beam operational, can abduct players
        if (scantime > scanningStartDelay + scanningTransitioning && scantime < scanningStartDelay + scanningTransitioning + scanningPause) {
          beamWidth = maxBeamWidth;

          // did player get abducted
          for (abductable a : as) {
            if (!a.canBeAbducted()) continue;
            PVector abducteePosition = a.getPosition();
            if (utils.unsignedAngleDiff(utils.angleOf(earth, abducteePosition), utils.angleOf(earth, globalPos())) < snatchMargin) {
              startState = clock;
              snatchStartPos = abducteePosition;
              abductedGuy.setPosition(abducteePosition);
              abductedGuy.facing = a.getFacing();
              abductedGuy.r = a.getRote();
              abductedGuy.modelVector = a.getModel();
              abducteeColor = a.getTint();

              startState = clock;
              state = SNATCHING;
              snatched = a.getID();
              abductedGuy.setPosition(PVector.lerp(snatchStartPos, globalPos(), 0));
              abductedGuy.scale = map(0, 0, 1, 1, .01);
              break; // only abduct a single dino
            }
          }
        }

        // cooling down tractor beam
        if (scantime > scanningStartDelay + scanningTransitioning + scanningPause && scantime < scanningStartDelay + scanningTransitioning + scanningPause + scanningTransitioning) {
          beamWidth = utils.easeInQuad(((scantime - scanningStartDelay - scanningTransitioning - scanningPause)/scanningTransitioning), maxBeamWidth, -maxBeamWidth, 1);
        }

        // tractor beam fully off, but UFO still hangs around for a couple seconds
        if (scantime > scanningStartDelay + scanningTransitioning + scanningPause + scanningTransitioning) {
          beamEnabled = false;
        }
      } else {
        state = LEAVING;
      }
      break;

    case SNATCHING:
      progress = (clock - startState)  / snatchDuration;
      if (progress <= 1) {
        abductedGuy.setPosition(PVector.lerp(snatchStartPos, globalPos(), progress));
        abductedGuy.scale = map(progress, 0, 1, 1, .01);
      } else {
        state = LEAVING;
        beamEnabled = false;
      }
      break;

    case LEAVING:
      dist = dist(x, y, 0, 0);
      if (dist < 2000) {
        angle = (float)Math.atan2(y, x);
        x = cos(angle) * (dist + (initialSpeed * dt));
        y = sin(angle) * (dist + (initialSpeed * dt));
        if (x < -HEIGHT_REF_HALF || x > HEIGHT_REF_HALF || y < -HEIGHT_REF_HALF || y > HEIGHT_REF_HALF) assets.ufostuff.ufoSound.stop_(); // it's offscreen
      } else {
        state = IDLE;
        spawnCountDown = 3e3;//random(5, 90) * 1000;
      }
      break;

    case DONE:
      break;

    default:
      println("ufo unhandled state change");
      break;
    }

    return snatched;
  }

  // foreground the ufo during approach
  void renderFront (color funkyColor) {

    if (!enabled) return;
    if (state==IDLE) return;

    // UFO itself
    if (state <= APPROACHING) {
      pushStyle();
      noFill();
      stroke(funkyColor);
      simpleRenderImageVector();
      popStyle();
    }
  }

  void render (color funkyColor) {
    if (!enabled) return;
    if (state==IDLE) return;

    // tractor beam
    if (beamEnabled) {
      pushStyle();
      //strokeWeight(assets.STROKE_WIDTH);
      strokeWeight(2);      
      stroke(funkyColor);
      line(x, y, x + cos(radians(beamAngle + beamWidth)) * 250, y + sin(radians(beamAngle + beamWidth)) * 250);
      line(x, y, x + cos(radians(beamAngle - beamWidth)) * 250, y + sin(radians(beamAngle - beamWidth)) * 250);
      popStyle();
    }

    // ABDUCTION
    if (state == SNATCHING) {
      pushStyle();
      noFill();
      stroke(abducteeColor);
      abductedGuy.simpleRenderImageVector();
      popStyle();
    }

    // UFO itself
    if (state > APPROACHING) {
      pushStyle();
      stroke(funkyColor);
      fill(0, 0, 0, 1);
      simpleRenderImageVector();
      popStyle();
    }
  }
}

class UFORespawn extends Entity {

  final static int APPROACHING = 0;
  final static int ANTISNATCHING = 1;
  final static int WAITING = 2;
  final static int LEAVING = 5;
  final static int DONE = 6;
  int state;
  float stateStart;

  PVector targetPosition = new PVector();

  boolean enabled = false;

  float beamAngle;

  Entity returningDino = new Entity();

  final static int initialDist = 1000;

  final float flickerRate = PlayerRespawn.FLICKER_RATE_FINAL;
  float lastFlicker;

  boolean returningDinoDisplay = false;
  int whichDino;
  color colour;

  UFORespawn (PShape model) {
    modelVector = model;
    scale = UFO.endScale;
  }

  void dispatch(abductable dino, PVector earth) {
    enabled = true;
    stateStart = millis();
    state = APPROACHING;
    whichDino = dino.getID();
    colour = dino.getTint();
    float angle = random(0, 360);
    x = cos(angle) * UFO.initialDist;
    y = sin(angle) * UFO.initialDist;
    returningDino.modelVector = dino.getModel();
  }

  boolean inTheProcessOfReturningPlayer () {
    return enabled && state!=LEAVING;
  }

  Entity update(float clock, float dt, PVector earth, boolean anykey) {
    if (!enabled) return null;
    Entity respawnable = null; 

    float progress, angle, dist;

    switch(state) {

    case APPROACHING:
      dist = dist(x, y, 0, 0);
      if (dist > UFO.finalDist) {
        angle = atan2(y, x);
        x = cos(angle) * (dist-UFO.initialSpeed * dt);
        y = sin(angle) * (dist-UFO.initialSpeed * dt);
        setPosition(utils.rotateAroundPoint(globalPos(), utils.ZERO_VECTOR, UFO.initialRotate * -1 * dt));
      } else {
        state = ANTISNATCHING;
        stateStart = clock;
        beamAngle = degrees(atan2(0 - y, 0 - x));
        targetPosition = new PVector(cos(radians(beamAngle + 180)) * (Earth.EARTH_RADIUS + 30), sin(radians(beamAngle + 180)) * (Earth.EARTH_RADIUS + 30));
        returningDino.r = degrees(atan2(0 - targetPosition.y, 0 - targetPosition.x) + radians(-90));
        returningDino.setPosition(globalPos());
        returningDino.scale = .01;
        returningDinoDisplay = true;
      }
      break;

    case ANTISNATCHING:
      progress = (clock - stateStart)  / UFO.snatchDuration;
      if (progress <= 1) {
        returningDino.setPosition(PVector.lerp(globalPos(), targetPosition, progress));
        returningDino.scale = map(progress, 0, 1, .01, 1);
      } else {
        state = WAITING;
        lastFlicker = millis();
      }
      break;

    case WAITING:
      if (millis() - lastFlicker > flickerRate) {
        returningDinoDisplay = !returningDinoDisplay;
        lastFlicker = millis();
      }
      if (anykey) { 
        respawnable = returningDino;
        state = LEAVING;
      }
      break;

    case LEAVING:
      dist = dist(x, y, 0, 0);
      if (dist < 2000) {
        angle = (float)Math.atan2(y, x);
        x = cos(angle) * (dist+UFO.initialSpeed * dt);
        y = sin(angle) * (dist+UFO.initialSpeed * dt);
      } else {
        state = DONE;
        enabled = false;
      }
      break;

    case DONE:
      break;

    default:
      println("ufo state wut");
      break;
    }

    return respawnable;
  }

  void render(color funkyColor) {
    if (!enabled) return;

    if (state==ANTISNATCHING || state==WAITING) {

      // beam
      pushStyle();
      noFill();
      strokeWeight(assets.STROKE_WIDTH);
      stroke(funkyColor);
      line(x, y, x + cos(radians(beamAngle + UFO.maxBeamWidth)) * 250, y + sin(radians(beamAngle + UFO.maxBeamWidth)) * 250);
      line(x, y, x + cos(radians(beamAngle - UFO.maxBeamWidth)) * 250, y + sin(radians(beamAngle - UFO.maxBeamWidth)) * 250);
      popStyle();

      // returning dino
      pushStyle();
      noFill();
      stroke(colour);
      //stroke(0, 0, 100, 1);
      if (returningDinoDisplay) returningDino.simpleRenderImageVector();
      popStyle();
    }

    // UFO itself
    pushStyle();
    fill(0, 0, 0, 1);
    stroke(funkyColor);
    simpleRenderImageVector();
    popStyle();
  }

  void restart () {
    enabled = false;
  }
}
