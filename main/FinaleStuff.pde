class FinalUFO extends Entity {
  PVector finalUFOStablePosition;
  final float MIN_SHAKE = 0;
  final float MAX_SHAKE = 100;
  final float TRAVEL_DIST = 250;
  final float FINAL_SCALE = .9;
  final float START_SCALE = .1;
  PShape model;
}

class FinaleStuff implements gameFinaleEvent, updateable, renderable {

  final int STEPS_TOWARD_EARTH = 4;
  final int FLICKER_RATE = 16;
  final float IMPACT_HIT_ANGLE = 45;

  Entity bigone;

  boolean isFinale = false;

  final static float BIG_ONE_INCOMING_DURATION = 6e3;
  float bigoneStart;
  int lastBeep = -1;
  float steplength, fromEarthToRoid, progress;

  final float EXPLOSIONS_DURATION = 10e3;
  float explosionsStart;

  final float RESCUING_DURATION = 5e3;

  final int INCOMING = 1;
  final int EXPLODING = 2;
  final int ABORT = 3;
  final int RESCUING = 4;
  final int PULLING_AWAY = 5;
  final int ZOOMING = 6;
  final int DONE = 7;
  int state = INCOMING;

  EventManager eventManager;
  Earth earth;
  PlayerManager playerManager;

  float bigOneAngle;
  float explosionTrailAngle;
  float explosionSlice;
  float killAngle;

  float abortStart;
  float rescueStart;
  float stateStart;

  final int NUM_EXPLOSIONS = 9;
  ArrayList<PVector> explosionRing = new ArrayList<PVector>(NUM_EXPLOSIONS);
  ArrayList<PVector> explosionRing2 = new ArrayList<PVector>(NUM_EXPLOSIONS);

  FinalUFO finalUFO;
  Entity dummyBronto;
  PVector dummyBrontoStartPos;  

  StarManager starManager;
  Camera cam;
  Time time;

  FinaleStuff(EventManager eventManager, Earth earth, PlayerManager playerManager, StarManager starManager, Camera cam, Time time) {
    this.eventManager = eventManager;
    eventManager.gameFinaleSubscribers.add(this);

    this.playerManager = playerManager;

    this.starManager = starManager;
    this.cam = cam;
    this.time = time;

    finalUFO = new FinalUFO();
    finalUFO.setPosition(HEIGHT_REF_HALF + 50, HEIGHT_REF_HALF + 50);
    finalUFO.scale = finalUFO.START_SCALE;
    finalUFO.model = assets.ufostuff.ufoFinalSingle;

    bigone = new Entity();
    bigone.setPosition(-HEIGHT_REF_HALF, -HEIGHT_REF_HALF);

    fromEarthToRoid = utils.angleOfRadians(utils.ZERO_VECTOR, bigone.globalPos());
    float impactX = cos(fromEarthToRoid) * Earth.EARTH_RADIUS;
    float impactY = sin(fromEarthToRoid) * Earth.EARTH_RADIUS;
    float dist = dist(bigone.globalPos().x, bigone.globalPos().y, impactX, impactY);
    steplength = dist / float(STEPS_TOWARD_EARTH);
    this.earth = earth;

    bigOneAngle = utils.angleOf(utils.ZERO_VECTOR, bigone.globalPos()); // angle does not change (big one only moves toward earth)
    explosionTrailAngle = utils.signedAngleDiff(bigOneAngle + IMPACT_HIT_ANGLE, bigOneAngle + 180); // distance from one side of explosions trail to opposite end of earth from impact
    explosionSlice = explosionTrailAngle / float(NUM_EXPLOSIONS); // how wide is one explosion 

    float p, ang, x, y, r;
    for (float i = 0; i < NUM_EXPLOSIONS; i++) {
      p = i/(NUM_EXPLOSIONS - .5);
      ang = bigOneAngle + IMPACT_HIT_ANGLE + p * explosionTrailAngle; // explosions going clockwise, starting from one side of Big One impact point
      x = cos(radians(ang)) * (Earth.EARTH_RADIUS + 20);
      y = sin(radians(ang)) * (Earth.EARTH_RADIUS + 20);
      r = utils.angleOf(utils.ZERO_VECTOR, new PVector(x, y)) + 90;
      explosionRing.add(new PVector(x, y, r));

      ang = bigOneAngle - IMPACT_HIT_ANGLE + p * -explosionTrailAngle; // explosions going counter-clockwise, starting from other side of Big One impact point
      x = cos(radians(ang)) * (Earth.EARTH_RADIUS + 20);
      y = sin(radians(ang)) * (Earth.EARTH_RADIUS + 20);
      r = utils.angleOf(utils.ZERO_VECTOR, new PVector(x, y)) + 90;
      explosionRing2.add(new PVector(x, y, r));
    }
  }

