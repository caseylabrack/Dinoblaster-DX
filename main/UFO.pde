class UFOManager implements updateable, renderable, abductionEvent, playerDiedEvent, playerRespawnedEvent {

  ColorDecider currentColor;
  UFO ufo = null;
  UFOrespawn ufoRespawn = null;
  Earth earth;
  PlayerManager playerManager;
  EventManager eventManager;
  Time time;

  int extralives;

  float spawnCountDown;
  boolean playerAlive = true;
  boolean enabled;

  UFOManager (ColorDecider _color, Earth _earth, PlayerManager _pm, EventManager _ev, Time t) {

    currentColor = _color;
    earth = _earth;
    playerManager = _pm;
    eventManager = _ev;
    time = t;

    eventManager.playerDiedSubscribers.add(this);
    eventManager.playerRespawnedSubscribers.add(this);
    eventManager.abductionSubscribers.add(this);

    extralives = settings.getInt("extraLives", 0);

    spawnCountDown = random(5, 90) * 1000;
    //spawnCountDown = 3000;

    enabled = settings.getBoolean("ufosEnabled", true);
  }

  void abductionHandle(PVector p) {
    extralives++;
    playerAlive = false;
  }

  void playerDiedHandle(PVector position) {
    if (extralives > 0) {
      ufoRespawn = new UFOrespawn(currentColor, earth, eventManager, time);
      if (ufo!=null) ufo.state=UFO.LEAVING;
    }
    extralives--;
    playerAlive = false;
  }

  void playerRespawnedHandle(PVector position) {
    playerAlive = true;
  }

  void update () {

    if (playerAlive && enabled) {
      spawnCountDown -= (1e3/60) * time.getTimeScale();
      if (spawnCountDown < 0) {
        spawnCountDown = random(40, 90) * 1000;
        ufo = new UFO(currentColor, earth, playerManager, eventManager, time);
      }
    }

    if (ufoRespawn!=null) {
      ufoRespawn.update();
      if (ufoRespawn.state==UFOrespawn.DONE) {
        ufoRespawn = null;
      }
    }

    if (ufo!=null) {
      ufo.update();
      if (ufo.state==UFO.DONE) {
        ufo = null;
      }
    }
  }

  void render () {
    if (ufo!=null) ufo.render();
    if (ufoRespawn!=null) ufoRespawn.render();
  }
}

class UFO extends Entity implements updateable, renderable {

  PImage[] brontoAbductionFrames;
  PImage[] ufoFrames;
  //PImage model;
  PShape model;
  ColorDecider currentColor;
  Earth earth;
  PlayerManager playerManager;
  EventManager eventManager;
  Time time;

  final static int INTO_VIEW = 0;
  final static int APPROACHING = 1;
  final static int CIRCLING = 2;
  final static int SCANNING = 3;
  final static int SNATCHING = 4;
  final static int LEAVING = 5;
  final static int DONE = 6;
  int state = INTO_VIEW;

  final static int initialDist = 600;
  final static int initialSpeed = 3;
  final static float initialRotate = .5;

  final static float NORMAL_SIZE = 64;
  final float startSize = 500;
  final float startDist = 530;
  final static float finalDist = 300;
  float currentSize = startSize;
  final float approachTime = 5e3;
  float startApproach;

  final float circlingMaxSpeed = 3;
  float speed = circlingMaxSpeed;
  final float circlingTime = 2e3;//2 * 1e3;
  float startCircling;

  final float scanningStartDelay = 1e3;
  final float scanningTransitioning = 2e3;
  final float scanningPause = 1e3;
  final static float maxBeamWidth = 15;
  float beamWidth = 0;

  final float scanDuration = scanningStartDelay + scanningTransitioning + scanningPause + scanningTransitioning + 2e3;
  float scanstart = 0;

  final float snatchMargin = 10;

  final static float snatchDuration = 3e3;
  float snatchStart = 0;
  PVector snatchStartPos = new PVector();
  PVector lilBrontoPos = new PVector();
  int lilBrontoFacingDirection = -1;
  float lilBrontoAngle = 0;
  final static float lilBrontoStartSize = 55;//40;
  final static float lilBrontoEndSize = 4;
  float lilBrontoSize = lilBrontoStartSize;

