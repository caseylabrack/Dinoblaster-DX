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

  Earth earth = new Earth();
  Time time = new Time();
  //EventManager eventManager;
  //StarManager starManager;
  RoidManager roidManager = new RoidManager();
  //VolcanoManager volcanoManager;
  //ColorDecider currentColor;
  //UIStory ui;
  //UFOManager ufoManager;
  //PlayerManager playerManager;
  //Time time;
  Camera camera = new Camera();
  //TrexManager trexManager;
  //GameScreenMessages gameText;
  //MusicManager musicManager;
  //FinaleStuff finaleManager;
  Player player = new Player();
  PlayerIntro playerIntro = new PlayerIntro();
  GameOver gameOver = new GameOver();

  //boolean options = false;
  //Rectangle dipswitchesButton;
  //Rectangle optionsButton;
  //Rectangle soundButton;
  //Rectangle restartButton;
  //Rectangle musicButton;
  //Rectangle launchFinderButton;
  //float directoryTextYPos = 0;//32 + 10 + 32 + 10 + 32 + 10 + 10;
  //float yoffset = -5; // optically vertically center align text within rectangle buttons
  //IntList validLvls = new IntList();

  //ArrayList<updateable> updaters = new ArrayList<updateable>();
  //ArrayList<renderableScreen> screenRenderers = new ArrayList<renderableScreen>();
  //ArrayList<renderable> renderers =  new ArrayList<renderable>();

  SinglePlayer(int lvl) {

    earth.model = assets.earthStuff.earth;
    earth.dr = settings.getFloat("earthRotationSpeed", Earth.DEFAULT_EARTH_ROTATION);
    playerIntro.model = assets.playerStuff.brontoFrames[0];
    playerIntro.y = -Player.DIST_FROM_EARTH;

    player.model = assets.playerStuff.brontoFrames[0];

    roidManager.minSpawnInterval = settings.getFloat("roidImpactRateInMilliseconds", RoidManager.DEFAULT_SPAWN_RATE) - settings.getFloat("roidImpactRateVariation", RoidManager.DEFAULT_SPAWN_DEVIATION)/2;
    roidManager.maxSpawnInterval = settings.getFloat("roidImpactRateInMilliseconds", RoidManager.DEFAULT_SPAWN_RATE) + settings.getFloat("roidImpactRateVariation", RoidManager.DEFAULT_SPAWN_DEVIATION)/2;
    roidManager.initRoidPool(assets.roidStuff.roidFrames);
    roidManager.initSplodePool(assets.roidStuff.explosionFrames);

    playerIntro.spawningStart = millis();


    //sceneID = TRIASSIC + lvl - 1;

    //eventManager = new EventManager();
    //time = new Time(eventManager);
    ////earth = new Earth(time, eventManager, lvl);
    //earth = new Earth();
    //camera = new Camera();
    //roids = new RoidManager(earth, eventManager, time);
    //currentColor = new ColorDecider();
    //volcanoManager = new VolcanoManager(eventManager, time, currentColor, earth, lvl);
    //starManager = new StarManager(currentColor, time, eventManager, lvl);
    //gameText = new GameScreenMessages(eventManager, currentColor);
    //playerManager = new PlayerManager(eventManager, earth, time, volcanoManager, starManager, camera);
    //trexManager = new TrexManager(eventManager, time, earth, playerManager, currentColor, lvl);
    //ui = new UIStory(eventManager, time, currentColor, lvl);
    //ufoManager = new UFOManager (currentColor, earth, playerManager, eventManager, time);
    //musicManager = new MusicManager(eventManager, lvl);
    //finaleManager = new FinaleStuff(eventManager, earth, playerManager, starManager, camera, time);

    //updaters.add(time);
    //updaters.add(ui);
    ////updaters.add(earth);
    //updaters.add(roids);
    //updaters.add(camera);
    //updaters.add(currentColor);
    //updaters.add(starManager);
    //updaters.add(ufoManager);
    //updaters.add(playerManager);
    //updaters.add(volcanoManager);
    //updaters.add(trexManager);
    //updaters.add(musicManager);
    //updaters.add(finaleManager);

    //renderers.add(ufoManager);
    //renderers.add(volcanoManager);
    //renderers.add(playerManager);
    //renderers.add(trexManager);
    //renderers.add(finaleManager);
    ////renderers.add(earth);
    //renderers.add(roids);
    //renderers.add(starManager);

    //screenRenderers.add(gameText);
    //screenRenderers.add(ui);

    //status = RUNNING;

    //float dipwidth =  assets.uiStuff.DIPswitchesBtn.width;
    //float dipheight = assets.uiStuff.DIPswitchesBtn.height;
    //dipswitchesButton = new Rectangle(HEIGHT_REF_HALF + (WIDTH_REF_HALF - HEIGHT_REF_HALF) / 2 - dipwidth/2, HEIGHT_REF_HALF - dipheight, dipwidth, dipheight);
    //optionsButton = new Rectangle(WIDTH_REF_HALF - 100, HEIGHT_REF_HALF - 125, 100, 100);
    //float y = -HEIGHT_REF_HALF + 125; // 125 pixels from top of screen
    //float optionsDY = 75;
    //float buttonWidth = HEIGHT_REFERENCE - 150;
    //soundButton = new Rectangle(-buttonWidth/2, y, buttonWidth, 50);
    //y += optionsDY;
    //musicButton = new Rectangle(-buttonWidth/2, y, buttonWidth, 50);
    //y+= optionsDY;
    //restartButton = new Rectangle(-buttonWidth/2, y, buttonWidth, 50);
    //y+= optionsDY;
    //launchFinderButton = new Rectangle(-HEIGHT_REF_HALF + 10, directoryTextYPos, HEIGHT_REFERENCE - 20, HEIGHT_REF_HALF - directoryTextYPos - 20);
  }

  void update () {

    time.update();
    playerIntro.update();
    earth.r += earth.dr * time.getTimeScale();
    if (playerIntro.state == PlayerIntro.SPAWNING) {
      playerIntro.state = PlayerIntro.DONE;
      player.enabled = true;
      player.y = playerIntro.y;
      earth.addChild(player);
    }
    if (keys.left != keys.right) player.move(keys.left ? -1 : 1, time.getTimeScale());
    roidManager.fireRoids(time.getClock(), earth.globalPos());
    roidManager.updateRoids(time.getTimeScale());

    // handle roids hitting earth
    ArrayList<Roid> earthHits = roidManager.anyRoidsHittingThisCircle(earth.x, earth.y, Earth.EARTH_RADIUS);
    if (!earthHits.isEmpty()) {
      for (Roid r : earthHits) {
        r.enabled = false;
        Explosion splode = roidManager.newExplosion(time.getClock());
        float incomingAngle = utils.angleOfRadians(earth.globalPos(), r.globalPos());        
        splode.x = earth.x + cos(incomingAngle) * (Earth.EARTH_RADIUS + Explosion.OFFSET_FROM_EARTH);
        splode.y = earth.y + sin(incomingAngle) * (Earth.EARTH_RADIUS + Explosion.OFFSET_FROM_EARTH);
        splode.r = utils.angleOf(earth.globalPos(), splode.globalPos()) + 90;
        earth.addChild(splode);

        // did the player get hit
        if (player.enabled) {
          if (utils.unsignedAngleDiff(splode.r, player.r) < Player.BOUNDING_ARC/2 + Explosion.BOUNDING_ARC/2) {
            player.restart();
            gameOver.callGameover();
            time.deathStart();
          }
        }
      }
    }

    roidManager.updateExplosions(time.getClock());

    // handle explosions killing player
    //if (player.enabled) {
    //  for (Explosion e : roidManager.splodes) {
    //    if (!e.enabled || !e.isDeadly) continue;
    //    if (utils.unsignedAngleDiff(e.r, player.r) < Player.BOUNDING_ARC/2 + Explosion.BOUNDING_ARC/2) {
    //      println("dead: " + frameCount);
    //      player.restart();
    //      gameOver.callGameover();
    //      time.deathStart();
    //    }
    //  }
    //}

    gameOver.update();
    if (gameOver.readyToRestart && keys.anykey) {
      playerIntro.startIntro();
      gameOver.restart();
      roidManager.restart();
    }

    //if (!options) {
    //  for (updateable u : updaters) u.update();
    //} else {
    //  starManager.update();
    //  currentColor.update();
    //}

    //if (ui.gameDone) {
    //  status = DONE;
    //}

    //if (ufoManager.ufo != null) {
    //  camera.setPosition(0, 0);
    //  camera.parent = ufoManager.ufo;
    //}
  }

  void render () {

    // world-space
    pushMatrix(); 
    translate(-camera.globalPos().x + width/2, -camera.globalPos().y + height/2);
    scale(SCALE);
    rotate(camera.globalRote());

    earth.simpleRenderImage();
    playerIntro.render();
    player.render();
    //pushStyle();
    //noFill();
    //stroke(30, 70, 70, 1);
    //strokeWeight(2);
    //float angDegrees = utils.angleOf(earth.globalPos(), player.globalPos());
    //PVector arc1 = new PVector(earth.globalPos().x + cos(radians(angDegrees - Player.BOUNDING_ARC/2)) * Earth.EARTH_RADIUS, earth.globalPos().y + sin(radians(angDegrees - Player.BOUNDING_ARC/2)) * Earth.EARTH_RADIUS);
    //PVector arc2 = new PVector(earth.globalPos().x + cos(radians(angDegrees + Player.BOUNDING_ARC/2)) * Earth.EARTH_RADIUS, earth.globalPos().y + sin(radians(angDegrees + Player.BOUNDING_ARC/2)) * Earth.EARTH_RADIUS);
    //circle(arc1.x, arc1.y, 10);
    //circle(arc2.x, arc2.y, 10);
    ////circle(player.globalPos().x, player.globalPos().y, Player.BOUNDING_CIRCLE);
    //popStyle();
    roidManager.renderRoids();
    roidManager.renderSplodes();
    popMatrix(); 

    //PVector m = screenspaceToWorldspace(mouseX, mouseY);

    //pushMatrix(); // world-space
    //translate(-camera.globalPos().x + width/2, -camera.globalPos().y + height/2);
    ////translate(camera.x, camera.y);
    //scale(SCALE);
    //rotate(camera.globalRote());
    ////scale(2);
    //if (!options) {
    //  for (renderable r : renderers) r.render();
    //} else {
    //  starManager.render();
    //}
    //popMatrix(); 

    //if (options) {
    //  pushMatrix(); // screen-space (UI)
    //  pushStyle();
    //  translate(width/2, height/2);
    //  scale(SCALE);
    //  rectMode(CORNER);
    //  textFont(assets.uiStuff.MOTD);
    //  textAlign(CENTER, CENTER);

    //  //fill(soundButton.inside(m) ? 80 : 300, 70, 70, 1);
    //  stroke(0, 0, 100, 1);
    //  noFill();
    //  rect(soundButton.x, soundButton.y, soundButton.w, soundButton.h);
    //  fill(0, 0, 100, 1);
    //  text(settings.getInt("sfxVolume", 100) > 0 ? "Sound: < ON >" : " Sound: < OFF >", soundButton.x + soundButton.w/2, soundButton.y + soundButton.h/2 + yoffset);      

    //  //fill(musicButton.inside(m) ? 80 : 300, 70, 70, 1);
    //  stroke(0, 0, 100, 1);
    //  noFill();
    //  rect(musicButton.x, musicButton.y, musicButton.w, musicButton.h);
    //  fill(0, 0, 100, 1);
    //  text(settings.getInt("musicVolume", 100) > 0 ? "Music: < ON >" : " Music: < OFF >", musicButton.x + musicButton.w/2, musicButton.y + musicButton.h/2 + yoffset);

    //  //fill(restartButton.inside(m) ? 80 : 300, 70, 70, 1);
    //  stroke(0, 0, 100, 1);
    //  noFill();
    //  rect(restartButton.x, restartButton.y, restartButton.w, restartButton.h);
    //  fill(0, 0, 100, 1);

    //  //fill(launchFinderButton.inside(m) ? 80 : 300, 70, 70, 1);
    //  stroke(0, 0, 100, 1);
    //  //noFill();
    //  //rect(launchFinderButton.x, launchFinderButton.y, launchFinderButton.w, launchFinderButton.h);
    //  fill(0, 0, 100, 1);

    //  switch(settings.getInt("startAtLevel", 4)) {
    //  case 0:
    //  case 1:
    //    text(" Restart at: < Triassic >", restartButton.x + restartButton.w/2, restartButton.y + restartButton.h/2 + yoffset);
    //    break;

    //  case 2:
    //    text(" Restart at: < Jurassic >", restartButton.x + restartButton.w/2, restartButton.y + restartButton.h/2 + yoffset);
    //    break;

    //  case 3:
    //    text("   Restart at: < Cretaceous >", restartButton.x + restartButton.w/2, restartButton.y + restartButton.h/2 + yoffset);
    //    break;
    //  case 4:
    //    text(" Restart at: < Furthest >", restartButton.x + restartButton.w/2, restartButton.y + restartButton.h/2 + yoffset);
    //    break;
    //  }

    //  textAlign(CENTER, TOP);
    //  textLeading(32);

    //  float y = 0;
    //  //text("More settings in\n`controls-settings.txt` and\n`game-settings.txt`", 0, y);
    //  text("More settings in", 0, y);
    //  y += 32 + 10;
    //  fill(currentColor.getColor());
    //  text("`controls-settings.txt`", 0, y);
    //  fill(0, 0, 100, 1);
    //  y += 32 + 10;
    //  text("in your install folder:", 0, y);
    //  y += 32 + 10 + 10;
    //  text(sketchPath(), -HEIGHT_REF_HALF + 10, y, HEIGHT_REFERENCE - 10, 400);

    //  popMatrix();
    //  popStyle();
    //}

    //pushMatrix(); // screen-space (UI)
    //pushStyle();
    //translate(width/2, height/2);
    //scale(SCALE);
    //if (!options) gameText.render();
    //assets.applyGlowiness();
    //ui.render();
    //imageMode(CORNER);
    //rectMode(CORNER);
    ////if (!settings.getBoolean("hideDIPSwitchesButton", false)) image(assets.uiStuff.optionsBtn, optionsButton.x, optionsButton.y, assets.uiStuff.optionsBtn.width/2, assets.uiStuff.optionsBtn.height/2);
    ////image(assets.uiStuff.DIPswitchesBtn, dipswitchesButton.x, dipswitchesButton.y, assets.uiStuff.DIPswitchesBtn.width/2, assets.uiStuff.DIPswitchesBtn.height/2);
    //if (!settings.getBoolean("hideDIPSwitchesButton", false)) image(assets.uiStuff.DIPswitchesBtn, dipswitchesButton.x, dipswitchesButton.y,dipswitchesButton.w,dipswitchesButton.h);

    //popStyle();
    //popMatrix();

    //pushMatrix(); // pillarboxing (for high aspect ratios)
    //pushStyle();
    //translate(0, 0);
    //float w = 2678 / 2 * SCALE;
    //fill(0, 0, 0, 1);
    //rect(0, 0, (width-w)/2, height);
    //rect((width-w)/2 + w, 0, (width-w)/2, height);
    //popStyle();
    //popMatrix();
  }

  void mouseUp() {

    //PVector m = screenspaceToWorldspace(mouseX, mouseY);

    //if (dipswitchesButton.inside(m)) {
    //  //println("you clicked dipswitch"); 
    //  Desktop desktop = Desktop.getDesktop();
    //  File dirToOpen = null;
    //  try {
    //    dirToOpen = new File(sketchPath());
    //    desktop.open(dirToOpen);
    //  } 
    //  catch (Exception iae) {
    //    System.out.println("File Not Found");
    //  }
    //}

    //if (optionsButton.inside(m) && settings.getBoolean("hideDIPSwitchesButton", false)==false) {
    //  options = !options;
    //}

    //if (options) {
    //  if (soundButton.inside(m)) {
    //    int sfx = settings.getInt("sfxVolume", 100);
    //    //settings.setInt("sfxVolume", sfx > 0 ? 0 : 100);
    //    assets.muteSFX(sfx > 0 ? true : false);
    //    //writeOutControls();
    //  }

    //  if (musicButton.inside(m)) {
    //    float msx = settings.getInt("musicVolume", 100);
    //    //settings.setInt("musicVolume", msx > 0 ? 0 : 100);
    //    assets.muteMusic(msx > 0 ? true : false);
    //    //writeOutControls();
    //  }

    //  if (restartButton.inside(m)) {
    //    int startAt = settings.getInt("startAtLevel", 4);

    //    validLvls.clear();
    //    validLvls.push(1);
    //    validLvls.push(4);
    //    if (highestUnlockedLevel() >= UIStory.JURASSIC   || settings.getBoolean("JurassicUnlocked", true)) validLvls.push(2); 
    //    if (highestUnlockedLevel() == UIStory.CRETACEOUS || settings.getBoolean("CretaceousUnlocked", true)) validLvls.push(3);
    //    validLvls.sort();

    //    // get index of current startAt setting
    //    int indexOfCurrent = 0;
    //    for (int i = 0; i < validLvls.size(); i++) {
    //      if (validLvls.get(i) == startAt) {
    //        indexOfCurrent = i;
    //        break;
    //      }
    //    }

    //    int nextOption = (indexOfCurrent+1) % validLvls.size(); // choose the next valid setting in the list by incrementing and wrapping current index
    //    //settings.setInt("startAtLevel", validLvls.get(nextOption));
    //    //writeOutControls();
    //  }

    //  if (launchFinderButton.inside(m)) {
    //    Desktop desktop = Desktop.getDesktop();
    //    File dirToOpen = null;
    //    try {
    //      dirToOpen = new File(sketchPath());
    //      desktop.open(dirToOpen);
    //    } 
    //    catch (Exception iae) {
    //      System.out.println("File Not Found");
    //    }
    //  }
    //}
  }

  void cleanup() {
    assets.stopAllMusic();
    assets.stopAllSfx();
  }

  //PVector screenToScaled (float x, float y) {
  //  return new PVector((x + WIDTH_REF_HALF) / SCALE, (y + HEIGHT_REF_HALF) / SCALE);
  //}

  //int nextScene () {
  //  return SINGLEPLAYER;
  //}
}

