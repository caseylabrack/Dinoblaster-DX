class FinaleStuff implements gameFinaleEvent, updateable, renderable {

  final int STEPS_TOWARD_EARTH = 4;
  final int FLICKER_RATE = 16;

  Entity bigone;

  boolean isFinale = false;

  final float BIG_ONE_INCOMING_DURATION = 6e3;
  float bigoneStart;
  int lastBeep = -1;
  float steplength, fromEarthToRoid, progress;

  final int INCOMING = 1;
  final int IMPACTING = 2;
  int state = INCOMING;

  EventManager eventManager;
  Earth earth;

  FinaleStuff(EventManager eventManager, Earth earth) {
    this.eventManager = eventManager;
    eventManager.gameFinaleSubscribers.add(this);

    bigone = new Entity();
    bigone.setPosition(-HEIGHT_REF_HALF, -HEIGHT_REF_HALF);

    fromEarthToRoid = utils.angleOfRadians(utils.ZERO_VECTOR, bigone.globalPos());
    float impactX = cos(fromEarthToRoid) * Earth.EARTH_RADIUS;
    float impactY = sin(fromEarthToRoid) * Earth.EARTH_RADIUS;
    float dist = dist(bigone.globalPos().x, bigone.globalPos().y, impactX, impactY);
    steplength = dist / float(STEPS_TOWARD_EARTH);
    this.earth = earth;
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
        state = IMPACTING;
      }
      break;

    case IMPACTING:
      earth.addChild(bigone);
      break;
    }
  }

  void render () {

    if (!isFinale) return;

    switch(state) {
    case INCOMING:
      bigone.simpleRenderImage(assets.roidStuff.bigone);
      break;

    case IMPACTING:
      if (frameCount % FLICKER_RATE > FLICKER_RATE / 2) bigone.simpleRenderImage(assets.roidStuff.bigone);
      break;
    }
  }

  void finaleHandle() {
    isFinale = true;
    bigoneStart = millis();
  }
}
