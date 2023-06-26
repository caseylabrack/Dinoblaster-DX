abstract class Scene {

  abstract void update();
  abstract void render();
  abstract void mouseUp();
}

class SinglePlayer extends Scene {

  final static int TRIASSIC = 0;
  final static int JURASSIC = 1;
  final static int CRETACEOUS = 3;
  final static int FINALE = 4;
  int stage;

  Earth earth;
  Time time = new Time();
  StarsSystem starsSystem = new StarsSystem();
  RoidManager roidManager = new RoidManager();
  VolcanoSystem volcanoSystem;
  ColorDecider currentColor;
  UIStory ui;
  UFO ufo;
  UFORespawn ufoRespawn;
  Camera camera = new Camera();
  Hypercube hypercube;
  //Player player;
  Player[] players;
  PlayerRespawn playerRespawn;
  PlayerIntro[] playerIntros = new PlayerIntro[2];
  //PlayerIntro playerIntro = new PlayerIntro();
  GameOver gameOver = new GameOver();
  EggHatch egg;
  EggRescue[] rescueEggs = new EggRescue[2];
  Trex trex;
  SPFinale finale;
  GibsSystem playerDeathAnimation;
  GibsSystem trexDeathAnimation;
  InGameText gameText;
  color[] twoPColors = new color[]{#FF00FF, #F08080};
  int numPlayers;

  boolean showingUI;

  int score;
  float lastScoreTick;
  boolean scoring = false;

  SoundPlayable music;

  //boolean options = false;
  Rectangle dipswitchesButton;
  //Rectangle optionsButton;
  //Rectangle soundButton;
  //Rectangle restartButton;
  //Rectangle musicButton;
  //Rectangle launchFinderButton;
  //float directoryTextYPos = 0;//32 + 10 + 32 + 10 + 32 + 10 + 10;
  //float yoffset = -5; // optically vertically center align text within rectangle buttons
  //IntList validLvls = new IntList();

  SinglePlayer(SimpleTXTParser settings, AssetManager assets, int numPlayers) {

    this.numPlayers = numPlayers;
    players = new Player[numPlayers];

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
    for (int i = 0; i <=1; i++) {
      playerIntros[i] = new PlayerIntro();
      playerIntros[i].model = i==0 ? assets.playerStuff.brontoFrames[0] : assets.playerStuff.oviFrames[0];
      playerIntros[i].y = Player.DIST_FROM_EARTH * (i==0 ? -1 : 1);
      playerIntros[i].r = i == 0 ? 0 : 180;
    }

    for (int i = 0; i <= (numPlayers - 1); i++) {
      players[i] = new Player(assets.playerStuff.brontoSVG, (i==0 ? assets.playerStuff.brontoFrames : assets.playerStuff.oviFrames), assets.playerStuff.step, assets.playerStuff.tarStep, twoPColors[i]);
      players[i].extraLives = settings.getInt("extraLives", 0);
      players[i].runSpeed = settings.getFloat("playerSpeed", Player.DEFAULT_RUNSPEED);
      players[i].id = i;
      players[i].usecolor = true;
    }

    for (int i = 0; i <= 1; i++) {
      rescueEggs[i] = new EggRescue(twoPColors[i], assets.playerStuff.eggWhole);
      //rescueEggs[i].enabled = true;
      earth.addChild(rescueEggs[i]);
    }

    playerRespawn = new PlayerRespawn(assets.playerStuff.brontoFrames[0]);

    roidManager.minSpawnInterval = settings.getFloat("roidImpactRateInMilliseconds", RoidManager.DEFAULT_SPAWN_RATE) - settings.getFloat("roidImpactRateVariation", RoidManager.DEFAULT_SPAWN_DEVIATION)/2;
    roidManager.maxSpawnInterval = settings.getFloat("roidImpactRateInMilliseconds", RoidManager.DEFAULT_SPAWN_RATE) + settings.getFloat("roidImpactRateVariation", RoidManager.DEFAULT_SPAWN_DEVIATION)/2;
    roidManager.initRoidPool(assets.roidStuff.roidFrames);
    roidManager.initSplodePool(assets.roidStuff.explosionFrames);
    roidManager.enabled = settings.getBoolean("roidsEnabled", true);

    starsSystem.spawnSomeStars();

    ufo = new UFO(assets.ufostuff.ufoSVG);
    ufoRespawn = new UFORespawn(assets.ufostuff.ufoSVG);

    volcanoSystem = new VolcanoSystem(assets.volcanoStuff.volcanoFrames, assets.roidStuff.explosionFrames[0]);
    volcanoSystem.addVolcanos(earth);

    hypercube = new Hypercube();
    hypercube.hyperspaceDuration = settings.getFloat("hyperspaceDuration", Hypercube.DEFAULT_HYPERSPACE_DURATION) * 1e3;

    egg = new EggHatch(assets.trexStuff.eggCracked, assets.trexStuff.eggBurst, assets.trexStuff.trexIdle);
    earth.addChild(egg);

    trex = new Trex(assets.trexStuff.trexIdle, assets.trexStuff.trexHead, assets.trexStuff.trexRun1, assets.trexStuff.trexRun2, assets.trexStuff.stomp, assets.trexStuff.rawr);
    trex.runSpeed = settings.getFloat("trexSpeed", Trex.DEFAULT_RUNSPEED);
    trex.attackAngle = settings.getFloat("trexAttackAngle", Trex.DEFAULT_ATTACK_ANGLE);
    earth.addChild(trex);

    playerDeathAnimation = new GibsSystem(assets.playerStuff.dethSVG, new PVector(28, 45));
    trexDeathAnimation = new GibsSystem(assets.trexStuff.deth, new PVector(52, 41));
    if (!settings.getBoolean("trexEnabled", true)) trexDeathAnimation.enabled = false;

    ui = new UIStory(assets.uiStuff.letterbox, assets.uiStuff.screenShine);
    ui.enabled = settings.getBoolean("showSidePanels", true);

    time.hyperspaceTimeScale = settings.getFloat("hyperspaceTimeScale", Time.HYPERSPACE_DEFAULT_TIME);
    time.setTimeScale(settings.getFloat("defaultTimeScale", 1));

    gameText = new InGameText(assets.uiStuff.extinctType, assets.uiStuff.MOTD, settings.getStrings("tips", assets.DEFAULT_TIPS));

    currentColor = new ColorDecider(settings.getStrings("colors", assets.DEFAULT_COLORS), assets.DEFAULT_COLORS);

    finale = new SPFinale(assets.roidStuff.bigone, assets.roidStuff.explosionFrames, new PShape[]{assets.ufostuff.ufoFinalSingle, assets.ufostuff.ufoFinalDuo, assets.ufostuff.ufoFinalDuoZoom}, assets.playerStuff.brontoSVG);

    music = assets.musicStuff.lvl1a;

    float dipwidth =  assets.uiStuff.DIPswitchesBtn.width;
    float dipheight = assets.uiStuff.DIPswitchesBtn.height;
    dipswitchesButton = new Rectangle(HEIGHT_REF_HALF + (WIDTH_REF_HALF - HEIGHT_REF_HALF) / 2 - dipwidth/2, HEIGHT_REF_HALF - dipheight, dipwidth, dipheight);
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

    // restart stuff
    //player.restart();
    for (Player p : players) p.restart();
    gameOver.restart();
    roidManager.restart();
    ufo.restart();
    volcanoSystem.restart();
    egg.reset();
    trex.restart();
    earth.restart();
    earth.dr = settings.getFloat("earthRotationSpeed", Earth.DEFAULT_EARTH_ROTATION);
    hypercube.restart();
    time.setTimeScale(time.defaultTimeScale);
    time.setHyperspace(false);
    starsSystem.setHyperspace(false);
    gameText.restart();
    finale.restart();
    music.stop_();
    music.rate(1);
    starsSystem.restart();

    gameText.showRandomTip();

    for (PlayerIntro playerIntro : playerIntros) {
      playerIntro.startIntro();
      playerIntro.spawningStart = millis();
    }
    //playerIntro.startIntro();
    //playerIntro.spawningStart = millis();
    assets.playerStuff.spawn.play();

    ufo.startCountDown();

    stage = lvl;

    if (lvl == TRIASSIC) {
      if (settings.getBoolean("hypercubesEnabled", true)) hypercube.startCountDown();
      score = 0;
      music = random(1) > .5 ? assets.musicStuff.lvl1a : assets.musicStuff.lvl1b;
    }

    if (lvl == JURASSIC) {
      if (settings.getBoolean("volcanosEnabled", true)) {
        volcanoSystem.spawn();
        volcanoSystem.startCountdown();
      }
      score = 100;
      music = random(1) > .5 ? assets.musicStuff.lvl2a : assets.musicStuff.lvl2b;
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
        egg.startAnimation(angle);
      }
      score = 200;
      music = assets.musicStuff.lvl3;
    }

    lastScoreTick = time.getClock();
    //earth.addChild(camera);
  }