//class Oviraptor extends Scene {

//  Earth earth;
//  EventManager eventManager;
//  StarManager starManager;
//  RoidManager roids;
//  ColorDecider currentColor;
//  UIStory ui;
//  UFOManager ufoManager;
//  PlayerManager playerManager;
//  Time time;
//  Camera camera;
//  TrexManager trexManager;
//  GameScreenMessages gameText;

//  ArrayList<updateable> updaters = new ArrayList<updateable>();
//  ArrayList<renderableScreen> screenRenderers = new ArrayList<renderableScreen>();
//  ArrayList<renderable> renderers =  new ArrayList<renderable>();

//  Oviraptor(int lvl) {
//    sceneID = OVIRAPTOR;

//    eventManager = new EventManager();
//    time = new Time(eventManager);
//    earth = new Earth(time, eventManager, lvl);
//    camera = new Camera();
//    roids = new RoidManager(earth, eventManager, time);
//    currentColor = new ColorDecider();
//    starManager = new StarManager(currentColor, time, eventManager, lvl);
//    gameText = new GameScreenMessages(eventManager, currentColor);
//    playerManager = new PlayerManager(eventManager, earth, time, null, starManager, camera);
//    trexManager = new TrexManager(eventManager, time, earth, playerManager, currentColor, lvl);
//    ui = new UIStory(eventManager, time, currentColor, lvl);