  float progress, dist, angle;

  UFO (ColorDecider _color, Earth _earth, PlayerManager _pm, EventManager _ev, Time time) {

    currentColor = _color;
    earth = _earth;
    ufoFrames = assets.ufostuff.ufoFrames;
    playerManager = _pm;
    brontoAbductionFrames = assets.ufostuff.brontoAbductionFrames;
    eventManager = _ev;
    this.time = time;
    //model = ufoFrames[0];

    float angle = random(0, 360);
    x = earth.x + cos(angle) * initialDist;
    y = earth.y + sin(angle) * initialDist;
    startApproach = time.getClock();

    assets.ufostuff.ufoSound.play(true);
  }

  void update() {

    switch(state) {

    case INTO_VIEW:
      dist = dist(x, y, earth.x, earth.y);
      if (dist > startDist) {
        angle = (float)Math.atan2(y - earth.y, x - earth.x);
        x = earth.x + cos(angle) * (dist - initialSpeed * time.getTimeScale());
        y = earth.y + sin(angle) * (dist - initialSpeed * time.getTimeScale());
        setPosition(utils.rotateAroundPoint(globalPos(), earth.globalPos(), initialRotate * -1 * time.getTimeScale()));
      } else {
        state = APPROACHING;
        startApproach = time.getClock();
      }
      break;

    case APPROACHING:
      progress = (time.getClock() - startApproach)  / approachTime;
      if (progress < 1) {
        currentSize = utils.easeInOutExpo(progress * 100, startSize, NORMAL_SIZE - startSize, 100);
        //model = ufoFrames[floor(utils.easeInQuad(progress, 0, 9, 1))];
        setPosition(utils.rotateAroundPoint(globalPos(), earth.globalPos(), (progress * circlingMaxSpeed + initialRotate) * -1 * time.getTimeScale()));
        angle = (float)Math.atan2(y - earth.y, x - earth.x);
        dist = utils.easeOutQuad(progress, startDist, -(startDist - finalDist), 1);
        x = earth.x + cos(angle) * dist;
        y = earth.y + sin(angle) * dist;
      } else {
        state = CIRCLING;
        startCircling = time.getClock();
      }
      break;

    case CIRCLING:
      progress = (time.getClock() - startCircling)  / circlingTime;
      if (progress < 1) {
        setPosition(utils.rotateAroundPoint(globalPos(), earth.globalPos(), utils.easeOutQuad((1 - progress), initialRotate, circlingMaxSpeed + initialRotate, 1) * -1 * time.getTimeScale()));
      } else {
        scanstart = time.getClock();
        state = SCANNING;
      }
      break;

    case SCANNING:
      if (time.getClock() - scanstart < scanDuration) {
        if (time.getClock() - scanstart > scanningStartDelay + scanningTransitioning && time.getClock() - scanstart < scanningStartDelay + scanningTransitioning + scanningPause) {
          if (playerManager.player!=null) {            
            if (utils.unsignedAngleDiff(utils.angleOf(earth.globalPos(), playerManager.player.globalPos()), utils.angleOf(earth.globalPos(), globalPos())) < snatchMargin) {
              snatchStart = time.getClock();
              snatchStartPos = playerManager.player.globalPos();
              lilBrontoFacingDirection = playerManager.player.direction;
              state = SNATCHING;
              lilBrontoAngle = playerManager.player.globalRote();
              eventManager.dispatchAbduction(playerManager.player.globalPos());
            }
          }
        }
      } else {
        state = LEAVING;
      }
      break;

    case SNATCHING:
      progress = (time.getClock() - snatchStart)  / snatchDuration;
      if (progress <= 1) {
        lilBrontoPos.set(PVector.lerp(snatchStartPos, globalPos(), progress));
        lilBrontoSize = utils.easeLinear(progress, lilBrontoStartSize, lilBrontoEndSize - lilBrontoStartSize, 1);
      } else {
        state = LEAVING;
      }
      break;

    case LEAVING:
      dist = dist(x, y, earth.x, earth.y);
      if (dist < 2000) {
        angle = (float)Math.atan2(y - earth.y, x - earth.x);
        x = earth.x + cos(angle) * (dist + (initialSpeed * time.getTimeScale()));
        y = earth.y + sin(angle) * (dist + (initialSpeed * time.getTimeScale()));
        if (x < -HEIGHT_REF_HALF || x > HEIGHT_REF_HALF || y < -HEIGHT_REF_HALF || y > HEIGHT_REF_HALF) assets.ufostuff.ufoSound.stop_(); // it's offscreen
      } else {
        state = DONE;
      }
      break;

    case DONE:
      break;

    default:
      println("ufo state wut");
      break;
    }

    x += dx;
    y += dy;
    r += dr;

    dx = dy = dr = 0;
  }