  void update () {

    if (!isFinale) return;

    switch(state) {

    case INCOMING:
      if (progress < 1) {
        progress = (millis() - bigoneStart) / BIG_ONE_INCOMING_DURATION;
        float currentStep = floor(progress * STEPS_TOWARD_EARTH);
        float travelDist = steplength * currentStep;
        if (currentStep > lastBeep + .001) {
          lastBeep = int(currentStep);
          assets.roidStuff.bigoneBlip.play();
        }
        bigone.setPosition(-HEIGHT_REF_HALF + cos(fromEarthToRoid + PI) * travelDist, -HEIGHT_REF_HALF + sin(fromEarthToRoid + PI) * travelDist);
      } else {        
        state = EXPLODING;
        explosionsStart = millis();
        earth.addChild(bigone);
        eventManager.dispatchFinaleImpact();
        playerManager.player.isFinale = true;
        float playerAngle = utils.angleOf(utils.ZERO_VECTOR, playerManager.player.localPos());
        if (utils.unsignedAngleDiff(bigOneAngle, playerAngle) < IMPACT_HIT_ANGLE) {
          playerManager.bigOneKill();
        }
        progress = 0;
      }
      break;

    case EXPLODING:
      progress = (millis() - explosionsStart) / EXPLOSIONS_DURATION;
      if (progress < 1) {
        if (playerManager.player != null) {
          killAngle = bigOneAngle + IMPACT_HIT_ANGLE + (explosionTrailAngle * progress - ((explosionTrailAngle * progress) % explosionSlice)) + explosionSlice/2;
          float playerAngle = utils.angleOf(utils.ZERO_VECTOR, playerManager.player.globalPos());
          if (utils.unsignedAngleDiff(bigOneAngle + 180, killAngle) > 22) {
            if (utils.unsignedAngleDiff(bigOneAngle + 180, killAngle) < utils.unsignedAngleDiff(bigOneAngle + 180, playerAngle)) {
              playerManager.bigOneKill();
            }
          }
        }
        if (progress > .5 && progress < .9) {
          float p = map(progress, .5, .9, 0, 1);
          p = utils.easeOutQuad(p, 0, 1-0, 1);
          float fromEarthToUFO = utils.angleOfRadians(utils.ZERO_VECTOR, new PVector(HEIGHT_REF_HALF, HEIGHT_REF_HALF));
          finalUFO.setPosition(HEIGHT_REF_HALF + 50 + cos(fromEarthToUFO + PI) * p * finalUFO.TRAVEL_DIST, HEIGHT_REF_HALF + 50 + sin(fromEarthToUFO + PI) * p * finalUFO.TRAVEL_DIST);
        }
      } else {
        if (playerManager.player != null) {
          state = RESCUING;
          // won the game
          rescueStart = millis();
          dummyBronto = new Entity();
          dummyBronto.setPosition(playerManager.player.globalPos());
          dummyBronto.r = playerManager.player.globalRote();
          dummyBrontoStartPos = playerManager.player.globalPos();
          dummyBronto.facing = playerManager.player.facing;
          playerManager.removePlayerNotKill();
        } else {
          state = ABORT;
          abortStart = millis();
        }
      }
      break;

    case RESCUING:
      progress = (millis() - rescueStart) / 5e3;
      if (progress < 1) {
        dummyBronto.setPosition(PVector.lerp(dummyBrontoStartPos, finalUFO.globalPos(), progress));
        dummyBronto.scale = map(progress, 0, 1, 1, .1);
        //cam.setPosition(PVector.lerp(utils.ZERO_VECTOR, finalUFO.globalPos(), progress));
      } else {
        state = PULLING_AWAY;

        earth.zoomAway();
        time.timeScale = 1;
        earth.state = earth.ZOOMING;
        stateStart = millis();
        earth.dr = settings.getFloat("earthRotationSpeed", Earth.DEFAULT_EARTH_ROTATION);
        finalUFO.model = assets.ufostuff.ufoFinalDuo;
      }
      break;

    case PULLING_AWAY: 
      progress = (millis() - stateStart) / 6e3;
      if (progress < 1) {
        float away = utils.angleOfRadians(utils.ZERO_VECTOR, new PVector(-HEIGHT_REF_HALF, -HEIGHT_REF_HALF/2));
        earth.x += cos(away) * 4;
        earth.y += sin(away) * 4;
        finalUFO.x += cos(away) * .25;
        finalUFO.y += sin(away) * .25;
        finalUFO.scale = map(progress, 0, 1, finalUFO.START_SCALE, finalUFO.FINAL_SCALE);
        //earth.scale += .001;
      } else {
        state = ZOOMING;
        starManager.startZooming();
        finalUFO.finalUFOStablePosition = new PVector(finalUFO.x, finalUFO.y);
        finalUFO.model = assets.ufostuff.ufoFinalDuoZoom;
      }
      break;

    case ZOOMING:
      progress = (millis() - stateStart) / StarManager.zoomSpeedupDuration;
      float shake = progress < 1 ? map(progress, 0, 1, finalUFO.MIN_SHAKE, finalUFO.MAX_SHAKE) : finalUFO.MAX_SHAKE; 
      finalUFO.x = finalUFO.finalUFOStablePosition.x + (noise(cos(float(frameCount)/37)) * 2 - 1) * shake;
      finalUFO.y = finalUFO.finalUFOStablePosition.y + (noise(sin(float(frameCount)/53)) * 2 - 1) * shake;
      break;

    case ABORT:
      progress = (millis() - abortStart) / 5e3;
      if (progress < 1) {
        float fromEarthToUFO = utils.angleOfRadians(utils.ZERO_VECTOR, new PVector(HEIGHT_REF_HALF, HEIGHT_REF_HALF));
        finalUFO.x += cos(fromEarthToUFO) * 2;
        finalUFO.y += sin(fromEarthToUFO) * 2;
        //finalUFO.setPosition(HEIGHT_REF_HALF + 50 + cos(fromEarthToUFO + PI) * p * FINAL_UFO_TRAVEL_DIST, HEIGHT_REF_HALF + 50 + sin(fromEarthToUFO + PI) * p * FINAL_UFO_TRAVEL_DIST);
      } else {
        state = DONE;
      }
      break;


    case DONE:
      break;
    }
  }

