abstract class Scene {
  public int sceneID;
  final static int SPLASH = 0;
  final static int MENU = 1;
  final static int PTUTORIAL = 2;
  final static int TRIASSIC = 3;
  final static int JURASSIC = 4;
  final static int CRETACEOUS = 5;
  final static int MULTIPLAYER = 6;
  final static int OVIRAPTOR = 7;

  public int status;
  final static int RUNNING = 1;
  final static int DONE = 2;

  abstract void update();
  abstract void render();
  abstract void mouseUp();
  abstract void cleanup();
  //abstract int nextScene();
}

class SinglePlayer extends Scene {

  Earth earth;
  EventManager eventManager;
  StarManager starManager;
  RoidManager roids;
  VolcanoManager volcanoManager;
  ColorDecider currentColor;
  UIStory ui;
  UFOManager ufoManager;
  PlayerManager playerManager;
  Time time;
  Camera camera;
  TrexManager trexManager;
  GameScreenMessages gameText;
  MusicManager musicManager;

  boolean options = false;
  Rectangle optionsButton;
  Rectangle soundButton;
  Rectangle restartButton;
  Rectangle musicButton;
  float optionsDY = 100;

  ArrayList<updateable> updaters = new ArrayList<updateable>();
  ArrayList<renderableScreen> screenRenderers = new ArrayList<renderableScreen>();
  ArrayList<renderable> renderers =  new ArrayList<renderable>();

  SinglePlayer(int lvl) {
    sceneID = TRIASSIC + lvl - 1;

    eventManager = new EventManager();
    time = new Time(eventManager);
    earth = new Earth(time, eventManager, lvl);
    camera = new Camera();
    roids = new RoidManager(earth, eventManager, time);
    currentColor = new ColorDecider();
    volcanoManager = new VolcanoManager(eventManager, time, currentColor, earth, lvl);
    starManager = new StarManager(currentColor, time, eventManager, lvl);
    gameText = new GameScreenMessages(eventManager, currentColor);
    playerManager = new PlayerManager(eventManager, earth, time, volcanoManager, starManager, camera);
    trexManager = new TrexManager(eventManager, time, earth, playerManager, currentColor, lvl);
    ui = new UIStory(eventManager, time, currentColor, lvl);
    ufoManager = new UFOManager (currentColor, earth, playerManager, eventManager, time);
    musicManager = new MusicManager(eventManager, lvl);

    updaters.add(time);
    updaters.add(ui);
    updaters.add(earth);
    updaters.add(roids);
    updaters.add(camera);
    updaters.add(currentColor);
    updaters.add(starManager);
    updaters.add(ufoManager);
    updaters.add(playerManager);
    updaters.add(volcanoManager);
    updaters.add(trexManager);
    updaters.add(musicManager);

    renderers.add(ufoManager);
    renderers.add(volcanoManager);
    renderers.add(playerManager);
    renderers.add(trexManager);
    renderers.add(earth);
    renderers.add(roids);
    renderers.add(starManager);

    screenRenderers.add(gameText);
    screenRenderers.add(ui);

    status = RUNNING;

    optionsButton = new Rectangle(WIDTH_REF_HALF - 75, HEIGHT_REF_HALF - 75, 25, 25);
    soundButton = new Rectangle(-WIDTH_REF_HALF/2, -HEIGHT_REF_HALF + optionsDY - 25, WIDTH_REF_HALF, 50);
    musicButton = new Rectangle(-WIDTH_REF_HALF/2, -HEIGHT_REF_HALF + optionsDY * 2 - 25, WIDTH_REF_HALF, 50);
    restartButton = new Rectangle(-WIDTH_REF_HALF/2, -HEIGHT_REF_HALF + optionsDY * 3 - 25, WIDTH_REF_HALF, 50);
  }

  void update () {

    if (!options) {
      for (updateable u : updaters) u.update();
    } else {
      starManager.update();
    }

    if (ui.gameDone) {
      status = DONE;
    }

    //if (ufoManager.ufo != null) {
    //  camera.setPosition(0, 0);
    //  camera.parent = ufoManager.ufo;
    //}
  }

