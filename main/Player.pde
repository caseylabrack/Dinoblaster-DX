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

  int extraLives = 0;

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

  public void move(boolean left, boolean right, float delta, float clock, float scaleElapsed, obstacle[] blockers) {
    if (!enabled) return;

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
      targetPos = utils.rotateAroundPoint(localPos(), utils.ZERO_VECTOR, runSpeed * delta * facing * tarpitFactor);
      int frame = (clock % runFrameRate) > runFrameRate / 2 ? 1 : 2;
      model = frames[frame];
    } else {
      state = IDLE;
      model = frames[0];
      step.stop_();
      tarStep.stop_();
    }

    //check for blockers (volcanos)
    for (obstacle b : blockers) {
      if (!b.enabled() || b.isPassable()) continue;
      float targetAngle = utils.angleOf(utils.ZERO_VECTOR, targetPos);

      // find closest blocker angle (edge of the closest side of the blocker)
      float blockerAngle = b.getAngle();
      float blockerArc = b.getArc();
      if (utils.unsignedAngleDiff(targetAngle, blockerAngle) < blockerArc) { // movement would place player inside obstacle
        float blockerEdge1 = blockerAngle - blockerArc;
        float blockerEdge2 = blockerAngle + blockerArc;
        float blockerClosestEdgeAngle = utils.unsignedAngleDiff(targetAngle, blockerEdge1) < utils.unsignedAngleDiff(targetAngle, blockerEdge2) ? blockerEdge1 : blockerEdge2;
        float currentPositionAngle = utils.angleOf(utils.ZERO_VECTOR, localPos());
        targetPos = utils.rotateAroundPoint(localPos(), utils.ZERO_VECTOR, utils.signedAngleDiff(currentPositionAngle, blockerClosestEdgeAngle)); // correct target position to edge of obstacle
      }
    }

    setPosition(targetPos);
    r = utils.angleOf(utils.ZERO_VECTOR, localPos()) + 90;

    float sink = DIST_FROM_EARTH - (DIST_FROM_EARTH - TARPIT_BOTTOM_DIST) * tarpitSink;
    PVector tarpitAdjusted = new PVector(cos(radians(utils.angleOf(utils.ZERO_VECTOR, localPos()))) * sink, sin(radians(utils.angleOf(utils.ZERO_VECTOR, localPos()))) * sink);
    setPosition(tarpitAdjusted);

    wasInTarpitLastFrame = inTarpit;
  }

  boolean getAtTarpitBottom () {
    return tarpitSink > 1;
  }

  void setTarpitImmune (boolean b) {
    tarpitImmune = b;
  }

  public void render() {
    if (!enabled) return;
    simpleRenderImage();
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
}

class GibsSystem extends Entity {

  Gib[] gibs;
  float startTime;
  boolean enabled = false;
  float friction = .99;
  PShape model;
  float defaultForce = 250;
  PVector opticalCenterPoint;
  float spreadForce = 4;

