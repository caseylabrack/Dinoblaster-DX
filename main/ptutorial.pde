class Ptutorial extends Scene {

  Entity earth = new Entity();
  Time time = new Time();
  StarsSystem starsSystem = new StarsSystem();
  RoidManager roidManager = new RoidManager();
  Camera camera = new Camera();
  final static int START = 0;
  final static int PTERO_RIGHT = 1;
  final static int WAIT_RIGHT = 2;
  final static int PTERO_LEFT = 3;
  final static int WAIT_LEFT = 4;
  int state = START;
  float stateStart;

  PFont tipFont;
  float startPteroAngle;

  final static float WALK_ARC = 22;

  PlayerIntro playerIntro;
  PtutorialBronto player = new PtutorialBronto();
  PtutorialPtero ptero = new PtutorialPtero();

  class PtutorialPtero extends Entity {
    PImage idle;
    PImage flap1;
    PImage flap2;
    final static float ORBIT = 775;
    boolean flapping = false;

    void flap() {
      model = (time.clock % 100) > 100 / 2 ? flap1 : flap2;
    }
  }

  class PtutorialBronto extends Entity {
    PImage[] frames;
    boolean enabled = false;
    SoundPlayable step;
    final static float ORBIT = 566 + 30; // earth radius plus offset
    float earthAngle = -90;
    boolean walking = false;
    final static float RUN_SPEED = .25;

    void move(int dir) {
      if (dir==0) {
        model = frames[0];
        walking = false;
      } else {
        model = millis() % 100 > 50 ? frames[1] : frames[2];
        facing = dir;
        earthAngle += RUN_SPEED * dir;
      }
      x = cos(radians(earthAngle)) * ORBIT;
      y = HEIGHT_REF_HALF + sin(radians(earthAngle)) * ORBIT + earth.y;
      r = earthAngle + 90;
    }

    void render() {
      if (!enabled) return; 
      this.simpleRenderImage();
    }
  }

  Ptutorial (SimpleTXTParser settings, AssetManager assets) {

    starsSystem.spawnSomeStars();

    ptero.idle = assets.ptutorialStuff.pteroIdle;
    ptero.flap1 = assets.ptutorialStuff.pteroFlap1;
    ptero.flap2 = assets.ptutorialStuff.pteroFlap2;
    ptero.model = ptero.idle;

    earth.model = loadImage("/_art/ptutorial/ptero_earth.png");

    player.frames = assets.playerStuff.brontoFrames;
    player.model = player.frames[0];
    player.step = assets.playerStuff.step;

    playerIntro = new PlayerIntro();
    playerIntro.model = assets.playerStuff.brontoFrames[0];

    tipFont = assets.uiStuff.MOTD;

    play();
  }

  void play() {
    time.restart();
    earth.y = 150;
    ptero.x = earth.x + cos(radians(-90)) * PtutorialPtero.ORBIT;
    ptero.y = earth.y + HEIGHT_REF_HALF + sin(radians(-90)) * PtutorialPtero.ORBIT;
    ptero.r = 0;

    state = START;
    stateStart = time.getClock();

    playerIntro.y = HEIGHT_REF_HALF + sin(radians(-90)) * PtutorialBronto.ORBIT + earth.y;
    playerIntro.startIntro();
    playerIntro.spawningStart = millis();
  }

  void update() {
    time.update();

    float pct;

    switch (state) {

    case START:
      ptero.model = ptero.idle;
      playerIntro.update();
      if (playerIntro.state == PlayerIntro.SPAWNING) {
        playerIntro.state = PlayerIntro.DONE;
        player.y = playerIntro.y;
        player.r = playerIntro.r;
        player.enabled = true;
        state = PTERO_RIGHT;
        stateStart = millis();
      }
      break;

    case PTERO_RIGHT:
      pct = (millis() - stateStart) / 2e3;
      if (pct < 1) {
        float startAngle = -90;
        float endAngle = startAngle + WALK_ARC;
        float diff = endAngle - startAngle;
        float dist = pct * diff;
        ptero.x = earth.x + cos(radians(startAngle + dist)) * PtutorialPtero.ORBIT;
        ptero.y = earth.y + HEIGHT_REF_HALF + sin(radians(startAngle + dist)) * PtutorialPtero.ORBIT;
        ptero.r = startAngle + dist + 90;
        ptero.flap();
      } else {
        ptero.facing = -1;
        ptero.model = ptero.idle;
        state = WAIT_RIGHT;
        stateStart = millis();
      }
      break;

    case WAIT_RIGHT:
      if (keys.p1Right()) {
        player.move(1);
      } else {
        player.move(0);
      }
      if (player.earthAngle>=-90 + WALK_ARC) {
        player.move(0);
        state = PTERO_LEFT;
        stateStart = millis();
      }
      break;

    case PTERO_LEFT:
      pct = (millis() - stateStart) / 4e3;
      if (pct < 1) {
        float startAngle = -90 + WALK_ARC;
        float endAngle = -90 - WALK_ARC;
        float diff = endAngle - startAngle;
        float dist = pct * diff;
        ptero.x = earth.x + cos(radians(startAngle + dist)) * PtutorialPtero.ORBIT;
        ptero.y = earth.y + HEIGHT_REF_HALF + sin(radians(startAngle + dist)) * PtutorialPtero.ORBIT;
        ptero.r = startAngle + dist + 90;
        ptero.flap();
      } else {
        ptero.facing = 1;
        ptero.model = ptero.idle;
        state = WAIT_LEFT;
        stateStart = millis();
      }
      break;

    case WAIT_LEFT:
      if (keys.p1Left()) {
        player.move(-1);
      } else {
        player.move(0);
      }
      if (player.earthAngle<=-90 - WALK_ARC) {
        player.move(0);
        state = 100000;
        stateStart = millis();
      }
      break;
    }

    starsSystem.update(time.getTimeScale(), time.getTargetTimeScale());
  }
  void renderPreGlow() {
    sb.pushMatrix();
    sb.translate(-camera.globalPos().x + width/2, -camera.globalPos().y + height/2);
    sb.scale(SCALE);
    sb.rotate(radians(-camera.globalRote()));
    sb.imageMode(CENTER);
    sb.clip(width/2, height/2, height, height);
    sb.pushStyle();

    earth.simpleRenderImage();

    ptero.simpleRenderImage();

    starsSystem.render(currentColor.getColor(), time.getTargetTimeScale());

    playerIntro.render();

    player.render();

    switch (state) {

    case WAIT_RIGHT:
      if (millis() % 1e3 > .25e3) {
        sb.pushStyle();
        sb.textFont(tipFont);
        sb.textAlign(CENTER, CENTER);
        sb.text("Move right", 0, HEIGHT_REF_HALF - 250);
        sb.popStyle();
      }
      break;

    case WAIT_LEFT:
      if (millis() % 1e3 > .25e3) {
        sb.pushStyle();
        sb.textFont(tipFont);
        sb.textAlign(CENTER, CENTER);
        sb.text("Move left", 0, HEIGHT_REF_HALF - 250);
        sb.popStyle();
      }
      break;
    }

    sb.pushStyle();
    sb.textFont(tipFont);
    sb.textAlign(CENTER, CENTER);
    sb.text("Ptutorial", 0, -HEIGHT_REF_HALF + 50);
    sb.popStyle();

    sb.popStyle();

    sb.noClip();

    sb.popMatrix();
  }
  void renderPostGlow() {
  }
  void mouseUp() {
  }
}

