//abstract class Scene { 

//  abstract void update();
//  abstract void renderPreGlow();
//  abstract void renderPostGlow();
//  abstract void mouseUp();
//}

class Titlescreen extends Scene {

  StarsSystem starsSystem = new StarsSystem();
  //ColorDecider currentColor = new ColorDecider();

  Titlescreen () {
    starsSystem.spawnSomeStars();
  }

  void update () {
    starsSystem.update(2);
    //currentColor.update();
  }

  void renderPreGlow () {
    pushMatrix();
    translate(width / 2, height / 2);
    scale(SCALE);
    imageMode(CENTER);
    image(assets.uiStuff.titlescreenImage, 0, 0);
    pushStyle();
    tint(currentColor.getColor());
    image(assets.uiStuff.title40, 0, 0);
    popStyle();
    starsSystem.render(#FFFFFF);
    popMatrix();
  }

  void mouseUp () {
  }

  void renderPostGlow() {
  }
}

class Oviraptor extends Scene {

  Earth earth;
  Time time = new Time();
  StarsSystem starsSystem = new StarsSystem();
  RoidManager roidManager = new RoidManager();
  ColorDecider currentColor;
  Camera camera = new Camera();
  PlayerIntro playerIntro = new PlayerIntro();
  Player player;
  Trex trex;
  GibsSystem playerDeathAnimation;
  EggOvi egg;
  int score = 0;
  float countdown = 60;
  float starttime;
  boolean isGameover = false;

  Oviraptor(SimpleTXTParser settings, AssetManager assets) {
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
    earth = new Earth(assets.earthStuff.mask);
    earth.dr = settings.getFloat("earthRotationSpeed", Earth.DEFAULT_EARTH_ROTATION);

    playerIntro.model = assets.playerStuff.oviFrames[0];
    playerIntro.y = -Player.DIST_FROM_EARTH;

    player = new Player(assets.playerStuff.brontoSVG, assets.playerStuff.oviFrames, assets.playerStuff.step, assets.playerStuff.tarStep);
    //player.extraLives = settings.getInt("extraLives", 0);
    player.runSpeed = settings.getFloat("playerSpeed", Player.DEFAULT_RUNSPEED);

    playerDeathAnimation = new GibsSystem(assets.playerStuff.dethSVG, new PVector(28, 45));

    time.hyperspaceTimeScale = settings.getFloat("hyperspaceTimeScale", Time.HYPERSPACE_DEFAULT_TIME);
    time.timeScale = settings.getFloat("defaultTimeScale", 1);

    starsSystem.spawnSomeStars();

    currentColor = new ColorDecider();

    //roidManager.minSpawnInterval = settings.getFloat("roidImpactRateInMilliseconds", RoidManager.DEFAULT_SPAWN_RATE) - settings.getFloat("roidImpactRateVariation", RoidManager.DEFAULT_SPAWN_DEVIATION)/2;
    //roidManager.maxSpawnInterval = settings.getFloat("roidImpactRateInMilliseconds", RoidManager.DEFAULT_SPAWN_RATE) + settings.getFloat("roidImpactRateVariation", RoidManager.DEFAULT_SPAWN_DEVIATION)/2;
    roidManager.initRoidPool(assets.roidStuff.roidFrames);
    roidManager.initSplodePool(assets.roidStuff.explosionFrames);
    roidManager.enabled = settings.getBoolean("roidsEnabled", true);

    trex = new Trex(assets.trexStuff.trexIdle, assets.trexStuff.trexHead, assets.trexStuff.trexRun1, assets.trexStuff.trexRun2, assets.trexStuff.stomp, assets.trexStuff.rawr);
    trex.runSpeed = settings.getFloat("trexSpeed", Trex.DEFAULT_RUNSPEED);
    trex.attackAngle = settings.getFloat("trexAttackAngle", Trex.DEFAULT_ATTACK_ANGLE);
    earth.addChild(trex);
    trex.enabled = true;
    //trex.x = 0;
    trex.y = EggHatch.EARTH_DIST_FINAL;
    //trex.r = 0;
    trex.facing = -1;

    egg = new EggOvi(assets.trexStuff.eggCracked);
    earth.addChild(egg);

    float ang = random(360);
    egg.x = cos(radians(ang)) * EggHatch.EARTH_DIST_FINAL;
    egg.y = sin(radians(ang)) * EggHatch.EARTH_DIST_FINAL;
    egg.r = ang + 90;

    starttime = time.getClock();
  }

