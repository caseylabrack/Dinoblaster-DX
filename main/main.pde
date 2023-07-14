// TO DO
// user toggle between 1 and 2 player
// ufos for 2p
// deaths and extra lives for 2p
// 1 and 2 meeple buttons
// dipswitches pauses
// on resume from dipswitches, reload settings
// dipswitches circle lock thingy
// title screen (turn on animation? attract mode?)
// hide UI
// nongaussian blur glow
// 40th anniversary edition
// fun stuff on edge of screen for aspect ratios > 4:3
// oviraptor mode

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

boolean paused = false;
Scene currentScene;

// recording
int fcount = 0;
boolean rec = false;
final int RECORD_FRAMERATE = 1;

Keys keys = new Keys();
AssetManager assets = new AssetManager();
SimpleTXTParser settings;
JSONObject picadeSettings;

boolean jurassicUnlocked, cretaceousUnlocked;
char leftkey1p, rightkey1p, leftkey2p, rightkey2p, triassicSelect, jurassicSelect, cretaceousSelect, onePlayerSelect, twoPlayerSelect;

float SCALE;
float WIDTH_REFERENCE = 1024;
float WIDTH_REF_HALF = WIDTH_REFERENCE/2;
float HEIGHT_REFERENCE = 768;
float HEIGHT_REF_HALF = HEIGHT_REFERENCE/2;

SinglePlayer singlePlayer;
Oviraptor oviraptor;

void setup () {
  //size(500, 500, P2D);
  size(1024, 768, P2D);
  //fullScreen(P2D);
  smooth(4);
  frameRate(30);
  //hint(DISABLE_OPTIMIZED_STROKE);
  orientation(LANDSCAPE);

  //pixelDensity(displayDensity());

  SCALE = (float)height / HEIGHT_REFERENCE;

  surface.setTitle("DinoBlaster DX");

  colorMode(HSB, 360, 100, 100, 1);
  imageMode(CENTER);

  minim = new Minim(this);

  try {
    settings = new SimpleTXTParser("DIP-switches.txt", true);
  }
  catch(Exception e) {
    println("problem load game settings");
    PrintWriter output;
    output = createWriter("DIP-switches.txt");
    String spacer = "     ";
    String settingsString = String.join("\n", 
      "--Edit this text file to change your controls, set preferences, and even cheat.", 
      "--(Restart DinoBlaster for changes to take effect.)", 
      "--Learn more about these settings here: https://github.com/caseylabrack/Dinoblaster-DX", 
      "", 
      "", 
      "----CONTROLS----", 
      "player1LeftKey: a", 
      "player1RightKey: d", 
      "", 
      "player2LeftKey: k", 
      "player2RightKey: l", 
      "", 
      "player2GetsArrowKeys: true" + spacer + "-- in 2p mode, arrow keys move p2", 
      "", 
      "triassicSelect: 1", 
      "jurassicSelect: 2", 
      "cretaceousSelect: 3", 
      "", 
      "1playerSelect: o", 
      "2playerSelect: p", 
      "", 
      "sfxVolume: 100", 
      "musicVolume: 100", 
      "", 
      "startAtLevel: 4", 
      "hideDIPSwitchesButton: false", 
      "glowiness: " + assets.DEFAULT_GLOWINESS, 
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
      "hyperspaceDuration: " + int(StarsSystem.DEFAULT_HYPERSPACE_DURATION / 1e3) + spacer + "-- in seconds", 
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
      "roidImpactRateInMilliseconds: " + RoidManager.DEFAULT_SPAWN_RATE, 
      "roidImpactRateVariation: " + RoidManager.DEFAULT_SPAWN_DEVIATION, 
      "", 
      "trexSpeed: " + Trex.DEFAULT_RUNSPEED, 
      "trexAttackAngle: " + Trex.DEFAULT_ATTACK_ANGLE + spacer + "-- how far the trex \"sees\", in degrees", 
      "", 
      "JurassicUnlocked: " + false, 
      "CretaceousUnlocked: " + false, 
      "", 
      "----MISC----", 
      "showSidePanels: " + true, 
      "", 
      "tips: " + "\"" + join(assets.DEFAULT_TIPS, "\",\"") + "\"", 
      "-- put tips inside double quotes, don't linebreak", 
      "", 
      "colors: " + "\"" + join(assets.DEFAULT_COLORS, "\",\"") + "\"", 
      "-- put colors inside double quotes, don't linebreak", 
      "-- colors can be hexadecimal, like \"#FF69B4\"", 
      "-- or use one of the HTML named colors, like \"hotpink\" (see https://en.wikipedia.org/wiki/Web_colors#Extended_colors)", 
      "-- you can have any number of colors. make a list with only fuschia, or one that creates a gradient, or one where the colors get brighter and darker, etc"
      );
    output.println(settingsString);
    output.flush();
    output.close();
    settings = new SimpleTXTParser(settingsString, true);
  }

  try {
    picadeSettings = loadJSONObject("picade.txt");
    noCursor();
    //frameRate(30);
  } 
  catch(Exception e) {
  }

  assets.load(this, picadeSettings);

  assets.setGlowiness(settings.getInt("glowiness", assets.DEFAULT_GLOWINESS));
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

  jurassicUnlocked = settings.getBoolean("JurassicUnlocked", false);
  cretaceousUnlocked = settings.getBoolean("CretaceousUnlocked", false);
  leftkey1p = settings.getChar("player1LeftKey", 'a');
  rightkey1p = settings.getChar("player1RightKey", 'd');
  leftkey2p = settings.getChar("player2LeftKey", 'k');
  rightkey2p = settings.getChar("player2RightKey", 'l');
  //p2arrows = settings.getBoolean("player2GetsArrowKeys", true);
  keys.p2HasArrows = settings.getBoolean("player2GetsArrowKeys", true);
  triassicSelect = settings.getChar("triassicSelect", '1');
  jurassicSelect = settings.getChar("jurassicSelect", '2');
  cretaceousSelect = settings.getChar("cretaceousSelect", '3');  
  onePlayerSelect = settings.getChar("1playerSelect", 'o');
  twoPlayerSelect = settings.getChar("2playerSelect", 'p');

  singlePlayer = new SinglePlayer(settings, assets);
  singlePlayer.play(SinglePlayer.TRIASSIC);
  //singlePlayer.play(SinglePlayer.JURASSIC);
  //singlePlayer.play(SinglePlayer.CRETACEOUS);

  oviraptor = new Oviraptor(settings, assets);

  currentScene = singlePlayer;
  //currentScene = oviraptor;
}