//    updaters.add(time);
//    updaters.add(ui);
//    updaters.add(earth);
//    updaters.add(roids);
//    updaters.add(camera);
//    updaters.add(currentColor);
//    updaters.add(starManager);
//    updaters.add(playerManager);
//    updaters.add(trexManager);

//    renderers.add(playerManager);
//    renderers.add(trexManager);
//    renderers.add(earth);
//    renderers.add(roids);
//    renderers.add(starManager);

//    screenRenderers.add(gameText);
//    screenRenderers.add(ui);

//    status = RUNNING;

//    //trexManager.spawnTrex();
//  }

//  void update () {

//    for (updateable u : updaters) u.update();
//  }

//  void render () {

//    pushMatrix(); // world-space
//    translate(camera.x, camera.y);
//    scale(SCALE);
//    for (renderable r : renderers) r.render();
//    popMatrix(); 

//    pushMatrix(); // screen-space (UI)
//    translate(width/2, height/2);
//    scale(SCALE);
//    gameText.render();
//    assets.applyGlowiness();
//    ui.render();
//    popMatrix();

//    pushMatrix(); // pillarboxing (for high aspect ratios)
//    pushStyle();
//    translate(0, 0);
//    float w = 2678 / 2 * SCALE;
//    fill(0, 0, 0, 1);
//    rect(0, 0, (width-w)/2, height);
//    rect((width-w)/2 + w, 0, (width-w)/2, height);
//    popStyle();
//    popMatrix();
//  }

