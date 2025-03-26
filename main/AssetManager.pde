class AssetManager {

  final static float STROKE_WIDTH = 1.5;
  final int DEFAULT_GLOWINESS = 30;
  final static int DEFAULT_EARTH = 1;
  final static int DEFAULT_EARTH_SIDE = 1;
  final static int DEFAULT_GHOSTING = 50;
  final static int MAX_GLOW = 60;
  final static float MAX_GHOST = .1;

  final String[] DEFAULT_TIPS = new String[]{"Real Winners Say No to Drugs", "This is Fine", "Life Finds a Way", "Tough Out There for Sauropods", "rawr", "hold on to your butts", "remember to take breaks"};
  final String[] DEFAULT_COLORS = new String[]{"#ff3800", "#ffff00", "#00ff00", "#00ffff", "#ff57ff"};

  PShader blur;

  UFOstuff ufostuff = new UFOstuff();
  UIStuff uiStuff = new UIStuff();
  VolcanoStuff volcanoStuff = new VolcanoStuff();
  RoidStuff roidStuff = new RoidStuff();
  PlayerStuff playerStuff = new PlayerStuff();
  TrexStuff trexStuff = new TrexStuff();
  EarthStuff earthStuff = new EarthStuff();
  PtutorialStuff ptutorialStuff = new PtutorialStuff();
  MusicStuff musicStuff = new MusicStuff();
  ArrayList<SoundPlayable> sounds = new ArrayList<SoundPlayable>(); 
  ArrayList<SoundPlayable> musics = new ArrayList<SoundPlayable>(); 

  PShader testmask;

  void load (PApplet context) {

    boolean raspi = false;

    testmask = loadShader("pixelmask.glsl");
    blur = loadShader("blur.glsl");

    ufostuff.ufoFrames = utils.sheetToSprites(loadImage("ufo-resizing-sheet.png"), 3, 3);
    ufostuff.brontoAbductionFrames = utils.sheetToSprites(loadImage("bronto-abduction-sheet.png"), 3, 3);    
    ufostuff.ufoSVG = loadShape("UFO.svg");
    ufostuff.ufoSVG.disableStyle();
    ufostuff.ufoFinalSingle = loadShape("UFO-final-pilot.svg");
    ufostuff.ufoFinalSingle.disableStyle();
    ufostuff.ufoFinalDuo = loadShape("UFO-final-pilot2.svg");
    ufostuff.ufoFinalDuo.disableStyle();
    ufostuff.ufoFinalDuoZoom = loadShape("UFO-final-pilot3.svg");
    ufostuff.ufoFinalDuoZoom.disableStyle();

    ufostuff.ufoSound = raspi ? new SoundM("_audio/ufo theme loop-low.wav", ngainSFX) : new SoundP("_audio/ufo theme loop-low.wav", context);
    sounds.add(ufostuff.ufoSound);

    ufostuff.ufoSound2 = raspi ? new SoundM("_audio/ufo theme loop-low.wav", ngainSFX) : new SoundP("_audio/ufo theme loop-low.wav", context);
    sounds.add(ufostuff.ufoSound2);

    uiStuff.extinctType = createFont("Hyperspace.otf", 150);
    //uiStuff.extinctSign = loadImage("gameover-lettering.png");
    uiStuff.letterbox = loadImage("letterboxes.png");
    uiStuff.screenShine = loadImage("screenShine.png");
    uiStuff.MOTD = createFont("Hyperspace Bold.otf", 32);
    uiStuff.progressBG = loadImage("progress-bg.png");
    uiStuff.extraDinosBG = loadImage("extra-life-bg.png");
    uiStuff.tick = loadImage("progress-tick.png");
    uiStuff.tickInActive = loadImage("progress-tick-inactive.png");
    uiStuff.extraDinoActive = loadImage("extra-dino-active.png");
    uiStuff.extraDinoInactive = loadImage("extra-dino-deactive.png");
    uiStuff.buttons = loadImage("ui-buttons.png");
    uiStuff.titlescreenImage = loadImage("title.png");
    uiStuff.titlescreenImageVec = loadShape("test.svg");
    uiStuff.titlescreenImageVec.disableStyle();
    uiStuff.title40 = loadImage("title_fortieth.png");
    uiStuff.titleSpeak =  raspi ? new SoundM("_audio/title_speak.wav", ngainSFX) : new SoundP("_audio/title_speak.wav", context);

    volcanoStuff.volcanoFrames = utils.sheetToSprites(loadImage("volcanos.png"), 4, 1);
    volcanoStuff.rumble = raspi ? new SoundM("_audio/volcano rumble2.wav", ngainSFX) : new SoundP("_audio/volcano rumble2.wav", context);
    sounds.add(volcanoStuff.rumble);

    roidStuff.explosionFrames = utils.sheetToSprites(loadImage("explosion.png"), 3, 1);
    roidStuff.roidFrames = utils.sheetToSprites(loadImage("roids.png"), 2, 2);
    roidStuff.trail = loadImage("roid-trail.png");
    for (int i = 0; i < roidStuff.hits.length; i++) {
      roidStuff.hits[i] = raspi ? new SoundM("_audio/roids/impact" + (i + 1) + ".wav", ngainSFX) : new SoundP("_audio/roids/impact" + (i + 1) + ".wav", context);
      sounds.add(roidStuff.hits[i]);
    }
    roidStuff.bigone = loadImage("bigone.png");
    roidStuff.bigoneBlip = raspi ? new SoundM("_audio/bigone-incoming-blip.wav", ngainSFX) : new SoundP("_audio/bigone-incoming-blip.wav", context);
    sounds.add(roidStuff.bigoneBlip);

    playerStuff.oviDethSVG = loadShape("ovi-death.svg");
    playerStuff.oviDethSVG.disableStyle();
    playerStuff.dethSVG = loadShape("bronto-death.svg");
    playerStuff.dethSVG.disableStyle();
    playerStuff.brontoSVG = loadShape("bronto-idle.svg");
    playerStuff.brontoSVG.disableStyle();
    playerStuff.brontoFrames = utils.sheetToSprites(loadImage("bronto-frames.png"), 3, 1);
    playerStuff.oviSVG = loadShape("ovi-idle.svg");
    playerStuff.oviSVG.disableStyle();
    playerStuff.oviFrames = utils.sheetToSprites(loadImage("ovi-frames.png"), 3, 1);
    playerStuff.eggWhole = loadImage("egg-whole.png");
    for (int i=0; i<5; i++) {
      playerStuff.eggFrames[i] = loadImage("eggs_egg-crack" + i + ".png");
    }
    playerStuff.extinct = raspi ? new SoundM("_audio/player/extinct.wav", ngainSFX) : new SoundP("_audio/player/extinct.wav", context);
    sounds.add(playerStuff.extinct);
    playerStuff.spawn = raspi ? new SoundM("_audio/player/spawn.wav", ngainSFX) : new SoundP("_audio/player/spawn.wav", context);
    sounds.add(playerStuff.spawn);
    playerStuff.step = raspi ? new SoundM("_audio/player/walking.wav", ngainSFX) : new SoundP("_audio/player/walking.wav", context);
    sounds.add(playerStuff.step);
    playerStuff.step2 = raspi ? new SoundM("_audio/player/step2b.wav", ngainSFX) : new SoundP("_audio/player/step2b.wav", context);
    sounds.add(playerStuff.step2);
    playerStuff.tarStep = raspi ? new SoundM("_audio/player/walking-in-tar.wav", ngainSFX) : new SoundP("_audio/player/walking-in-tar.wav", context);
    sounds.add(playerStuff.tarStep);
    playerStuff.littleDeath = raspi ? new SoundM("_audio/player/dino little death.wav", ngainSFX) : new SoundP("_audio/player/dino little death.wav", context);
    sounds.add(playerStuff.littleDeath); 
    playerStuff.respawnRise = raspi ? new SoundM("_audio/player/revup2-loop-vol-adjusted.wav", ngainSFX) : new SoundP("_audio/player/revup2-loop-vol-adjusted.wav", context);
    sounds.add(playerStuff.respawnRise); 

    trexStuff.trexIdle = loadImage("trex-idle.png");
    trexStuff.trexRun1 = loadImage("trex-run1.png");
    trexStuff.trexRun2 = loadImage("trex-run2.png");
    trexStuff.trexHead = loadImage("trex-head.png");
    trexStuff.eggCracked = loadImage("egg-cracked.png");
    trexStuff.eggBurst = loadImage("egg-burst.png");
    trexStuff.deth = loadShape("trexDeth.svg");
    trexStuff.eggHatch = raspi ? new SoundM("_audio/trex-and-egg/egg-hatch.wav", ngainSFX) : new SoundP("_audio/trex-and-egg/egg-hatch.wav", context);
    sounds.add(trexStuff.eggHatch);
    trexStuff.eggWiggle = raspi ? new SoundM("_audio/trex-and-egg/egg-wiggle.wav", ngainSFX) : new SoundP("_audio/trex-and-egg/egg-wiggle.wav", context);
    sounds.add(trexStuff.eggWiggle);
    trexStuff.rawr = raspi ? new SoundM("_audio/trex-and-egg/rawr.wav", ngainSFX) : new SoundP("_audio/trex-and-egg/rawr.wav", context);
    sounds.add(trexStuff.rawr);
    trexStuff.stomp = raspi ? new SoundM("_audio/trex-and-egg/trex-walking.wav", ngainSFX) : new SoundP("_audio/trex-and-egg/trex-walking.wav", context);
    sounds.add(trexStuff.stomp);
    trexStuff.sinking = raspi ? new SoundM("_audio/trex-and-egg/trex-sinking-in-tar.wav", ngainSFX) : new SoundP("_audio/trex-and-egg/trex-sinking-in-tar.wav", context);
    sounds.add(trexStuff.sinking);

    earthStuff.earth = loadImage("earth.png");
    //earthStuff.earth = loadImage("earth-east-clear.png");
    earthStuff.earthV = loadShape("earth.svg");
    earthStuff.earthV.disableStyle();
    earthStuff.earth2 = loadImage("earth-east.png");
    earthStuff.earthPangea1 = loadImage("earth-pangea1.png");
    earthStuff.earthPangea2 = loadImage("earth-pangea2.png");
    earthStuff.mask = loadShader("pixelmask.glsl");
    //earthStuff.mask.set("mask", earthStuff.tarpitMask);
    earthStuff.doodadBone = loadImage("doodad-bone.png");
    earthStuff.doodadFemur = loadImage("doodad-femur.png");
    earthStuff.doodadHead = loadImage("doodad-head.png");
    earthStuff.doodadRibs = loadImage("doodad-ribcage.png");

    ptutorialStuff.pteroIdle = loadImage("/_art/ptutorial/ptero_idle.png");
    ptutorialStuff.pteroFlap1 = loadImage("/_art/ptutorial/ptero_flap1.png");
    ptutorialStuff.pteroFlap2 = loadImage("/_art/ptutorial/ptero_flap2.png");
    ptutorialStuff.earth = loadImage("/_art/ptutorial/ptero_earth.png");
    ptutorialStuff.flap = raspi ? new SoundM("_audio/ptutorial/flap2.wav", ngainMusic) : new SoundP("_audio/ptutorial/flap2.wav", context);
    ptutorialStuff.success = raspi ? new SoundM("_audio/ptutorial/success.wav", ngainMusic) : new SoundP("_audio/ptutorial/success.wav", context);

    musicStuff.lvl1a = raspi ? new SoundM("_music/lvl1.wav", ngainMusic) : new SoundP("_music/lvl1.wav", context);
    musicStuff.lvl1b = raspi ? new SoundM("_music/lvl1-jump.wav", ngainMusic) : new SoundP("_music/lvl1-jump.wav", context);
    musicStuff.lvl2a = raspi ? new SoundM("_music/lvl2.wav", ngainMusic) : new SoundP("_music/lvl2.wav", context);
    musicStuff.lvl2b = raspi ? new SoundM("_music/lvl2-seek.wav", ngainMusic) : new SoundP("_music/lvl2-seek.wav", context);
    musicStuff.lvl3 = raspi ? new SoundM("_music/lvl3.wav", ngainMusic) : new SoundP("_music/lvl3.wav", context);
    musics.add(musicStuff.lvl1a);
    musics.add(musicStuff.lvl1b);
    musics.add(musicStuff.lvl2a);
    musics.add(musicStuff.lvl2b);
    musics.add(musicStuff.lvl3);
  }

  void volumeSFX (float v) {
    for (SoundPlayable s : sounds) s.vol(v);
  }

  void volumeMusic (float v) {
    for (SoundPlayable m : musics) m.vol(v);
  }

  void muteSFX (boolean mute) {
    for (SoundPlayable s : sounds) s.mute(mute);
  }

  void muteMusic (boolean mute) {
    for (SoundPlayable m : musics) m.mute(mute);
  }

  void stopAllMusic () {
    for (SoundPlayable s : musics) {
      s.stop_();
      s.rate(1);
    }
  }

  void stopAllSfx () {
    for (SoundPlayable s : sounds) s.stop_();
  }

  class UFOstuff {
    PImage[] ufoFrames;  
    PImage[] brontoAbductionFrames;
    PShape ufoSVG;
    SoundPlayable ufoSound;
    SoundPlayable ufoSound2;
    PShape ufoFinalSingle;
    PShape ufoFinalDuo;
    PShape ufoFinalDuoZoom;
  }

  class UIStuff {
    //PImage extinctSign;
    PImage letterbox;
    PImage screenShine;
    PFont MOTD;
    PImage progressBG;
    PImage extraDinosBG;
    PImage tick;
    PImage tickInActive;
    PImage extraDinoActive;
    PImage extraDinoInactive;
    PImage buttons;
    //PImage optionsBtn;
    PFont extinctType;
    //PImage DIPswitchesBtn;
    PImage titlescreenImage;
    PShape titlescreenImageVec;
    PImage title40;
    SoundPlayable titleSpeak;
  }

  class VolcanoStuff {
    PImage[] volcanoFrames;
    SoundPlayable rumble;
  }

  class RoidStuff {
    PImage[] explosionFrames;
    PImage[] roidFrames;
    PImage trail;
    SoundPlayable[] hits = new SoundPlayable[5];
    PImage bigone;
    SoundPlayable bigoneBlip;
  }

  class PlayerStuff {
    PShape dethSVG;
    PShape oviDethSVG;
    PShape brontoSVG;
    PShape oviSVG;
    PImage[] brontoFrames;
    PImage[] oviFrames;
    PImage eggWhole;
    PImage eggFrames[] = new PImage[5];
    SoundPlayable extinct;
    SoundPlayable spawn;
    SoundPlayable step;
    SoundPlayable step2;
    SoundPlayable tarStep;
    SoundPlayable littleDeath;
    SoundPlayable respawnRise;
  }

  class TrexStuff {
    PImage trexIdle;
    PImage trexRun1;
    PImage trexRun2;
    PImage trexHead;
    PImage eggCracked;
    PImage eggBurst;
    PShape deth;
    SoundPlayable eggHatch;
    SoundPlayable eggWiggle;
    SoundPlayable rawr;
    SoundPlayable stomp;
    SoundPlayable sinking;
  }

  class EarthStuff {
    PImage earth;
    PShape earthV;
    PImage earth2;
    PImage earthPangea1;
    PImage earthPangea2;
    PImage tarpitMask;
    PShader mask;
    PImage doodadBone;
    PImage doodadFemur;
    PImage doodadHead;
    PImage doodadRibs;
  }

  class PtutorialStuff {
    PImage pteroIdle;
    PImage pteroFlap1;
    PImage pteroFlap2;
    PImage earth;
    SoundPlayable flap;
    SoundPlayable success;
  }

  class MusicStuff {
    SoundPlayable lvl1a;
    SoundPlayable lvl1b;
    SoundPlayable lvl2a;
    SoundPlayable lvl2b;
    SoundPlayable lvl3;
  }
}