void touchStarted() {
  //println("touch started");
}

void mousePressed () {
  //  frameRate(5);
}

void mouseReleased () {
  currentScene.mouseUp();
  //frameRate(60);
  //rec = true;
}

void draw () {

  //if (frameCount==1) {
  //  currentScene = new SinglePlayer(chooseNextLevel()); 
  //  return;
  //}

  //if(touches.length==0) {
  //  keys.setKey(Keys.LEFT, false);
  //  keys.setKey(Keys.RIGHT, false);
  //} else {
  //  keys.setKey(touches[0].x < width/2 ? Keys.LEFT : Keys.RIGHT, true);
  //}

  //int b = int(map(mouseX, 0, width, 0, 25));
  //float s = map(mouseY, 0, height, 0, 20);

  //assets.glow.set("blurSize", b);
  //assets.glow.set("sigma", s);

  if (!paused) {
    background(0, 0, 0, 1);
    //fill(0,0,0,.2);
    //rect(0,0,width,height);
    //if (currentScene.status==Scene.DONE) {
    //  currentScene.cleanup();
    //  currentScene = new SinglePlayer(chooseNextLevel());
    //}
    currentScene.update();
    currentScene.render();
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

void keyPressed() {

  //println(key, keyCode);
  //println(key==CODED);

  if (key==CODED) {
    if (keyCode==LEFT) keys.arrowleft = true;
    if (keyCode==RIGHT) keys.arrowright = true;
  } else {
    if (key=='1' || key==triassicSelect) singlePlayer.play(SinglePlayer.TRIASSIC);
    if ((key=='2' || key==jurassicSelect) && jurassicUnlocked) singlePlayer.play(SinglePlayer.JURASSIC);
    if ((key=='3' || key==cretaceousSelect) && cretaceousUnlocked) singlePlayer.play(SinglePlayer.CRETACEOUS);
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
      singlePlayer.numPlayers = 1;
      keys.playingMultiplayer = false;
      singlePlayer.play(SinglePlayer.TRIASSIC);
    }
    if (key==twoPlayerSelect) {
      singlePlayer.numPlayers = 2;
      keys.playingMultiplayer = true;
      singlePlayer.play(SinglePlayer.TRIASSIC);
    }
    if (key=='r') {
      rec = false;
      println("stopped recording");
    }
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
    return leftp1 || rightp1 || leftp2 || rightp2;
  }
}

PVector screenspaceToWorldspace (float x, float y) {
  return new PVector((x - width/2) / SCALE, (y - height/2) / SCALE);
}
