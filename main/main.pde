// TO DO
// speako 8 read title at start https://www.lexaloffle.com/bbs/?tid=49108
// title screen animation (ripple distortion on titlescreen) 
//(fill in w lazer?). https://www.youtube.com/watch?v=wDkG1CgREaQ. start on dot. do the sine circle animation from insta. humming. clicking on each . in "graphics go . . . . . . ok". 
// brontoscan logo
// title screen sound or music
// start getting some trailer shots
// oviraptor is a hidden game mode unlocked by beating level 2. key combo to start
// should settings load every time you play()?
// scale vectors with pshape.scale
// Ptutorial (if dino.dat is empty or 0)
// try again with splodes having longer deadliness time. show splode sprite only when deadly?
// replace trex skull in tarpit with a different doodad
// special note to people with disabilities: warning, timescale, no flash, rebinds and mousewheel (but not joystick), vestibular (rotation)
// try-catch for launching dipswitches notepad
// player can wait out hyperspace duration in respawn any-key mode, fix
// fix: caps-lock messes with input keys
// design the custom console for picade; order console; assemble
// custom artwork for the picade
// dipswitch option for kingofthedinosaurs mode: override all difficulty settings with a special chef's blend of extra spicy difficulty
// probably put picade settings in dipswitches
// try to not generate garbage
// settings: allow bare colors? (no quote marks)
// fun stuff on edge of screen for aspect ratios > 4:3
// oviraptor mode (make its own release maybe)
// bring back near-miss shake? or maybe sweat animation?
// coding train license add: https://github.com/CodingTrain/Coding-Challenges/blob/main/LICENSE
// blogposts: fan art; differences from last edition; in-depth on the dipswitches; spotlight on the picade

import java.util.Collections;

import java.awt.Desktop;
import java.io.File;
import java.io.IOException;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import processing.sound.*;

Minim minim;

final static String SAVE_FILENAME = "dino.dat";
final static String SETTINGS_FILENAME = "settings.txt";

final String VERSION_NUM = "v.156";
final char versionchar = '`';

boolean paused = false;
Scene currentScene;

// recording
int fcount = 0;
boolean rec = false;
final int RECORD_FRAMERATE = 1;

Keys keys = new Keys();
AssetManager assets = new AssetManager();
SimpleTXTParser settings;

boolean jurassicUnlocked, cretaceousUnlocked, buttonsHide, panelsHide, glow;
char leftkey1p, rightkey1p, leftkey2p, rightkey2p, pauseKey, dipSwitches, triassicSelect, jurassicSelect, cretaceousSelect, onePlayerSelect, twoPlayerSelect, secretVersionButton;
float ngainSFX, ngainMusic;

float SCALE;
float WIDTH_REFERENCE = 1024;
float WIDTH_REF_HALF = WIDTH_REFERENCE/2;
float HEIGHT_REFERENCE = 768;
float HEIGHT_REF_HALF = HEIGHT_REFERENCE/2;

SinglePlayer singlePlayer;
Oviraptor oviraptor;
Titlescreen title;
Bootscreen bootScreen;

ColorDecider currentColor = new ColorDecider();

Rectangle spButton; // single player button
Rectangle mpButton; // multiplayer button
Rectangle settingsButtonHitbox;

PGraphics sb; // screen buffer
PGraphics blurPass; // apply the blur shader to this to achieve glow

void setup () {
  //size(500, 500, P2D);
  size(1024, 768, P2D);
  //size(1920, 1080, P2D);
  //fullScreen(P2D);
  smooth(4);
  frameRate(60);
  //hint(DISABLE_OPTIMIZED_STROKE);
  //orientation(LANDSCAPE);

  //pixelDensity(displayDensity());

  sb = createGraphics(width, height, P2D);
  sb.smooth(4);
  sb.beginDraw();
  sb.colorMode(HSB, 360, 100, 100, 1);
  sb.imageMode(CENTER);
  sb.endDraw();

  blurPass = createGraphics(width/8, height/8, P2D);
  blurPass.noSmooth();

  SCALE = (float)height / HEIGHT_REFERENCE;

  surface.setTitle("DinoBlaster: 40th Anniversary Edition");

  colorMode(HSB, 360, 100, 100, 1);
  imageMode(CENTER);

  minim = new Minim(this);

  assets.load(this);

  key = 'a';

  loadSettingsFromTXT();

  spButton = new Rectangle(416, 162, 60, 60);
  mpButton = new Rectangle(416, 230, 60, 60);
  settingsButtonHitbox = new Rectangle(WIDTH_REF_HALF - 80, HEIGHT_REF_HALF - 80, 80, 80);

  singlePlayer = new SinglePlayer(settings, assets);
  singlePlayer.numPlayers = 1;
  keys.playingMultiplayer = false;
  singlePlayer.loadSettings(settings);

  oviraptor = new Oviraptor(settings, assets);

  title = new Titlescreen();
  bootScreen = new Bootscreen();

  currentScene = bootScreen;//title;
  //currentScene = oviraptor;
  background(0, 0, 0, 1);
}

