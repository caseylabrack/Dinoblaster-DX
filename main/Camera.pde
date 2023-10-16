class Camera extends Entity {
}

//class Camera extends Entity implements updateable {

//  public float magn = 0;
//  private Entity following = null;

//  Camera () {
//  }

//  void update () {

//    dx = 0;
//    dy = 0;
//    //x = width/2;
//    //y = height/2;

//    //if (mousePressed) magn += 3;

//    float angle = random(360);
//    dx += cos(radians(angle)) * magn;
//    dy += sin(radians(angle)) * magn;
//    magn *= .9;

//    //cute screenshake idea
//    //float magnitude = 25;
//    //float start = 0;
//    //float duration = 120;
//    //translate(
//    //  camera.x + (frameCount - start < duration ? cos(frameCount % 360) * magnitude * pow((duration - frameCount - start) / duration, 5) : 0), 
//    //  camera.y + (frameCount - start < duration ? sin(frameCount % 360) * magnitude * pow((duration - frameCount - start) / duration, 5) : 0)
//    //  );

//    x += dx;
//    y += dy;
//    r += dr;
//  }
//}


class ColorDecider implements updateable {
  private int currentHue = 0;

  IntList cs = new IntList();

  HashMap<String, String> hm = new HashMap<String, String>();
  boolean dontPaletteSwap = false;
  color white = #FFFFFF;
  int idx = 0;
  int mode = 1;
  final static int DEFAULT_SWAP_FREQUENCY = 15;
  int swapFrequency = DEFAULT_SWAP_FREQUENCY;