  void render () {

    PVector m = screentoScaled2(mouseX, mouseY);

    pushMatrix(); // world-space
    translate(-camera.globalPos().x + width/2, -camera.globalPos().y + height/2);
    //translate(camera.x, camera.y);
    scale(SCALE);
    if (!options) {
      for (renderable r : renderers) r.render();
    } else {
      starManager.render();
    }
    popMatrix(); 

    if (options) {
      pushMatrix(); // screen-space (UI)
      pushStyle();
      translate(width/2, height/2);
      scale(SCALE);
      rectMode(CORNER);
      textFont(assets.uiStuff.MOTD);
      textAlign(CENTER, CENTER);

      fill(soundButton.inside(m) ? 80 : 300, 70, 70, 1);
      rect(soundButton.x, soundButton.y, soundButton.w, soundButton.h);
      fill(0, 0, 100, 1);
      text(inputs.getInt("sfxVolume", 100) > 0 ? "Sound: < ON >" : " Sound: < OFF >", 0, -HEIGHT_REF_HALF + optionsDY);

      fill(musicButton.inside(m) ? 80 : 300, 70, 70, 1);
      rect(musicButton.x, musicButton.y, musicButton.w, musicButton.h);
      fill(0, 0, 100, 1);
      text(inputs.getInt("musicVolume", 100) > 0 ? "Music: < ON >" : "Music: < OFF >", 0, -HEIGHT_REF_HALF + optionsDY * 2);

      fill(restartButton.inside(m) ? 80 : 300, 70, 70, 1);
      rect(restartButton.x, restartButton.y, restartButton.w, restartButton.h);
      fill(0, 0, 100, 1);
      text(" Restart at: < Triassic >", 0, -HEIGHT_REF_HALF + optionsDY * 3);
      popMatrix();
      popStyle();
    }

    pushMatrix(); // screen-space (UI)
    translate(width/2, height/2);
    scale(SCALE);
    if (!options) gameText.render();
    assets.applyBlur();
    ui.render();
    popMatrix();

    pushMatrix(); // pillarboxing (for high aspect ratios)
    pushStyle();
    translate(0, 0);
    float w = 2678 / 2 * SCALE;
    fill(0, 0, 0, 1);
    rect(0, 0, (width-w)/2, height);
    rect((width-w)/2 + w, 0, (width-w)/2, height);
    popStyle();
    popMatrix();

    pushMatrix();
    pushStyle();
    translate(width/2, height/2);
    scale(SCALE);
    PVector b = new PVector(WIDTH_REF_HALF - 75, HEIGHT_REF_HALF - 75);

    fill(optionsButton.inside(m) ? 200 : 0, 70, 70, 1);
    rect(b.x, b.y, 25, 25);
    popStyle();
    popMatrix();


    //pushStyle();
    //fill(270, 70, 70, 1);
    //float x = (mouseX + WIDTH_REF_HALF) / SCALE;
    //float y = (mouseY + HEIGHT_REF_HALF) / SCALE;
    //circle(x, y, 25 * SCALE);
    //PVector p = screenToScaled(mouseX, mouseY);
    //fill(320, 70, 70, 1);
    //ellipseMode(CENTER);
    //circle(p.x, p.y, 10 * SCALE);
    //popStyle();

    //pushStyle();
    //fill(180, 70, 70, 1);
    ////circle(x, 0, 25);
    //circle((WIDTH_REF_HALF - 50) * SCALE + (width/2), HEIGHT_REF_HALF - 50, 25);
    //popStyle();

    //println(screentoScaled2(mouseX, mouseY), b);
    //println(mouseX);
  }

  void mouseUp() {

    PVector m = screentoScaled2(mouseX, mouseY);

    if (optionsButton.inside(m)) {
      options = !options;
    }

    if (options) {
      if (soundButton.inside(m)) {
        float sfx = inputs.getInt("sfxVolume", 100);
        inputs.setInt("sfxVolume", sfx > 0 ? 0 : 100);
        assets.muteSFX(sfx > 0 ? true : false);
        writeOutControls();
      }

      if (musicButton.inside(m)) {
        float msx = inputs.getInt("musicVolume", 100);
        inputs.setInt("musicVolume", msx > 0 ? 0 : 100);
        assets.muteMusic(msx > 0 ? true : false);
        writeOutControls();
      }

      if (restartButton.inside(m)) {
        println("restart from somewhere else");
      }
    }
  }

  void cleanup() {
    assets.stopAllMusic();
    assets.stopAllSfx();
  }

  PVector screenToScaled (float x, float y) {
    return new PVector((x + WIDTH_REF_HALF) / SCALE, (y + HEIGHT_REF_HALF) / SCALE);
  }

  PVector screentoScaled2 (float x, float y) {
    return new PVector((x - width/2) / SCALE, (y - height/2) / SCALE);
  }

  //int nextScene () {
  //  return SINGLEPLAYER;
  //}
}

class Rectangle {
  float x, y, w, h;

  Rectangle (float _x, float _y, float _w, float _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
  }

  boolean inside (PVector point) {
    return inside(point.x, point.y);
  }

  boolean inside (float px, float py) {
    return px > x && px < x + w && py > y && py < y + h;
  }
}

class Oviraptor extends Scene {

  Earth earth;
  EventManager eventManager;
  StarManager starManager;
  RoidManager roids;
  ColorDecider currentColor;
  UIStory ui;
  UFOManager ufoManager;
  PlayerManager playerManager;
  Time time;
  Camera camera;
  TrexManager trexManager;
  GameScreenMessages gameText;

  ArrayList<updateable> updaters = new ArrayList<updateable>();
  ArrayList<renderableScreen> screenRenderers = new ArrayList<renderableScreen>();
  ArrayList<renderable> renderers =  new ArrayList<renderable>();