void touchStarted() {
  //println("touch started");
}

void draw () {

  //if(touches.length==0) {
  //  keys.setKey(Keys.LEFT, false);
  //  keys.setKey(Keys.RIGHT, false);
  //} else {
  //  keys.setKey(touches[0].x < width/2 ? Keys.LEFT : Keys.RIGHT, true);
  //}

  if (singlePlayer.requestsPause()) paused = true;
  currentColor.update(); // always cycle colors, even when paused or whatever

  if (!paused) {
    currentScene.update();
  }
  sb.beginDraw();
  sb.background(0);
  //sb.fill(0, 0, 0, .5);
  //sb.rect(0, 0, width, height);
  currentScene.renderPreGlow();
  sb.endDraw();

  pushMatrix();
  imageMode(CORNER);
  image(sb, 0, 0, width, height);
  popMatrix();

  if (glow) {
    blurPass.beginDraw();
    blurPass.background(0);
    blurPass.image(sb, 0, 0, blurPass.width, blurPass.height);
    for (int i = 0; i < 8; i++) blurPass.filter(assets.blur);
    blurPass.endDraw();

    pushMatrix();
    pushStyle();
    imageMode(CORNER);
    blendMode(ADD);
    image(blurPass, 0, 0, width, height);
    //image(blurPass, 0, 0, width, height);
    popStyle();
    popMatrix();
  }

  if (paused) { 
    pushStyle();
    pushMatrix();
    translate(width/2, height/2);
    scale(SCALE);
    if (frameCount % 30 < 20) { 
      fill(0, 0, 100, 1);
      textFont(assets.uiStuff.MOTD);
      textAlign(CENTER, CENTER);
      text("- paused - ", 0, HEIGHT_REF_HALF - 50);
    }
    popMatrix();
    popStyle();
  }

  // side panels
  pushMatrix();
  translate(width/2, height/2);
  scale(SCALE);
  if (!panelsHide) {
    imageMode(CORNER);
    image(assets.uiStuff.progressBG, -WIDTH_REF_HALF + 40, -HEIGHT_REF_HALF);
    image(assets.uiStuff.extraDinosBG, WIDTH_REF_HALF - 100, -HEIGHT_REF_HALF);
    imageMode(CENTER);
    image(assets.uiStuff.extraDinoInactive, WIDTH_REF_HALF - 65, -HEIGHT_REF_HALF + 75);
    image(assets.uiStuff.extraDinoInactive, WIDTH_REF_HALF - 65, -HEIGHT_REF_HALF + 75 + 75);
    image(assets.uiStuff.extraDinoInactive, WIDTH_REF_HALF - 65, -HEIGHT_REF_HALF + 75 + 75 + 75);
  }
  popMatrix();
  currentScene.renderPostGlow();
  pushMatrix();
  translate(width/2, height/2);
  scale(SCALE);
  imageMode(CENTER);
  if (!panelsHide) {
    image(assets.uiStuff.screenShine, 0, 0);
    imageMode(CORNER);
    imageMode(CENTER);
    image(assets.uiStuff.letterbox, 0, 0);
  }
  if (!buttonsHide && !panelsHide) image(assets.uiStuff.buttons, 0, 0);
  popMatrix();

  if (key==secretVersionButton) {
    pushStyle();
    fill(0, 0, 0, 1);
    textSize(16);
    textAlign(LEFT, TOP);
    text(VERSION_NUM, 0, 0);
    popStyle();
  }

  if (rec) {
    if (frameCount % RECORD_FRAMERATE == 0) {
      saveFrame("spoofs-and-goofs/frames/dino-" + nf(fcount, 4) + ".png");
      fcount++;
    }
    //if (fcount==360) exit();
    pushStyle();
    stroke(0, 0, 100);
    strokeWeight(2);
    fill(0, 70, 80);
    circle(width - 20, 20, 20);
    popStyle();
  }

  //if (frameCount % 60 == 0) println(frameRate);
}