  void update () {

    time.update();
    starsSystem.update(time.getTimeScale());
    currentColor.update();

    gameText.update();

    // check if it's time to go from intro -> player control
    for (PlayerIntro playerIntro : playerIntros) playerIntro.update();
    if (playerIntros[0].state == PlayerIntro.SPAWNING) {
      playerIntros[0].state = PlayerIntro.DONE;
      playerIntros[1].state = PlayerIntro.DONE;

      for (int i = 0; i <= (numPlayers - 1); i++) {
        players[i].enabled = true;
        players[i].y = playerIntros[i].y;
        players[i].r = playerIntros[i].r;
        earth.addChild(players[i]);
        players[i].ppos.set(players[i].localPos());
      }

      //for (Player player : players) {
      //  player.enabled = true;
      //  player.y = playerIntro.y;
      //  earth.addChild(player);
      //}
      //player.enabled = true;
      //player.y = playerIntro.y;
      //earth.addChild(player);
      scoring = true;
      lastScoreTick = time.getClock();
      music.play(true);
    }
    //playerIntro.update();
    //if (playerIntro.state == PlayerIntro.SPAWNING) {
    //  playerIntro.state = PlayerIntro.DONE;

    //  for (Player player : players) {
    //    player.enabled = true;
    //    player.y = playerIntro.y;
    //    earth.addChild(player);
    //  }
    //  //player.enabled = true;
    //  //player.y = playerIntro.y;
    //  //earth.addChild(player);
    //  scoring = true;
    //  lastScoreTick = time.getClock();
    //  music.play(true);
    //}

    // respawn following getting extra life
    //boolean canSpawn = playerRespawn.update(time.getClock());
    //if (keys.anykey && canSpawn) {
    //  playerRespawn.enabled = false;
    //  player.enabled = true;
    //  player.y = playerIntro.y;
    //  earth.addChild(player);
    //  ufo.resumeCountDown();
    //  scoring = true;
    //  lastScoreTick = time.getClock();
    //}

    //if(frameCount == 90) {
    // playerKilled(1); 
    //}


    for (EggRescue r : rescueEggs) r.update(time.getClock());

    // volcano eruption
    for (Volcano v : volcanoSystem.volcanos) {
      if (v.enabled && v.state==Volcano.ERUPTING) {
        earth.shake(10, 1, time.getClock());
        break;
      }
    }

    earth.move(time.getTimeScale(), time.getClock());

    // is player in tarpit
    for (Player p : players) earth.setStuckInTarpit(p);
    //println(players[0].inTarpit, players[1].inTarpit);

    players[0].move(keys.left, keys.right, time.getTimeScale(), time.getClock(), time.getScaledElapsed());
    players[1].move(false, false, time.getTimeScale(), time.getClock(), time.getScaledElapsed());
    //players[1].move(frameCount > 100 ? true : false, false, time.getTimeScale(), time.getClock(), time.getScaledElapsed());

    // check for collisions between players
    if (numPlayers==2 && players[0].enabled && players[1].enabled) {

      boolean colliding = false;

      //  //check tunnelling case
      float localAngOld1 = utils.angleOfOrigin(players[0].ppos);
      float localAngOld2 = utils.angleOfOrigin(players[1].ppos);
      float localAngNew1 = utils.angleOfOrigin(players[0].localPos());
      float localAngNew2 = utils.angleOfOrigin(players[1].localPos());
      float oldDiff = utils.signedAngleDiff(localAngOld1, localAngOld2);
      float newDiff = utils.signedAngleDiff(localAngNew1, localAngNew2);

      if (abs(newDiff) < 90 && utils.sign(oldDiff)!=utils.sign(newDiff)) colliding = true; // if they were close and their angle difference just switched sign, then they tunnelled
      if (colliding) println("tunnelling");

      if (abs(newDiff) < Player.BOUNDING_ARC) colliding = true;

      if (colliding) {
        //println(utils.signedAngleDiff(players[0].r, players[1].r), frameCount);

        //delta rotation around earth last frame for each
        float dr1 = utils.signedAngleDiff(localAngOld1, localAngNew1);
        float dr2 = utils.signedAngleDiff(localAngOld2, localAngNew2);

        //rewind to last frame, then walk up to the point of collision
        float a1 = localAngOld1;
        float a2 = localAngOld2;
        PVector oldPos1 = players[0].ppos.copy();
        PVector oldPos2 = players[1].ppos.copy();
        float rez = 10;
        float step1 = dr1 / rez;
        float step2 = dr2 / rez;
        int count = 0;
        float newA1, newA2, angDiff;
        do {
          a1 += step1;
          a2 += step2;

          oldPos1.x = cos(radians(a1)) * players[0].getRadius();
          oldPos1.y = sin(radians(a1)) * players[0].getRadius();

          oldPos2.x = cos(radians(a2)) * players[1].getRadius();
          oldPos2.y = sin(radians(a2)) * players[1].getRadius();

          newA1 = utils.angleOf(utils.ZERO_VECTOR, oldPos1);
          newA2 = utils.angleOf(utils.ZERO_VECTOR, oldPos2);
          angDiff = utils.unsignedAngleDiff(newA1, newA2);

          count++;
          if (count > rez) { 
            println("uh oh"); 
            break;
          }
        } while (angDiff > Player.BOUNDING_ARC);
        //println(utils.signedAngleDiff(walk1 - step1, walk2 - step2), frameCount);
        players[0].x = cos(radians(a1 - step1)) * players[0].getRadius();
        players[0].y = sin(radians(a1 - step1)) * players[0].getRadius();
        players[0].r = utils.angleOf(utils.ZERO_VECTOR, players[0].localPos()) + 90;
        players[1].x = cos(radians(a2 - step2)) * players[1].getRadius();
        players[1].y = sin(radians(a2 - step2)) * players[1].getRadius();
        players[1].r = utils.angleOf(utils.ZERO_VECTOR, players[1].localPos()) + 90;

        float an1 = utils.angleOf(utils.ZERO_VECTOR, players[0].localPos());
        float an2 = utils.angleOf(utils.ZERO_VECTOR, players[1].localPos());
        float newNewDiff = utils.signedAngleDiff(an1, an2) * -1;
        println(newDiff, angDiff, newNewDiff);

        if (!players[0].inTarpit) players[0].bounceStart(time.getClock(), utils.sign(newNewDiff));
        if (!players[1].inTarpit) players[1].bounceStart(time.getClock(), utils.sign(newNewDiff) * -1);
      }
    }

    // check for collisions against blockers (volcanos)
    for (Player p : players) {
      for (Volcano v : volcanoSystem.volcanos) {

        if (!v.enabled || v.isPassable()) continue;

        boolean colliding = false;
        float lastR = utils.angleOfOrigin(p.ppos);
        float currentR = utils.angleOfOrigin(p.localPos());
        float obR = utils.angleOfOrigin(v.localPos());
        float olddiff = utils.signedAngleDiff(lastR,obR);
        float diff = utils.signedAngleDiff(currentR, obR);
        // check tunnelling case
        if (abs(diff) < 90 && utils.sign(diff)!=utils.sign(olddiff)) colliding = true; // if they were close and their angle difference just switched sign, then they tunnelled
        if(colliding) println("tunnelled");
        boolean tunnelled = false;
        if(colliding) tunnelled = true;

        if (abs(diff) < Player.BOUNDING_ARC / 2 + v.getArc() / 2) colliding = true;
        if (colliding) {
          println(utils.sign(diff), diff, frameCount);
          if(diff==0) paused = true;

          println("hit a volcano", frameCount);
          float fixedAngle = obR + v.getArc() * utils.sign(diff) * (tunnelled ? 1 : -1);
          p.x = cos(radians(fixedAngle)) * p.getRadius();
          p.y = sin(radians(fixedAngle)) * p.getRadius();
          p.r = utils.angleOfOrigin(p.localPos()) + 90;
          float updatedAngle = utils.angleOfOrigin(p.localPos());
          float updateddiff = utils.signedAngleDiff(updatedAngle,obR);
          println("updated angle", updatedAngle, updateddiff, frameCount);
        }
      }
    }

    // player drowned in tarpit
    //if (player.getAtTarpitBottom()) {

    //  playerDeathAnimation.fire(time.getClock(), player, trex.globalPos(), 0, .75, .5);
    //  earth.addChild(playerDeathAnimation);
    //  println("died in tarpit");
    //  playerKilled();
    //}

    //boolean abducted = ufo.update(time.getClock(), time.getTimeScale(), earth.globalPos(), player);
    //if (abducted) {
    //  player.extraLives++;
    //  player.restart();
    //  playerRespawn.respawn();
    //  scoring = false;
    //}

    // respawn following losing extra life 
    //Entity ufoRespawned = ufoRespawn.update(time.getClock(), time.getTimeScale(), earth.globalPos(), keys.anykey);
    //if (ufoRespawned != null) {
    //  player.enabled = true;
    //  player.parent = null;
    //  player.setPosition(ufoRespawned.globalPos());
    //  player.r = ufoRespawned.r;
    //  earth.addChild(player);
    //  scoring = true;
    //  lastScoreTick = time.getClock();
    //}

    volcanoSystem.update(time.getClock(), time.getTimeScale());

    if (score < 290) roidManager.fireRoids(time.getClock(), earth.globalPos());
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

        assets.roidStuff.hits[int(random(0, 5))].play();

        // did the player get hit
        for (Player player : players) {
          if (player.enabled) {
            if (utils.unsignedAngleDiff(splode.r, player.r) < Player.BOUNDING_ARC/2 + Explosion.BOUNDING_ARC/2) {

              PVector impactPointAdjusted = new PVector(earth.x + cos(incomingAngle) * Earth.EARTH_RADIUS, earth.y + sin(incomingAngle) * Earth.EARTH_RADIUS);
              playerDeathAnimation.fire(time.getClock(), player, impactPointAdjusted, 15, .98, .98); 

              println("died from roid");

              playerKilled(player.id);
            }
          }
        }
        //if (player.enabled) {
        //  if (utils.unsignedAngleDiff(splode.r, player.r) < Player.BOUNDING_ARC/2 + Explosion.BOUNDING_ARC/2) {

        //    PVector impactPointAdjusted = new PVector(earth.x + cos(incomingAngle) * Earth.EARTH_RADIUS, earth.y + sin(incomingAngle) * Earth.EARTH_RADIUS);
        //    playerDeathAnimation.fire(time.getClock(), player, impactPointAdjusted, 15, .98, .98); 

        //    println("died from roid");

        //    playerKilled();
        //  }
        //}
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
    //if (hypercube.state == Hypercube.NORM && hypercube.enabled) {
    //  if (PVector.dist(player.globalPos(), hypercube.globalPos()) < Player.BOUNDING_CIRCLE_RADIUS + Hypercube.BOUNDING_CIRCLE_RADIUS) {
    //    hypercube.goHyperspace();
    //    time.setHyperspace(true);
    //    starsSystem.setHyperspace(true);
    //    music.rate(time.hyperspaceTimeScale);
    //  }
    //}

    // hyperspace finished?
    if (hypercube.state == Hypercube.HYPERSPACE_DONE) {
      time.setHyperspace(false);
      starsSystem.setHyperspace(false);
      hypercube.startCountDown();
      music.rate(1);
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

      assets.trexStuff.rawr.play();
    }

    earth.setStuckInTarpit(trex);
    //trex.update(time.getTimeScale(), time.getScaledElapsed(), player);
    if (trex.isStomping) earth.shake(8, 300, time.getClock());

    // is trex touching player
    //if (player.enabled && trex.isDeadly()) {
    //  if (utils.unsignedAngleDiff(player.r, trex.r) < Player.BOUNDING_ARC/2 + Trex.BOUNDING_ARC/2) {

    //    playerDeathAnimation.fire(time.getClock(), player, trex.globalPos(), 10, .99, .999);
    //    println("died from trex");

    //    playerKilled();
    //  }
    //}

    playerDeathAnimation.update(time.getTimeScale(), time.getClock());
    trexDeathAnimation.update(time.getTimeScale(), time.getClock());

    gameText.update();

    // restart
    gameOver.update();
    if (gameOver.readyToRestart && keys.anykey) {
      play(stage);
    }

    if (time.getClock() - lastScoreTick > 1000 && scoring) {
      if (scoring) score++;
      lastScoreTick = time.getClock();
    }

    if (score == 85 && hypercube.enabled && hypercube.state == Hypercube.COUNTING_DOWN) hypercube.enabled = false; // don't spawn a hypercube right before jurassic transition
    if (score == 185 && volcanoSystem.spawning) volcanoSystem.spawning = false; // don't spawn a volcanos right before cretaceous transition
    if (score == 260 && ufo.countingDown) ufo.countingDown = false; // don't spawn a UFO right before finale

    if (score == 100 && stage != JURASSIC) {
      stage = JURASSIC;
      if (settings.getBoolean("volcanosEnabled", true)) {
        volcanoSystem.spawn();
        volcanoSystem.startCountdown();
      }
      music.stop_();
      music = random(1) > .5 ? assets.musicStuff.lvl2a : assets.musicStuff.lvl2b;
      music.play(true);
    } else if (score == 200 && stage != CRETACEOUS) {
      stage = CRETACEOUS;

      volcanoSystem.shutdownVolcanos(time.getClock());

      float angle = 0;
      if (settings.getBoolean("tarpitsEnabled", true)) {
        earth.spawnTarpit();
        angle = earth.tarpitAngle + 180;
      } else {
        angle = random(359);
      }

      if (settings.getBoolean("trexEnabled", true)) {
        egg.startAnimation(angle);
      }
      music.stop_();
      music = assets.musicStuff.lvl3;
      music.play(true);
    } else if (score == 300 && stage != FINALE) {
      stage = FINALE;
      scoring = false;
      music.stop_();

      finale.state = trex.enabled && trex.state == Trex.WALKING ? SPFinale.WAITING_TREX : SPFinale.NO_TREX; // if trex is alive, prepare to hit it with the big one. otherwise just start big one.
      if (!(trex.enabled && trex.state == Trex.WALKING)) trexDeathAnimation.enabled = false;
      trex.stun();

      println("finale time");
    }

    // do the finale
    //finale.update(earth, trex, player, time);
    //if (finale.died && player.enabled) {
    //  float angle = utils.angleOfRadians(earth.globalPos(), player.globalPos());
    //  playerDeathAnimation.fire(time.getClock(), player, new PVector(cos(angle) * (Earth.EARTH_RADIUS - 20), sin(angle) * (Earth.EARTH_RADIUS - 20)), 15, .98, .98); 
    //  player.extraLives = 0;
    //  playerKilled();
    //}
    //if (finale.won && player.enabled) {
    //  player.restart();
    //}
    //if (finale.state == SPFinale.PULLING_AWAY) {
    //  earth.dy *= .99;
    //}
    //if (finale.state == SPFinale.ZOOMING && !starsSystem.isZooming) {
    //  starsSystem.startZooming();
    //} 
    //if (finale.state == SPFinale.PULLING_AWAY && finale.lastState != SPFinale.PULLING_AWAY) {
    //  time.timeScale = 1;
    //  earth.dx = -2;
    //  earth.dy = -2;
    //  earth.shake(0);
    //  earth.dr = settings.getFloat("earthRotationSpeed", Earth.DEFAULT_EARTH_ROTATION);
    //}
    //if (finale.state == SPFinale.DONE && finale.lastState == SPFinale.ABORT) {
    //  earth.shake(0);
    //  time.timeScale = 1;
    //  earth.dr = settings.getFloat("earthRotationSpeed", Earth.DEFAULT_EARTH_ROTATION);
    //}
    //if (finale.state == SPFinale.EXPLODING && finale.lastState != SPFinale.EXPLODING) {
    //  music.play(true);
    //  float angle = utils.angleOfRadians(earth.globalPos(), trex.globalPos());
    //  if (trex.enabled && trex.state == Trex.STUNNED) trexDeathAnimation.fire(time.getClock(), trex, new PVector(cos(angle) * (Earth.EARTH_RADIUS - 20), sin(angle) * (Earth.EARTH_RADIUS - 20)), 50, .99, .99, 50);
    //  trex.vanish();
    //}

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

    for (Player p : players) {
      p.ppos.set(p.localPos());
      p.pr = p.r;
    }
  }