//  void mouseUp() {
//    println("somebody clicked");
//  }

//  void cleanup() {
//    assets.stopAllMusic();
//    assets.stopAllSfx();
//  }

//  //int nextScene () {
//  //  return SINGLEPLAYER;
//  //}
//}

//class testScene extends Scene {

//  Earth earth;
//  EventManager eventManager;
//  ColorDecider currentColor;
//  StarManager starManager;  
//  UIStory ui;
//  RoidManager roids;
//  //UFOManager ufoManager;
//  PlayerManager playerManager;
//  Time time;
//  Camera camera;
//  VolcanoManager volcanoManager;

//  ArrayList<updateable> updaters = new ArrayList<updateable>();
//  ArrayList<renderableScreen> screeenRenderers = new ArrayList<renderableScreen>();
//  ArrayList<renderable> renderers =  new ArrayList<renderable>();

//  testScene (int lvl) {
//    sceneID = TRIASSIC;

//    eventManager = new EventManager();
//    time = new Time(eventManager);
//    earth = new Earth(time, eventManager, lvl);
//    //earth.dr = 0;

//    camera = new Camera();
//    roids = new RoidManager(earth, eventManager, time);
//    currentColor = new ColorDecider();
//    starManager = new StarManager(currentColor, time, eventManager, lvl);
//    //starManager = new StarManager(currentColor, time);

