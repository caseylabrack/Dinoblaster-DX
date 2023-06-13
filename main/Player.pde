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

  int extraLives = 0;
  color c;
  boolean usecolor = false;
  boolean bounceHitThisFrame = false;
  boolean bouncing;
  float bounceOriginR;
  float bounceOriginM;
  float bounceStart;
  int bounceDir;
  PVector bounceOrigin;
  static final float BOUNCE_DURATION = .5e3;

  PVector ppos = new PVector(); // previous position (last frame)
  float pr; // previous angle

  PImage[] frames;
  PShape abductModel;
  SoundPlayable step;
  SoundPlayable tarStep;

  Player(PShape abductModel, PImage[] frames, SoundPlayable step, SoundPlayable tarStep, color c) {
    this.abductModel = abductModel;
    this.frames = frames;
    this.step = step;
    this.tarStep = tarStep;
    model = frames[0];
    this.c = c;
  }

  //float tarpitSlowing (boolean in, ) {
  //  float tarpitFactor = 1;
  //  if (inTarpit) {
  //    tarpitSink -= (scaleElapsed / Earth.TARPIT_SINK_DURATION) * TARPIT_RISE_FACTOR; // if you're running, you rise out of the tarpit faster than you sink
  //    if (tarpitSink < 0) {
  //      tarpitSink = 0;
  //    }
  //    // on tarpit surface, run at a slow factor unless immunity set. 
  //    // beneath surface, can't run (but can rise)
  //    // setting tarpit immunity disables sinking motion but retains rising motion, so player can start ignore tarpits even if below the surface
  //    tarpitFactor = tarpitSink == 0 ? (tarpitImmune ? 1 : TARPIT_SLOW_FACTOR) : 0;
  //  }
  //}

  void bounceStart (float clock) {
    bounceOrigin = localPos();
    bounceOriginR = r;
    //bounceOriginM
    bounceStart = clock;
    bounceDir = 1;
    bouncing = true;
  }

  public void move(boolean left, boolean right, float delta, float clock, float scaleElapsed, ArrayList<obstacle> blockers) {
    //public void move(boolean left, boolean right, float delta, float clock, float scaleElapsed, obstacle[] blockers) {
    if (!enabled) return;

    float _dr = 0;
    float targetR = r; // polar angle
    float targetM = DIST_FROM_EARTH; // polar radius
    PVector targetPos = localPos();

    if (inTarpit) {
      tarpitSink += scaleElapsed / Earth.TARPIT_SINK_DURATION;
    }

    // running or not. if running, update target position
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
        tarpitSink -= (scaleElapsed / Earth.TARPIT_SINK_DURATION) * TARPIT_RISE_FACTOR; // if you're running, you rise out of the tarpit faster than you sink
        if (tarpitSink < 0) {
          tarpitSink = 0;
        }
        // on tarpit surface, run at a slow factor unless immunity set. 
        // beneath surface, can't run (but can rise)
        // setting tarpit immunity disables sinking motion but retains rising motion, so player can start ignore tarpits even if below the surface
        tarpitFactor = tarpitSink == 0 ? (tarpitImmune ? 1 : TARPIT_SLOW_FACTOR) : 0;
      }

      facing = left ? -1 : 1;
      //_dr = runSpeed * delta * facing * tarpitFactor;
      targetR = r + runSpeed * delta * facing * tarpitFactor;
      targetPos = utils.rotateAroundPoint(localPos(), utils.ZERO_VECTOR, runSpeed * delta * facing * tarpitFactor);
      int frame = (clock % runFrameRate) > runFrameRate / 2 ? 1 : 2;
      model = frames[frame];
    } else {
      state = IDLE;
      model = frames[0];
      step.stop_();
      tarStep.stop_();
    }

    if (bouncing) {

      float progress = (clock - bounceStart) / BOUNCE_DURATION;

      if (progress > 1) {
        bouncing = false;
      } else {
        float progress2 = utils.easeOutCirc(progress);
        targetR = bounceOriginR - map(progress2,0,1,0,30);
        targetM = DIST_FROM_EARTH + sin(radians(progress * 180)) * 25;
      }
    }

    setPosition(utils.rotateAroundPoint(localPos(), utils.ZERO_VECTOR, targetR - r));
    PVector tarpitAdjusted = new PVector(cos(radians(utils.angleOf(utils.ZERO_VECTOR, localPos()))) * targetM, sin(radians(utils.angleOf(utils.ZERO_VECTOR, localPos()))) * targetM);
    setPosition(tarpitAdjusted);

    //check for blockers (volcanos)
    //if (blockers != null) {
    //  for (obstacle b : blockers) {
    //    if (!b.enabled() || b.isPassable()) continue;
    //    //println("blocker", frameCount, b.enabled(), b.isPassable());
    //    float targetAngle = utils.angleOf(utils.ZERO_VECTOR, targetPos);

    //    // find closest blocker angle (edge of the closest side of the blocker)
    //    float blockerAngle = b.getAngle();
    //    float blockerArc = b.getArc();
    //    if (utils.unsignedAngleDiff(targetAngle, blockerAngle) < blockerArc) { // movement would place player inside obstacle
    //      if (b.bounce()) {
    //        bounceHitThisFrame = true;
    //        b.markBounce();
    //        println("I should bounce off this");
    //      }

    //      float blockerEdge1 = blockerAngle - blockerArc;
    //      float blockerEdge2 = blockerAngle + blockerArc;
    //      float blockerClosestEdgeAngle = utils.unsignedAngleDiff(targetAngle, blockerEdge1) < utils.unsignedAngleDiff(targetAngle, blockerEdge2) ? blockerEdge1 : blockerEdge2;
    //      float currentPositionAngle = utils.angleOf(utils.ZERO_VECTOR, localPos());
    //      targetPos = utils.rotateAroundPoint(localPos(), utils.ZERO_VECTOR, utils.signedAngleDiff(currentPositionAngle, blockerClosestEdgeAngle)); // correct target position to edge of obstacle
    //    }
    //  }
    //}

    //setPosition(targetPos);
    r = utils.angleOf(utils.ZERO_VECTOR, localPos()) + 90; // recompute R to avoid accumulation of error
    //println(r, targetR % 360);


    //float sink = DIST_FROM_EARTH - (DIST_FROM_EARTH - TARPIT_BOTTOM_DIST) * tarpitSink;
    //PVector tarpitAdjusted = new PVector(cos(radians(utils.angleOf(utils.ZERO_VECTOR, localPos()))) * sink, sin(radians(utils.angleOf(utils.ZERO_VECTOR, localPos()))) * sink);
    //setPosition(tarpitAdjusted);

    wasInTarpitLastFrame = inTarpit;
  }

  boolean getAtTarpitBottom () {
    return tarpitSink > 1;
  }

  void setTarpitImmune (boolean b) {
    tarpitImmune = b;
  }

  boolean checkForBounce() {
    boolean r = bounceHitThisFrame;
    bounceHitThisFrame = false;
    return r;
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
  int state = FLASHING;

  final float FLICKER_RATE = 16;

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
      simpleRenderImage();
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
    if (display) simpleRenderImage();
  }

  void restart() {
    display = false;
    y = startY;
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
