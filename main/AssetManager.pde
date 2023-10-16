class AssetManager {

  final static float STROKE_WIDTH = 1.5;
  final int DEFAULT_GLOWINESS = 30;
  final static int DEFAULT_EARTH = 1;
  final static int DEFAULT_EARTH_SIDE = 1;

  final String[] DEFAULT_TIPS = new String[]{"Real Winners Say No to Drugs", "This is Fine", "Life Finds a Way", "Tough Out There for Sauropods","rawr","hold on to your butts","remember to take breaks"};
  final String[] DEFAULT_COLORS = new String[]{"#ff3800", "#ffff00", "#00ff00", "#00ffff", "#ff57ff"};

  PShader glow;
  boolean glowing = true;

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


    boolean raspi = true;//false;

    //if (picadeSettings!=null) {
    //  ngainSFX = picadeSettings.getFloat("negativeGainSFX", 30);
    //  ngainMusic = picadeSettings.getFloat("negativeGainMusic", 30);
    //  raspi = true;
    //}

    glow = loadShader("glowiness.glsl");


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
    PImage title40;
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

    //out = minim.getLineOut(Minim.MONO, 1024, 44100, 16);
        out = minim.getLineOut(Minim.MONO, 2048, 44100, 16);
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
      //println("couldn't load sound file: " + file);
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