void keyPressed() {

  //println(key, keyCode);
  //println(key==CODED);

  if (key==CODED) {
    if (keyCode==LEFT) keys.arrowleft = true;
    if (keyCode==RIGHT) keys.arrowright = true;
  } else {
    if (key==triassicSelect) {
      paused = false;
      currentScene = singlePlayer;
      loadSettingsFromTXT();
      singlePlayer.loadSettings(settings);
      singlePlayer.play(SinglePlayer.TRIASSIC);
    }
    if (key==jurassicSelect) {
      if (singlePlayer.canPlayLevel(SinglePlayer.JURASSIC)) {
        paused = false;
        currentScene = singlePlayer;
        loadSettingsFromTXT();
        singlePlayer.loadSettings(settings);
        singlePlayer.play(SinglePlayer.JURASSIC);
      }
    }
    if (key==cretaceousSelect) {
      if (singlePlayer.canPlayLevel(SinglePlayer.CRETACEOUS)) {
        paused = false;
        currentScene = singlePlayer;
        loadSettingsFromTXT();
        singlePlayer.loadSettings(settings);
        singlePlayer.play(SinglePlayer.CRETACEOUS);
      }
    }
    if (key==leftkey1p) keys.leftp1 = true;
    if (key==rightkey1p) keys.rightp1 = true;
    if (key==leftkey2p) keys.leftp2 = true;
    if (key==rightkey2p) keys.rightp2 = true;    
    if (key=='r') {
      rec = true;
      println("recording");
    }
  }
}

void keyReleased() {

  if (key==CODED) {
    if (keyCode==LEFT) keys.arrowleft = false; 
    if (keyCode==RIGHT) keys.arrowright = false;
  } else {
    if (key==leftkey1p) keys.leftp1 = false; 
    if (key==rightkey1p) keys.rightp1 = false;
    if (key==leftkey2p) keys.leftp2 = false; 
    if (key==rightkey2p) keys.rightp2 = false; 
    if (key==onePlayerSelect) {
      currentScene = singlePlayer;
      singlePlayer.numPlayers = 1;
      keys.playingMultiplayer = false;
      loadSettingsFromTXT();
      singlePlayer.loadSettings(settings);
      singlePlayer.play(SinglePlayer.TRIASSIC);
      paused = false;
    }
    if (key==twoPlayerSelect) {
      currentScene = singlePlayer;
      singlePlayer.numPlayers = 2;
      keys.playingMultiplayer = true;
      loadSettingsFromTXT();
      singlePlayer.loadSettings(settings);
      singlePlayer.play(SinglePlayer.TRIASSIC);
      paused = false;
    }
    if (key=='r') {
      rec = false;
      println("stopped recording");
    }
    if (key==dipSwitches) {
      paused = true;
      singlePlayer.handlePause();
      launch(sketchPath() + "\\" + SETTINGS_FILENAME);
    }
    if (key==pauseKey || key==' ') {
      println("pause pls");
      if (paused) {
        loadSettingsFromTXT();
        singlePlayer.loadSettings(settings);
        singlePlayer.handleUnpause();
      } else {
        singlePlayer.handlePause();
      }
      paused = !paused;
    }
  }
}

void mouseMoved() {
  PVector m = screenspaceToWorldspace(mouseX, mouseY);

  if (settingsButtonHitbox.inside(m) || spButton.inside(m) || mpButton.inside(m)) {
    cursor(HAND);
  } else {
    cursor(ARROW);
  }
}

void mouseReleased () {
  currentScene.mouseUp();

  PVector m = screenspaceToWorldspace(mouseX, mouseY);

  if (settingsButtonHitbox.inside(m)) {
    paused = true;
    launch(sketchPath() + "\\" + SETTINGS_FILENAME);
  }

  if (spButton.inside(m)) {
    currentScene = singlePlayer;
    paused = false;
    singlePlayer.numPlayers = 1;
    keys.playingMultiplayer = false;
    singlePlayer.play(SinglePlayer.TRIASSIC);
  }

  if (mpButton.inside(m)) {
    currentScene = singlePlayer;
    paused = false;
    singlePlayer.numPlayers = 2;
    keys.playingMultiplayer = true;
    singlePlayer.play(SinglePlayer.TRIASSIC);
  }
}

class Keys {

  // keys on picade console:
  // |joy|    |16| |90| |88|
  //          |17| |18| |32|

  // front panel:
  // |27|      |79|

