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
  final static int ROLL_CREDITS = 10;
  final static int DONE = 11;
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

  boolean p1Died = false;
  boolean p2Died = false;
  boolean won = false;

  FinalUFO finalUFO;
  Entity dummyBronto1;
  PVector dummyBrontoStartPos1;  

  Entity dummyBronto2;
  PVector dummyBrontoStartPos2;  

  final float FADING_DURATION = 6e3;
  PVector fadingStartPos;

  PFont thanksFont;
  String thanksMessage = "";

  SPFinale (PImage bigOneModel, PShape[] finaleUFOFrames, PShape abducteeModel) {

    incomingAngle = utils.angleOf(utils.ZERO_VECTOR, new PVector(-HEIGHT_REF_HALF, -HEIGHT_REF_HALF));

    bigOne = new Entity();
    bigOne.model = bigOneModel;
    bigOne.setPosition(-HEIGHT_REF_HALF, -HEIGHT_REF_HALF);

    finalUFO = new FinalUFO();
    finalUFO.setPosition(HEIGHT_REF_HALF + 50, HEIGHT_REF_HALF + 50);
    finalUFO.scale = finalUFO.START_SCALE;
    finalUFO.modelVector = finaleUFOFrames[0];
    finalUFO.frames = finaleUFOFrames;

    dummyBronto1 = new Entity();
    dummyBronto1.modelVector = abducteeModel;

    dummyBronto2 = new Entity();
    dummyBronto2.modelVector = abducteeModel;

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

    thanksFont = assets.uiStuff.MOTD;
  }

  void update(Earth earth, Trex trex, Player[] ps, Time time) {
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
        //time.setTimeScale(constrain(1-progress, .1, 1));
        time.timeScale = constrain(1-progress, .1, 1);
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
        for (Player player : ps) {
          killAngle = bigOneAngle + IMPACT_HIT_ANGLE + (explosionTrailAngle * progress - ((explosionTrailAngle * progress) % explosionSlice)) + explosionSlice/2;
          float playerAngle = utils.angleOf(utils.ZERO_VECTOR, player.globalPos());
          if (utils.unsignedAngleDiff(bigOneAngle + 180, killAngle) > 22) {
            if (utils.unsignedAngleDiff(bigOneAngle + 180, killAngle) < utils.unsignedAngleDiff(bigOneAngle + 180, playerAngle)) {
              //died = true; // player died in the finale
              if (player.id == 0) {
                p1Died = true;
              } else {
                p2Died = true;
              }
            }
          }
          if (progress > .5 && progress < .9) {
            float p = map(progress, .5, .9, 0, 1);
            p = utils.easeOutQuad(p, 0, 1-0, 1);
            float fromEarthToUFO = utils.angleOfRadians(utils.ZERO_VECTOR, new PVector(HEIGHT_REF_HALF, HEIGHT_REF_HALF));
            finalUFO.setPosition(HEIGHT_REF_HALF + 50 + cos(fromEarthToUFO + PI) * p * finalUFO.TRAVEL_DIST, HEIGHT_REF_HALF + 50 + sin(fromEarthToUFO + PI) * p * finalUFO.TRAVEL_DIST);
          }
        }
      } else {
        displayBigOne = true;
        //if (!died) { 
        if (p1Died==false || p2Died==false) {
          won = true; // player won
          state = RESCUING;
          stateStart = millis();
          if (p1Died==false) {
            dummyBronto1.setPosition(ps[0].globalPos());
            dummyBronto1.r = ps[0].globalRote();
            dummyBrontoStartPos1 = ps[0].globalPos();
            dummyBronto1.facing = ps[0].facing;
          }
          if (p2Died==false) {
            dummyBronto2.setPosition(ps[1].globalPos());
            dummyBronto2.r = ps[1].globalRote();
            dummyBrontoStartPos2 = ps[1].globalPos();
            dummyBronto2.facing = ps[1].facing;
          }
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
        if (!p1Died) {
          dummyBronto1.setPosition(PVector.lerp(dummyBrontoStartPos1, finalUFO.globalPos(), progress));
          dummyBronto1.scale = map(progress, 0, 1, 1, .1);
        }
        if (!p2Died) {
          dummyBronto2.setPosition(PVector.lerp(dummyBrontoStartPos2, finalUFO.globalPos(), progress));
          dummyBronto2.scale = map(progress, 0, 1, 1, .1);
        }
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
        state = ROLL_CREDITS;
        stateStart = millis();
      }
      break;

    case ROLL_CREDITS: 
      progress = (millis() - stateStart) / 2e3;
      if(progress > 1) {
       thanksMessage = "Thanks for playing!\n\nSpecial thanks:\nSara Bennett\nJeff Labrack\nJonathan Lauffer"; 
      }
      break;

    case DONE:

      break;
    }
  }

  void renderBigOne () {
    if (state == NOT_FINALE) return;
    if (displayBigOne) bigOne.simpleRenderImage();
  }

  void render(Earth earth) {

    switch(state) {

    case NOT_FINALE:
      return;

    case EXPLODING:
      sb.pushMatrix();
      sb.translate(earth.globalPos().x, earth.globalPos().y);
      float progress = (millis() - stateStart) / EXPLOSIONS_DURATION;
      for (float i = 0; i < NUM_EXPLOSIONS - 1; i++) {
        if (i/float(NUM_EXPLOSIONS) > progress) { 
          break;
        }
        sb.pushMatrix();
        sb.translate(explosionRing.get(int(i)).x, explosionRing.get(int(i)).y);
        sb.rotate(radians(explosionRing.get(int(i)).z));
        sb.image(assets.roidStuff.explosionFrames[0], 0, 0);
        sb.popMatrix();

        sb.pushMatrix();
        sb.translate(explosionRing2.get(int(i)).x, explosionRing2.get(int(i)).y);
        sb.rotate(radians(explosionRing2.get(int(i)).z));
        sb.image(assets.roidStuff.explosionFrames[0], 0, 0);
        sb.popMatrix();
      }
      sb.popMatrix();
      break;

    case RESCUING:

      // explosions
      sb.pushMatrix();
      sb.translate(earth.globalPos().x, earth.globalPos().y);
      for (float i = 0; i < NUM_EXPLOSIONS; i++) {
        sb.pushMatrix();
        sb.translate(explosionRing.get(int(i)).x, explosionRing.get(int(i)).y);
        sb.rotate(radians(explosionRing.get(int(i)).z));
        sb.image(assets.roidStuff.explosionFrames[0], 0, 0);
        sb.popMatrix();

        sb.pushMatrix();
        sb.translate(explosionRing2.get(int(i)).x, explosionRing2.get(int(i)).y);
        sb.rotate(radians(explosionRing2.get(int(i)).z));
        sb.image(assets.roidStuff.explosionFrames[0], 0, 0);
        sb.popMatrix();
      }
      sb.popMatrix();

      // UFO beam
      sb.pushStyle();
      sb.noFill();
      sb.strokeWeight(assets.STROKE_WIDTH);
      sb.stroke(0, 0, 100, 1);
      //stroke(currentColor.getColor());
      float angle = degrees(atan2(0 - finalUFO.y, 0 - finalUFO.x));
      sb.line(finalUFO.x, finalUFO.y, finalUFO.x + cos(radians(angle + UFO.maxBeamWidth)) * 250, finalUFO.y + sin(radians(angle + UFO.maxBeamWidth)) * 250);
      sb.line(finalUFO.x, finalUFO.y, finalUFO.x + cos(radians(angle - UFO.maxBeamWidth)) * 250, finalUFO.y + sin(radians(angle - UFO.maxBeamWidth)) * 250);
      sb.popStyle();

      // DINO ABDUCTING
      if (!p1Died) {
        sb.pushMatrix();
        sb.pushStyle();
        sb.noFill();
        sb.stroke(0, 0, 100, 1);
        dummyBronto1.simpleRenderImageVector();
        sb.popStyle();
        sb.popMatrix();
      }
      if (!p2Died) {
        sb.pushMatrix();
        sb.pushStyle();
        sb.noFill();
        sb.stroke(0, 0, 100, 1);
        dummyBronto2.simpleRenderImageVector();
        sb.popStyle();
        sb.popMatrix();
      }
      break;
    }

    if (state!=INCOMING && state != DONE && state != ROLL_CREDITS) {
      sb.pushStyle();
      sb.fill(0, 0, 0, 1);
      sb.stroke(0, 0, 100, 1);
      finalUFO.simpleRenderImageVector();
      sb.popStyle();
    }

    sb.pushStyle();
    sb.textFont(thanksFont);
    sb.textAlign(CENTER, CENTER);
    sb.text(thanksMessage, 0, 0);
    sb.popStyle();
  }

  void restart() {
    state = NOT_FINALE;
    bigOne.setPosition(-HEIGHT_REF_HALF, -HEIGHT_REF_HALF);
    //died = false;
    p1Died = false;
    p2Died = false;
    won = false;
    finalUFO.setPosition(HEIGHT_REF_HALF + 50, HEIGHT_REF_HALF + 50);
    finalUFO.scale = finalUFO.START_SCALE;
    finalUFO.modelVector = finalUFO.frames[0];
    bigOne.parent = null;
    thanksMessage = "";
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