  ColorDecider() {
    hm.put("aliceblue", "#F0F8FF");
    hm.put("antiquewhite", "#FAEBD7");
    hm.put("aqua", "#00FFFF");
    hm.put("aquamarine", "#7FFFD4");
    hm.put("azure", "#F0FFFF");
    hm.put("beige", "#F5F5DC");
    hm.put("bisque", "#FFE4C4");
    hm.put("black", "#000000");
    hm.put("blanchedalmond", "#FFEBCD");
    hm.put("blue", "#0000FF");
    hm.put("blueviolet", "#8A2BE2");
    hm.put("brown", "#A52A2A");
    hm.put("burlywood", "#DEB887");
    hm.put("cadetblue", "#5F9EA0");
    hm.put("chartreuse", "#7FFF00");
    hm.put("chocolate", "#D2691E");
    hm.put("coral", "#FF7F50");
    hm.put("cornflowerblue", "#6495ED");
    hm.put("cornsilk", "#FFF8DC");
    hm.put("crimson", "#DC143C");
    hm.put("cyan", "#00FFFF");
    hm.put("darkblue", "#00008B");
    hm.put("darkcyan", "#008B8B");
    hm.put("darkgoldenrod", "#B8860B");
    hm.put("darkgray", "#A9A9A9");
    hm.put("darkgrey", "#A9A9A9");
    hm.put("darkgreen", "#006400");
    hm.put("darkkhaki", "#BDB76B");
    hm.put("darkmagenta", "#8B008B");
    hm.put("darkolivegreen", "#556B2F");
    hm.put("darkorange", "#FF8C00");
    hm.put("darkorchid", "#9932CC");
    hm.put("darkred", "#8B0000");
    hm.put("darksalmon", "#E9967A");
    hm.put("darkseagreen", "#8FBC8F");
    hm.put("darkslateblue", "#483D8B");
    hm.put("darkslategray", "#2F4F4F");
    hm.put("darkslategrey", "#2F4F4F");
    hm.put("darkturquoise", "#00CED1");
    hm.put("darkviolet", "#9400D3");
    hm.put("deeppink", "#FF1493");
    hm.put("deepskyblue", "#00BFFF");
    hm.put("dimgray", "#696969");
    hm.put("dimgrey", "#696969");
    hm.put("dodgerblue", "#1E90FF");
    hm.put("firebrick", "#B22222");
    hm.put("floralwhite", "#FFFAF0");
    hm.put("forestgreen", "#228B22");
    hm.put("fuchsia", "#FF00FF");
    hm.put("gainsboro", "#DCDCDC");
    hm.put("ghostwhite", "#F8F8FF");
    hm.put("gold", "#FFD700");
    hm.put("goldenrod", "#DAA520");
    hm.put("gray", "#808080");
    hm.put("grey", "#808080");
    hm.put("green", "#008000");
    hm.put("greenyellow", "#ADFF2F");
    hm.put("honeydew", "#F0FFF0");
    hm.put("hotpink", "#FF69B4");
    hm.put("indianred", "#CD5C5C");
    hm.put("indigo", "#4B0082");
    hm.put("ivory", "#FFFFF0");
    hm.put("khaki", "#F0E68C");
    hm.put("lavender", "#E6E6FA");
    hm.put("lavenderblush", "#FFF0F5");
    hm.put("lawngreen", "#7CFC00");
    hm.put("lemonchiffon", "#FFFACD");
    hm.put("lightblue", "#ADD8E6");
    hm.put("lightcoral", "#F08080");
    hm.put("lightcyan", "#E0FFFF");
    hm.put("lightgoldenrodyellow", "#FAFAD2");
    hm.put("lightgray", "#D3D3D3");
    hm.put("lightgrey", "#D3D3D3");
    hm.put("lightgreen", "#90EE90");
    hm.put("lightpink", "#FFB6C1");
    hm.put("lightsalmon", "#FFA07A");
    hm.put("lightseagreen", "#20B2AA");
    hm.put("lightskyblue", "#87CEFA");
    hm.put("lightslategray", "#778899");
    hm.put("lightslategrey", "#778899");
    hm.put("lightsteelblue", "#B0C4DE");
    hm.put("lightyellow", "#FFFFE0");
    hm.put("lime", "#00FF00");
    hm.put("limegreen", "#32CD32");
    hm.put("linen", "#FAF0E6");
    hm.put("magenta", "#FF00FF");
    hm.put("maroon", "#800000");
    hm.put("mediumaquamarine", "#66CDAA");
    hm.put("mediumblue", "#0000CD");
    hm.put("mediumorchid", "#BA55D3");
    hm.put("mediumpurple", "#9370D8");
    hm.put("mediumseagreen", "#3CB371");
    hm.put("mediumslateblue", "#7B68EE");
    hm.put("mediumspringgreen", "#00FA9A");
    hm.put("mediumturquoise", "#48D1CC");
    hm.put("mediumvioletred", "#C71585");
    hm.put("midnightblue", "#191970");
    hm.put("mintcream", "#F5FFFA");
    hm.put("mistyrose", "#FFE4E1");
    hm.put("moccasin", "#FFE4B5");
    hm.put("navajowhite", "#FFDEAD");
    hm.put("navy", "#000080");
    hm.put("oldlace", "#FDF5E6");
    hm.put("olive", "#808000");
    hm.put("olivedrab", "#6B8E23");
    hm.put("orange", "#FFA500");
    hm.put("orangered", "#FF4500");
    hm.put("orchid", "#DA70D6");
    hm.put("palegoldenrod", "#EEE8AA");
    hm.put("palegreen", "#98FB98");
    hm.put("paleturquoise", "#AFEEEE");
    hm.put("palevioletred", "#D87093");
    hm.put("papayawhip", "#FFEFD5");
    hm.put("peachpuff", "#FFDAB9");
    hm.put("peru", "#CD853F");
    hm.put("pink", "#FFC0CB");
    hm.put("plum", "#DDA0DD");
    hm.put("powderblue", "#B0E0E6");
    hm.put("purple", "#800080");
    hm.put("red", "#FF0000");
    hm.put("rosybrown", "#BC8F8F");
    hm.put("royalblue", "#4169E1");
    hm.put("saddlebrown", "#8B4513");
    hm.put("salmon", "#FA8072");
    hm.put("sandybrown", "#F4A460");
    hm.put("seagreen", "#2E8B57");
    hm.put("seashell", "#FFF5EE");
    hm.put("sienna", "#A0522D");
    hm.put("silver", "#C0C0C0");
    hm.put("skyblue", "#87CEEB");
    hm.put("slateblue", "#6A5ACD");
    hm.put("slategray", "#708090");
    hm.put("slategrey", "#708090");
    hm.put("snow", "#FFFAFA");
    hm.put("springgreen", "#00FF7F");
    hm.put("steelblue", "#4682B4");
    hm.put("tan", "#D2B48C");
    hm.put("teal", "#008080");
    hm.put("thistle", "#D8BFD8");
    hm.put("tomato", "#FF6347");
    hm.put("turquoise", "#40E0D0");
    hm.put("violet", "#EE82EE");
    hm.put("wheat", "#F5DEB3");
    hm.put("white", "#FFFFFF");
    hm.put("whitesmoke", "#F5F5F5");
    hm.put("yellow", "#FFFF00");
    hm.put("yellowgreen", "#9ACD32");
  }

