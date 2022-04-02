class SPFinale {
  final static int NOT_FINALE = 0;
  final static int NO_TREX = -1;
  final static int WAITING_TREX = 1;
  final static int ALIGNING_TREX = 2;
  final static int INCOMING = 3;
  final static int EXPLODING = 4;
  final static int RESCUING = 5;
  final static int ABORT = 6;
  final static int PULLING_AWAY = 7;
  final static int ZOOMING = 8;
  final static int FADING = 9;
  final static int DONE = 10;
  int state = NOT_FINALE;
  int lastState = NOT_FINALE;

  Entity bigOne;
  boolean displayBigOne = false;

  final int STEPS_TOWARD_EARTH = 3;
  final int FLICKER_RATE = 16;
  final float IMPACT_HIT_ANGLE = 45;

  float incomingAngle;
  float fromEarthToRoid;
  float waitingRange = 45;
  float stateStart;

  final static float ALIGNING_DURATION = 1e3;
  float earthStartAlignR;
  float earthEndAlignR;

  final static float BIG_ONE_INCOMING_DURATION = 4e3;
  float steplength;
  int lastBeep = -1;

  final int NUM_EXPLOSIONS = 9;
  Explosion[] ring1 = new Explosion[NUM_EXPLOSIONS];
  ArrayList<PVector> explosionRing = new ArrayList<PVector>(NUM_EXPLOSIONS);
  ArrayList<PVector> explosionRing2 = new ArrayList<PVector>(NUM_EXPLOSIONS);
  float bigOneAngle;
  float explosionTrailAngle;
  float explosionSlice;
  float killAngle;
  final float EXPLOSIONS_DURATION = 10e3;

  boolean died = false;
  boolean won = false;

  FinalUFO finalUFO;
  Entity dummyBronto;
  PVector dummyBrontoStartPos;  

  final float FADING_DURATION = 6e3;
  PVector fadingStartPos;


  SPFinale (PImage bigOneModel, PImage[] frames, PShape[] finaleUFOFrames, PShape abducteeModel) {

    incomingAngle = utils.angleOf(utils.ZERO_VECTOR, new PVector(-HEIGHT_REF_HALF, -HEIGHT_REF_HALF));

    bigOne = new Entity();
    bigOne.model = bigOneModel;
    bigOne.setPosition(-HEIGHT_REF_HALF, -HEIGHT_REF_HALF);

    finalUFO = new FinalUFO();
    finalUFO.setPosition(HEIGHT_REF_HALF + 50, HEIGHT_REF_HALF + 50);
    finalUFO.scale = finalUFO.START_SCALE;
    finalUFO.modelVector = finaleUFOFrames[0];
    finalUFO.frames = finaleUFOFrames;

    dummyBronto = new Entity();
    dummyBronto.modelVector = abducteeModel;

    fromEarthToRoid = utils.angleOfRadians(utils.ZERO_VECTOR, bigOne.globalPos());
    float impactX = cos(fromEarthToRoid) * Earth.EARTH_RADIUS;
    float impactY = sin(fromEarthToRoid) * Earth.EARTH_RADIUS;
    float dist = dist(bigOne.globalPos().x, bigOne.globalPos().y, impactX, impactY);
    steplength = dist / float(STEPS_TOWARD_EARTH);

    bigOneAngle = utils.angleOf(utils.ZERO_VECTOR, bigOne.globalPos()); // angle does not change (big one only moves toward earth)
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

    //float startAngle = bigOneAngle + IMPACT_HIT_ANGLE;
    //float endAngle = bigOneAngle + 180 - 11;
    //float diff = utils.signedAngleDiff(startAngle,endAngle);
    //float a;
    //println(startAngle, endAngle, diff);
    //for(int i = 0; i < NUM_EXPLOSIONS; i++) {
    //  ring1[i] = new Explosion();
    //  ring1[i].model = frames[0];
    //  ring1[i].frames = frames;

    //  a = startAngle + diff * (float(i) / float(NUM_EXPLOSIONS));
    //  println(float(i) / float(NUM_EXPLOSIONS));
    //  ring1[i].x = cos(radians(a)) * Earth.EARTH_RADIUS;
    //  ring1[i].y = sin(radians(a)) * Earth.EARTH_RADIUS;
    //  ring1[i].r = a + 90;
    //}
  }

  void update(Earth earth, Trex trex, Player player, Time time) {
    //if (state == NOT_FINALE) return; 

    lastState = state;

    float progress;

    switch(state) {
    case NOT_FINALE:
      return;

    case NO_TREX:
      earthStartAlignR = earth.r;
      earthEndAlignR = earth.r + 45;
      state = ALIGNING_TREX;
      stateStart = millis();
      earth.dr = 0;
      break;

    case WAITING_TREX:
      float trexAngle = utils.angleOf(utils.ZERO_VECTOR, trex.globalPos());
      float diff = utils.unsignedAngleDiff(incomingAngle, trexAngle);
      float signedDiff = utils.signedAngleDiff(incomingAngle, trexAngle);
      if (signedDiff > -45 && signedDiff < 0) {
        state = ALIGNING_TREX;
        stateStart = millis();
        earth.dr = 0;
        earthStartAlignR = earth.r;
        earthEndAlignR = earth.r + diff;
      }
      break;

    case ALIGNING_TREX:
      progress = (millis() - stateStart) / ALIGNING_DURATION;
      if (progress < 1) {
        earth.r = earthStartAlignR + (earthEndAlignR - earthStartAlignR) * progress;
        time.setTimeScale(constrain(1-progress, .1, 1));
      } else {
        state = INCOMING;
        stateStart = millis();
      }
      break;

    case INCOMING:
      progress = (millis() - stateStart) / BIG_ONE_INCOMING_DURATION;
      if (progress < 1) {
        float currentStep = floor(progress * STEPS_TOWARD_EARTH);
        float travelDist = steplength * currentStep;
        if (currentStep > lastBeep + .001) {
          lastBeep = int(currentStep);
          assets.roidStuff.bigoneBlip.play();
        }
        bigOne.setPosition(-HEIGHT_REF_HALF + cos(radians(incomingAngle) + PI) * travelDist, -HEIGHT_REF_HALF + sin(radians(incomingAngle) + PI) * travelDist);
        displayBigOne = true;
      } else {
        bigOne.setPosition(earth.x + cos(radians(incomingAngle)) * Earth.EARTH_RADIUS, earth.y + sin(radians(incomingAngle)) * Earth.EARTH_RADIUS);
        assets.roidStuff.bigoneBlip.play();
        earth.addChild(bigOne);
        state = EXPLODING;
        stateStart = millis();
      }
      break;

    case EXPLODING:
      earth.shake(20);
      if (frameCount % FLICKER_RATE > FLICKER_RATE / 2) displayBigOne = !displayBigOne;
      progress = (millis() - stateStart) / EXPLOSIONS_DURATION;
      if (progress <1) {
        killAngle = bigOneAngle + IMPACT_HIT_ANGLE + (explosionTrailAngle * progress - ((explosionTrailAngle * progress) % explosionSlice)) + explosionSlice/2;
        float playerAngle = utils.angleOf(utils.ZERO_VECTOR, player.globalPos());
        if (utils.unsignedAngleDiff(bigOneAngle + 180, killAngle) > 22) {
          if (utils.unsignedAngleDiff(bigOneAngle + 180, killAngle) < utils.unsignedAngleDiff(bigOneAngle + 180, playerAngle)) {
            died = true; // player died in the finale
          }
        }
        if (progress > .5 && progress < .9) {
          float p = map(progress, .5, .9, 0, 1);
          p = utils.easeOutQuad(p, 0, 1-0, 1);
          float fromEarthToUFO = utils.angleOfRadians(utils.ZERO_VECTOR, new PVector(HEIGHT_REF_HALF, HEIGHT_REF_HALF));
          finalUFO.setPosition(HEIGHT_REF_HALF + 50 + cos(fromEarthToUFO + PI) * p * finalUFO.TRAVEL_DIST, HEIGHT_REF_HALF + 50 + sin(fromEarthToUFO + PI) * p * finalUFO.TRAVEL_DIST);
        }
      } else {
        displayBigOne = true;
        if (!died) { 
          won = true; // player won
          state = RESCUING;
          stateStart = millis();
          dummyBronto.setPosition(player.globalPos());
          dummyBronto.r = player.globalRote();
          dummyBrontoStartPos = player.globalPos();
          dummyBronto.facing = player.facing;
        } else {
          state = ABORT;
          stateStart = millis();
        }
      }
      break;

    case ABORT:
      progress = (millis() - stateStart) / 5e3;
      if (progress < 1) {
        float fromEarthToUFO = utils.angleOfRadians(utils.ZERO_VECTOR, new PVector(HEIGHT_REF_HALF, HEIGHT_REF_HALF));
        finalUFO.x += cos(fromEarthToUFO) * 2;
        finalUFO.y += sin(fromEarthToUFO) * 2;
      } else {
        state = DONE;
      }
      break;

    case RESCUING:
      progress = (millis() - stateStart) / 5e3;
      if (progress < 1) {
        dummyBronto.setPosition(PVector.lerp(dummyBrontoStartPos, finalUFO.globalPos(), progress));
        dummyBronto.scale = map(progress, 0, 1, 1, .1);
      } else {
        state = PULLING_AWAY;
        stateStart = millis();
        finalUFO.modelVector = finalUFO.frames[1];
      }
      break;

    case PULLING_AWAY: 
      progress = (millis() - stateStart) / 6e3;
      if (progress < 1) {
        float away = utils.angleOfRadians(utils.ZERO_VECTOR, new PVector(-HEIGHT_REF_HALF, -HEIGHT_REF_HALF/2));
        //earth.x += cos(away) * 4;
        //earth.y += sin(away) * 4;
        finalUFO.x += cos(away) * .25;
        finalUFO.y += sin(away) * .25;
        finalUFO.scale = map(progress, 0, 1, finalUFO.START_SCALE, finalUFO.FINAL_SCALE);
      } else {
        state = ZOOMING;
        stateStart = millis();
        finalUFO.finalUFOStablePosition = new PVector(finalUFO.x, finalUFO.y);
        finalUFO.modelVector = finalUFO.frames[2];
      }
      break;

    case ZOOMING:
      progress = (millis() - stateStart) / (StarsSystem.zoomSpeedupDuration + 4e3);
      if (progress < 1) {
        float shake = progress < 1 ? map(progress, 0, 1, finalUFO.MIN_SHAKE, finalUFO.MAX_SHAKE) : finalUFO.MAX_SHAKE; 
        finalUFO.x = finalUFO.finalUFOStablePosition.x + (noise(cos(float(frameCount)/37)) * 2 - 1) * shake;
        finalUFO.y = finalUFO.finalUFOStablePosition.y + (noise(sin(float(frameCount)/53)) * 2 - 1) * shake;
      } else {
        stateStart = millis();
        state = FADING;
        fadingStartPos = finalUFO.globalPos();
      }
      break;

    case FADING:
      progress = (millis() - stateStart) / FADING_DURATION;
      if (progress < 1) {
        finalUFO.setPosition(PVector.lerp(fadingStartPos, utils.ZERO_VECTOR, progress)); // zoom away toward middle of screen
        finalUFO.x += (noise(cos(float(frameCount)/37)) * 2 - 1) * (1 - progress) * 20; // add some shake
        finalUFO.y += (noise(sin(float(frameCount)/53)) * 2 - 1) * (1 - progress) * 20; // add some shake
        finalUFO.scale = map(progress, 0, 1, finalUFO.FINAL_SCALE, .001);
      } else {
        state = DONE;
      }
      break;

    case DONE:

      break;
    }
  }

  void renderBigOne () {
    if(state == NOT_FINALE) return;
    if (displayBigOne) bigOne.simpleRenderImage();
  }

  void render(Earth earth) {

    switch(state) {

    case NOT_FINALE:
      return;

    case EXPLODING:
      pushMatrix();
      translate(earth.globalPos().x, earth.globalPos().y);
      float progress = (millis() - stateStart) / EXPLOSIONS_DURATION;
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

      // UFO beam
      pushStyle();
      noFill();
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
      dummyBronto.simpleRenderImageVector();
      popStyle();
      popMatrix();
      break;
    }

    if (state!=INCOMING && state != DONE) {
      pushStyle();
      fill(0, 0, 0, 1);
      stroke(0, 0, 100, 1);
      finalUFO.simpleRenderImageVector();
      popStyle();
    }
  }

  void restart() {
    state = NOT_FINALE;
    bigOne.setPosition(-HEIGHT_REF_HALF, -HEIGHT_REF_HALF);
    died = false;
    won = false;
    finalUFO.modelVector = finalUFO.frames[0];
    bigOne.parent = null;
  }
}

class FinalUFO extends Entity {
  PVector finalUFOStablePosition;
  final float MIN_SHAKE = 0;
  final float MAX_SHAKE = 100;
  final float TRAVEL_DIST = 250;
  final float FINAL_SCALE = .9;
  final float START_SCALE = .1;
  PShape[] frames;
}