  void update() {

    if (isGameover) return;

    time.update();

    countdown = 60 - (time.getClock() - starttime) / 1e3;

    playerIntro.update();
    if (playerIntro.state == PlayerIntro.SPAWNING) {
      playerIntro.state = PlayerIntro.DONE;
      player.enabled = true;
      player.y = playerIntro.y;
      earth.addChild(player);
    }

    player.move(keys.leftp1, keys.leftp2, time.getTimeScale(), time.getClock(), time.getScaledElapsed());
    playerDeathAnimation.update(time.getTimeScale(), time.getClock());

    starsSystem.update(time.getTimeScale());
    earth.move(time.getTimeScale(), time.getClock());
    //currentColor.update();
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

        assets.roidStuff.hits[int(random(0, 5))].play();

        // did the player get hit
        if (player.enabled) {
          if (utils.unsignedAngleDiff(splode.r, player.r) < Player.BOUNDING_ARC/2 + Explosion.BOUNDING_ARC/2) {

            PVector impactPointAdjusted = new PVector(earth.x + cos(incomingAngle) * Earth.EARTH_RADIUS, earth.y + sin(incomingAngle) * Earth.EARTH_RADIUS);
            playerDeathAnimation.fire(time.getClock(), player, impactPointAdjusted, 15, .98, .98); 

            println("died from roid");

            //playerKilled();
          }
        }
      }
    }
    roidManager.updateExplosions(time.getClock());

    if (trex.isStomping) earth.shake(8, 300, time.getClock());
    //trex.update(time.getTimeScale(), time.getScaledElapsed(), players[0], players[1]);
    // is trex touching player
    if (player.enabled && trex.isDeadly()) {
      if (utils.unsignedAngleDiff(player.r, trex.r) < Player.BOUNDING_ARC/2 + Trex.BOUNDING_ARC/2) {

        playerDeathAnimation.fire(time.getClock(), player, trex.globalPos(), 10, .99, .999);
        println("died from trex");

        //playerKilled();
      }
    }

    if (utils.unsignedAngleDiff(player.r, egg.r) < Player.BOUNDING_ARC/2 + Trex.BOUNDING_ARC/2) {
      //egg.enabled = false;
      score++;

      //float ang = utils.angleOf(utils.ZERO_VECTOR, trex.localPos());
      //println(trang);
      egg.touched();
      float ang = random(360);
      egg.x = cos(radians(ang)) * EggHatch.EARTH_DIST_FINAL;
      egg.y = sin(radians(ang)) * EggHatch.EARTH_DIST_FINAL;
      egg.r = ang + 90;
    }

    egg.update();
  }

  void renderPreGlow() {
    //world-space
    pushMatrix(); 
    translate(-camera.globalPos().x + width/2, -camera.globalPos().y + height/2);
    scale(SCALE);
    //scale(2);
    //rotate(radians(-player.globalRote()));
    rotate(radians(-camera.globalRote()));
    earth.render(time.getClock());
    playerIntro.render();
    player.render();
    trex.render();
    starsSystem.render(currentColor.getColor());
    roidManager.renderRoids();
    roidManager.renderSplodes();
    playerDeathAnimation.render();
    egg.render(currentColor.getColor());


    textFont(assets.uiStuff.MOTD);
    textAlign(LEFT, CENTER);
    text(score, -HEIGHT_REF_HALF, -HEIGHT_REF_HALF + 50);


    textAlign(RIGHT, CENTER);
    text(floor(countdown), HEIGHT_REF_HALF, -HEIGHT_REF_HALF + 50);

    popMatrix();
  }

  void renderPostGlow() {
  }
  void mouseUp() {
  }

  void playerKilled() {
    //player.restart();
    assets.playerStuff.littleDeath.play(false);
  }
}
