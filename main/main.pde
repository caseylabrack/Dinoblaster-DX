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

Keys keys = new Keys();
AssetManager assets = new AssetManager();
SimpleTXTParser settings;
JSONObject picadeSettings;

boolean jurassicUnlocked, cretaceousUnlocked;
char leftkey, rightkey, leftkey2p, rightkey2p, triassicSelect, jurassicSelect, cretaceousSelect;

float SCALE;
float WIDTH_REFERENCE = 1024;
float WIDTH_REF_HALF = WIDTH_REFERENCE/2;
float HEIGHT_REFERENCE = 768;
float HEIGHT_REF_HALF = HEIGHT_REFERENCE/2;


void setup () {
  //size(500, 500, P2D);
  size(1024, 768, P2D);
  //fullScreen(P2D);
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
    String spacer = "          ";
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
      "triassicSelect: 1",
      "jurassicSelect: 2",
      "cretaceousSelect: 3",
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
      "", 
      "hypercubesEnabled: " + true, 
      "hyperspaceDuration: " + int(StarManager.DEFAULT_HYPERSPACE_DURATION / 1e3) + spacer + "-- in seconds", 
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
      "JurassicUnlocked: " + false, 
      "CretaceousUnlocked: " + false
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
  leftkey = settings.getString("player1LeftKey", "a").charAt(0);
  rightkey = settings.getString("player1RightKey", "d").charAt(0);
  triassicSelect = settings.getString("triassicSelect", "1").charAt(0);
  jurassicSelect = settings.getString("jurassicSelect", "2").charAt(0);
  cretaceousSelect = settings.getString("cretaceousSelect", "3").charAt(0);  

  //currentScene = new SinglePlayer(UIStory.TRIASSIC);
  //currentScene = new Oviraptor(Scene.OVIRAPTOR);
  //currentScene = new SinglePlayer(chooseNextLevel());
}

void keyPressed() {

  //println(key, keyCode);
  //println(key==CODED);

  if (key==CODED) {
    if (keyCode==LEFT) keys.setKey(Keys.LEFT, true);
    if (keyCode==RIGHT) keys.setKey(Keys.RIGHT, true);
  } else {
    if (key=='1' || key==triassicSelect || key=='2' || key==jurassicSelect || key=='3' || key==cretaceousSelect) currentScene.cleanup();
    if (key=='1' || key==triassicSelect) currentScene = new SinglePlayer(UIStory.TRIASSIC);
    if ((key=='2' || key==jurassicSelect) && jurassicUnlocked) currentScene = new SinglePlayer(UIStory.JURASSIC);
    if ((key=='3' || key==cretaceousSelect) && cretaceousUnlocked) currentScene = new SinglePlayer(UIStory.CRETACEOUS);
    if (key==leftkey) keys.setKey(Keys.LEFT, true);
    if (key==rightkey) keys.setKey(Keys.RIGHT, true);
    if (key=='r') {
      rec = true;
      println("recording");
    }
  }
}

void touchStarted() {
  //println("touch started");
}

