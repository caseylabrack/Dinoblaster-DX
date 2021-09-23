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
final int RECORD_FRAMERATE = 2;

Keys keys = new Keys();
AssetManager assets = new AssetManager();
JSONObject settings;
JSONObject inputs;
JSONObject picadeSettings = null;

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
    settings = loadJSONObject("game-settings.txt");
  }
  catch(Exception e) {
    println("problem load game settings");
    settings = new JSONObject();
    PrintWriter output;
    output = createWriter("game-settings.txt"); 
    output.println("{");
    settings.setBoolean("roidsEnabled", true);
    output.println("\t\"roidsEnabled\": true,");
    settings.setBoolean("trexEnabled", true);
    output.println("\t\"trexEnabled\": true,");
    settings.setBoolean("hypercubesEnabled", true);
    output.println("\t\"hypercubesEnabled\": true,");
    settings.setBoolean("ufosEnabled", true);
    output.println("\t\"ufosEnabled\": true,");
    settings.setFloat("defaultTimeScale", 1);
    output.println("\t\"defaultTimeScale\": 1,");
    settings.setFloat("hyperspaceTimeScale", 1.75);
    output.println("\t\"hyperspaceTimeScale\": 1.75,");
    settings.setInt("extraLives", 0);
    output.println("\t\"extraLives\": 0,");
    settings.setFloat("earthRotationSpeed", Earth.DEFAULT_EARTH_ROTATION);
    output.println("\t\"earthRotationSpeed\": " + Earth.DEFAULT_EARTH_ROTATION + ",");
    settings.setFloat("playerSpeed", Player.DEFAULT_RUNSPEED);
    output.println("\t\"playerSpeed\": " + Player.DEFAULT_RUNSPEED + ",");
    settings.setFloat("roidImpactRateInMilliseconds", RoidManager.DEFAULT_SPAWN_RATE);
    output.println("\t\"roidImpactRateInMilliseconds\": " + (int)(RoidManager.DEFAULT_SPAWN_RATE) + ",");
    settings.setFloat("roidImpactRateVariation", RoidManager.DEFAULT_SPAWN_DEVIATION);
    output.println("\t\"roidImpactRateVariation\": " + (int)(RoidManager.DEFAULT_SPAWN_DEVIATION) + ",");
    settings.setBoolean("JurassicUnlocked", true);
    output.println("\t\"JurassicUnlocked\": true,");
    settings.setBoolean("CretaceousUnlocked", true);
    output.println("\t\"CretaceousUnlocked\": true,");
    settings.setInt("glowiness", assets.DEFAULT_GLOWINESS);
    output.println("\t\"glowiness\": " + assets.DEFAULT_GLOWINESS + ",");
    settings.setBoolean("earthIsPangea", false);
    output.println("\t\"earthIsPangea\": false,");
    settings.setBoolean("earthIsWest", true);
    output.println("\t\"earthIsWest\": true");
    output.println("}");
    output.flush();
    output.close();
  }

  try {
    inputs = loadJSONObject("controls-settings.txt");
  }
  catch(Exception e) {
    println("problem load inputs");
    inputs = new JSONObject();
    inputs.setString("player1LeftKey", "a");
    inputs.setString("player1RightKey", "d");
    inputs.setString("player2LeftKey", "k");
    inputs.setString("player2RightKey", "l");
    inputs.setBoolean("player2UsesArrowKeys", false);
    inputs.setString("triassicSelect", "1");
    inputs.setString("jurassicSelect", "2");
    inputs.setString("cretaceousSelect", "3");
    inputs.setInt("sfxVolume", 100);
    inputs.setInt("musicVolume", 100);
    inputs.setInt("startAtLevel", 4);
    inputs.setBoolean("hideHelpButton", false); 
    writeOutControls();
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
  int vsfx = inputs.getInt("sfxVolume", 100);
  if (vsfx == 0) {
    assets.muteSFX(true);
  } else {
    assets.volumeSFX(float(vsfx) / 100);
  }
  int vmusic = inputs.getInt("musicVolume", 100);
  if (vmusic == 0) {
    assets.muteMusic(true);
  } else {
    assets.volumeMusic(float(vmusic) / 100);
  }

  jurassicUnlocked = settings.getBoolean("JurassicUnlocked", false);
  cretaceousUnlocked = settings.getBoolean("CretaceousUnlocked", false);
  leftkey = inputs.getString("player1LeftKey", "a").charAt(0);
  rightkey = inputs.getString("player1RightKey", "d").charAt(0);
  triassicSelect = inputs.getString("triassicSelect", "1").charAt(0);
  jurassicSelect = inputs.getString("jurassicSelect", "2").charAt(0);
  cretaceousSelect = inputs.getString("cretaceousSelect", "3").charAt(0);  

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

int highestUnlockedLevel () {
  int nextlvl = UIStory.TRIASSIC;
  switch(int(loadHighScore(UIStory.SCORE_DATA_FILENAME) / 100)) {
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

  int startAt = inputs.getInt("startAtLevel", 4);
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

void writeOutControls () {
  PrintWriter output;
  output = createWriter("controls-settings.txt"); 
  output.println("{");
  output.println("\t\"player1LeftKey\": " + inputs.getString("player1LeftKey", "a") + ",");
  output.println("\t\"player1RightKey\": " + inputs.getString("player1RightKey", "d") + ",");
  output.println("\t\"player2LeftKey\": " + inputs.getString("player2LeftKey", "k") + ",");
  output.println("\t\"player2RightKey\": " + inputs.getString("player2RightKey", "l") + ",");
  output.println("\t\"player2UsesArrowKeys\": " + inputs.getBoolean("player2UsesArrowKeys", false) + ",");
  output.println("\t\"triassicSelect\": " + inputs.getString("triassicSelect", "1") + ",");
  output.println("\t\"jurassicSelect\": " + inputs.getString("jurassicSelect", "2") + ",");
  output.println("\t\"cretaceousSelect\": " + inputs.getString("cretaceousSelect", "3") + ",");
  output.println("\t\"sfxVolume\": " + inputs.getInt("sfxVolume", 100) + ",");    
  output.println("\t\"musicVolume\": " + inputs.getInt("musicVolume", 100) + ",");
  output.println("\t\"startAtLevel\": " + inputs.getInt("startAtLevel", 4) + ",");
  output.println("\t\"hideHelpButton\": " + inputs.getBoolean("hideHelpButton", false));
  output.println("}");
  output.flush();
  output.close();
}

float loadHighScore (String filename) {
  float h = 0;
  byte[] scoreData = loadBytes(filename);
  if (scoreData!=null) {
    for (byte n : scoreData) {
      h += float(n + 128);
    }
  }

  return h;
}

void saveHighScore (float score, String filename) {
  byte[] nums = new byte[score > 255 ? 2 : 1];
  nums[0] = byte(score > 255 ? 127 : floor(score) - 128);
  if (score > 256) nums[1] = byte(floor(score) - 256 - 127);
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

PVector screenspaceToWorldspace (float x, float y) {
  return new PVector((x - width/2) / SCALE, (y - height/2) / SCALE);
}