  boolean leftp1 = false;
  boolean rightp1 = false;
  boolean leftp2 = false;
  boolean rightp2 = false;
  boolean arrowleft = false;
  boolean arrowright = false;
  boolean p2HasArrows = false;
  boolean playingMultiplayer = false;

  // in singleplayer, player always has mappable keys and arrow keys
  // in multiplayer, p2 gets arrows keys by default. changeable in prefs
  boolean p1Left() {
    return keys.leftp1 || (!playingMultiplayer ?  keys.arrowleft : p2HasArrows ? false : keys.arrowleft);
  }

  boolean p1Right() {
    return keys.rightp1 || (!playingMultiplayer ?  keys.arrowright : p2HasArrows ? false : keys.arrowright);
  }

  boolean p2Left() {
    return keys.leftp2 || (p2HasArrows ? keys.arrowleft : false);
  }

  boolean p2Right() {
    return keys.rightp2 || (p2HasArrows ? keys.arrowright : false);
  }

  boolean anyKey () {
    return leftp1 || rightp1 || leftp2 || rightp2 || keys.arrowleft || keys.arrowright;
  }

  boolean p1anykey() {
    return p1Left() || p1Right();
  }

  boolean p2anykey() {
    return p2Left() || p2Right();
  }
}

PVector screenspaceToWorldspace (float x, float y) {
  return new PVector((x - width/2) / SCALE, (y - height/2) / SCALE);
}

