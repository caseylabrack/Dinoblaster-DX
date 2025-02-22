abstract class Scene { 

  abstract void update();
  abstract void renderPreGlow();
  abstract void renderPostGlow();
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
  UIStory ui;
  UFO ufo;
  UFORespawn ufoRespawn;
  Camera camera = new Camera();
  Hypercube hypercube;
  Player[] players = new Player[2];
  PlayerRespawn[] playerRespawns = new PlayerRespawn[2];
  PlayerIntro[] playerIntros = new PlayerIntro[2];
  EggHatch egg;
  EggRescue[] rescueEggs = new EggRescue[2];
  Trex trex;
  SPFinale finale;
  GibsSystem[] playerDeathAnimations = new GibsSystem[2];
  GibsSystem trexDeathAnimation;
  InGameText gameText;
  int numPlayers = 1;

  int extraLives, startingExtraLives;

  boolean showingUI;

  int score, highscore;
  float lastScoreTick;
  boolean scoring = false;

  boolean wantToPause = false;

  SoundPlayable music;
  
  ArrayList<SoundPlayable> soundsToTimeScale = new ArrayList<SoundPlayable>(); 

  SinglePlayer(SimpleTXTParser settings, AssetManager assets) {

    soundsToTimeScale.add(assets.playerStuff.step);
    soundsToTimeScale.add(assets.playerStuff.tarStep);
    for(SoundPlayable s : assets.roidStuff.hits) soundsToTimeScale.add(s);
    soundsToTimeScale.add(assets.trexStuff.rawr);
    soundsToTimeScale.add(assets.trexStuff.stomp);
    
    highscore = loadHighScore(SAVE_FILENAME);

    earth = new Earth(assets.earthStuff.mask);
    
    for (int i = 0; i <=1; i++) {
      playerIntros[i] = new PlayerIntro();
      playerIntros[i].model = i==0 ? assets.playerStuff.brontoFrames[0] : assets.playerStuff.oviFrames[0];
      playerIntros[i].y = Player.DIST_FROM_EARTH * (i==0 ? -1 : 1);
      playerIntros[i].r = i == 0 ? 0 : 180;
    }

    for (int i = 0; i < 2; i++) {   
      players[i] = new Player((i==0 ? assets.playerStuff.brontoSVG : assets.playerStuff.oviSVG), (i==0 ? assets.playerStuff.brontoFrames : assets.playerStuff.oviFrames), (i==0 ? assets.playerStuff.step : assets.playerStuff.step2), assets.playerStuff.tarStep);
      players[i].id = i;
    }

    for (int i = 0; i <= 1; i++) {
      rescueEggs[i] = new EggRescue(assets.playerStuff.eggFrames, i, i==0 ? assets.playerStuff.brontoFrames[0] : assets.playerStuff.oviFrames[0]);
      //rescueEggs[i].enabled = true;
      earth.addChild(rescueEggs[i]);
    }

    for (int i = 0; i < 2; i++) {
      playerRespawns[i] = new PlayerRespawn(i==0 ? assets.playerStuff.brontoFrames[0] : assets.playerStuff.oviFrames[0]);
    }

    roidManager.initRoidPool(assets.roidStuff.roidFrames);
    roidManager.initSplodePool(assets.roidStuff.explosionFrames);

    starsSystem.spawnSomeStars();

    ufo = new UFO(assets.ufostuff.ufoSVG);
    ufoRespawn = new UFORespawn(assets.ufostuff.ufoSVG);

    volcanoSystem = new VolcanoSystem(assets.volcanoStuff.volcanoFrames, assets.roidStuff.explosionFrames[0]);
    volcanoSystem.addVolcanos(earth);

    hypercube = new Hypercube();

    egg = new EggHatch(assets.trexStuff.eggCracked, assets.trexStuff.eggBurst, assets.trexStuff.trexIdle);
    earth.addChild(egg);

    trex = new Trex(assets.trexStuff.trexIdle, assets.trexStuff.trexHead, assets.trexStuff.trexRun1, assets.trexStuff.trexRun2, assets.trexStuff.stomp, assets.trexStuff.rawr);
    earth.addChild(trex);

    playerDeathAnimations[0] = new GibsSystem(assets.playerStuff.dethSVG, new PVector(28, 45));
    playerDeathAnimations[1] = new GibsSystem(assets.playerStuff.oviDethSVG, new PVector(28, 45));

    trexDeathAnimation = new GibsSystem(assets.trexStuff.deth, new PVector(52, 41));
    if (!settings.getBoolean("trexEnabled", true)) trexDeathAnimation.enabled = false;

    ui = new UIStory(assets.uiStuff.letterbox, assets.uiStuff.screenShine, assets.uiStuff.buttons);

    time.hyperspaceTimeScale = settings.getFloat("hyperspaceTimeScale", Time.HYPERSPACE_DEFAULT_TIME);

    gameText = new InGameText(assets.uiStuff.extinctType, assets.uiStuff.MOTD);

    finale = new SPFinale(assets.roidStuff.bigone, new PShape[]{assets.ufostuff.ufoFinalSingle, assets.ufostuff.ufoFinalDuo, assets.ufostuff.ufoFinalDuoZoom}, assets.playerStuff.brontoSVG);

    music = assets.musicStuff.lvl1a;
  }

  void loadSettings (SimpleTXTParser settings) {
    if (settings.getBoolean("earthIsPangea", false)) {
      if (settings.getBoolean("earthIsWest", true)) {
        earth.model = assets.earthStuff.earthPangea1;
      } else {
        earth.model = assets.earthStuff.earthPangea2;
      }
    } else {
      if (settings.getBoolean("earthIsWest", true)) {
        earth.model = assets.earthStuff.earth;
      } else {
        earth.model = assets.earthStuff.earth2;
      }
    }
    earth.targetRotationRate = settings.getFloat("earthRotationSpeed", Earth.DEFAULT_EARTH_ROTATION);
    earth.dr = earth.targetRotationRate;

    players[0].runSpeed = settings.getFloat("playerSpeed", Player.DEFAULT_RUNSPEED);
    players[1].runSpeed = players[0].runSpeed;

    color p1tryColor = currentColor.parseColorString(settings.getString("player1Color", Player.P1_DEFAULT_COLOR));
    color p1color = p1tryColor == -1 ? currentColor.parseColorString(Player.P1_DEFAULT_COLOR) : p1tryColor; // check for failure to parse
    players[0].c = p1color;
    playerIntros[0].colour = p1color;
    playerRespawns[0].colour = p1color;
    rescueEggs[0].pcolor = p1color;
    playerDeathAnimations[0].c = p1color;

    color p2tryColor = currentColor.parseColorString(settings.getString("player2Color", Player.P2_DEFAULT_COLOR));
    color p2color = p2tryColor == -1 ? currentColor.parseColorString(Player.P2_DEFAULT_COLOR) : p2tryColor; // check for failure to parse
    players[1].c = p2color;
    playerIntros[1].colour = p2color;
    playerRespawns[1].colour = p2color;
    rescueEggs[1].pcolor = p2color;
    playerDeathAnimations[1].c = p2color;

    for (PlayerIntro p : playerIntros) p.dontFlicker = settings.getBoolean("reduceFlashing", false);
    for (EggRescue e : rescueEggs) e.dontFlicker = settings.getBoolean("reduceFlashing", false);
    for (PlayerRespawn p : playerRespawns) p.dontFlicker = settings.getBoolean("reduceFlashing", false);

    startingExtraLives = settings.getInt("extraLives", 0);

    roidManager.enabled = settings.getBoolean("roidsEnabled", true);
    roidManager.fireRate = 1 / settings.getFloat("roidsPerSecond", RoidManager.DEFAULT_SPAWN_RATE);

    trex.runSpeed = settings.getFloat("trexSpeed", Trex.DEFAULT_RUNSPEED);
    trex.attackAngle = settings.getFloat("trexAttackAngle", Trex.DEFAULT_ATTACK_ANGLE); 
    boolean t = settings.getBoolean("trexEnabled", true);
    if (!t) trex.enabled = false;

    hypercube.hyperspaceDuration = settings.getFloat("hyperspaceDurationInSeconds", Hypercube.DEFAULT_HYPERSPACE_DURATION) * 1e3;
    boolean h = settings.getBoolean("hypercubesEnabled", true);
    if (!h) hypercube.enabled = false;

    boolean z = settings.getBoolean("volcanosEnabled", true);
    if (!z) for (Volcano v : volcanoSystem.volcanos) v.enabled = false;

    boolean u = settings.getBoolean("ufosEnabled", true);
    if (!u) ufo.enabled = false;
    ufo.spawnTimeLow = settings.getFloat("ufoSpawnRateLow", UFO.DEFAULT_SPAWNRATE_LOW);
    ufo.spawnTimeHigh = settings.getFloat("ufoSpawnRateHigh", UFO.DEFAULT_SPAWNRATE_HIGH);

    time.setDefaultTimeScale(settings.getFloat("defaultTimeScale", Time.DEFAULT_DEFAULT_TIME_SCALE));
    time.setHyperTimeScale(settings.getFloat("hyperspaceTimeScale", Time.HYPERSPACE_DEFAULT_TIME));

    ui.hideButtons = settings.getBoolean("hideButtons", false);
    ui.hideAll = settings.getBoolean("hideSidePanels", false);

    gameText.setTips(settings.getStrings("tips", assets.DEFAULT_TIPS));
    gameText.dontFlicker = settings.getBoolean("reduceFlashing", false);
    
    starsSystem.defaultTimeScale = settings.getFloat("defaultTimeScale", Time.DEFAULT_DEFAULT_TIME_SCALE);
    starsSystem.hyperTimeScale = settings.getFloat("hyperspaceTimeScale", Time.DEFAULT_DEFAULT_TIME_SCALE);
  }

  boolean canPlayLevel (int lvl) {
    boolean canPlay = true;
    switch(lvl) {
    case TRIASSIC:
      break;

    case JURASSIC:
      if (highscore < 100 && !jurassicUnlocked) canPlay = false;
      break;

    case CRETACEOUS:
      if (highscore < 200 && !cretaceousUnlocked) canPlay = false;
      break;
    }
    return canPlay;
  }

  void play (int lvl) {
    println("level: " + lvl + "  highscore: " + highscore);

    assets.stopAllMusic();
    assets.stopAllSfx();

    // restart stuff
    for (Player p : players) {
      p.restart();
      p.usecolor = numPlayers == 2;
    }
    if (numPlayers==1) {
      players[1].enabled = false;
    } 
    for (PlayerRespawn p : playerRespawns) {
      p.restart();
      p.usecolor = numPlayers == 2;
    }
    for (GibsSystem g : playerDeathAnimations) g.useColor = numPlayers == 2;
    for (EggRescue r : rescueEggs) r.reset();
    extraLives = startingExtraLives;
    roidManager.restart();
    ufo.restart();
    ufoRespawn.restart();
    volcanoSystem.restart();
    egg.reset();
    trex.restart();
    earth.restart();
    hypercube.restart();
    time.restart();
    starsSystem.setHyperspace(false);
    gameText.restart();
    finale.restart();
    music.stop_();
    music.rate(1);
    starsSystem.restart();

    gameText.showRandomTip();

    time.update(); // to initialize the clock if this is first time this method is invoked

    for (int i = 0; i < numPlayers; i++) {
      playerIntros[i].startIntro();
      playerIntros[i].spawningStart = millis();
      playerIntros[i].usecolor = numPlayers == 2;
    }
    assets.playerStuff.spawn.play();

    if (settings.getBoolean("ufosEnabled", true)) ufo.startCountDown();

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
        egg.startAnimation(angle, time.getClock());
        println("init clock: " + time.getClock());
      }
      score = 200;
      music = assets.musicStuff.lvl3;
    }

    //score = 295;

    lastScoreTick = time.getClock();
    //earth.addChild(camera);
  }

  void update () {

    time.update();
    starsSystem.update(time.getTimeScale(), time.getTargetTimeScale());
    //currentColor.update();
    gameText.update();
    
    for(SoundPlayable s : soundsToTimeScale) s.rate(time.getTargetTimeScale());
    music.rate(time.getTargetTimeScale());

    scoring = numPlayers == 2 ? (players[0].enabled && players[1].enabled) : players[0].enabled;

    // check if it's time to go from intro -> player control
    for (PlayerIntro playerIntro : playerIntros) playerIntro.update();
    if (playerIntros[0].state == PlayerIntro.SPAWNING) {
      playerIntros[0].state = PlayerIntro.DONE;
      playerIntros[1].state = PlayerIntro.DONE;

      for (int i = 0; i < numPlayers; i++) {
        players[i].enabled = true;
        players[i].y = playerIntros[i].y;
        players[i].r = playerIntros[i].r;
        earth.addChild(players[i]);
        players[i].ppos.set(players[i].localPos());
      }

      //scoring = true;
      lastScoreTick = time.getClock();
      music.play(true);
    }

    //if (frameCount == 90) {
    //  playerKilled(1);
    //}

    // volcano eruption
    for (Volcano v : volcanoSystem.volcanos) {
      if (v.enabled && v.state==Volcano.ERUPTING) {
        earth.shake(10, 1, time.getClock());
        break;
      }
    }

    earth.move(time.getTimeScale(), time.getClock());

    // is player in tarpit
    for (Player p : players) {
      p.inTarpit = false;
      if (!earth.tarpitEnabled) continue;
      if (!p.grounded) continue;
      p.inTarpit = utils.unsignedAngleDiff(utils.angleOfOrigin(p.localPos()), earth.tarpitAngle) < Earth.TARPIT_ARC / 2;
    }

    players[0].move(keys.p1Left(), keys.p1Right(), time.getTimeScale(), time.getClock(), time.getScaledElapsed());
    players[1].move(keys.p2Left(), keys.p2Right(), time.getTimeScale(), time.getClock(), time.getScaledElapsed());

    // check for collisions between players
    if (numPlayers==2 && players[0].enabled && players[1].enabled) {

      boolean colliding = false;

      //check tunnelling case
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

        if (!players[0].inTarpit) players[0].bounceStart(utils.sign(newNewDiff) * Player.PLAYER_COLLISION_BOUNCE_FORCE);
        if (!players[1].inTarpit) players[1].bounceStart(utils.sign(newNewDiff) * -1 * Player.PLAYER_COLLISION_BOUNCE_FORCE);
      }
    }

    // check for collisions against volcanos
    for (Player p : players) {
      for (Volcano v : volcanoSystem.volcanos) {

        if (!v.enabled || v.isPassable() || !p.enabled) continue;

        boolean colliding = false;
        float lastR = utils.angleOfOrigin(p.ppos);
        float currentR = utils.angleOfOrigin(p.localPos());
        float obR = utils.angleOfOrigin(v.localPos());
        float olddiff = utils.signedAngleDiff(lastR, obR);
        float diff = utils.signedAngleDiff(currentR, obR);
        // check tunnelling case
        if (abs(diff) < 90 && utils.sign(diff)!=utils.sign(olddiff)) colliding = true; // if they were close and their angle difference just switched sign, then they tunnelled
        if (colliding) println("tunnelled");
        boolean tunnelled = false;
        if (colliding) tunnelled = true;

        if (abs(diff) < Player.BOUNDING_ARC / 2 + v.getArc() / 2) colliding = true;
        if (colliding) {
          if (diff==0) {
            paused = true;
            println("diff zero against volcano?");
          }

          float fixedAngle = obR + v.getArc() * utils.sign(diff) * (tunnelled ? 1 : -1);
          p.x = cos(radians(fixedAngle)) * p.getRadius();
          p.y = sin(radians(fixedAngle)) * p.getRadius();
          p.r = utils.angleOfOrigin(p.localPos()) + 90;
        }
      }
    }

    // player collision against player eggs
    for (Player p : players) {
      for (EggRescue e : rescueEggs) {

        if (!p.enabled || !e.enabled || e.state == EggRescue.BURST || e.player == p.id) continue;

        boolean colliding = false;
        float lastR = utils.angleOfOrigin(p.ppos);
        float currentR = utils.angleOfOrigin(p.localPos());
        float obR = utils.angleOfOrigin(e.localPos());
        float olddiff = utils.signedAngleDiff(lastR, obR);
        float diff = utils.signedAngleDiff(currentR, obR);
        // check tunnelling case
        if (abs(diff) < 90 && utils.sign(diff)!=utils.sign(olddiff)) colliding = true; // if they were close and their angle difference just switched sign, then they tunnelled
        if (colliding) println("tunnelled");
        boolean tunnelled = false;
        if (colliding) tunnelled = true;

        if (abs(diff) < Player.BOUNDING_ARC / 2 + e.getArc() / 2) colliding = true;
        if (colliding) {
          if (diff==0) {
            paused = true;
            println("diff zero against egg?");
          }

          float fixedAngle = obR + e.getArc() * utils.sign(diff) * (tunnelled ? 1 : -1);
          p.x = cos(radians(fixedAngle)) * p.getRadius();
          p.y = sin(radians(fixedAngle)) * p.getRadius();
          p.r = utils.angleOfOrigin(p.localPos()) + 90;
          e.bounce(time.getClock());
          //p.bounceStart(utils.sign(diff) * -1);
          p.bounceStart(utils.sign(diff) * -1 * Player.PLAYER_COLLISION_BOUNCE_FORCE);
        }
      }
    }

    // do 2player egg rescue
    for (EggRescue e : rescueEggs) {
      e.update(time.getClock(), e.player == 0 ? keys.p1Left() : keys.p2Left(), e.player == 0 ? keys.p1Right() : keys.p2Right());
      if (e.state == EggRescue.BURST && !players[e.player].enabled && (e.player==0 ? keys.p1anykey() : keys.p2anykey())) {
        earth.addChild(players[e.player]);
        players[e.player].enabled = true;
        players[e.player].x = e.x;
        players[e.player].y = e.y;
        players[e.player].r = e.r;
        players[e.player].ppos.set(players[e.player].localPos());
        e.spawn();
      }
    }

    // player drowned in tarpit
    for (Player p : players) {
      if (!p.enabled) continue;
      if (p.localPos().mag() < Player.TARPIT_BOTTOM_DIST) {
        playerDeathAnimations[p.id].fire(time.getClock(), p, p.globalPos(), 0, .75, .5);
        earth.addChild(playerDeathAnimations[p.id]);
        println("died in tarpit");
        playerKilled(p.id);
      }
    }

    // player abducted by UFO?
    int abducted = ufo.update(time.getClock(), time.getTimeScale(), earth.globalPos(), players);
    if (abducted !=-1) {
      extraLives++;
      players[abducted].restart();
      playerRespawns[abducted].respawn();
      println("abducted");
      //paused = true;
    }

    // respawn following getting extra life
    for (int i = 0; i < 2; i++) {
      boolean canSpawn = playerRespawns[i].update(time.getClock());
      if (canSpawn && (i==0 ? keys.p1anykey() : keys.p2anykey())) {
        playerRespawns[i].enabled = false;
        players[i].enabled = true;

        players[i].y = -Player.DIST_FROM_EARTH; //playerIntro.y;
        players[i].x = 0;
        earth.addChild(players[i]);

        //paused = true;
        ufo.resumeCountDown();
        lastScoreTick = time.getClock();
        assets.playerStuff.respawnRise.stop_();
      }
    }

    // respawn death (rescue UFO) 
    Entity ufoRespawned = ufoRespawn.update(time.getClock(), time.getTimeScale(), earth.globalPos(), keys.anyKey());
    if (ufoRespawned != null) {
      players[ufoRespawn.whichDino].enabled = true;
      players[ufoRespawn.whichDino].parent = null;
      players[ufoRespawn.whichDino].setPosition(ufoRespawned.globalPos());
      players[ufoRespawn.whichDino].r = ufoRespawned.r;
      earth.addChild(players[ufoRespawn.whichDino]);
      ufo.resumeCountDown();
      lastScoreTick = time.getClock();
    }

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
              //playerDeathAnimation.fire(time.getClock(), player, impactPointAdjusted, 15, .98, .98); 
              playerDeathAnimations[player.id].fire(time.getClock(), player, impactPointAdjusted, 15, .98, .98); 

              println("died from roid");

              playerKilled(player.id);
            } else if (utils.unsignedAngleDiff(splode.r, player.r) < Player.ROID_PUSHBACK_ANGLE_RANGE) { // near miss
              float diff = utils.unsignedAngleDiff(splode.r,player.r);
              float min = Player.BOUNDING_ARC/2 + Explosion.BOUNDING_ARC/2;
              float max = Player.ROID_PUSHBACK_ANGLE_RANGE;
              float range = max - min;
              float d = diff - min;
              float pct = 1 - (d / range);
              float force = pct * 10;
              float dir = utils.sign(utils.signedAngleDiff(splode.r,player.r));
              //player.bounceStart(force * dir);
              player.bounceStart(Player.PLAYER_COLLISION_BOUNCE_FORCE * dir);
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
    if (hypercube.state == Hypercube.NORM && hypercube.enabled) {
      for (Player p : players) {
        if (PVector.dist(p.globalPos(), hypercube.globalPos()) < Player.BOUNDING_CIRCLE_RADIUS + Hypercube.BOUNDING_CIRCLE_RADIUS) {
          hypercube.goHyperspace();
          time.setHyperspace(true);
          starsSystem.setHyperspace(true);
          //music.rate(time.hyperspaceTimeScale);
        }
      }
    }

    // hyperspace finished?
    if (hypercube.state == Hypercube.HYPERSPACE_DONE) {
      time.setHyperspace(false);
      starsSystem.setHyperspace(false);
      hypercube.startCountDown();
      hypercube.enabled = false;
      //music.rate(1);
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
    trex.update(time.getTimeScale(), time.getScaledElapsed(), players[0], players[1]);
    if (trex.isStomping) earth.shake(8, 300, time.getClock());

    // is trex touching player
    for (Player p : players) {
      if (p.enabled && trex.isDeadly()) {
        if (utils.unsignedAngleDiff(p.r, trex.r) < Player.BOUNDING_ARC/2 + Trex.BOUNDING_ARC/2) {

          playerDeathAnimations[p.id].fire(time.getClock(), p, trex.globalPos(), 10, .99, .999);
          println("died from trex");

          playerKilled(p.id);
        }
      }
    }

    for (GibsSystem p : playerDeathAnimations) p.update(time.getTimeScale(), time.getClock());
    trexDeathAnimation.update(time.getTimeScale(), time.getClock());


    // restart
    gameText.update();
    if (gameText.doneFlashExtinct() && keys.anyKey()) {
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
        egg.startAnimation(angle, time.getClock());
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
    finale.update(earth, trex, players, time);
    if (finale.p1Died && players[0].enabled) {
      float angle = utils.angleOfRadians(earth.globalPos(), players[0].globalPos());
      playerDeathAnimations[0].fire(time.getClock(), players[0], new PVector(cos(angle) * (Earth.EARTH_RADIUS - 20), sin(angle) * (Earth.EARTH_RADIUS - 20)), 15, .98, .98);
      playerKilledFinale(0);
    }
    if (finale.p2Died && players[1].enabled) {
      float angle = utils.angleOfRadians(earth.globalPos(), players[1].globalPos());
      playerDeathAnimations[1].fire(time.getClock(), players[1], new PVector(cos(angle) * (Earth.EARTH_RADIUS - 20), sin(angle) * (Earth.EARTH_RADIUS - 20)), 15, .98, .98);
      playerKilledFinale(1);
    }
    if (finale.won && (players[0].enabled || players[1].enabled)) {
      players[0].restart();
      players[1].restart();
    }

    if (finale.state == SPFinale.PULLING_AWAY) {
      earth.dy *= .99;
    }
    if (finale.state == SPFinale.ZOOMING && !starsSystem.isZooming) {
      starsSystem.startZooming();
    } 
    if (finale.state == SPFinale.PULLING_AWAY && finale.lastState != SPFinale.PULLING_AWAY) {
      time.timeScale = 1;
      earth.dx = -2;
      earth.dy = -2;
      earth.shake(0);
      earth.dr = settings.getFloat("earthRotationSpeed", Earth.DEFAULT_EARTH_ROTATION);
    }
    if (finale.state == SPFinale.DONE && finale.lastState == SPFinale.ABORT) {
      earth.shake(0);
      time.timeScale = 1;
      earth.dr = settings.getFloat("earthRotationSpeed", Earth.DEFAULT_EARTH_ROTATION);
    }
    if (finale.state == SPFinale.EXPLODING && finale.lastState != SPFinale.EXPLODING) {
      music.play(true);
      float angle = utils.angleOfRadians(earth.globalPos(), trex.globalPos());
      if (trex.enabled && trex.state == Trex.STUNNED) trexDeathAnimation.fire(time.getClock(), trex, new PVector(cos(angle) * (Earth.EARTH_RADIUS - 20), sin(angle) * (Earth.EARTH_RADIUS - 20)), 50, .99, .99, 50);
      trex.vanish();
    }

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

  void renderPreGlow () {

    // world-space
    sb.pushMatrix();
    sb.translate(-camera.globalPos().x + width/2, -camera.globalPos().y + height/2);
    sb.scale(SCALE);
    sb.rotate(radians(-camera.globalRote()));
    sb.imageMode(CENTER);
    sb.clip(width/2, height/2, height, height);

    ufo.render(currentColor.getColor());
    ufoRespawn.render(currentColor.getColor());
    volcanoSystem.render(currentColor.getColor());
    finale.render(earth); // behind earth
    for (PlayerRespawn p : playerRespawns) p.render();
    earth.render(time.getClock());
    for (Player player : players) player.render();
    for (PlayerIntro playerIntro : playerIntros) playerIntro.render();
    for (EggRescue r : rescueEggs) r.render();
    roidManager.renderRoids();
    roidManager.renderSplodes();
    egg.render(currentColor.getColor());
    trex.render();
    trexDeathAnimation.render();
    sb.noClip();

    for (GibsSystem p : playerDeathAnimations) p.render();
    gameText.render(currentColor.getColor());
    hypercube.render(time.getTimeScale(), currentColor.getColor());
    finale.renderBigOne(); // in front of earth

    sb.popMatrix();

    // matte (screen space)
    //pushMatrix(); 
    //  pushStyle();
    //  noStroke();
    //  fill(30, 60, 60, 1);
    //  rect(0, 0, (width-height)/2, height);
    //  rect((width-height)/2 + height, 0, width, height);
    //  popStyle();
    //popMatrix();

    // world space again
    sb.pushMatrix();
    sb.translate(-camera.globalPos().x + width/2, -camera.globalPos().y + height/2);
    sb.scale(SCALE);
    sb.rotate(radians(-camera.globalRote()));
    ufo.renderFront(currentColor.getColor());
    starsSystem.render(currentColor.getColor(), time.getTargetTimeScale());
    sb.popMatrix();
  }

  void renderPostGlow () {

    // UI
    pushMatrix();
    translate(width/2, height/2);
    scale(SCALE);
    imageMode(CENTER);
    ui.render(extraLives, score);
    popMatrix();
  }

  void playerKilled(int id) {

    if (numPlayers==1) {
      if (extraLives <= 0) {
        gameText.goExtinct();
        assets.playerStuff.extinct.play(false);
        music.stop_();
        if (score > highscore) {
          highscore = score;
          saveHighScore(score, SAVE_FILENAME);
        }
      } else {
        extraLives--;
        ufo.pauseCountDown();
        ufoRespawn.dispatch(players[id], earth.globalPos());
        assets.playerStuff.littleDeath.play(false);
      }
    } else {
      // if other player is dead, gameover
      // other player isn't really dead if they're in the process of respawning through: rising animation, ufo, or egg
      if (!players[id==1 ? 0 : 1].enabled && !ufoRespawn.inTheProcessOfReturningPlayer() && !playerRespawns[id==1 ? 0 : 1].enabled && rescueEggs[id==1 ? 0 : 1].state!=EggRescue.BURST) {
        if (extraLives <= 0) {
          //gameover
          gameText.goExtinct();
          assets.playerStuff.extinct.play(false);
          music.stop_();
          if (score > highscore) {
            highscore = score;
            saveHighScore(score, SAVE_FILENAME);
          }
        } else {
          //rescue UFO
          extraLives--;
          ufoRespawn.dispatch(players[id], earth.globalPos());
          assets.playerStuff.littleDeath.play(false);
        }
      } else {
        // otherwise spawn an egg
        float a = utils.angleOfOrigin(players[id].localPos());
        rescueEggs[id].startAnimation(a, time.getClock());
      }
    }

    players[id].enabled = false;
    players[id].restart();
    time.deathStart();
  }

  void playerKilledFinale (int id) {
    players[id].enabled = false;
    players[id].restart();

    if (!players[0].enabled && !players[1].enabled && !finale.won) {
      gameText.goExtinct();
      assets.playerStuff.extinct.play(false);
      music.stop_();
    }
  }

  void mouseUp() {

    //PVector m = screenspaceToWorldspace(mouseX, mouseY);

    //if (settingsButtonHitbox.inside(m)) {
    //  wantToPause = true;
    //  launch(sketchPath() + "\\DIP-switches.txt");
    //}

    //playerKilled(1);
    //players[0].bounceStart(time.getClock(), -1);
  }

  void cleanup() {
    assets.stopAllMusic();
    assets.stopAllSfx();
  }

  boolean requestsPause () {
    return wantToPause;
  }

  void handlePause () {
    wantToPause = false;
    assets.stopAllSfx();
  }

  void handleUnpause () {
    wantToPause = false;
    time.rebaseTime();
    trex.handleUnpaused();
  }

  //PVector screenToScaled (float x, float y) {
  //  return new PVector((x + WIDTH_REF_HALF) / SCALE, (y + HEIGHT_REF_HALF) / SCALE);
  //}

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
