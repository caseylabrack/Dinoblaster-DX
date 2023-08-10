class InGameText {

  boolean extinct = false;
  boolean showingTip = false;
  String tip;
  int tipIndex = 0;
  final float TIP_DURATION = 6e3;
  float tipStart;

  final float EXTINCT_FLICKER_RATE_START = 30;
  float extinctFlickerRate = EXTINCT_FLICKER_RATE_START;
  final float EXTINCT_FLICKERING_DURATION = 1900;
  float extinctFlickeringStart;
  float extinctLastFlicker;
  boolean extinctDisplay = false;

  PFont extinctFont;
  PFont tipFont;
  StringList tips = new StringList();

  InGameText (PFont extinctFont, PFont tipFont) {
    this.extinctFont = extinctFont;
    this.tipFont = tipFont;
  }

  void setTips (String[] tips) {
    this.tips.clear();
    for (int i = 0; i < tips.length; i++) this.tips.append(tips[i]);
    this.tips.shuffle();
    tipIndex = 0;
  }

  void goExtinct() {
    extinctFlickeringStart = millis();
    extinctLastFlicker = millis();
    //state = EXTINCT;
    extinct = true;
    extinctFlickerRate = EXTINCT_FLICKER_RATE_START;
  }

  void showRandomTip () {
    showingTip = true;
    tipStart = millis();
    tip = tips.get(tipIndex);

    tipIndex++;
    if (tipIndex > tips.size() - 1) {
      tips.shuffle();
      tipIndex = 0;
    }
  }

  void update() {
    if (!extinct && !showingTip) return;

    if (extinct) {
      if (millis() - extinctFlickeringStart < EXTINCT_FLICKERING_DURATION) {
        if (millis() - extinctLastFlicker > extinctFlickerRate) {
          extinctDisplay = !extinctDisplay;
          extinctLastFlicker = millis();
        }
      } else {
        extinctDisplay = true;
      }
    }

    if (showingTip) {
      if (millis() - tipStart > TIP_DURATION) showingTip = false;
    }
  }

  void render(color funkyColor) {
    if (!extinct && !showingTip) return;

    if (extinct) {
      pushStyle();
      fill(funkyColor);
      textFont(extinctFont);
      textAlign(CENTER, CENTER);

      if (extinctDisplay) text("EXTINCT", 15, -15);
      popStyle();
    }

    if (showingTip) {
      pushStyle();
      textFont(tipFont);
      textAlign(CENTER, CENTER);
      text(tip, 0, -HEIGHT_REF_HALF + 50);
      popStyle();
    }
  }

  void restart () {
    extinct = false;
    showingTip = false;
  }
}

class GameOver {
  float start;
  final static float DURATION = 5e3;
  boolean enabled = false;
  boolean readyToRestart = false;

  void restart () {
    enabled = false;
    readyToRestart = false;
  }

  void callGameover () {
    enabled = true;
    start = millis();
  }

  void update() {
    if (!enabled) return;
    if (millis() - start > DURATION) readyToRestart = true;
  }

  void render() {
    if (!enabled) return;
  }
}

class UIStory {
  final static String SCORE_DATA_FILENAME = "highscore.dat";

  int lives;
  boolean enabled = true;
  PImage letterbox;
  PImage screenShine;
  PImage buttons;
  boolean hideAll = false;
  boolean hideButtons = false;

  UIStory (PImage letterbox, PImage screenShine, PImage buttons) {
    this.letterbox = letterbox;
    this.screenShine = screenShine;
    this.buttons = buttons;
  }

  void render(int extralives, int score) {
    if (!enabled || hideAll) return;

    push();
    imageMode(CORNER);
    image(assets.uiStuff.progressBG, -WIDTH_REF_HALF + 40, -HEIGHT_REF_HALF);
    image(assets.uiStuff.extraDinosBG, WIDTH_REF_HALF - 100, -HEIGHT_REF_HALF);
    pop();

    image(extralives>=1 ? assets.uiStuff.extraDinoActive : assets.uiStuff.extraDinoInactive, WIDTH_REF_HALF - 65, -HEIGHT_REF_HALF + 75);
    image(extralives>=2 ? assets.uiStuff.extraDinoActive : assets.uiStuff.extraDinoInactive, WIDTH_REF_HALF - 65, -HEIGHT_REF_HALF + 75 + 75);
    image(extralives>=3 ? assets.uiStuff.extraDinoActive : assets.uiStuff.extraDinoInactive, WIDTH_REF_HALF - 65, -HEIGHT_REF_HALF + 75 + 75 + 75);

    push();
    //tint(0,60,99,1);
    imageMode(CENTER);
    float p = ((float)score)/300.0;
    float totalpixels = HEIGHT_REFERENCE - 80;
    float fillupto = p * totalpixels;
    float tickheight = 10;//assets.uiStuff.tick.height;
    for (int i = 0; i < fillupto; i+=tickheight) {
      image(assets.uiStuff.tick, -WIDTH_REF_HALF + 64, -HEIGHT_REF_HALF + 40 + i);
    }
    pop();

    image(screenShine, 0, 0);
    image(letterbox, 0, 0);
    if (!hideButtons) image(buttons, 0, 0);
  }
}

//class UIStory implements gameOverEvent, abductionEvent, playerDiedEvent, playerSpawnedEvent, playerRespawnedEvent, updateable, renderableScreen {
//  boolean isGameOver = false;
//  float gameOverGracePeriodStart;
//  final float gameOverGracePeriodDuration = 4e3;
//  int score = 0;

