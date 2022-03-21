abstract class Scene {

  abstract void update();
  abstract void render();
  abstract void mouseUp();
}

class SinglePlayer extends Scene {

  final static int TRIASSIC = 0;
  final static int JURASSIC = 1;
  final static int CRETACEOUS = 3;

  Earth earth;
  Time time = new Time();
  StarsSystem starsSystem = new StarsSystem();
  RoidManager roidManager = new RoidManager();
  VolcanoSystem volcanoSystem;
  ColorDecider currentColor = new ColorDecider();
  UIStory ui;
  UFO ufo;
  UFORespawn ufoRespawn;
  Camera camera = new Camera();
  Hypercube hypercube;
  //GameScreenMessages gameText;
  //MusicManager musicManager;
  //FinaleStuff finaleManager;
  Player player;
  PlayerRespawn playerRespawn;
  PlayerIntro playerIntro = new PlayerIntro();
  GameOver gameOver = new GameOver();
  EggHatch egg;
  Trex trex;
  GibsSystem playerDeathAnimation;

  int score;
  float lastScoreTick;
  boolean scoring;

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

  SinglePlayer(SimpleTXTParser settings, AssetManager assets) {

    PImage earthmodel;
    if (settings.getBoolean("earthIsPangea", false)) {
      if (settings.getBoolean("earthIsWest", true)) {
        earthmodel = assets.earthStuff.earthPangea1;
      } else {
        earthmodel = assets.earthStuff.earthPangea2;
      }
    } else {
      if (settings.getBoolean("earthIsWest", true)) {
        earthmodel = assets.earthStuff.earth;
      } else {
        earthmodel = assets.earthStuff.earth2;
      }
    }
    earth = new Earth(earthmodel, assets.earthStuff.mask);

    earth.dr = settings.getFloat("earthRotationSpeed", Earth.DEFAULT_EARTH_ROTATION);
    playerIntro.model = assets.playerStuff.brontoFrames[0];
    playerIntro.y = -Player.DIST_FROM_EARTH;

    player = new Player(assets.playerStuff.brontoSVG, assets.playerStuff.brontoFrames, assets.playerStuff.step, assets.playerStuff.tarStep);
    player.extraLives = settings.getInt("extraLives", 0);
    player.runSpeed = settings.getFloat("playerSpeed", Player.DEFAULT_RUNSPEED);

    playerRespawn = new PlayerRespawn(assets.playerStuff.brontoFrames[0]);

    roidManager.minSpawnInterval = settings.getFloat("roidImpactRateInMilliseconds", RoidManager.DEFAULT_SPAWN_RATE) - settings.getFloat("roidImpactRateVariation", RoidManager.DEFAULT_SPAWN_DEVIATION)/2;
    roidManager.maxSpawnInterval = settings.getFloat("roidImpactRateInMilliseconds", RoidManager.DEFAULT_SPAWN_RATE) + settings.getFloat("roidImpactRateVariation", RoidManager.DEFAULT_SPAWN_DEVIATION)/2;
    roidManager.initRoidPool(assets.roidStuff.roidFrames);
    roidManager.initSplodePool(assets.roidStuff.explosionFrames);
    roidManager.enabled = settings.getBoolean("roidsEnabled", true);

    starsSystem.spawnSomeStars();
    currentColor.update();

    ufo = new UFO(assets.ufostuff.ufoSVG);
    ufoRespawn = new UFORespawn(assets.ufostuff.ufoSVG);

    volcanoSystem = new VolcanoSystem(assets.volcanoStuff.volcanoFrames, assets.roidStuff.explosionFrames[0]);
    volcanoSystem.addVolcanos(earth);

    hypercube = new Hypercube();

    egg = new EggHatch(assets.trexStuff.eggCracked, assets.trexStuff.eggBurst, assets.trexStuff.trexIdle);
    earth.addChild(egg);

    trex = new Trex(assets.trexStuff.trexIdle, assets.trexStuff.trexHead, assets.trexStuff.trexRun1, assets.trexStuff.trexRun2, assets.trexStuff.stomp);
    earth.addChild(trex);

    playerDeathAnimation = new GibsSystem(assets.playerStuff.dethSVG, new PVector(28, 45));

    ui = new UIStory(assets.uiStuff.letterbox);

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

  void play (int lvl) {
    println("level: " + lvl);

    playerIntro.spawningStart = millis();
    ufo.startCountDown();

    if (lvl == TRIASSIC) {
      if (settings.getBoolean("hypercubesEnabled", true)) hypercube.startCountDown();
      score = 0;
    }

    if (lvl == JURASSIC) {
      if (settings.getBoolean("volcanosEnabled", true)) {
        volcanoSystem.spawn();
        volcanoSystem.startCountdown();
      }
      score = 100;
    }

    if (lvl == CRETACEOUS) {
      float angle = 0;
      if (settings.getBoolean("tarpitsEnabled", true)) {
        earth.spawnTarpit();
        angle = earth.tarpitAngle + 180;
      } else {
        angle = random(359);
      }

      if (settings.getBoolean("trexEnabled", true)) {
        egg.x = cos(radians(angle));
        egg.y = sin(radians(angle));
        egg.startAnimation();
      }
      score = 200;
    }

    lastScoreTick = time.getClock();
    scoring = true;
  }

  void update () {

    time.update();
    starsSystem.spin(time.getTimeScale());
    currentColor.update();

    // check if it's time to go from intro -> player control
    playerIntro.update();
    if (playerIntro.state == PlayerIntro.SPAWNING) {
      playerIntro.state = PlayerIntro.DONE;
      player.enabled = true;
      player.y = playerIntro.y;
      earth.addChild(player);
    }

    // respawn following getting extra life
    boolean canSpawn = playerRespawn.update(time.getClock());
    if (keys.anykey && canSpawn) {
      playerRespawn.enabled = false;
      player.enabled = true;
      player.y = playerIntro.y;
      earth.addChild(player);
      ufo.resumeCountDown();
    }

    for (Volcano v : volcanoSystem.volcanos) {
      if (v.state==Volcano.ERUPTING) {
        earth.shake(10);
        break;
      }
    }

    earth.move(time.getTimeScale(), time.getClock());

    // is player in tarpit
    earth.setStuckInTarpit(player);

    player.move(keys.left, keys.right, time.getTimeScale(), time.getClock(), time.getScaledElapsed(), volcanoSystem.volcanos);

    // player drowned in tarpit
    if (player.getAtTarpitBottom()) {

      playerDeathAnimation.fire(time.getClock(), player, trex.globalPos(), 0, .75, .5);
      earth.addChild(playerDeathAnimation);
      println("died in tarpit");
      if (player.extraLives <= 0) {
        player.restart();
        gameOver.callGameover();
        time.deathStart();
      } else {
        player.extraLives--;
        println("extra lives: " + player.extraLives);
        player.restart();
        time.deathStart();
        ufo.pauseCountDown();
        ufoRespawn.dispatch(player, earth.globalPos());
      }
    }

    boolean abducted = ufo.update(time.getClock(), time.getTimeScale(), earth.globalPos(), player);
    if (abducted) {
      player.extraLives++;
      player.restart();
      playerRespawn.respawn();
    }

    // respawn following losing extra life 
    Entity ufoRespawned = ufoRespawn.update(time.getClock(), time.getTimeScale(), earth.globalPos(), keys.anykey);
    if (ufoRespawned != null) {
      player.enabled = true;
      player.parent = null;
      player.setPosition(ufoRespawned.globalPos());
      player.r = ufoRespawned.r;
      earth.addChild(player);
    }

    volcanoSystem.update(time.getClock(), time.getTimeScale());

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

            PVector impactPointAdjusted = new PVector(earth.x + cos(incomingAngle) * Earth.EARTH_RADIUS, earth.y + sin(incomingAngle) * Earth.EARTH_RADIUS);
            playerDeathAnimation.fire(time.getClock(), player, impactPointAdjusted, 15, .98, .98); 

            println("died from roid");

            if (player.extraLives <= 0) {
              player.restart();
              gameOver.callGameover();
              time.deathStart();
              roidManager.killer = splode;
            } else {
              player.extraLives--;
              println("extra lives: " + player.extraLives);
              player.restart();
              time.deathStart();
              ufo.pauseCountDown();
              ufoRespawn.dispatch(player, earth.globalPos());
            }
          }
        }
      }
    }

    roidManager.updateExplosions(time.getClock());

    hypercube.update(starsSystem.xShiftThisFrame(), starsSystem.yShiftThisFrame());
    // time to spawn a hypercube?
    if (hypercube.state == Hypercube.READY) {
      hypercube.setPosition(starsSystem.lookAhead(Hypercube.hypercubeLead, Hypercube.hypercubeOffset));
      hypercube.state = Hypercube.NORM;
      println("spawn hypercube");
    }

    // player touching a hypercube?
    if (hypercube.state == Hypercube.NORM) {
      if (PVector.dist(player.globalPos(), hypercube.globalPos()) < Player.BOUNDING_CIRCLE_RADIUS + Hypercube.BOUNDING_CIRCLE_RADIUS) {
        hypercube.goHyperspace();
        time.setHyperspace(true);
        starsSystem.setHyperspace(true);
      }
    }

    // hyperspace finished?
    if (hypercube.state == Hypercube.HYPERSPACE_DONE) {
      time.setHyperspace(false);
      starsSystem.setHyperspace(false);
      hypercube.startCountDown();
    }

    egg.update(time.getClock());

    // handle egg hatching animations complete
    if (egg.enabled && egg.state == EggHatch.DONE) {
      egg.reset();
      trex.enabled = true;
      trex.x = egg.x;
      trex.y = egg.y;
      trex.r = egg.r;
      trex.facing = -1;
    }

    earth.setStuckInTarpit(trex);
    trex.update(time.getTimeScale(), time.getScaledElapsed(), player);
    if (trex.isStomping) earth.shake(8, 300, time.getClock());

    // is trex touching player
    if (player.enabled && trex.isDeadly()) {
      if (utils.unsignedAngleDiff(player.r, trex.r) < Player.BOUNDING_ARC/2 + Trex.BOUNDING_ARC/2) {

        playerDeathAnimation.fire(time.getClock(), player, trex.globalPos(), 10, .99, .999);
        println("died from trex");

        if (player.extraLives <= 0) {
          player.restart();
          gameOver.callGameover();
          time.deathStart();
        } else {
          player.extraLives--;
          println("extra lives: " + player.extraLives);
          player.restart();
          time.deathStart();
          ufo.pauseCountDown();
          ufoRespawn.dispatch(player, earth.globalPos());
        }
      }
    }

    playerDeathAnimation.update(time.getTimeScale(), time.getClock());

    // restart
    gameOver.update();
    if (gameOver.readyToRestart && keys.anykey) {
      playerIntro.startIntro();
      gameOver.restart();
      roidManager.restart();
      ufo.restart();
      trex.restart();
      earth.restart();
      time.setHyperspace(false);
      starsSystem.setHyperspace(false);
      play(TRIASSIC);
    }

    if (time.getClock() - lastScoreTick > 1000 && scoring) {
      score++;
      //score+=20;
      lastScoreTick = time.getClock();
    }

    if (score == 100) {
    } else if (score == 200) {
    } else if (score == 300) {
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
    playerRespawn.render();
    ufo.render(currentColor.getColor());
    ufoRespawn.render(currentColor.getColor());
    volcanoSystem.render(currentColor.getColor());
    earth.render(time.getClock());
    playerIntro.render();
    player.render();
    roidManager.renderRoids();
    roidManager.renderSplodes();
    starsSystem.render(currentColor.getColor());
    hypercube.render(time.getTimeScale(), currentColor.getColor());
    egg.render(currentColor.getColor());
    trex.render();
    playerDeathAnimation.render();
    popMatrix(); 

    assets.applyGlowiness();

    // matte (screen space)
    pushMatrix(); 
    pushStyle();
    noStroke();
    fill(0, 0, 0, 1);
    rect(0, 0, (width-height)/2, height);
    rect((width-height)/2 + height, 0, width, height);
    popStyle();
    popMatrix();

    // UI
    pushMatrix();
    translate(width/2, height/2);
    scale(SCALE);
    imageMode(CENTER);
    image(assets.uiStuff.screenShine, 0, 0);
    ui.render(player.extraLives, score);
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