  void render () {

    if (state==SCANNING) {
      pushStyle();
      strokeWeight(assets.STROKE_WIDTH);
      stroke(currentColor.getColor());
      float angle = degrees(atan2(earth.y - y, earth.x - x));
      float scantime = time.getClock() - scanstart;
      if (scantime < scanningStartDelay) {
        //line(x, y, x + cos(radians(angle)) * 250, y + sin(radians(angle)) * 250);
      }
      if (scantime > scanningStartDelay && scantime < scanningStartDelay + scanningTransitioning) {
        beamWidth = utils.easeInExpo((scantime - scanningStartDelay)/scanningTransitioning, 0, maxBeamWidth, 1);
        line(x, y, x + cos(radians(angle + beamWidth)) * 250, y + sin(radians(angle + beamWidth)) * 250);
        line(x, y, x + cos(radians(angle - beamWidth)) * 250, y + sin(radians(angle - beamWidth)) * 250);
      }
      if (scantime > scanningStartDelay + scanningTransitioning && scantime < scanningStartDelay + scanningTransitioning + scanningPause) {
        line(x, y, x + cos(radians(angle + maxBeamWidth)) * 250, y + sin(radians(angle + maxBeamWidth)) * 250);
        line(x, y, x + cos(radians(angle - maxBeamWidth)) * 250, y + sin(radians(angle - maxBeamWidth)) * 250);
      }
      if (scantime > scanningStartDelay + scanningTransitioning + scanningPause && scantime < scanningStartDelay + scanningTransitioning + scanningPause + scanningTransitioning) {
        beamWidth = utils.easeInQuad(((scantime - scanningStartDelay - scanningTransitioning - scanningPause)/scanningTransitioning), maxBeamWidth, -maxBeamWidth, 1);
        line(x, y, x + cos(radians(angle + beamWidth)) * 250, y + sin(radians(angle + beamWidth)) * 250);
        line(x, y, x + cos(radians(angle - beamWidth)) * 250, y + sin(radians(angle - beamWidth)) * 250);
      }
      popStyle();
    }

    if (state==SNATCHING) {
      pushStyle();
      noFill();
      strokeWeight(assets.STROKE_WIDTH);
      stroke(currentColor.getColor());
      float angle = degrees(atan2(earth.y - y, earth.x - x));
      line(x, y, x + cos(radians(angle + maxBeamWidth)) * 250, y + sin(radians(angle + maxBeamWidth)) * 250);
      line(x, y, x + cos(radians(angle - maxBeamWidth)) * 250, y + sin(radians(angle - maxBeamWidth)) * 250);
      popStyle();

      pushMatrix();
      pushStyle();
      noFill();
      stroke(0, 0, 100, 1);
      strokeWeight(assets.STROKE_WIDTH * assets.playerStuff.brontoSVG.width/lilBrontoSize);
      scale(lilBrontoFacingDirection, 1);
      translate(lilBrontoPos.x * lilBrontoFacingDirection, lilBrontoPos.y);
      rotate(radians(lilBrontoAngle  * lilBrontoFacingDirection));
      shapeMode(CENTER);      
      shape(assets.playerStuff.brontoSVG, 0, 0, lilBrontoSize, lilBrontoSize * (assets.playerStuff.brontoSVG.height/assets.playerStuff.brontoSVG.width));
      popMatrix();
      popStyle();

      //pushMatrix();
      //scale(lilBrontoFacingDirection, 1);
      //translate(lilBrontoPos.x * lilBrontoFacingDirection, lilBrontoPos.y);
      //rotate(radians(lilBrontoAngle  * lilBrontoFacingDirection));
      //imageMode(CENTER);      
      //progress = (millis() - snatchStart)  / snatchDuration;
      //image(brontoAbductionFrames[ceil(progress * 8)], 0, 0);
      //popMatrix();
      //popStyle();
    }

    pushStyle();
    noFill();
    strokeWeight(assets.STROKE_WIDTH * assets.ufostuff.ufoSVG.width/currentSize);
    stroke(currentColor.getColor());
    //tint(currentColor.getColor());
    pushMatrix();
    fill(0, 0, 0);
    shapeMode(CENTER);
    //image(model, x, y, currentSize, currentSize);
    shape(assets.ufostuff.ufoSVG, x, y, currentSize, currentSize * (assets.ufostuff.ufoSVG.height/assets.ufostuff.ufoSVG.width));
    popMatrix();
    popStyle();

    //pushStyle();
    //noFill();
    //tint(currentColor.getColor());
    //pushMatrix();
    //fill(0, 0, 0);
    //imageMode(CENTER);
    //image(model, x, y);
    //popMatrix();
    //popStyle();
  }
}