void keyReleased() {

  if (key==CODED) {
    if (keyCode==LEFT) keys.setKey(Keys.LEFT, false);
    if (keyCode==RIGHT) keys.setKey(Keys.RIGHT, false);
  } else {
    if (key==leftkey) keys.setKey(Keys.LEFT, false);
    if (key==rightkey) keys.setKey(Keys.RIGHT, false);
    if (key=='r') {
      rec = false;
      println("stopped recording");
    }
  }
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

  if (frameCount==1) {
    currentScene = new SinglePlayer(chooseNextLevel()); 
    return;
  }

  //if(touches.length==0) {
  //  keys.setKey(Keys.LEFT, false);
  //  keys.setKey(Keys.RIGHT, false);
  //} else {
  //  keys.setKey(touches[0].x < width/2 ? Keys.LEFT : Keys.RIGHT, true);
  //}

  if (!paused) {
    background(0, 0, 0, 1);
    //fill(0,0,0,.2);
    //rect(0,0,width,height);
    if (currentScene.status==Scene.DONE) {
      currentScene.cleanup();
      currentScene = new SinglePlayer(chooseNextLevel());
    }
    currentScene.update();
    currentScene.render();
  }

  if (rec) {
    if (frameCount % 1 == 0) {
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

int highestUnlockedLevel () {
  int nextlvl = UIStory.TRIASSIC;
  int highscorefloor = loadHighScore(UIStory.SCORE_DATA_FILENAME) / 100;
  switch(highscorefloor) {
  case 0:  
    nextlvl = UIStory.TRIASSIC;
    break;
  case 1:  
    nextlvl = UIStory.JURASSIC;
    break;
  case 2:  
    nextlvl = UIStory.CRETACEOUS;
    break;
  }

  if (settings.getBoolean("JurassicUnlocked", false)) nextlvl = max(nextlvl, UIStory.JURASSIC);
  if (settings.getBoolean("CretaceousUnlocked", false)) nextlvl = max(nextlvl, UIStory.CRETACEOUS);

  return nextlvl;
}

int chooseNextLevel () {

  int startAt = settings.getInt("startAtLevel", 4);
  int unlocked = highestUnlockedLevel();
  int chosen = unlocked; // default to highest level unlocked. user can choose this with any number 4+

  switch(startAt) {
  case 0:
  case 1:
    chosen = UIStory.TRIASSIC;
    break;

  case 2: 
    if (settings.getBoolean("JurassicUnlocked", false) || unlocked >= UIStory.JURASSIC) chosen = UIStory.JURASSIC;
    break;

  case 3: 
    if (settings.getBoolean("CretaceousUnlocked", false) || unlocked >= UIStory.CRETACEOUS) chosen = UIStory.CRETACEOUS;
    break;
  }

  return chosen;
}

//void writeOutControls () {
//  PrintWriter output;
//  output = createWriter("controls-settings.txt"); 
//  output.println("{");
//  output.println("\t\"player1LeftKey\": " + inputs.getString("player1LeftKey", "a") + ",");
//  output.println("\t\"player1RightKey\": " + inputs.getString("player1RightKey", "d") + ",");
//  output.println("\t\"player2LeftKey\": " + inputs.getString("player2LeftKey", "k") + ",");
//  output.println("\t\"player2RightKey\": " + inputs.getString("player2RightKey", "l") + ",");
//  output.println("\t\"player2UsesArrowKeys\": " + inputs.getBoolean("player2UsesArrowKeys", false) + ",");
//  output.println("\t\"triassicSelect\": " + inputs.getString("triassicSelect", "1") + ",");
//  output.println("\t\"jurassicSelect\": " + inputs.getString("jurassicSelect", "2") + ",");
//  output.println("\t\"cretaceousSelect\": " + inputs.getString("cretaceousSelect", "3") + ",");
//  output.println("\t\"sfxVolume\": " + inputs.getInt("sfxVolume", 100) + ",");    
//  output.println("\t\"musicVolume\": " + inputs.getInt("musicVolume", 100) + ",");
//  output.println("\t\"startAtLevel\": " + inputs.getInt("startAtLevel", 4) + ",");
//  output.println("\t\"hideHelpButton\": " + inputs.getBoolean("hideHelpButton", false));
//  output.println("}");
//  output.flush();
//  output.close();
//}

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


class Keys {

  // keys on picade console:
  // |joy|    |16| |90| |88|
  //          |17| |18| |32|

  // front panel:
  // |27|      |79|

  static final int LEFT = 0;
  static final int RIGHT = 1;
  static final int MOUSEUP = 3;
  boolean left = false;
  boolean right = false;
  boolean anykey = false;

  void setKey(int _key, boolean _value) {

    switch(_key) {

    case LEFT:
      left = _value;
      break;

    case RIGHT:
      right = _value;
      break;

    default:
      println("unknown key press/release");
      break;
    }

    anykey = left || right;
  }
}