interface SoundPlayable {
  void play(boolean loop);
  void play();
  void mute(Boolean m);
  void stop_();
  void rate(float r);
  void vol(float v);
  boolean isPlaying();
}

// the Minim library for Processing (Picade needs)
class SoundM implements SoundPlayable {

  AudioPlayer player;
  TickRate rateControl;
  FilePlayer filePlayer;
  AudioOutput out;

  SoundM (String file, float negativeGain) {
    try {
      filePlayer = new FilePlayer(minim.loadFileStream(file));
    } 
    catch (Exception e) { 
      filePlayer = new FilePlayer(minim.loadFileStream("silence.wav"));
    }

    rateControl = new TickRate(1.f);
    rateControl.setInterpolation( true );

    out = minim.getLineOut(Minim.MONO, 1024, 44100, 16);
    out.setGain(-negativeGain);

    filePlayer.patch(rateControl).patch(out);
  }

  void play() {
    play(false);
  }

  void play(boolean loop) {
    filePlayer.rewind();

    if (loop) {
      filePlayer.loop();
    } else {
      filePlayer.play();
    }
  }

  void stop_ () {
    filePlayer.pause();
  }

  void rate(float r) {
    rateControl.value.setLastValue(r);
  }

  void mute(Boolean m) {
    if (m) {
      out.mute();
    } else {
      out.unmute();
    }
  }

  void vol(float v) {
    out.setVolume(v);
  }

  // to do
  boolean isPlaying() {
    return true;
  }
}

// the Processing 3.0 official sound library (Android needs)
class SoundP implements SoundPlayable {

  SoundFile player;

  SoundP (String file, PApplet context) {
    player = new SoundFile(context, file);
    try {
      player.channels(); // throw if sound file not loaded
    } 
    catch (Exception e) {
      println("couldn't load sound file: " + file);
      player = new SoundFile(context, "silence.wav");
    }
  }

  void play() {
    play(false);
  }

  void play(boolean loop) {
    if (loop) {
      player.loop();
    } else {
      player.play();
    }
  }

  boolean isPlaying() {
    return player.isPlaying();
  }

  void stop_ () {
    player.stop();
  }

  void rate (float r) {
    player.rate(r);
  }

  void mute(Boolean m) {
    if (m) {
      player.amp(0);
    } else {
      player.amp(1);
    }
  }

  void vol(float v) {
    player.amp(v);
  }
}
