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
  boolean dontFlicker = false;

  PFont extinctFont;
  PFont tipFont;
  StringList tips = new StringList();

  boolean extinctAnimationDone = false;

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

  boolean doneFlashExtinct () {
    return extinctAnimationDone;
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
        extinctAnimationDone = true;
      }
    }

    if (showingTip) {
      if (millis() - tipStart > TIP_DURATION) showingTip = false;
    }
  }

  void render(color funkyColor) {
    if (!extinct && !showingTip) return;

    if (extinct) {
      sb.pushStyle();
      sb.fill(funkyColor);
      sb.textFont(extinctFont);
      sb.textAlign(CENTER, CENTER);

      if (dontFlicker) {
        sb.text("EXTINCT", 15, -15);
      } else {
        if (extinctDisplay) sb.text("EXTINCT", 15, -15);
      }
      sb.popStyle();
    }

    if (showingTip) {
      sb.pushStyle();
      sb.textFont(tipFont);
      sb.textAlign(CENTER, CENTER);
      sb.text(tip, 0, -HEIGHT_REF_HALF + 50);
      sb.popStyle();
    }
  }

  void restart () {
    extinct = false;
    showingTip = false;
    extinctAnimationDone = false;
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

    if (extralives >= 1) image(assets.uiStuff.extraDinoActive, WIDTH_REF_HALF - 65, -HEIGHT_REF_HALF + 75);
    if (extralives >= 2) image(assets.uiStuff.extraDinoActive, WIDTH_REF_HALF - 65, -HEIGHT_REF_HALF + 75 + 75);
    if (extralives >= 3) image(assets.uiStuff.extraDinoActive, WIDTH_REF_HALF - 65, -HEIGHT_REF_HALF + 75 + 75 + 75);
    //image(extralives>=1 ? assets.uiStuff.extraDinoActive : assets.uiStuff.extraDinoInactive, WIDTH_REF_HALF - 65, -HEIGHT_REF_HALF + 75);
    //image(extralives>=2 ? assets.uiStuff.extraDinoActive : assets.uiStuff.extraDinoInactive, WIDTH_REF_HALF - 65, -HEIGHT_REF_HALF + 75 + 75);
    //image(extralives>=3 ? assets.uiStuff.extraDinoActive : assets.uiStuff.extraDinoInactive, WIDTH_REF_HALF - 65, -HEIGHT_REF_HALF + 75 + 75 + 75);

    push();
    //tint(0,60,99,1);
    imageMode(CENTER);
    float p = ((float)score)/300.0;
    float totalpixels = HEIGHT_REFERENCE - 80;
    float tickheight = 10;//assets.uiStuff.tick.height;
    //for (int i = 0; i < totalpixels; i+=tickheight) {
    //  image(assets.uiStuff.tickInActive, -WIDTH_REF_HALF + 64, -HEIGHT_REF_HALF + 40 + i);
    //}
    float fillupto = p * totalpixels;
    for (int i = 0; i < fillupto; i+=tickheight) {
      image(assets.uiStuff.tick, -WIDTH_REF_HALF + 64, -HEIGHT_REF_HALF + 40 + i);
    }

    pop();

    //push();
    ////tint(0,60,99,1);
    //imageMode(CENTER);
    //p = ((float)score)/300.0;
    //totalpixels = HEIGHT_REFERENCE - 80;
    //fillupto = p * totalpixels;
    //tickheight = 10;//assets.uiStuff.tick.height;
    //for (int i = 0; i < fillupto; i+=tickheight) {
    //  image(assets.uiStuff.tick, -WIDTH_REF_HALF + 64, -HEIGHT_REF_HALF + 40 + i);
    //}
    //pop();

    //image(screenShine, 0, 0);
    //image(letterbox, 0, 0);
    //if (!hideButtons) image(buttons, 0, 0);
  }
}