  Oviraptor(int lvl) {
    sceneID = OVIRAPTOR;

    eventManager = new EventManager();
    time = new Time(eventManager);
    earth = new Earth(time, eventManager, lvl);
    camera = new Camera();
    roids = new RoidManager(earth, eventManager, time);
    currentColor = new ColorDecider();
    starManager = new StarManager(currentColor, time, eventManager, lvl);
    gameText = new GameScreenMessages(eventManager, currentColor);
    playerManager = new PlayerManager(eventManager, earth, time, null, starManager, camera);
    trexManager = new TrexManager(eventManager, time, earth, playerManager, currentColor, lvl);
    ui = new UIStory(eventManager, time, currentColor, lvl);

    updaters.add(time);
    updaters.add(ui);
    updaters.add(earth);
    updaters.add(roids);
    updaters.add(camera);
    updaters.add(currentColor);
    updaters.add(starManager);
    updaters.add(playerManager);
    updaters.add(trexManager);

    renderers.add(playerManager);
    renderers.add(trexManager);
    renderers.add(earth);
    renderers.add(roids);
    renderers.add(starManager);

    screenRenderers.add(gameText);
    screenRenderers.add(ui);

    status = RUNNING;

    //trexManager.spawnTrex();
  }

  void update () {

    for (updateable u : updaters) u.update();
  }

  void render () {

    pushMatrix(); // world-space
    translate(camera.x, camera.y);
    scale(SCALE);
    for (renderable r : renderers) r.render();
    popMatrix(); 

    pushMatrix(); // screen-space (UI)
    translate(width/2, height/2);
    scale(SCALE);
    gameText.render();
    assets.applyBlur();
    ui.render();
    popMatrix();

    pushMatrix(); // pillarboxing (for high aspect ratios)
    pushStyle();
    translate(0, 0);
    float w = 2678 / 2 * SCALE;
    fill(0, 0, 0, 1);
    rect(0, 0, (width-w)/2, height);
    rect((width-w)/2 + w, 0, (width-w)/2, height);
    popStyle();
    popMatrix();
  }

  void mouseUp() {
    println("somebody clicked");
  }

  void cleanup() {
    assets.stopAllMusic();
    assets.stopAllSfx();
  }

  //int nextScene () {
  //  return SINGLEPLAYER;
  //}
}

class testScene extends Scene {

  Earth earth;
  EventManager eventManager;
  ColorDecider currentColor;
  StarManager starManager;  
  UIStory ui;
  RoidManager roids;
  //UFOManager ufoManager;
  PlayerManager playerManager;
  Time time;
  Camera camera;
  VolcanoManager volcanoManager;

  ArrayList<updateable> updaters = new ArrayList<updateable>();
  ArrayList<renderableScreen> screeenRenderers = new ArrayList<renderableScreen>();
  ArrayList<renderable> renderers =  new ArrayList<renderable>();

  testScene (int lvl) {
    sceneID = TRIASSIC;

    eventManager = new EventManager();
    time = new Time(eventManager);
    earth = new Earth(time, eventManager, lvl);
    //earth.dr = 0;

    camera = new Camera();
    roids = new RoidManager(earth, eventManager, time);
    currentColor = new ColorDecider();
    starManager = new StarManager(currentColor, time, eventManager, lvl);
    //starManager = new StarManager(currentColor, time);

    //soundManager = new SoundManager(main, eventManager);
    volcanoManager = new VolcanoManager(eventManager, time, currentColor, earth, lvl);
    playerManager = new PlayerManager(eventManager, earth, time, volcanoManager, starManager, camera);
    playerManager.spawningDuration = 10;
    ui = new UIStory(eventManager, time, currentColor, lvl);
    ui.score = 90;
    //ufoManager = new UFOManager (currentColor, earth, playerManager, eventManager);

    updaters.add(time);
    //updaters.add(ui);
    updaters.add(earth);
    updaters.add(roids);
    updaters.add(camera);
    updaters.add(currentColor);
    //updaters.add(starManager);
    //updaters.add(ufoManager);
    updaters.add(playerManager);
    //updaters.add(volcanoManager);

    //renderers.add(ufoManager);
    renderers.add(playerManager);
    //renderers.add(volcanoManager);

    renderers.add(earth);
    renderers.add(roids);
    //renderers.add(starManager);

    //screeenRenderers.add(ui);
  }

  void update () {

    //if (time.getTick()==20) ufoManager.spawnUFOAbducting();

    for (updateable u : updaters) u.update();
  }

  void render () {
    //pushMatrix(); // world-space
    //translate(camera.x, camera.y);
    //for (renderable r : renderers) r.render();

    //popMatrix(); // screen-space
    //for (renderableScreen rs : screeenRenderers) rs.render(); // UI
  }

  void mouseUp() {
    println("somebody clicked");
  }

  void cleanup() {
    assets.stopAllMusic();
    assets.stopAllSfx();
  }

  //int nextScene () {
  //  return SINGLEPLAYER;
  //}
}

interface updateable {
  void update();
}

interface renderable {
  void render();
} 

interface renderableScreen {
  void render();
}