//    //soundManager = new SoundManager(main, eventManager);
//    volcanoManager = new VolcanoManager(eventManager, time, currentColor, earth, lvl);
//    playerManager = new PlayerManager(eventManager, earth, time, volcanoManager, starManager, camera);
//    playerManager.spawningDuration = 10;
//    ui = new UIStory(eventManager, time, currentColor, lvl);
//    ui.score = 90;
//    //ufoManager = new UFOManager (currentColor, earth, playerManager, eventManager);

//    updaters.add(time);
//    //updaters.add(ui);
//    updaters.add(earth);
//    updaters.add(roids);
//    updaters.add(camera);
//    updaters.add(currentColor);
//    //updaters.add(starManager);
//    //updaters.add(ufoManager);
//    updaters.add(playerManager);
//    //updaters.add(volcanoManager);

//    //renderers.add(ufoManager);
//    renderers.add(playerManager);
//    //renderers.add(volcanoManager);

//    renderers.add(earth);
//    renderers.add(roids);
//    //renderers.add(starManager);

//    //screeenRenderers.add(ui);
//  }

//  void update () {

//    //if (time.getTick()==20) ufoManager.spawnUFOAbducting();

//    for (updateable u : updaters) u.update();
//  }

//  void render () {
//    //pushMatrix(); // world-space
//    //translate(camera.x, camera.y);
//    //for (renderable r : renderers) r.render();

//    //popMatrix(); // screen-space
//    //for (renderableScreen rs : screeenRenderers) rs.render(); // UI
//  }

//  void mouseUp() {
//    println("somebody clicked");
//  }

//  void cleanup() {
//    assets.stopAllMusic();
//    assets.stopAllSfx();
//  }

//  //int nextScene () {
//  //  return SINGLEPLAYER;
//  //}
//}

interface updateable {
  void update();
}

interface renderable {
  void render();
} 

interface renderableScreen {
  void render();
}