//class PtutorialZoom extends Scene {

//  Earth earth;
//  Entity earth2 = new Entity();
//  Time time = new Time();
//  StarsSystem starsSystem = new StarsSystem();
//  RoidManager roidManager = new RoidManager();
//  Camera camera = new Camera();
//  final static int START_LEFT = 0;
//  int state = START_LEFT;
//  Entity ptero = new Entity();
//  PShape pteroVectorIdle;
//  PShape pteroVectorFlap1;
//  PShape pteroVectorFlap2;
//  //PImage pteroVectorIdle;
//  //PImage pteroVectorFlap1;
//  //PImage pteroVectorFlap2;

//  PtutorialZoom (SimpleTXTParser settings, AssetManager assets) {
//    earth2.modelVector = assets.earthStuff.earthV;

//    starsSystem.spawnSomeStars();

//    pteroVectorIdle = loadShape("/_art/ptutorial/ptero_idle.svg");
//    //pteroVectorIdle.getChild("idle").disableStyle();
//    pteroVectorIdle.disableStyle();
//    ptero.modelVector = pteroVectorIdle;

//    pteroVectorFlap1 = loadShape("/_art/ptutorial/ptero_flap1.svg");
//    pteroVectorFlap1.disableStyle();

//    pteroVectorFlap2 = loadShape("/_art/ptutorial/ptero_flap2.svg");
//    pteroVectorFlap2.disableStyle();