class UFOrespawn extends Entity {

  ColorDecider currentColor;
  Earth earth;
  EventManager eventManager;
  Time time;

  final static int APPROACHING = 0;
  final static int ANTISNATCHING = 1;
  final static int WAITING = 2;
  final static int LEAVING = 5;
  final static int DONE = 6;
  int state = APPROACHING;

  final static int initialDist = 1000;

  float startApproach;

  PVector lilBrontoPos = new PVector();
  int lilBrontoFacingDirection = -1;
  float lilBrontoAngle = 0;

  float snatchStart;
  PVector snatchTarget;

  float flickerStart;
  boolean display = true;

  float dist, angle, progress;
  float lilBrontoSize = UFO.lilBrontoStartSize;

  UFOrespawn (ColorDecider _color, Earth _earth, EventManager _ev, Time time) {

    currentColor = _color;
    earth = _earth;
    eventManager = _ev;
    this.time = time;

    float angle = random(0, 360);
    x = earth.x + cos(angle) * UFO.initialDist;
    y = earth.y + sin(angle) * UFO.initialDist;
    startApproach = time.getClock();
  }

  void update() {
    switch(state) {

    case APPROACHING:
      dist = dist(x, y, earth.x, earth.y);
      if (dist > UFO.finalDist) {
        angle = atan2(y - earth.y, x - earth.x);
        x = earth.x + cos(angle) * (dist-UFO.initialSpeed * time.getTimeScale());
        y = earth.y + sin(angle) * (dist-UFO.initialSpeed * time.getTimeScale());
        setPosition(utils.rotateAroundPoint(globalPos(), earth.globalPos(), UFO.initialRotate * -1 * time.getTimeScale()));
      } else {
        state = ANTISNATCHING;
        snatchStart = time.getClock();
        float snatchAngle = atan2(y - earth.y, x - earth.x);
        snatchTarget = new PVector(earth.x + cos(snatchAngle) * (Earth.EARTH_RADIUS + 30), earth.y + sin(snatchAngle) * (Earth.EARTH_RADIUS + 30));
        lilBrontoAngle = atan2(earth.y - snatchTarget.y, earth.x - snatchTarget.x) + radians(-90);
      }
      break;

    case ANTISNATCHING:
      progress = (time.getClock() - snatchStart)  / UFO.snatchDuration;
      if (progress <= 1) {
        lilBrontoPos.set(PVector.lerp(globalPos(), snatchTarget, progress));
        lilBrontoSize = utils.easeLinear(progress, UFO.lilBrontoEndSize, UFO.lilBrontoStartSize - UFO.lilBrontoEndSize, 1);
      } else {
        state = WAITING;
        flickerStart = time.getClock();
      }
      break;

    case WAITING:
      if (keys.anykey) {
        state = LEAVING;
        eventManager.dispatchPlayerRespawned(lilBrontoPos);
      }
      break;

    case LEAVING:
      dist = dist(x, y, earth.x, earth.y);
      if (dist < 2000) {
        angle = (float)Math.atan2(y - earth.y, x - earth.x);
        x = earth.x + cos(angle) * (dist+UFO.initialSpeed * time.getTimeScale());
        y = earth.y + sin(angle) * (dist+UFO.initialSpeed * time.getTimeScale());
      } else {
        state = DONE;
      }
      break;

    case DONE:
      break;

    default:
      println("ufo state wut");
      break;
    }
  }