  void render () {

    if (!isFinale) return;

    switch(state) {
    case INCOMING:
      bigone.simpleRenderImage(assets.roidStuff.bigone);
      break;

    case EXPLODING:
      if (frameCount % FLICKER_RATE > FLICKER_RATE / 2) bigone.simpleRenderImage(assets.roidStuff.bigone);      

      // debug kill angle
      //pushStyle();
      //fill(30, 70, 80);
      //circle(cos(radians(killAngle)) * Earth.EARTH_RADIUS, sin(radians(killAngle)) * Earth.EARTH_RADIUS, 20);
      //popStyle();

      pushMatrix();
      translate(earth.globalPos().x, earth.globalPos().y);
      progress = (millis() - explosionsStart) / EXPLOSIONS_DURATION;
      for (float i = 0; i < NUM_EXPLOSIONS - 1; i++) {
        if (i/float(NUM_EXPLOSIONS) > progress) { 
          break;
        }
        pushMatrix();
        translate(explosionRing.get(int(i)).x, explosionRing.get(int(i)).y);
        rotate(radians(explosionRing.get(int(i)).z));
        image(assets.roidStuff.explosionFrames[0], 0, 0);
        popMatrix();

        pushMatrix();
        translate(explosionRing2.get(int(i)).x, explosionRing2.get(int(i)).y);
        rotate(radians(explosionRing2.get(int(i)).z));
        image(assets.roidStuff.explosionFrames[0], 0, 0);
        popMatrix();
      }
      popMatrix();
      break;

    case RESCUING:

      bigone.simpleRenderImage(assets.roidStuff.bigone);

      // explosions
      pushMatrix();
      translate(earth.globalPos().x, earth.globalPos().y);
      for (float i = 0; i < NUM_EXPLOSIONS; i++) {
        //if (i/float(NUM_EXPLOSIONS) > progress) { 
        //  break;
        //}
        pushMatrix();
        translate(explosionRing.get(int(i)).x, explosionRing.get(int(i)).y);
        rotate(radians(explosionRing.get(int(i)).z));
        image(assets.roidStuff.explosionFrames[0], 0, 0);
        popMatrix();

        pushMatrix();
        translate(explosionRing2.get(int(i)).x, explosionRing2.get(int(i)).y);
        rotate(radians(explosionRing2.get(int(i)).z));
        image(assets.roidStuff.explosionFrames[0], 0, 0);
        popMatrix();
      }
      popMatrix();

      // UFO beam
      pushStyle();
      noFill();
      //fill(0,0,0,1);
      strokeWeight(assets.STROKE_WIDTH);
      stroke(0, 0, 100, 1);
      //stroke(currentColor.getColor());
      float angle = degrees(atan2(0 - finalUFO.y, 0 - finalUFO.x));
      line(finalUFO.x, finalUFO.y, finalUFO.x + cos(radians(angle + UFO.maxBeamWidth)) * 250, finalUFO.y + sin(radians(angle + UFO.maxBeamWidth)) * 250);
      line(finalUFO.x, finalUFO.y, finalUFO.x + cos(radians(angle - UFO.maxBeamWidth)) * 250, finalUFO.y + sin(radians(angle - UFO.maxBeamWidth)) * 250);
      popStyle();

      // DINO ABDUCTING
      pushMatrix();
      pushStyle();
      noFill();
      stroke(0, 0, 100, 1);
      strokeWeight(assets.STROKE_WIDTH / constrain(dummyBronto.scale, .1, 1));
      //strokeWeight(assets.STROKE_WIDTH * assets.playerStuff.brontoSVG.width/lilBrontoSize);
      scale(dummyBronto.facing, 1);
      //scale(dummyBronto.facing * .5, .5);
      translate(dummyBronto.x * dummyBronto.facing, dummyBronto.y);
      rotate(radians(dummyBronto.r * dummyBronto.facing));
      //scale(.25);
      scale(constrain(dummyBronto.scale, .1, 1));
      shapeMode(CENTER);      
      shape(assets.playerStuff.brontoSVG, 0, 0);
      //shape(assets.playerStuff.brontoSVG, 0, 0, lilBrontoSize, lilBrontoSize * (assets.playerStuff.brontoSVG.height/assets.playerStuff.brontoSVG.width));
      popMatrix();
      popStyle();

      break;

    case ABORT:

      bigone.simpleRenderImage(assets.roidStuff.bigone);

      // explosions
      pushMatrix();
      translate(earth.globalPos().x, earth.globalPos().y);
      for (float i = 0; i < NUM_EXPLOSIONS - 1; i++) {
        pushMatrix();
        translate(explosionRing.get(int(i)).x, explosionRing.get(int(i)).y);
        rotate(radians(explosionRing.get(int(i)).z));
        image(assets.roidStuff.explosionFrames[0], 0, 0);
        popMatrix();

        pushMatrix();
        translate(explosionRing2.get(int(i)).x, explosionRing2.get(int(i)).y);
        rotate(radians(explosionRing2.get(int(i)).z));
        image(assets.roidStuff.explosionFrames[0], 0, 0);
        popMatrix();
      }
      popMatrix();

      break;

    case PULLING_AWAY:
      bigone.simpleRenderImage(assets.roidStuff.bigone);

      // explosions
      //pushMatrix();
      //translate(earth.globalPos().x, earth.globalPos().y);
      //for (float i = 0; i < NUM_EXPLOSIONS - 1; i++) {
      //  pushMatrix();
      //  translate(explosionRing.get(int(i)).x, explosionRing.get(int(i)).y);
      //  rotate(radians(explosionRing.get(int(i)).z));
      //  image(assets.roidStuff.explosionFrames[0], 0, 0);
      //  popMatrix();

      //  pushMatrix();
      //  translate(explosionRing2.get(int(i)).x, explosionRing2.get(int(i)).y);
      //  rotate(radians(explosionRing2.get(int(i)).z));
      //  image(assets.roidStuff.explosionFrames[0], 0, 0);
      //  popMatrix();
      //}
      //popMatrix();

      break;

    case ZOOMING:

      bigone.simpleRenderImage(assets.roidStuff.bigone);

      // explosions
      pushMatrix();
      translate(earth.globalPos().x, earth.globalPos().y);
      for (float i = 0; i < NUM_EXPLOSIONS; i++) {
        pushMatrix();
        translate(explosionRing.get(int(i)).x, explosionRing.get(int(i)).y);
        rotate(radians(explosionRing.get(int(i)).z));
        image(assets.roidStuff.explosionFrames[0], 0, 0);
        popMatrix();

        pushMatrix();
        translate(explosionRing2.get(int(i)).x, explosionRing2.get(int(i)).y);
        rotate(radians(explosionRing2.get(int(i)).z));
        image(assets.roidStuff.explosionFrames[0], 0, 0);
        popMatrix();
      }
      popMatrix();
      break;

    case DONE:
      bigone.simpleRenderImage(assets.roidStuff.bigone);
      break;
    }

    if (state!=INCOMING) {
      pushStyle();
      fill(0, 0, 0, 1);
      strokeWeight(assets.STROKE_WIDTH / finalUFO.scale);
      stroke(0, 0, 100, 1);
      //finalUFO.pushTransforms();
      finalUFO.simpleRenderImage(finalUFO.model);
      //popMatrix();
      popStyle();
    }
  }

  void finaleHandle() {
    //isFinale = true;
    //bigoneStart = millis();
  }
  void finaleTrexHandled(PVector _) {
    isFinale = true;
    bigoneStart = millis();
  }

  void finaleImpact() {
  }
  void finaleClose () {}
}
