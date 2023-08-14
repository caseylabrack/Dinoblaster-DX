interface targetable {
  boolean isTargettable ();
  PVector position ();
}

interface tarpitSinkable {
  float angleOnEarth ();
  float nudgeMargin ();
  void setInTarpit (boolean inTarpit);
  boolean sinkingEnabled ();
}

class Player extends Entity implements abductable, targetable, tarpitSinkable {
  final static float DIST_FROM_EARTH = 194;//197;
  final static float DEFAULT_RUNSPEED = 5;
  final static float TARPIT_SLOW_FACTOR = .25;
  final static float TARPIT_BOTTOM_DIST = 110;
  final float TARPIT_RISE_FACTOR = 2;
  final static float BOUNDING_CIRCLE_RADIUS = 30;
  final static float BOUNDING_ARC = 15;
  final static float BOUNDING_ARC_TARPIT_NUDGE = 6;
  
  final static String P1_DEFAULT_COLOR = "#00ffff";
  final static String P2_DEFAULT_COLOR = "#ff57ff";

  final int IDLE = 0;
  final int RUNNING = 1;
  int state = IDLE;

  boolean inTarpit = false;
  boolean wasInTarpitLastFrame = false;
  float tarpitSink = 0;
  boolean tarpitImmune = false;
  boolean enabled = false;
  float runSpeed = DEFAULT_RUNSPEED;
  float tarpitFactor = 1;
  float runFrameRate = 100;

  int id; // player 1 or 2

  color c;
  boolean usecolor = false;
  int bounceDir;

  PVector ppos = new PVector(); // previous position (last frame)
  float pr; // previous angle

  // polar coords
  float localAngle;
  float localDist;
  float targetAngle;
  float targetDist;
  float va = 0; // angle velocity
  float vm = 0; // magnitude (radius) velocity
  float bounceForce = 10;
  float bounceFriction = .75;
  float bounceForceUp = 20;
  final static float bounceGravity = 4;
  boolean grounded = true;
  final static float TAR_SINK_RATE = -1;
  final static float TAR_RISE_RATE = 4;

  PImage[] frames;
  PShape abductModel;
  SoundPlayable step;
  SoundPlayable tarStep;

  Player(PShape abductModel, PImage[] frames, SoundPlayable step, SoundPlayable tarStep) {
    this.abductModel = abductModel;
    this.frames = frames;
    this.step = step;
    this.tarStep = tarStep;
    model = frames[0];
  }

  void bounceStart (int dir) {
    bounceDir = dir;
    va = bounceForce * dir;
    vm = bounceForceUp;
    grounded = false;
  }

  public void move(boolean left, boolean right, float delta, float clock, float scaleElapsed) {
    if (!enabled) return;

    targetAngle = utils.angleOf(utils.ZERO_VECTOR, localPos());
    //targetDist = DIST_FROM_EARTH;
    targetDist = (inTarpit || !grounded) ? dist(0, 0, x, y) : DIST_FROM_EARTH;

    if (inTarpit && !tarpitImmune) vm = TAR_SINK_RATE * delta;

    // running or not. if running, update target angle
    if (left != right) { 
      // if this is the first step
      if (state == IDLE) {
        state = RUNNING;
        if (inTarpit) {
          tarStep.play(true);
        } else {
          step.play(true);
        }
      }
      // if just entering tarpit
      if (inTarpit && !wasInTarpitLastFrame) {
        step.stop_();
        tarStep.play(true);
      } 
      // if just leaving tarpit
      if (!inTarpit && wasInTarpitLastFrame) {
        step.play(true);
        tarStep.stop_();
      }

      float tarpitFactor = 1;
      if (inTarpit) {
        vm += TAR_RISE_RATE * delta;

        // on tarpit surface, run at a slow factor unless immunity set. 
        // beneath surface, can't run (but can rise)
        // setting tarpit immunity disables sinking motion but retains rising motion, so player can start ignore tarpits even if below the surface
        tarpitFactor = 0;
        if (targetDist + vm > DIST_FROM_EARTH) {
          vm = DIST_FROM_EARTH - targetDist;
          tarpitFactor = TARPIT_SLOW_FACTOR;
        }
        if (tarpitImmune) tarpitFactor = 1;
      }

      facing = left ? -1 : 1;
      if (grounded) va = runSpeed * delta * facing * tarpitFactor;
      int frame = (clock % runFrameRate) > runFrameRate / 2 ? 1 : 2;
      model = frames[frame];
    } else {
      if (grounded) va = 0;
      state = IDLE;
      model = frames[0];
      step.stop_();
      tarStep.stop_();
    }

    if (!grounded) {
      va *= bounceFriction;
      vm -= bounceGravity;
      if (targetDist + vm < DIST_FROM_EARTH) {
        //vm = DIST_FROM_EARTH - targetDist;
        grounded = true;
        vm = 0;
        targetDist = DIST_FROM_EARTH;
      }
    }

    targetAngle += va;
    targetDist += vm;

    x = cos(radians(targetAngle)) * targetDist;
    y = sin(radians(targetAngle)) * targetDist;
    r = utils.angleOfOrigin(localPos()) + 90;

    //if (!grounded && dist(0, 0, x, y) < DIST_FROM_EARTH) {
    //  targetDist = DIST_FROM_EARTH;
    //  vm = 0;
    //  grounded = true;
    //}

    wasInTarpitLastFrame = inTarpit;
  }