  GibsSystem (PShape model, PVector opticalCenterPoint) {
    this.model = model;
    this.opticalCenterPoint = opticalCenterPoint;
    gibs = new Gib[model.getChildCount()];
    Gib g;

    PVector centerOffset = new PVector(model.width, model.height).div(2);
    opticalCenterPoint.sub(centerOffset);
    println("optical " + opticalCenterPoint);

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

  void fire (float clock, Entity guy, PVector forcePoint, float force, float gibsFriction, float overallFriction) {
    
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

//  class DinoGib {
//    float dx, dy;
//    PVector points;
//    PVector p1, p2;
//    PVector midpoint;
//    PVector center;
//    boolean enabled = true;
//    final static float minDisable = 1e3;
//    final static float maxDisable = 4e3;
//    float disableStart;
//    float disableDuration;
//    final PVector sourceImageCenter = new PVector(51, 67).div(2);
//  }
//  DinoGib[] gibs;

//  PlayerDeath (Time t, PVector _coords, float _r, float facing, PVector forcePoint) {
//    time = t;
//    setPosition(_coords);
//    r = _r;

//    gibs = new DinoGib[assets.playerStuff.dethSVG.getChildCount()];
//    DinoGib g;
//    PShape model;

//    for (int i = 0; i < gibs.length; i++) {

//      g = gibs[i] = new DinoGib();
//      model = assets.playerStuff.dethSVG.getChild(i); // one line

//      g.p1 = new PVector(model.getParams()[0], model.getParams()[1]); // first anchor point of line
//      g.p2 = new PVector(model.getParams()[2], model.getParams()[3]); // second anchor point
//      g.p1.sub(g.sourceImageCenter); // translate anchor points so that center of image is (0,0)
//      g.p2.sub(g.sourceImageCenter); 
//      g.p1.x *= facing==1 ? 1 : -1; // flip x-coords if facing opposite way
//      g.p2.x *= facing==1 ? 1 : -1;
//      g.midpoint = PVector.add(g.p1, g.p2).div(2); // part of line to apply force to
//      g.disableDuration = random(DinoGib.minDisable, DinoGib.maxDisable);
//      g.disableStart = time.getClock();
//      //g.disableStart = millis();

//      float angle = utils.angleOfRadians(forcePoint, g.midpoint);
//      float d = forcePoint.dist(g.midpoint);
//      //float force = (1/(d * d)) * 5000;
//      //float force = (1/d) * 500;
//      float force = (1/d) * 250;
//      //float force = 5;
//      //float force = (1/ (d * d)) * 1e3;
//      g.dx = cos(angle) * force;
//      g.dy = sin(angle) * force;
//    }
//  }

//  void update () {
//    for (DinoGib g : gibs) {
//      if (time.getClock() - g.disableStart > g.disableDuration) g.enabled = false;
//      //if (millis() - g.disableStart > g.disableDuration) g.enabled = false;

//      g.p1.x += g.dx * time.getTimeScale();
//      g.p1.y += g.dy * time.getTimeScale();

//      g.p2.x += g.dx * time.getTimeScale();
//      g.p2.y += g.dy * time.getTimeScale();

//      g.dx *= .99;
//      g.dy *= .99;
//    }
//  }

//  void render () {

//    pushTransforms();
//    pushStyle();
//    stroke(0, 0, 100);
//    strokeWeight(assets.STROKE_WIDTH);

//    for (DinoGib g : gibs) {
//      if (!g.enabled) continue;
//      line(g.p1.x, g.p1.y, g.p2.x, g.p2.y);
//    }
//    popStyle();
//    popMatrix();
//  }
//} 


//class PlayerManager implements updateable, renderable, abductionEvent, roidImpactEvent, playerRespawnedEvent, nebulaEvents {

//  EventManager eventManager;
//  Earth earth;
//  Time time;
//  VolcanoManager volcanoManager;
//  StarManager stars;
//  Camera cam;

//  public Player player = null;
//  PlayerDeath deathAnim = null;

//  PImage model;
//  int extralives;

//  boolean display = true;
//  float flickerStart = 0;
//  float flickerDuration = 6e3;
//  boolean respawning = false;
//  float flickerInitialRate = 1e3;
//  final static float respawnReadyFlickerRate = 50;
//  float flickerRate = 250;
//  float respawningY = -100;
//  float respawningYTarget = -Player.DIST_FROM_EARTH;//-197;
//  float respawningDuration = 3e3;
//  float respawningStart = 0;
//  float progress = 0;

//  boolean spawning = true;
//  float spawningStart = 0;
//  float spawningDuration = 1e3;
//  float spawningRate = 90;//125;
//  private float spawningFlickerStart;

//  boolean isHyperspace = false;
//  boolean delayingOneFrame = true;

//  PlayerManager (EventManager _ev, Earth _earth, Time t, VolcanoManager volcs, StarManager _stars, Camera c) {
//    eventManager = _ev;
//    earth = _earth;
//    time = t;
//    volcanoManager = volcs;
//    stars = _stars;
//    cam = c;

//    model = utils.sheetToSprites(loadImage("bronto-frames.png"), 3, 1)[0];
//    extralives = settings.getInt("extraLives", 0);

//    spawningStart = millis();
//    progress = 0;
//    spawningFlickerStart = millis();
//    //spawning = false;

//    eventManager.roidImpactSubscribers.add(this);
//    eventManager.abductionSubscribers.add(this);
//    eventManager.playerRespawnedSubscribers.add(this);
//  }

//  void roidImpactHandle(PVector impact) {

//    if (player!=null) {
//      if (PVector.dist(player.globalPos(), impact) < 65*2) { // close call
//        cam.magn += 6;
//      }

//      if (PVector.dist(player.globalPos(), impact) < 65) {
//        extralives--;
//        assets.playerStuff.step.stop_();
//        assets.playerStuff.tarStep.stop_();
//        float incomingAngle = utils.angleOf(earth.globalPos(), impact);
//        float offset = -20;
//        PVector adjustedPosition = new PVector(earth.globalPos().x + cos(radians(incomingAngle)) * (Earth.EARTH_RADIUS + offset), earth.globalPos().y + sin(radians(incomingAngle)) * (Earth.EARTH_RADIUS + offset));

//        deathAnim = new PlayerDeath(time, player.globalPos(), player.globalRote(), player.facing, player.globalToLocalPos(adjustedPosition));
//        if (extralives<0) {
//          assets.playerStuff.extinct.play();
//          eventManager.dispatchGameOver();
//          player = null;
//        } else {
//          eventManager.dispatchPlayerDied(player.globalPos());
//          assets.playerStuff.littleDeath.play();
//          player = null;
//        }
//      }
//    }
//  }

//  void bigOneKill () {

//    if (player!=null) {
//      assets.playerStuff.step.stop_();
//      assets.playerStuff.tarStep.stop_();
//      float incomingAngle = utils.angleOf(earth.globalPos(), player.globalPos());
//      float offset = -20;
//      PVector adjustedPosition = new PVector(earth.globalPos().x + cos(radians(incomingAngle)) * (Earth.EARTH_RADIUS + offset), earth.globalPos().y + sin(radians(incomingAngle)) * (Earth.EARTH_RADIUS + offset));

//      deathAnim = new PlayerDeath(time, player.globalPos(), player.globalRote(), player.facing, player.globalToLocalPos(adjustedPosition));
//      assets.playerStuff.extinct.play();
//      eventManager.dispatchGameOver();
//      player = null;
//    }
//  }

//  void abductionHandle(PVector p) {
//    assets.playerStuff.step.stop_();
//    assets.playerStuff.tarStep.stop_();
//    player = null;
//    extralives++;
//    respawning = true;
//    flickerStart = millis();
//    flickerRate = flickerInitialRate;
//    respawningStart = millis();
//    display = true;
//    progress = 0;
//  }

//  void removePlayerNotKill () {
//    assets.playerStuff.step.stop_();
//    assets.playerStuff.tarStep.stop_();
//    player = null;
//    respawning = false;
//  }

//  void nebulaStartHandle() {
//  };
//  void nebulaStopHandle() {
//    isHyperspace = false;
//  };

//  void playerRespawnedHandle(PVector position) {
//    player = new Player(eventManager, time, earth, Player.PLAYER_BRONTO, volcanoManager, position, this);
//  }

//  void update() {

//    if (delayingOneFrame) {
//      delayingOneFrame = false;
//      assets.playerStuff.spawn.play();
//    }

//    if (player!=null) player.update();

//    if (deathAnim!=null) deathAnim.update();

//    if (player!=null && stars!=null && !isHyperspace) {
//      float hypercubeDist = PVector.dist(player.globalPos(), stars.hypercubePosition());
//      if (hypercubeDist < 125) {
//        eventManager.dispatchNebulaStarted();
//        isHyperspace = true;
//      }
//    }
//  }

//  void render() {

//    if (deathAnim!=null) deathAnim.render();

//    if (spawning) {
//      progress = (millis() - spawningStart) / spawningDuration;
//      if (progress < 1) {
//        if (millis() - spawningFlickerStart > spawningRate) {
//          display = !display;
//          spawningFlickerStart = millis();
//        }
//      } else {
//        spawning = false;
//        player = new Player(eventManager, time, earth, 1, volcanoManager, null, this);
//        eventManager.dispatchPlayerSpawned(player);
//      }
//      if (display) {
//        image(model, 0, respawningYTarget);
//      }
//    }

//    if (player!=null) player.render();

//    if (respawning) {
//      progress = (millis() - respawningStart) / respawningDuration;
//      if (millis() - flickerStart > flickerRate) {
//        display = !display;
//        flickerStart = millis();
//      }
//      if (progress < 1) {
//        respawningY = utils.easeOutQuad(progress, -100, respawningYTarget - (-100), 1);    
//        flickerRate = utils.easeOutExpo(progress, flickerInitialRate, respawnReadyFlickerRate - flickerInitialRate, 1);
//      } else { // allow respawning
//        if (keys.anykey) {
//          respawning = false;
//          eventManager.dispatchPlayerRespawned(null);
//        }
//      }
//      if (display) {
//        image(model, 0, respawningY);
//      }
//    }
//  }
//}

//class Player extends Entity implements updateable, renderable { 
//  final static int PLAYER_BRONTO = 1;
//  final static int PLAYER_OVIRAPTOR = 2;
//  PImage model;
//  PImage[] runFrames = new PImage[2];
//  PImage idle;
//  float runSpeed;
//  int playerNum = 1;
//  int framesTotal = 8;
//  final static float DIST_FROM_EARTH = 194;//197;
//  final static float DEFAULT_RUNSPEED = 5;
//  final static float TARPIT_SLOW_FACTOR = .25;
//  final static float TARPIT_BOTTOM_DIST = 110;
//  final float TARPIT_RISE_FACTOR = 2;

//  float tarpitSink = 0;

//  final int STATE_IDLE = 0;
//  final int STATE_RUNNING = 1;
//  int state = STATE_IDLE;

//  boolean wasInTarpitLastFrame = false;

//  EventManager eventManager;
//  Time time;
//  VolcanoManager volcanoManager;
//  Earth earth;
//  PlayerManager manager;

//  boolean isFinale = false;

//  Player (EventManager _eventManager, Time t, Earth e, int whichPlayer, VolcanoManager volcs, PVector pos, PlayerManager p) {
//    eventManager = _eventManager;
//    time = t;
//    volcanoManager = volcs;
//    earth = e;
//    manager = p;

//    runSpeed = settings.getFloat("playerSpeed", DEFAULT_RUNSPEED);

//    PImage[] frames = whichPlayer==1 ? assets.playerStuff.brontoFrames : assets.playerStuff.oviFrames;

//    idle = frames[0];
//    runFrames[0] = frames[1];
//    runFrames[1] = frames[2];
//    model = idle;
//    x = pos==null ? earth.x + cos(radians(-90)) * DIST_FROM_EARTH : pos.x;
//    y = pos==null ? earth.y + sin(radians(-90)) * DIST_FROM_EARTH : pos.y;
//    r = degrees(atan2(earth.y - y, earth.x - x)) - 90;
//    earth.addChild(this);
//  }

//  void update () {

//    boolean inTarpit = earth.isInTarpit(localPos());

//    if (inTarpit) {
//      tarpitSink += time.getScaledElapsed() / Earth.TARPIT_SINK_DURATION;
//      if (tarpitSink > 1) {
//        manager.roidImpactHandle(this.globalPos());
//      }
//    } 

//    PVector targetPos = localPos();

//    if (keys.left != keys.right) { // xor
//      if (state==STATE_IDLE) {
//        state = STATE_RUNNING;
//        if (inTarpit) {
//          assets.playerStuff.tarStep.play(true);
//        } else {
//          assets.playerStuff.step.play(true);
//        }
//      }
//      if (inTarpit && !wasInTarpitLastFrame) {
//        assets.playerStuff.step.stop_();
//        assets.playerStuff.tarStep.play(true);
//      } 
//      if (!inTarpit && wasInTarpitLastFrame) {
//        assets.playerStuff.step.play(true);
//        assets.playerStuff.tarStep.stop_();
//      }

//      model = runFrames[utils.cycleRangeWithDelay(runFrames.length, 4, frameCount)];
//      facing = keys.left ? -1 : 1;

//      float tarpitFactor = 1;
//      if (inTarpit) {
//        tarpitSink -= (time.getElapsed() / Earth.TARPIT_SINK_DURATION) * TARPIT_RISE_FACTOR; // if you're running, you rise out of the tarpit faster than you sink
//        if (tarpitSink < 0) {
//          tarpitSink = 0;
//        }
//        tarpitFactor = tarpitSink == 0 ? (isFinale ? 1 : TARPIT_SLOW_FACTOR) : 0;
//      }

//      targetPos = utils.rotateAroundPoint(localPos(), utils.ZERO_VECTOR, runSpeed * time.getTimeScale() * facing * tarpitFactor);
//    } else {
//      model = idle;
//      state = STATE_IDLE;
//      assets.playerStuff.step.stop_();
//      assets.playerStuff.tarStep.stop_();
//    }

//    if (volcanoManager!=null) {
//      for (Volcano v : volcanoManager.volcanos) {
//        if (v.passable()) continue;
//        float myAngle = utils.angleOf(utils.ZERO_VECTOR, targetPos);
//        float vAngle = utils.angleOf(utils.ZERO_VECTOR, v.localPos());
//        float volcanoDist = utils.signedAngleDiff(myAngle, vAngle);
//        if (abs(volcanoDist) < v.getCurrentMargin()) {
//          int side = volcanoDist > 0 ? -1 : 1;
//          targetPos = utils.rotateAroundPoint(new PVector(cos(radians(vAngle)) * DIST_FROM_EARTH, sin(radians(vAngle)) * DIST_FROM_EARTH), new PVector(0, 0), v.getCurrentMargin() * side);
//        }
//      }
//    }

//    setPosition(targetPos);
//    r = utils.angleOf(utils.ZERO_VECTOR, localPos()) + 90;

//    float sink = DIST_FROM_EARTH - (DIST_FROM_EARTH - TARPIT_BOTTOM_DIST) * tarpitSink;
//    PVector tarpitAdjusted = new PVector(cos(radians(utils.angleOf(utils.ZERO_VECTOR, localPos()))) * sink, sin(radians(utils.angleOf(utils.ZERO_VECTOR, localPos()))) * sink);
//    setPosition(tarpitAdjusted);

//    wasInTarpitLastFrame = inTarpit;
//  }

//  void render () {
//    simpleRenderImage(model);
//    //    pushMatrix();
//    //PVector pos = globalPos();
//    //scale(facing, 1);
//    //translate(pos.x * facing, pos.y);
//    //rotate(radians(globalRote() * facing));
//    //image(model, 0, 0);
//    //popMatrix();
//  }
//}

//class PlayerDeath extends Entity {

//  Time time;

//  class DinoGib {
//    float dx, dy;
//    PVector points;
//    PVector p1, p2;
//    PVector midpoint;
//    PVector center;
//    boolean enabled = true;
//    final static float minDisable = 1e3;
//    final static float maxDisable = 4e3;
//    float disableStart;
//    float disableDuration;
//    final PVector sourceImageCenter = new PVector(51, 67).div(2);
//  }
//  DinoGib[] gibs;

//  PlayerDeath (Time t, PVector _coords, float _r, float facing, PVector forcePoint) {
//    time = t;
//    setPosition(_coords);
//    r = _r;

//    gibs = new DinoGib[assets.playerStuff.dethSVG.getChildCount()];
//    DinoGib g;
//    PShape model;

//    for (int i = 0; i < gibs.length; i++) {

//      g = gibs[i] = new DinoGib();
//      model = assets.playerStuff.dethSVG.getChild(i); // one line

//      g.p1 = new PVector(model.getParams()[0], model.getParams()[1]); // first anchor point of line
//      g.p2 = new PVector(model.getParams()[2], model.getParams()[3]); // second anchor point
//      g.p1.sub(g.sourceImageCenter); // translate anchor points so that center of image is (0,0)
//      g.p2.sub(g.sourceImageCenter); 
//      g.p1.x *= facing==1 ? 1 : -1; // flip x-coords if facing opposite way
//      g.p2.x *= facing==1 ? 1 : -1;
//      g.midpoint = PVector.add(g.p1, g.p2).div(2); // part of line to apply force to
//      g.disableDuration = random(DinoGib.minDisable, DinoGib.maxDisable);
//      g.disableStart = time.getClock();
//      //g.disableStart = millis();

//      float angle = utils.angleOfRadians(forcePoint, g.midpoint);
//      float d = forcePoint.dist(g.midpoint);
//      //float force = (1/(d * d)) * 5000;
//      //float force = (1/d) * 500;
//      float force = (1/d) * 250;
//      //float force = 5;
//      //float force = (1/ (d * d)) * 1e3;
//      g.dx = cos(angle) * force;
//      g.dy = sin(angle) * force;
//    }
//  }

//  void update () {
//    for (DinoGib g : gibs) {
//      if (time.getClock() - g.disableStart > g.disableDuration) g.enabled = false;
//      //if (millis() - g.disableStart > g.disableDuration) g.enabled = false;

//      g.p1.x += g.dx * time.getTimeScale();
//      g.p1.y += g.dy * time.getTimeScale();

//      g.p2.x += g.dx * time.getTimeScale();
//      g.p2.y += g.dy * time.getTimeScale();

//      g.dx *= .99;
//      g.dy *= .99;
//    }
//  }

//  void render () {

//    pushTransforms();
//    pushStyle();
//    stroke(0, 0, 100);
//    strokeWeight(assets.STROKE_WIDTH);

//    for (DinoGib g : gibs) {
//      if (!g.enabled) continue;
//      line(g.p1.x, g.p1.y, g.p2.x, g.p2.y);
//    }
//    popStyle();
//    popMatrix();
//  }
//} 
