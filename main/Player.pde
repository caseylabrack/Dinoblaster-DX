class PlayerManager implements updateable, renderable, abductionEvent, roidImpactEvent, playerRespawnedEvent, nebulaEvents {

  EventManager eventManager;
  Earth earth;
  Time time;
  VolcanoManager volcanoManager;
  StarManager stars;
  Camera cam;

  public Player player = null;
  PlayerDeath deathAnim = null;

  PImage model;
  int extralives;

  boolean display = true;
  float flickerStart = 0;
  float flickerDuration = 6e3;
  boolean respawning = false;
  float flickerInitialRate = 1e3;
  final static float respawnReadyFlickerRate = 50;
  float flickerRate = 250;
  float respawningY = -100;
  float respawningYTarget = -Player.DIST_FROM_EARTH;//-197;
  float respawningDuration = 3e3;
  float respawningStart = 0;
  float progress = 0;

  boolean spawning = true;
  float spawningStart = 0;
  float spawningDuration = 1e3;
  float spawningRate = 90;//125;
  private float spawningFlickerStart;

  boolean isHyperspace = false;
  boolean delayingOneFrame = true;

  PlayerManager (EventManager _ev, Earth _earth, Time t, VolcanoManager volcs, StarManager _stars, Camera c) {
    eventManager = _ev;
    earth = _earth;
    time = t;
    volcanoManager = volcs;
    stars = _stars;
    cam = c;

    model = utils.sheetToSprites(loadImage("bronto-frames.png"), 3, 1)[0];
    extralives = settings.getInt("extraLives", 0);

    spawningStart = millis();
    progress = 0;
    spawningFlickerStart = millis();
    //spawning = false;

    eventManager.roidImpactSubscribers.add(this);
    eventManager.abductionSubscribers.add(this);
    eventManager.playerRespawnedSubscribers.add(this);
  }

  void roidImpactHandle(PVector impact) {

    if (player!=null) {
      if (PVector.dist(player.globalPos(), impact) < 65*2) { // close call
        cam.magn += 6;
      }

      if (PVector.dist(player.globalPos(), impact) < 65) {
        extralives--;
        assets.playerStuff.step.stop_();
        assets.playerStuff.tarStep.stop_();
        float incomingAngle = utils.angleOf(earth.globalPos(), impact);
        float offset = -20;
        PVector adjustedPosition = new PVector(earth.globalPos().x + cos(radians(incomingAngle)) * (Earth.EARTH_RADIUS + offset), earth.globalPos().y + sin(radians(incomingAngle)) * (Earth.EARTH_RADIUS + offset));

        deathAnim = new PlayerDeath(time, player.globalPos(), player.globalRote(), player.direction, player.globalToLocalPos(adjustedPosition));
        if (extralives<0) {
          assets.playerStuff.extinct.play();
          eventManager.dispatchGameOver();
          player = null;
        } else {
          eventManager.dispatchPlayerDied(player.globalPos());
          assets.playerStuff.littleDeath.play();
          player = null;
        }
      }
    }
  }

  void bigOneKill () {

    if (player!=null) {
      assets.playerStuff.step.stop_();
      assets.playerStuff.tarStep.stop_();
      float incomingAngle = utils.angleOf(earth.globalPos(), player.globalPos());
      float offset = -20;
      PVector adjustedPosition = new PVector(earth.globalPos().x + cos(radians(incomingAngle)) * (Earth.EARTH_RADIUS + offset), earth.globalPos().y + sin(radians(incomingAngle)) * (Earth.EARTH_RADIUS + offset));

      deathAnim = new PlayerDeath(time, player.globalPos(), player.globalRote(), player.direction, player.globalToLocalPos(adjustedPosition));
      assets.playerStuff.extinct.play();
      eventManager.dispatchGameOver();
      player = null;
    }
  }

  void abductionHandle(PVector p) {
    assets.playerStuff.step.stop_();
    assets.playerStuff.tarStep.stop_();
    player = null;
    extralives++;
    respawning = true;
    flickerStart = millis();
    flickerRate = flickerInitialRate;
    respawningStart = millis();
    display = true;
    progress = 0;
  }

  void nebulaStartHandle() {
  };
  void nebulaStopHandle() {
    isHyperspace = false;
  };

  void playerRespawnedHandle(PVector position) {
    player = new Player(eventManager, time, earth, Player.PLAYER_BRONTO, volcanoManager, position, this);
  }

  void update() {

    if (delayingOneFrame) {
      delayingOneFrame = false;
      assets.playerStuff.spawn.play();
    }

    if (player!=null) player.update();

    if (deathAnim!=null) deathAnim.update();

    if (player!=null && stars!=null && !isHyperspace) {
      float hypercubeDist = PVector.dist(player.globalPos(), stars.hypercubePosition());
      if (hypercubeDist < 125) {
        eventManager.dispatchNebulaStarted();
        isHyperspace = true;
      }
    }
  }

  void render() {

    if (deathAnim!=null) deathAnim.render();

    if (spawning) {
      progress = (millis() - spawningStart) / spawningDuration;
      if (progress < 1) {
        if (millis() - spawningFlickerStart > spawningRate) {
          display = !display;
          spawningFlickerStart = millis();
        }
      } else {
        spawning = false;
        player = new Player(eventManager, time, earth, 1, volcanoManager, null, this);
        eventManager.dispatchPlayerSpawned(player);
      }
      if (display) {
        image(model, 0, respawningYTarget);
      }
    }

    if (player!=null) player.render();

    if (respawning) {
      progress = (millis() - respawningStart) / respawningDuration;
      if (millis() - flickerStart > flickerRate) {
        display = !display;
        flickerStart = millis();
      }
      if (progress < 1) {
        respawningY = utils.easeOutQuad(progress, -100, respawningYTarget - (-100), 1);    
        flickerRate = utils.easeOutExpo(progress, flickerInitialRate, respawnReadyFlickerRate - flickerInitialRate, 1);
      } else { // allow respawning
        if (keys.anykey) {
          respawning = false;
          eventManager.dispatchPlayerRespawned(null);
        }
      }
      if (display) {
        image(model, 0, respawningY);
      }
    }
  }
}