  float getRadius () {
    //return dist(0, 0, x, y);
    return targetDist;
  }

  boolean getAtTarpitBottom () {
    return tarpitSink > 1;
  }

  void setTarpitImmune (boolean b) {
    tarpitImmune = b;
  }

  public void render() {
    if (!enabled) return;
    pushStyle();
    if (usecolor) tint(c);
    simpleRenderImage();
    popStyle();
  }

  public void restart () {
    identity();
    enabled = false;
    tarpitFactor = 1;
    tarpitSink = 0;
    step.stop_();
    tarStep.stop_();
    inTarpit = false;
  }

  PShape getModel () {
    return abductModel;
  }

  PVector getPosition () {
    return globalPos();
  }

  float getRote() {
    return globalRote();
  }

  int getFacing() {
    return facing;
  }

  boolean canBeAbducted () {
    return enabled;
  }

  color getTint() {
    return usecolor ? c : #FFFFFF;
  }

  int getID() {
    return id;
  }

  boolean isTargettable () {
    return enabled;
  }

  PVector position () {
    return localPos();
  }

  float angleOnEarth () {
    return r - 90;
  }

  float nudgeMargin () {
    return BOUNDING_ARC_TARPIT_NUDGE;
  }

  void setInTarpit (boolean inTarpit) {
    this.inTarpit = inTarpit;
  }

  boolean sinkingEnabled () {
    return enabled;
  }
}

class PlayerIntro extends Entity {
  float spawningStart;
  final float spawningDuration = 1e3;
  final static int FLASHING = 0;
  final static int SPAWNING = 1;
  final static int DONE = 2;
  int state = DONE;
  color colour;
  boolean usecolor = false;

  final static float FLICKER_RATE = 16;

  public void startIntro () {
    spawningStart = millis();
    state = FLASHING;
  }

  public void update () {
    if (state==DONE) return;
    if (millis() - spawningStart > spawningDuration) state = SPAWNING;
  }

  public void spawn () {
    state = DONE;
  }

  public void render () {
    if (state==DONE) return;
    if (frameCount % FLICKER_RATE > FLICKER_RATE / 2) {
      pushStyle();
      if (usecolor) tint(colour);
      simpleRenderImage();
      popStyle();
    }
  }
}

class PlayerRespawn extends Entity {
  float spawningStart;
  final float spawningDuration = 1e3;
  boolean display = true;
  float startY = -100;
  float endY = -Player.DIST_FROM_EARTH;
  final float RISING_DURATION = 5e3;
  final float FLICKER_RATE_START = 400;
  final static float FLICKER_RATE_FINAL = 60;
  float flickerRate;
  float flickerStart;
  boolean enabled = false;
  boolean canSpawn = false;
  color colour;
  boolean usecolor = false;

  PlayerRespawn (PImage model) {
    this.model = model;
  }

  void respawn () {
    enabled = true;
    flickerRate = FLICKER_RATE_START;
    spawningStart = millis();
    flickerStart = millis();
    display = true;
  }

  boolean update (float clock) {
    if (!enabled) return false;
    boolean canSpawn = false;

    float progress = (millis() - spawningStart) / RISING_DURATION;
    if (progress < 1) {
      float t = utils.easeOutCubicT(progress);
      flickerRate = map(t, 0, 1, FLICKER_RATE_START, FLICKER_RATE_FINAL);
      y = map(t, 0, 1, startY, endY);
    } else {
      flickerRate = FLICKER_RATE_FINAL;
      y = endY;
      canSpawn = true;
    }
    if (millis() - flickerStart > flickerRate) {
      display = !display;
      flickerStart = millis();
    }

    return canSpawn;
  }