//  final static int TRIASSIC = 0;
//  final static int JURASSIC = 1;
//  final static int CRETACEOUS = 2;
//  final static int FINAL = 3;
//  int stage = TRIASSIC;

//  float lastScoreTick = 0;
//  boolean scoring = false;

//  EventManager eventManager;
//  ColorDecider currentColor;
//  Time time;

//  int extralives;
//  float extralifeAnimationStart = 0;
//  boolean extralifeAnimating = false;
//  float extralifeAnimationDuration = 5e3;

//  float highscore = 85;
//  boolean newHighScore = false;

//  final static String SCORE_DATA_FILENAME = "highscore.dat";
//  StringList motds;
//  int motdIndex = 0;
//  float motdStart;
//  final float MOTD_DURATION = 4e3;

//  boolean extinctDisplay = true;
//  final float EXTINCT_FLICKER_RATE_START = 100;
//  float extinctFlickerRate = 100;
//  final float EXTINCT_FLICKERING_DURATION = 3e3;
//  float extinctFlickeringStart;

//  boolean gameDone = false;

//  UIStory (EventManager _eventManager, Time t, ColorDecider _currentColor, int lvl) {
//    eventManager = _eventManager;
//    currentColor = _currentColor;
//    time = t;

//    stage = lvl;
//    score = constrain(lvl * 100, 0, 200);

//    lastScoreTick = time.getClock();

//    eventManager.gameOverSubscribers.add(this);
//    eventManager.abductionSubscribers.add(this);
//    eventManager.playerDiedSubscribers.add(this);
//    eventManager.playerSpawnedSubscribers.add(this);
//    eventManager.playerRespawnedSubscribers.add(this);

//    extralives = settings.getInt("extraLives", 0);

//    motdStart = millis();

//    highscore = loadHighScore(SCORE_DATA_FILENAME);
//  }

//  void gameOverHandle() {
//    isGameOver = true;
//    gameOverGracePeriodStart = millis();
//    if (score > highscore) {
//      saveHighScore(score, SCORE_DATA_FILENAME);
//    }
//  }

//  void playerSpawnedHandle(Player p) {
//    scoring = true;
//  }

//  void playerRespawnedHandle(PVector position) {
//    scoring = true;
//  }

//  void playerDiedHandle(PVector position) {
//    extralives--;
//    scoring = false;
//  }

//  void abductionHandle(PVector p) {
//    extralifeAnimationStart = time.getClock();
//    extralifeAnimating = true;
//    extralives++;
//    scoring = false;
//  }

//  public void setLevel (int lvl) {
//    stage = lvl;
//    score = lvl * 100;
//  }

//  void update () {
//    if (isGameOver) {
//      if (millis() - gameOverGracePeriodStart > gameOverGracePeriodDuration) {
//        if (keys.anykey) {
//          gameDone = true;
//        }
//      }
//      return;
//    }

//    if (!newHighScore) {
//      if (score > highscore) {
//        newHighScore = true;
//      }
//    }

//    if (time.getClock() - lastScoreTick > 1000 && scoring) {
//      score++;
//      //score+=20;
//      lastScoreTick = time.getClock();
//    }

//    if (score==100 && stage==TRIASSIC) {
//      stage = JURASSIC;
//      eventManager.dispatchLevelChanged(stage);
//    }

//    if (score==200 && stage==JURASSIC) {
//      stage = CRETACEOUS;
//      eventManager.dispatchLevelChanged(stage);
//    }

//    if (score == 290) {
//      eventManager.dispatchFinaleClose();
//    }

//    if (score >= 300 && stage == CRETACEOUS) {
//      stage = FINAL;
//      eventManager.dispatchGameFinale();
//      println("finale start");
//    }
//  }

//  void render () {

//    push();
//    imageMode(CORNER);
//    image(assets.uiStuff.progressBG, -WIDTH_REF_HALF + 40, -HEIGHT_REF_HALF);
//    image(assets.uiStuff.extraDinosBG, WIDTH_REF_HALF - 100, -HEIGHT_REF_HALF);
//    pop();

//    // score tracker
//    push();
//    //tint(0,60,99,1);
//    imageMode(CENTER);
//    float p = ((float)score)/300.0;
//    float totalpixels = HEIGHT_REFERENCE - 80;
//    float fillupto = p * totalpixels;
//    float tickheight = 10;//assets.uiStuff.tick.height;
//    for (int i = 0; i < fillupto; i+=tickheight) {
//      image(assets.uiStuff.tick, -WIDTH_REF_HALF + 64, -HEIGHT_REF_HALF + 40 + i);
//    }
//    pop();

//    // acrylics
//    pushStyle();
//    imageMode(CENTER);
//    pushMatrix();
//    image(assets.uiStuff.letterbox, 0, 0, assets.uiStuff.letterbox.width, HEIGHT_REFERENCE);
//    popMatrix();
//    popStyle();

//    image(extralives>=1 ? assets.uiStuff.extraDinoActive : assets.uiStuff.extraDinoInactive, WIDTH_REF_HALF - 65, -HEIGHT_REF_HALF + 75);
//    image(extralives>=2 ? assets.uiStuff.extraDinoActive : assets.uiStuff.extraDinoInactive, WIDTH_REF_HALF - 65, -HEIGHT_REF_HALF + 75 + 75);
//    image(extralives>=3 ? assets.uiStuff.extraDinoActive : assets.uiStuff.extraDinoInactive, WIDTH_REF_HALF - 65, -HEIGHT_REF_HALF + 75 + 75 + 75);


//  }
//} 
