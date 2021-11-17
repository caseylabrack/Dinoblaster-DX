class FinaleStuff implements gameFinaleEvent, updateable, renderable {

  final int STEPS_TOWARD_EARTH = 4;
  final int FLICKER_RATE = 16;
  final float IMPACT_HIT_ANGLE = 45;

  Entity bigone;

  boolean isFinale = false;

  final static float BIG_ONE_INCOMING_DURATION = 1e3;//6e3;
  float bigoneStart;
  int lastBeep = -1;
  float steplength, fromEarthToRoid, progress;

  final float EXPLOSIONS_DURATION = 10e3;
  float explosionsStart;

  final int INCOMING = 1;
  final int EXPLODING = 2;
  final int DONE = 3;
  int state = INCOMING;

  EventManager eventManager;
  Earth earth;
  PlayerManager playerManager;

  float bigOneAngle;
  float explosionTrailAngle;
  float explosionSlice;
  float killAngle;

  final int NUM_EXPLOSIONS = 9;
  ArrayList<PVector> explosionRing = new ArrayList<PVector>(NUM_EXPLOSIONS);
  ArrayList<PVector> explosionRing2 = new ArrayList<PVector>(NUM_EXPLOSIONS);

  FinaleStuff(EventManager eventManager, Earth earth, PlayerManager playerManager) {
    this.eventManager = eventManager;
    eventManager.gameFinaleSubscribers.add(this);

    this.playerManager = playerManager;

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
          if (utils.unsignedAngleDiff(bigOneAngle + 180, killAngle) < utils.unsignedAngleDiff(bigOneAngle + 180, playerAngle)) {
            playerManager.bigOneKill();
          }
        }
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
      for (float i = 0; i < NUM_EXPLOSIONS; i++) {
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
}