  void render() {
    if (!enabled) return;
    if (display) { 
      pushStyle();
      if (usecolor) tint(colour);
      simpleRenderImage();
      popStyle();
    }
  }

  void restart() {
    display = false;
    y = startY;
    enabled = false;
  }
}

class GibsSystem extends Entity {

  Gib[] gibs;
  float startTime;
  boolean enabled = false;
  float friction = .99;
  PShape model;
  float defaultForce = 250;
  PVector opticalCenterPoint;
  float defaultSpreadForce = 4;
  color c;
  boolean useColor = false;

  GibsSystem (PShape model, PVector opticalCenterPoint) {
    this.model = model;
    this.opticalCenterPoint = opticalCenterPoint;
    gibs = new Gib[model.getChildCount()];
    Gib g;

    PVector centerOffset = new PVector(model.width, model.height).div(2);
    opticalCenterPoint.sub(centerOffset);

    for (int i = 0; i < gibs.length; i++) {
      g = gibs[i] = new Gib();
      PShape m = model.getChild(i); // one line

      g.p1_init = new PVector(m.getParams()[0], m.getParams()[1]); // first anchor point of line
      g.p2_init = new PVector(m.getParams()[2], m.getParams()[3]); // second anchor point
      g.p1_init.sub(centerOffset); // translate anchor points so that center of image is (0,0)
      g.p2_init.sub(centerOffset); 
      g.midpoint = PVector.add(g.p1_init, g.p2_init).div(2); // part of line to apply force to
      g.p1 = new PVector();
      g.p2 = new PVector();
    }
  }

  void fire(float clock, Entity guy, PVector forcePoint, float force, float gibsFriction, float overallFriction) {
    fire (clock, guy, forcePoint, force, gibsFriction, overallFriction, defaultSpreadForce);
  }

  void fire (float clock, Entity guy, PVector forcePoint, float force, float gibsFriction, float overallFriction, float spreadForce) {

    this.parent = null;

    enabled = true;
    startTime = clock;

    setPosition(guy.globalPos());

    r = guy.globalRote();
    facing = guy.facing;

    float overallAngle = utils.angleOfRadians(forcePoint, guy.globalPos());
    dx = cos(overallAngle) * force;
    dy = sin(overallAngle) * force;
    friction = overallFriction;

    for (Gib g : gibs) {
      g.enabled = true;
      g.disableStart = clock;
      g.disableDuration = random(Gib.minDisable, Gib.maxDisable);

      g.p1.x = g.p1_init.x;
      g.p1.y = g.p1_init.y;
      g.p2.x = g.p2_init.x;
      g.p2.y = g.p2_init.y;

      g.friction = gibsFriction;

      float angle = utils.angleOfRadians(opticalCenterPoint, g.midpoint);
      g.dx = cos(angle) * spreadForce;
      g.dy = sin(angle) * spreadForce;
    }
  }

  void update (float dt, float clock) {
    if (!enabled) return;
    for (Gib g : gibs) {
      if (!g.enabled) continue;
      if (clock - g.disableStart > g.disableDuration) g.enabled = false;

      g.p1.x += g.dx * dt;
      g.p1.y += g.dy * dt;

      g.p2.x += g.dx * dt;
      g.p2.y += g.dy * dt;

      g.dx *= g.friction;
      g.dy *= g.friction;
    }

    x += dx * dt;
    y += dy * dt;

    dx *= friction;
    dy *= friction;
  }

  void render() {
    if (!enabled) return;
    pushTransforms();
    pushStyle();
    stroke(0, 0, 100);
    if(useColor) stroke(c);
    strokeWeight(assets.STROKE_WIDTH);

    for (Gib g : gibs) {
      if (!g.enabled) continue;
      line(g.p1.x, g.p1.y, g.p2.x, g.p2.y);
    }
    popStyle();
    popMatrix();
  }

  class Gib {
    float dx, dy;
    PVector p1, p2, p1_init, p2_init;
    PVector midpoint;
    boolean enabled = true;
    float friction;
    final static float minDisable = 10;
    final static float maxDisable = 500;
    float disableStart;
    float disableDuration;
  }
}
