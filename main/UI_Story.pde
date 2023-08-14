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

    //push();
    //imageMode(CORNER);
    //image(assets.uiStuff.progressBG, -WIDTH_REF_HALF + 40, -HEIGHT_REF_HALF);
    //image(assets.uiStuff.extraDinosBG, WIDTH_REF_HALF - 100, -HEIGHT_REF_HALF);
    //pop();

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

    //image(screenShine, 0, 0);
    //image(letterbox, 0, 0);
    //if (!hideButtons) image(buttons, 0, 0);
  }
}