  void parseUserColors(String[] userColors, String[] defaulthues) {

    cs.clear();
    idx = 0;

    for (String s : userColors) {
      s = s.toLowerCase();
      if (hm.containsKey(s)) s = hm.get(s);
      s = s.replace("#", "");
      if (s.length()==6) s = "ff" + s;
      if (match(s, "[a-fA-F0-9]{8}") != null) cs.append(unhex(s)); // is it actually a color hex
    }

    // couldn't parse user colors, use default
    if (cs.size()==0) {
      for (String h : defaulthues) cs.append(unhex("ff"+h.replace("#", "")));
    }
  }

  // input: string that is either color name or hex value
  // output: color value or -1 (for null)
  color parseColorString (String c) {
    color thecolor = -1;
    c = c.toLowerCase();
    if (hm.containsKey(c)) c = hm.get(c);
    c = c.replace("#", "");
    if (c.length()==6) c = "ff" + c;
    if (match(c, "[a-fA-F0-9]{8}") != null) thecolor = unhex(c); // is it actually a color hex
    return thecolor;
  }

  void update () {
    //currentHue = cs.get(utils.cycleRangeWithDelay(cs.size(), 10, frameCount));
    if (frameCount % swapFrequency == 0) {
      idx = mode > 0 ? idx + 1 : idx - 1;
      if (idx > cs.size()-1 || idx < 0) {
        mode *= -1;      
        idx = mode > 0 ? idx + 2 : idx - 2;
      }
    }
    currentHue = cs.size() > 1 ? cs.get(idx) : cs.get(0);
  }

  color getColor () {
    //return dontPaletteSwap ? white : currentHue;
    return dontPaletteSwap ? white : currentHue;
  }
}

class Time {
  float clock;
  float lastmillis;
  long lastNanos;
  float delta;
  int tick;
  float elapsed;
  final static float HYPERSPACE_DEFAULT_TIME = 1.75;
  final static float DEFAULT_DEFAULT_TIME_SCALE = 1;
  final static float DEATH_SCALING_DURATION = 3e3;

  float defaultTimeScale = DEFAULT_DEFAULT_TIME_SCALE;
  float hyperspaceTimeScale = HYPERSPACE_DEFAULT_TIME;
  float timeScale = DEFAULT_DEFAULT_TIME_SCALE;

  boolean isHyperSpace = false;
  boolean isDying = false;

  final static int NORM = 0;
  final static int DEATH = 1;
  int state = NORM;
  float stateStart;

  public void update () {
    elapsed = millis() - lastmillis;
    clock += elapsed * timeScale;
    lastmillis = millis();
        delta = min((frameRateLastNanos - lastNanos)/1e6/16.6666, 2.5);
    //delta = min((frameRateLastNanos - lastNanos)/1e6/16.6666, 4);
    lastNanos = frameRateLastNanos;

    if (state == DEATH) {
      float progress = (millis() - stateStart) / DEATH_SCALING_DURATION;
      float targetTimeScale = isHyperSpace ? hyperspaceTimeScale: defaultTimeScale;
      if (progress >= 1) {
        state = NORM;
        isDying = false;
        timeScale = targetTimeScale;
      } else {
        timeScale = utils.easeInOutExpo(progress, .1, targetTimeScale - .1, targetTimeScale);
      }
    }
  }

  void setDefaultTimeScale(float n) {
    defaultTimeScale = n;
    if (!isHyperSpace || !isDying) timeScale = defaultTimeScale;
  }

  void setHyperspace (boolean h) {
    isHyperSpace = h;
    if (h) {
      timeScale = hyperspaceTimeScale;
    } else {
      timeScale = defaultTimeScale;
    }
  }

  public void deathStart () {
    state = DEATH;
    stateStart = millis();
    isDying = false;
  }

  public float getTimeScale () {
    return timeScale * delta;
  }

  public float getClock() {
    return clock;
  }

  public float getScaledElapsed () {
    return elapsed * timeScale;
  }

  public void restart () {
    isDying = false;
    isHyperSpace = false;
    state = NORM;
    timeScale = defaultTimeScale;
  }

  public void rebaseTime () {
    lastmillis = millis();
    println("rebase time");
  }
}