  void render () {

    if (state==ANTISNATCHING || state==WAITING) {
      pushStyle();
      noFill();
      strokeWeight(assets.STROKE_WIDTH);
      stroke(currentColor.getColor());
      float angle = degrees(atan2(earth.y - y, earth.x - x));
      line(x, y, x + cos(radians(angle + UFO.maxBeamWidth)) * 250, y + sin(radians(angle + UFO.maxBeamWidth)) * 250);
      line(x, y, x + cos(radians(angle - UFO.maxBeamWidth)) * 250, y + sin(radians(angle - UFO.maxBeamWidth)) * 250);
      popStyle();

      pushMatrix();
      pushStyle();
      noFill();
      stroke(0, 0, 100, 1);
      strokeWeight(assets.STROKE_WIDTH * assets.playerStuff.brontoSVG.width/lilBrontoSize);
      scale(lilBrontoFacingDirection, 1);
      translate(lilBrontoPos.x * lilBrontoFacingDirection, lilBrontoPos.y);
      rotate(lilBrontoAngle  * lilBrontoFacingDirection);
      shapeMode(CENTER);  
      if (state==WAITING) {
        if (time.getClock() - flickerStart > PlayerManager.respawnReadyFlickerRate) {
          display = !display;
          flickerStart = time.getClock();
        }
      }
      if (display) shape(assets.playerStuff.brontoSVG, 0, 0, lilBrontoSize, lilBrontoSize * (assets.playerStuff.brontoSVG.height/assets.playerStuff.brontoSVG.width));
      popStyle();
      popMatrix();

      //pushMatrix();
      //scale(lilBrontoFacingDirection, 1);
      //translate(lilBrontoPos.x * lilBrontoFacingDirection, lilBrontoPos.y);
      //rotate(lilBrontoAngle  * lilBrontoFacingDirection);
      //imageMode(CENTER);      
      //progress = min((millis() - snatchStart)  / UFO.snatchDuration, .999);
      //if (state==WAITING) {
      //  if (millis() - flickerStart > PlayerManager.respawnReadyFlickerRate) {
      //    display = !display;
      //    flickerStart = millis();
      //  }
      //}
      //if (display) image(assets.ufostuff.brontoAbductionFrames[ceil((1-progress) * 8)], 0, 0);
      //popMatrix();
      //popStyle();
    }

    pushStyle();
    noFill();
    strokeWeight(assets.STROKE_WIDTH * assets.ufostuff.ufoSVG.width/UFO.NORMAL_SIZE);
    stroke(currentColor.getColor());
    pushMatrix();
    fill(0, 0, 0);
    shapeMode(CENTER);
    shape(assets.ufostuff.ufoSVG, x, y, UFO.NORMAL_SIZE, UFO.NORMAL_SIZE * (assets.ufostuff.ufoSVG.height/assets.ufostuff.ufoSVG.width));
    popMatrix();
    popStyle();

    //pushStyle();
    //noFill();
    //tint(currentColor.getColor());
    //pushMatrix();
    //fill(0, 0, 0);
    //imageMode(CENTER);
    //image(assets.ufostuff.ufoFrames[8], x, y);
    //popMatrix();
    //popStyle();
  }
}