  void render () {

    // world-space
    pushMatrix(); 
    translate(-camera.globalPos().x + width/2, -camera.globalPos().y + height/2);
    scale(SCALE);
    //scale(2);
    //rotate(radians(-player.globalRote()));
    rotate(radians(-camera.globalRote()));
    playerRespawn.render();
    ufo.render(currentColor.getColor());
    ufoRespawn.render(currentColor.getColor());
    volcanoSystem.render(currentColor.getColor());
    finale.render(earth); // behind earth
    earth.render(time.getClock());
    for (PlayerIntro playerIntro : playerIntros) playerIntro.render();
    for (Player player : players) player.render();
    for (EggRescue r : rescueEggs) r.render();
    //player.render();
    roidManager.renderRoids();
    roidManager.renderSplodes();
    starsSystem.render(currentColor.getColor());
    hypercube.render(time.getTimeScale(), currentColor.getColor());
    egg.render(currentColor.getColor());
    trex.render();
    playerDeathAnimation.render();
    trexDeathAnimation.render();
    gameText.render(currentColor.getColor());
    finale.renderBigOne(); // in front of earth
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
    ui.render(players[0].extraLives, score);
    popMatrix();

    pushMatrix(); // screen-space (UI)
    pushStyle();
    translate(width/2, height/2);
    scale(SCALE);
    imageMode(CORNER);
    rectMode(CORNER);
    if (!settings.getBoolean("hideDIPSwitchesButton", false)) image(assets.uiStuff.DIPswitchesBtn, dipswitchesButton.x, dipswitchesButton.y, dipswitchesButton.w, dipswitchesButton.h);

    popStyle();
    popMatrix();
  }

