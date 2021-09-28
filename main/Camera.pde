class Camera extends Entity implements updateable {

  public float magn = 0;
  private Entity following = null;

  Camera () {
  }

  void update () {

    dx = 0;
    dy = 0;
    //x = width/2;
    //y = height/2;

    //if (mousePressed) magn += 3;

    float angle = random(360);
    dx += cos(radians(angle)) * magn;
    dy += sin(radians(angle)) * magn;
    magn *= .9;

    //cute screenshake idea
    //float magnitude = 25;
    //float start = 0;
    //float duration = 120;
    //translate(
    //  camera.x + (frameCount - start < duration ? cos(frameCount % 360) * magnitude * pow((duration - frameCount - start) / duration, 5) : 0), 
    //  camera.y + (frameCount - start < duration ? sin(frameCount % 360) * magnitude * pow((duration - frameCount - start) / duration, 5) : 0)
    //  );

    x += dx;
    y += dy;
    r += dr;
  }
}


class ColorDecider implements updateable {
  private int currentHue = 0;
  private color[] hues = new color[]{#ff3800, #ffff00, #00ff00, #00ffff, #ff57ff};   // photoshop LAB
  //private color[] hues = new color[]{#FEA7DD,#ABC3FB,#4BD7E4,#5DDDA6,#ADD568,#F7C155}; // chroma.js
  //private color[] hues = new color[]{#926E9B,#5384A8,#009293,#3C9867,#7C953D,#B58834}; // chroma.js darker 

  void update () {
    currentHue = hues[utils.cycleRangeWithDelay(hues.length, 10, frameCount)];
  }

  color getColor () {
    return currentHue;
  }
}

class Time implements updateable, playerDiedEvent, gameOverEvent, nebulaEvents, gameFinaleEvent {

  private float clock;
  private float lastmillis;
  private float timeScale = 1;
  private long lastNanos;
  private float delta;
  private int tick;
  private float elapsed;

  private boolean dying = false;
  private float dyingStartTime;
  final float dyingDuration = 3e3;

  private boolean hyperspace = false;
  final static float HYPERSPACE_DEFAULT_TIME = 1.75;

  boolean isFinale = false;
  private float finaleStart;
  final static float FINALE_SLOWDOWN_TRANSITION = 3e3;
  final float FINALE_SLOWDOWN_START_VALUE = .25;
  final float FINALE_SLOWDOWN_END_VALUE = .05;

  EventManager eventManager;

  Time (EventManager ev) {
    eventManager = ev;

    eventManager.playerDiedSubscribers.add(this);
    eventManager.gameOverSubscribers.add(this);
    eventManager.nebulaStartSubscribers.add(this);
    eventManager.gameFinaleSubscribers.add(this);

    lastmillis = millis();
    //clock = millis();
    clock = 0;
  }

  void update () {

    tick++;

    elapsed = millis() - lastmillis;
    clock += elapsed * timeScale;
    //clock += (millis() - lastmillis) * timeScale;
    lastmillis = millis();

    delta = min((frameRateLastNanos - lastNanos)/1e6/16.6666, 2.5);
    //println("delta: " + delta);
    lastNanos = frameRateLastNanos;
    eventManager.playerDiedSubscribers.add(this);

    if (dying) {
      float progress = (millis() - dyingStartTime) / dyingDuration;
      float targetTimeScale = hyperspace ? HYPERSPACE_DEFAULT_TIME: 1;
      if (progress < 1) {
        timeScale = utils.easeInOutExpo(progress, .1, targetTimeScale - .1, targetTimeScale);
      } else {
        dying = false;
        timeScale = targetTimeScale;
      }
    }

    if (isFinale) {
      float progress = (millis() - finaleStart) / FINALE_SLOWDOWN_TRANSITION;
      if (progress < 1) {
        timeScale = utils.easeOutQuad(progress, FINALE_SLOWDOWN_START_VALUE, FINALE_SLOWDOWN_END_VALUE - FINALE_SLOWDOWN_START_VALUE, 1);
      }
    }
  }

  void finaleHandle () {
    isFinale = true;
  }

  void finaleTrexHandled (PVector _) {
    finaleStart = millis();
  }
  
  void finaleImpact() {}

  void nebulaStartHandle() {

    if (!hyperspace) {
      timeScale = settings.getFloat("hyperspaceTimeScale", HYPERSPACE_DEFAULT_TIME);
      hyperspace = true;
    }
  }

  void nebulaStopHandle() {

    hyperspace = false;
    if (!dying) { 
      timeScale = 1;
    }
  }

  void gameOverHandle() {
    dying = true;
    dyingStartTime = millis();
  }

  void playerDiedHandle(PVector position) {
    dying = true;
    dyingStartTime = millis();
  }

  public float getTimeScale () {
    //return timeScale; 
    return timeScale * delta;
  }
  public float getClock() {
    return clock;
  }
  public float getTick() {
    return tick;
  }

  public float getElapsed () {
    return elapsed;
  }

  public float getScaledElapsed () {
    return elapsed * timeScale;
  }
}

class MusicManager implements updateable, levelChangeEvent, gameOverEvent, nebulaEvents {

  final float START_DELAY = 2e3;
  float start;
  boolean playing = false;
  int lvl;
  SoundPlayable currentMusic;

  MusicManager (EventManager events, int lvl) {
    this.lvl = lvl;

    //assets.stopAllMusic();

    events.gameOverSubscribers.add(this);
    events.levelChangeSubscribers.add(this);
    events.nebulaStartSubscribers.add(this);

    start = millis();
  }

  void update() {
    if (playing) return;
    if (millis() - start > START_DELAY) {
      playing = true;
      chooseTrack();
    }
  }

  void chooseTrack () {
    switch(lvl) {
    case UIStory.TRIASSIC: 
      if (random(0, 1) < .5) {
        currentMusic = assets.musicStuff.lvl1a;
      } else {
        currentMusic = assets.musicStuff.lvl1b;
      }
      break;

    case UIStory.JURASSIC: 
      if (random(0, 1) < .5) {
        currentMusic = assets.musicStuff.lvl2a;
      } else {
        currentMusic = assets.musicStuff.lvl2b;
      }
      break;

    case UIStory.CRETACEOUS: 
      currentMusic = assets.musicStuff.lvl3;
      break;
    }
    currentMusic.play(true);
  }

  void nebulaStartHandle () {
    currentMusic.rate(settings.getFloat("hyperspaceTimeScale", Time.HYPERSPACE_DEFAULT_TIME));
  }

  void nebulaStopHandle() {
    currentMusic.rate(1);
  }

  void levelChangeHandle(int stage) {
    println("changed level");
    lvl = stage;
    currentMusic.stop_();
    chooseTrack();
  }

  void gameOverHandle() {
    assets.stopAllMusic();
  }
}