class Player extends Entity implements updateable, renderable { 
  final static int PLAYER_BRONTO = 1;
  final static int PLAYER_OVIRAPTOR = 2;
  PImage model;
  PImage[] runFrames = new PImage[2];
  PImage idle;
  float runSpeed;
  int direction = 1;
  int playerNum = 1;
  int framesTotal = 8;
  final static float DIST_FROM_EARTH = 194;//197;
  final static float DEFAULT_RUNSPEED = 5;
  final static float TARPIT_SLOW_FACTOR = .25;
  final static float TARPIT_BOTTOM_DIST = 110;
  final float TARPIT_RISE_FACTOR = 2;

  float tarpitSink = 0;

  final int STATE_IDLE = 0;
  final int STATE_RUNNING = 1;
  int state = STATE_IDLE;

  boolean wasInTarpitLastFrame = false;


  EventManager eventManager;
  Time time;
  VolcanoManager volcanoManager;
  Earth earth;
  PlayerManager manager;

  Player (EventManager _eventManager, Time t, Earth e, int whichPlayer, VolcanoManager volcs, PVector pos, PlayerManager p) {
    eventManager = _eventManager;
    time = t;
    volcanoManager = volcs;
    earth = e;
    manager = p;

    runSpeed = settings.getFloat("playerSpeed", DEFAULT_RUNSPEED);

    PImage[] frames = whichPlayer==1 ? assets.playerStuff.brontoFrames : assets.playerStuff.oviFrames;

    idle = frames[0];
    runFrames[0] = frames[1];
    runFrames[1] = frames[2];
    model = idle;
    x = pos==null ? earth.x + cos(radians(-90)) * DIST_FROM_EARTH : pos.x;
    y = pos==null ? earth.y + sin(radians(-90)) * DIST_FROM_EARTH : pos.y;
    r = degrees(atan2(earth.y - y, earth.x - x)) - 90;
    earth.addChild(this);
  }

  void update () {

    boolean inTarpit = earth.isInTarpit(localPos());

    if (inTarpit) {
      tarpitSink += time.getScaledElapsed() / Earth.TARPIT_SINK_DURATION;
      if (tarpitSink > 1) {
        manager.roidImpactHandle(this.globalPos());
      }
    } 

    PVector targetPos = localPos();

    if (keys.left != keys.right) { // xor
      if (state==STATE_IDLE) {
        state = STATE_RUNNING;
        if (inTarpit) {
          assets.playerStuff.tarStep.play(true);
        } else {
          assets.playerStuff.step.play(true);
        }
      }
      if (inTarpit && !wasInTarpitLastFrame) {
        assets.playerStuff.step.stop_();
        assets.playerStuff.tarStep.play(true);
      } 
      if (!inTarpit && wasInTarpitLastFrame) {
        assets.playerStuff.step.play(true);
        assets.playerStuff.tarStep.stop_();
      }

      model = runFrames[utils.cycleRangeWithDelay(runFrames.length, 4, frameCount)];
      direction = keys.left ? -1 : 1;

      float tarpitFactor = 1;
      if (inTarpit) {
        tarpitSink -= (time.getElapsed() / Earth.TARPIT_SINK_DURATION) * TARPIT_RISE_FACTOR; // if you're running, you rise out of the tarpit faster than you sink
        if (tarpitSink < 0) {
          tarpitSink = 0;
        }
        tarpitFactor = tarpitSink == 0 ? TARPIT_SLOW_FACTOR : 0;
      }

      targetPos = utils.rotateAroundPoint(localPos(), utils.ZERO_VECTOR, runSpeed * time.getTimeScale() * direction * tarpitFactor);
    } else {
      model = idle;
      state = STATE_IDLE;
      assets.playerStuff.step.stop_();
      assets.playerStuff.tarStep.stop_();
    }

    if (volcanoManager!=null) {
      for (Volcano v : volcanoManager.volcanos) {
        if (v.passable()) continue;
        float myAngle = utils.angleOf(utils.ZERO_VECTOR, targetPos);
        float vAngle = utils.angleOf(utils.ZERO_VECTOR, v.localPos());
        float volcanoDist = utils.signedAngleDiff(myAngle, vAngle);
        if (abs(volcanoDist) < v.getCurrentMargin()) {
          int side = volcanoDist > 0 ? -1 : 1;
          targetPos = utils.rotateAroundPoint(new PVector(cos(radians(vAngle)) * DIST_FROM_EARTH, sin(radians(vAngle)) * DIST_FROM_EARTH), new PVector(0, 0), v.getCurrentMargin() * side);
        }
      }
    }

    setPosition(targetPos);
    r = utils.angleOf(utils.ZERO_VECTOR, localPos()) + 90;

    float sink = DIST_FROM_EARTH - (DIST_FROM_EARTH - TARPIT_BOTTOM_DIST) * tarpitSink;
    PVector tarpitAdjusted = new PVector(cos(radians(utils.angleOf(utils.ZERO_VECTOR, localPos()))) * sink, sin(radians(utils.angleOf(utils.ZERO_VECTOR, localPos()))) * sink);
    setPosition(tarpitAdjusted);

    wasInTarpitLastFrame = inTarpit;
  }