void loadSettingsFromTXT () {
  try {
    settings = new SimpleTXTParser(SETTINGS_FILENAME, true);
  }
  catch(Exception e) {
    println("problem load game settings");
    PrintWriter output;
    output = createWriter(SETTINGS_FILENAME);
    String spacer = "     ";
    String settingsString = String.join("\n", 
      "--edit this text file to change your controls, set preferences, and even cheat", 
      "", 
      "----CONTROLS----", 
      "player1LeftKey: a", 
      "player1RightKey: d", 
      "", 
      "player2LeftKey: k", 
      "player2RightKey: l", 
      pss("player2GetsArrowKeys: true") + "--in 2p mode, arrow keys move p2", 
      "", 
      pss("pauseKey: g") + "--or space bar", 
      pss("openSettings: t") + "--open this file from in game", 
      "", 
      pss("triassicSelect: 1"), 
      pss("jurassicSelect: 2") + "--beat Triassic to unlock (or cheat)", 
      pss("cretaceousSelect: 3") + "--beat Jurassic to unlock (or cheat)", 
      "", 
      "singleplayerMode: o", 
      "multiplayerMode: p", 
      "", 
      "sfxVolume: 100", 
      "musicVolume: 100", 
      "", 
      "hideButtons: false", 
      "hideSidePanels: false", 
      "", 
      pss("reduceFlashing: false") + "--reduce flickering and palette swapping, for photosensitive people", 
      pss("glowiness: true") + "-- uses GPU power", 
      "", 
      "", 
      "----GAMEPLAY----", 
      "roidsEnabled: " + true, 
      "trexEnabled: " + true, 
      "volcanosEnabled: " + true, 
      "ufosEnabled: " + true, 
      "tarpitsEnabled: " + true, 
      "", 
      "hypercubesEnabled: " + true, 
      "hyperspaceDurationInSeconds: " + int(StarsSystem.DEFAULT_HYPERSPACE_DURATION / 1e3), 
      "hyperspaceTimeScale: " + Time.HYPERSPACE_DEFAULT_TIME, 
      "defaultTimeScale: " + Time.DEFAULT_DEFAULT_TIME_SCALE, 
      "", 
      "playerSpeed: " + Player.DEFAULT_RUNSPEED, 
      "extraLives: " + 0, 
      "", 
      "earthRotationSpeed: " + Earth.DEFAULT_EARTH_ROTATION, 
      "earthIsPangea: " + false, 
      "earthIsWest: " + true, 
      "", 
      "roidsPerSecond: " + 3, 
      "", 
      pss("ufoSpawnRateLow: " + 30) + "--spawn a UFO at least this often (seconds)", 
      pss("ufoSpawnRateHigh: " + 90) + "--spawn a UFO no more than this often (seconds)", 
      "", 
      "trexSpeed: " + Trex.DEFAULT_RUNSPEED, 
      pss("trexAttackAngle: " + Trex.DEFAULT_ATTACK_ANGLE) + "-- how far the trex \"sees\", in degrees", 
      "", 
      "JurassicUnlockedCheat: " + false, 
      "CretaceousUnlockedCheat: " + false, 
      "", 
      "----MISC----", 
      "tips: " + "\"" + join(assets.DEFAULT_TIPS, "\",\"") + "\"", 
      "-- put tips inside double quotes, seperate with comma, don't linebreak", 
      "", 
      "player1Color: \"#00ffff\"", 
      "player2Color: \"#ff57ff\"", 
      "", 
      pss("superColorsSwapEvery: " + ColorDecider.DEFAULT_SWAP_FREQUENCY) + "--swap palette every x number of frames", 
      "superColors: " + "\"" + join(assets.DEFAULT_COLORS, "\",\"") + "\"", 
      "-- put colors inside double quotes, seperate with comma, don't linebreak", 
      "-- colors can be hexadecimal, like \"#FF69B4\"", 
      "-- or use one of the HTML named colors, like \"hotpink\" (see https://en.wikipedia.org/wiki/Web_colors#Extended_colors)", 
      "-- you can have any number of colors. make a list with only fuschia, or one that creates a gradient, or one where the colors get brighter and darker, etc"
      );
    output.println(settingsString);
    output.flush();
    output.close();
    settings = new SimpleTXTParser(settingsString, true);
  }

  jurassicUnlocked = settings.getBoolean("JurassicUnlockedCheat", false);
  cretaceousUnlocked = settings.getBoolean("CretaceousUnlockedCheat", false);
  buttonsHide = settings.getBoolean("hideButtons", false); 
  panelsHide = settings.getBoolean("hideSidePanels", false);
  glow = settings.getBoolean("glowiness", true);
  leftkey1p = settings.getChar("player1LeftKey", 'a');
  rightkey1p = settings.getChar("player1RightKey", 'd');
  leftkey2p = settings.getChar("player2LeftKey", 'k');
  rightkey2p = settings.getChar("player2RightKey", 'l');
  pauseKey = settings.getChar("pauseKey", 'g');
  dipSwitches = settings.getChar("openSettings", 't');
  keys.p2HasArrows = settings.getBoolean("player2GetsArrowKeys", true);

  currentColor.dontPaletteSwap = settings.getBoolean("reduceFlashing", false);
  currentColor.parseUserColors(settings.getStrings("superColors", assets.DEFAULT_COLORS), assets.DEFAULT_COLORS);
  currentColor.swapFrequency = settings.getInt("superColorsSwapEvery", ColorDecider.DEFAULT_SWAP_FREQUENCY);

  secretVersionButton = settings.getChar("version", '\0');

  triassicSelect = settings.getChar("triassicSelect", '1');
  jurassicSelect = settings.getChar("jurassicSelect", '2');
  cretaceousSelect = settings.getChar("cretaceousSelect", '3');  
  onePlayerSelect = settings.getChar("singleplayerMode", 'o');
  twoPlayerSelect = settings.getChar("multiplayerMode", 'p');

  ngainSFX = settings.getFloat("negativeGainSFX", 30);
  ngainMusic = settings.getFloat("negativeGainMusic", 30);

  int vsfx = settings.getInt("sfxVolume", 100);
  if (vsfx == 0) {
    assets.muteSFX(true);
  } else {
    assets.volumeSFX(float(vsfx) / 100);
  }
  int vmusic = settings.getInt("musicVolume", 100);
  if (vmusic == 0) {
    assets.muteMusic(true);
  } else {
    assets.volumeMusic(float(vmusic) / 100);
  }
}

// padded settings string
String pss (String str) {
  char[] cs = new char[30];
  for (int i = 0; i < 30; i++) {
    cs[i] = i < str.length() ? str.charAt(i) : ' ';
  }
  return new String(cs);
}

int loadHighScore (String filename) {
  // load four bytes into one 32-bit integer by ORing bytes together
  int highscore = 0;
  byte[] scoreData = loadBytes(filename);
  if (scoreData != null ) {
    highscore = (((scoreData[3]       ) << 24) |
      ((scoreData[2] & 0xff) << 16) |
      ((scoreData[1] & 0xff) <<  8) |
      ((scoreData[0] & 0xff)      ));
  }
  return highscore;
}

void saveHighScore (int score, String filename) {
  // split score (32-bit integer in java) into four bytes, bitwise. save as byte array
  byte[] nums = new byte[4];
  nums[0] = (byte) (score & 0xff);
  nums[1] = (byte) ((score >>> 8) & 0xff);
  nums[2] = (byte) ((score >>> 16) & 0xff);
  nums[3] = (byte) ((score >>> 24) & 0xff);

  saveBytes(filename, nums);
}