//    //pteroVectorIdle = loadImage("ptero_idle.png");
//    //ptero.model = pteroVectorIdle;

//    //pteroVectorFlap1 = loadImage("ptero_flap1.png");

//    //pteroVectorFlap2 = loadImage("ptero_flap2.png");

//    //earth2.model = loadImage("/_art/ptutorial/ptutorial-earth.png");


//    //earth2.addChild(camera);
//    earth2.addChild(ptero);

//    //camera.y = -200;
//    earth2.y = 0;
//    ptero.scale = 1;
//    ptero.y = -250;
//    //ptero.modelVector.width = 25;
//    //println(ptero.modelVector.width);
//  }

//  void update() {
//    time.update();

//    //earth.move(time.getTimeScale(), time.getClock());
//    //println(camera.x, camera.y, camera.r);

//    //float t = constrain(float(frameCount)/500,0,1);
//    float t = 1;

//    camera.scale = .1 + t * 3;
//    earth2.x = 0 + t * -100;
//    earth2.y = 0 + t * 200;

//    switch (state) {

//    case START_LEFT:
//      break;
//    }

//    ptero.modelVector = (time.clock % 100) > 100 / 2 ? pteroVectorFlap1 : pteroVectorFlap2;
//    //ptero.model = (time.clock % 100) > 100 / 2 ? pteroVectorFlap1 : pteroVectorFlap2;

//    starsSystem.update(time.getTimeScale(), time.getTargetTimeScale());
//  }
//  void renderPreGlow() {
//    sb.pushMatrix();
//    sb.translate(-camera.globalPos().x + width/2, -camera.globalPos().y + height/2);
//    //sb.translate(width/2, height/2);
//    //sb.translate(-300, 500);
//    sb.scale(SCALE);
//    sb.scale(camera.scale);
//    sb.rotate(radians(-camera.globalRote()));
//    sb.imageMode(CENTER);
//    sb.clip(width/2, height/2, height, height);
//    //earth.render(time.getClock());
//    sb.pushStyle();

//    sb.noFill();
//    sb.stroke(0, 0, 100, 1);
//    sb.strokeWeight(1.5/camera.scale);
//    sb.shapeMode(CENTER);
//    //earth2.simpleRenderImage();
//    earth2.pushTransforms();
//    sb.shape(earth2.modelVector, 0, 0);
//    sb.popMatrix();

//    ptero.pushTransforms();
//    sb.strokeWeight(1.5/camera.scale);
//    //sb.shape(ptero.modelVector.getChild("idle"), 0, 0);
//    //sb.shape(ptero.modelVector.getChild(1).getChild(0).getChild(1), 0, 0);
//    sb.shape(ptero.modelVector, 0, 0);
//    sb.popMatrix();

//    //ptero.simpleRenderImage();

//    sb.popStyle();

//    //earth2.simpleRenderImageVector();
//    //sb.noClip();

//    sb.popMatrix();

//    sb.pushMatrix();
//    sb.translate(-camera.globalPos().x + width/2, -camera.globalPos().y + height/2);
//    //sb.translate(width/2, height/2);
//    sb.translate(-100, 400);
//    sb.scale(SCALE);
//    //sb.scale(3);
//    sb.rotate(radians(-camera.globalRote()));
//    sb.imageMode(CENTER);
//    sb.clip(width/2, height/2, height, height);
//    sb.noClip();
//    starsSystem.render(currentColor.getColor(), time.getTargetTimeScale());

//    sb.popMatrix();
//  }
//  void renderPostGlow() {
//  }
//  void mouseUp() {
//  }
//}