  void render () {
    pushMatrix();
    pushStyle();
    imageMode(CENTER);
    PVector trans = globalPos();
    scale(direction, 1);
    translate(trans.x * direction, trans.y);
    rotate(radians(globalRote() * direction));
    image(model, 0, 0);
    popStyle();
    popMatrix();
  }
}

class PlayerDeath extends Entity {

  Time time;

  class DinoGib {
    float dx, dy;
    PVector points;
    PVector p1, p2;
    PVector midpoint;
    PVector center;
    boolean enabled = true;
    final static float minDisable = 1e3;
    final static float maxDisable = 4e3;
    float disableStart;
    float disableDuration;
    final PVector sourceImageCenter = new PVector(51, 67).div(2);
  }
  DinoGib[] gibs;

  PlayerDeath (Time t, PVector _coords, float _r, float facing, PVector forcePoint) {
    time = t;
    setPosition(_coords);
    r = _r;

    gibs = new DinoGib[assets.playerStuff.dethSVG.getChildCount()];
    DinoGib g;
    PShape model;

    for (int i = 0; i < gibs.length; i++) {

      g = gibs[i] = new DinoGib();
      model = assets.playerStuff.dethSVG.getChild(i); // one line

      g.p1 = new PVector(model.getParams()[0], model.getParams()[1]); // first anchor point of line
      g.p2 = new PVector(model.getParams()[2], model.getParams()[3]); // second anchor point
      g.p1.sub(g.sourceImageCenter); // translate anchor points so that center of image is (0,0)
      g.p2.sub(g.sourceImageCenter); 
      g.p1.x *= facing==1 ? 1 : -1; // flip x-coords if facing opposite way
      g.p2.x *= facing==1 ? 1 : -1;
      g.midpoint = PVector.add(g.p1, g.p2).div(2); // part of line to apply force to
      g.disableDuration = random(DinoGib.minDisable, DinoGib.maxDisable);
      g.disableStart = time.getClock();
      //g.disableStart = millis();

      float angle = utils.angleOfRadians(forcePoint, g.midpoint);
      float d = forcePoint.dist(g.midpoint);
      //float force = (1/(d * d)) * 5000;
      //float force = (1/d) * 500;
      float force = (1/d) * 250;
      //float force = 5;
      //float force = (1/ (d * d)) * 1e3;
      g.dx = cos(angle) * force;
      g.dy = sin(angle) * force;
    }
  }

  void update () {
    for (DinoGib g : gibs) {
      if (time.getClock() - g.disableStart > g.disableDuration) g.enabled = false;
      //if (millis() - g.disableStart > g.disableDuration) g.enabled = false;

      g.p1.x += g.dx * time.getTimeScale();
      g.p1.y += g.dy * time.getTimeScale();

      g.p2.x += g.dx * time.getTimeScale();
      g.p2.y += g.dy * time.getTimeScale();

      g.dx *= .99;
      g.dy *= .99;
    }
  }

  void render () {

    pushTransforms();
    pushStyle();
    stroke(0, 0, 100);
    strokeWeight(assets.STROKE_WIDTH);

    for (DinoGib g : gibs) {
      if (!g.enabled) continue;
      line(g.p1.x, g.p1.y, g.p2.x, g.p2.y);
    }
    popStyle();
    popMatrix();
  }
} 