  void playerKilled(int id) {
    scoring = false;
    //time.deathStart();

    rescueEggs[id].setPosition(players[id].localPos());
    rescueEggs[id].r = players[id].r;
    rescueEggs[id].enabled = true;

    players[id].restart();



    //if (player.extraLives <= 0) {
    //  gameOver.callGameover();
    //  gameText.goExtinct();
    //  assets.playerStuff.extinct.play(false);
    //  music.stop_();
    //} else {
    //  player.extraLives--;
    //  ufo.pauseCountDown();
    //  ufoRespawn.dispatch(player, earth.globalPos());
    //  assets.playerStuff.littleDeath.play(false);
    //}
  }

  void mouseUp() {

    PVector m = screenspaceToWorldspace(mouseX, mouseY);

    if (dipswitchesButton.inside(m)) {
      //println("you clicked dipswitch"); 
      //Desktop desktop = Desktop.getDesktop();
      //File dirToOpen = null;
      //try {
      //  dirToOpen = new File(sketchPath());
      //  desktop.open(dirToOpen);
      //} 
      //catch (Exception e) {
      //  System.out.println("File Not Found");
      //}
      paused = true;
      launch(sketchPath() + "\\DIP-switches.txt");
    }

    players[0].bounceStart(time.getClock(), -1);
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
