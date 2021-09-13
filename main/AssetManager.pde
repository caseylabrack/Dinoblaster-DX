class AssetManager {

  final float STROKE_WIDTH = 1.5;
  final int DEFAULT_GLOWINESS = 30;

  PShader glow;
  boolean glowing = true;

  StringList motds;
  int motdsIndex;

  UFOstuff ufostuff = new UFOstuff();
  UIStuff uiStuff = new UIStuff();
  VolcanoStuff volcanoStuff = new VolcanoStuff();
  RoidStuff roidStuff = new RoidStuff();
  PlayerStuff playerStuff = new PlayerStuff();
  TrexStuff trexStuff = new TrexStuff();
  EarthStuff earthStuff = new EarthStuff();
  MusicStuff musicStuff = new MusicStuff();
  ArrayList<SoundPlayable> sounds = new ArrayList<SoundPlayable>(); 
  ArrayList<SoundPlayable> musics = new ArrayList<SoundPlayable>(); 

  void load (PApplet context, JSONObject picadeSettings) {

    float ngainSFX = 0;
    float ngainMusic = 0;
    boolean raspi = false;

    if (picadeSettings!=null) {
      ngainSFX = picadeSettings.getFloat("negativeGainSFX", 30);
      ngainMusic = picadeSettings.getFloat("negativeGainMusic", 30);
      raspi = true;
    }

    glow = loadShader("glowiness.glsl");

    motds = new StringList();
    motds.append("Real Winners Say No to Drugs");
    motds.append("This is Fine");
    motds.append("Life Finds a Way");
    motds.append("Tough Out There for Sauropods"); 
    motds.append("rawr");
    motds.append("hold on to your butts");
    motds.shuffle();

    ufostuff.ufoFrames = utils.sheetToSprites(loadImage("ufo-resizing-sheet.png"), 3, 3);
    ufostuff.brontoAbductionFrames = utils.sheetToSprites(loadImage("bronto-abduction-sheet.png"), 3, 3);    
    ufostuff.ufoSVG = loadShape("UFO.svg");
    ufostuff.ufoSVG.disableStyle();
    ufostuff.ufoSound = raspi ? new SoundM("_audio/ufo theme loop-low.wav", ngainSFX) : new SoundP("_audio/ufo theme loop-low.wav", context);
    sounds.add(ufostuff.ufoSound);

    uiStuff.extinctType = createFont("Hyperspace.otf", 150);
    //uiStuff.extinctSign = loadImage("gameover-lettering.png");
    uiStuff.letterbox = loadImage("letterboxes2.png");
    uiStuff.MOTD = createFont("Hyperspace Bold.otf", 32);
    uiStuff.progressBG = loadImage("progress-bg.png");
    uiStuff.extraDinosBG = loadImage("extra-life-bg.png");
    uiStuff.tick = loadImage("progress-tick.png");
    uiStuff.extraDinoActive = loadImage("extra-dino-active.png");
    uiStuff.extraDinoInactive = loadImage("extra-dino-deactive.png");
    uiStuff.optionsBtn = loadImage("button-final.png");

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

    playerStuff.dethSVG = loadShape("bronto-death.svg");
    playerStuff.dethSVG.disableStyle();
    playerStuff.brontoSVG = loadShape("bronto-idle.svg");
    playerStuff.brontoSVG.disableStyle();
    playerStuff.brontoFrames = utils.sheetToSprites(loadImage("bronto-frames.png"), 3, 1);
    playerStuff.oviFrames = utils.sheetToSprites(loadImage("oviraptor-frames.png"), 2, 2, 1);
    playerStuff.extinct = raspi ? new SoundM("_audio/player/extinct.wav", ngainSFX) : new SoundP("_audio/player/extinct.wav", context);
    sounds.add(playerStuff.extinct);
    playerStuff.spawn = raspi ? new SoundM("_audio/player/spawn.wav", ngainSFX) : new SoundP("_audio/player/spawn.wav", context);
    sounds.add(playerStuff.spawn);
    playerStuff.step = raspi ? new SoundM("_audio/player/walking.wav", ngainSFX) : new SoundP("_audio/player/walking.wav", context);
    sounds.add(playerStuff.step);
    playerStuff.tarStep = raspi ? new SoundM("_audio/player/walking-in-tar.wav", ngainSFX) : new SoundP("_audio/player/walking-in-tar.wav", context);
    sounds.add(playerStuff.tarStep);
    playerStuff.littleDeath = raspi ? new SoundM("_audio/player/dino little death.wav", ngainSFX) : new SoundP("_audio/player/dino little death.wav", context);
    sounds.add(playerStuff.littleDeath);    

    trexStuff.trexIdle = loadImage("trex-idle.png");
    trexStuff.trexRun1 = loadImage("trex-run1.png");
    trexStuff.trexRun2 = loadImage("trex-run2.png");
    trexStuff.eggCracked = loadImage("egg-cracked.png");
    trexStuff.eggBurst = loadImage("egg-burst.png");
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
    earthStuff.mask = loadShader("pixelmask.glsl");
    //earthStuff.mask.set("mask", earthStuff.tarpitMask);
    earthStuff.doodadBone = loadImage("doodad-bone.png");
    earthStuff.doodadFemur = loadImage("doodad-femur.png");
    earthStuff.doodadHead = loadImage("doodad-head.png");
    earthStuff.doodadRibs = loadImage("doodad-ribcage.png");

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

  void setGlowiness (int glowiness) {
    if (glowiness != 0) {
      assets.glow.set("blurSize", glowiness);
      assets.glow.set("sigma", (float)glowiness/2);
      glowing = true;
    } else {
      glowing = false;
    }
  }

  void applyGlowiness () {
    if (!glowing) return;
    glow.set("horizontalPass", 0);
    filter(glow);
    glow.set("horizontalPass", 1);
    filter(glow);
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

  String getMOTD () {

    String m = motds.get(motdsIndex);

    motdsIndex++;
    if (motdsIndex > motds.size() - 1) {
      motds.shuffle();
      motdsIndex = 0;
    }

    return m;
  }

  class UFOstuff {
    PImage[] ufoFrames;  
    PImage[] brontoAbductionFrames;
    PShape ufoSVG;
    SoundPlayable ufoSound;
  }

  class UIStuff {
    //PImage extinctSign;
    PImage letterbox;
    PFont MOTD;
    PImage progressBG;
    PImage extraDinosBG;
    PImage tick;
    PImage extraDinoActive;
    PImage extraDinoInactive;
    PImage optionsBtn;
    PFont extinctType;
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
  }

  class PlayerStuff {
    PShape dethSVG;
    PShape brontoSVG;
    PImage[] brontoFrames;
    PImage[] oviFrames;
    SoundPlayable extinct;
    SoundPlayable spawn;
    SoundPlayable step;
    SoundPlayable tarStep;
    SoundPlayable littleDeath;
  }

  class TrexStuff {
    PImage trexIdle;
    PImage trexRun1;
    PImage trexRun2;
    PImage eggCracked;
    PImage eggBurst;
    SoundPlayable eggHatch;
    SoundPlayable eggWiggle;
    SoundPlayable rawr;
    SoundPlayable stomp;
    SoundPlayable sinking;
  }

  class EarthStuff {
    PImage earth;
    PImage tarpitMask;
    PShader mask;
    PImage doodadBone;
    PImage doodadFemur;
    PImage doodadHead;
    PImage doodadRibs;
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
    //println("gain? " + out.hasControl(Controller.GAIN));

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
