static class utils {

  static final PVector ZERO_VECTOR = new PVector(0, 0);

  static float angleOf(PVector from, PVector to) {

    return degrees(atan2(to.y - from.y, to.x - from.x));
  }

  static float angleOfRadians(PVector from, PVector to) {
    return atan2(to.y - from.y, to.x - from.x);
  }

  static PVector midpoint (PVector p1, PVector p2) {
    float angle = atan2(p2.y - p1.y, p2.x - p1.x);
    float dist = PVector.dist(p1, p2);
    return new PVector(p1.x + cos(angle) * dist/2, p1.y + sin(angle) * dist/2);
  }

  static PVector offset (PVector point, PVector offset) {
    return new PVector(point.x - offset.x, point.y - offset.y);
  }

  static PVector rotateAroundPoint (PVector obj, PVector center, float degrees) {
    float angle = degrees(atan2(center.y - obj.y, center.x - obj.x));
    float dist = dist(center.x, center.y, obj.x, obj.y);
    angle += degrees;
    return new PVector(center.x - cos(radians(angle)) * dist, center.y - sin(radians(angle)) * dist);
  }

  static PImage[] sheetToSprites (PImage sheet, int rows, int cols, int blanks) {
    PImage[] sprites = new PImage[rows*cols-blanks];
    int cellX = sheet.width / rows;
    int cellY = sheet.height / cols;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (r * cols + c < rows*cols-blanks) sprites[r * cols + c] = sheet.get(r * cellX, c * cellY, cellX, cellY);
      }
    }
    return sprites;
  }

  static PImage[] sheetToSprites (PImage sheet, int rows, int cols) {
    return sheetToSprites(sheet, rows, cols, 0);
  }

  static int cycleRangeWithDelay (int framesTotal, int delay, int seed) {
    return floor((seed % floor(framesTotal * delay))/delay);
  }

  public static float unsignedAngleDiff(float alpha, float beta) {
    float phi = Math.abs(beta - alpha) % 360;       
    float distance = phi > 180 ? 360 - phi : phi;
    return distance;
  }

  static float signedAngleDiff (float r1, float r2) {
    float diff = (r2 - r1 + 180) % 360 - 180;
    return diff < -180 ? diff + 360: diff;
  }

  static boolean rectOverlap (PVector l1, PVector r1, PVector l2, PVector r2) {
    if (r1.x < l2.x || r2.x < l1.x) {
      return false;
    }

    if (r2.y < l1.y || r1.y < l2.y) {
      return false;
    }

    return true;
  }
  
  static int sign (float x) {
    return x == 0 ? 0 : x > 0 ? 1 : -1;
  }

  static float easeLinear (float t, float b, float c, float d) { 
    return b + c * (t/d);
  }

  static float easeOutCirc(float x) {
    return sqrt(1 - pow(x - 1, 2));
  }

  static float easeInOutQuad (float t, float b, float c, float d) {
    if ((t/=d/2) < 1) return c/2*t*t + b;
    return -c/2 * ((--t)*(t-2) - 1) + b;
  }

  static float easeInOutQuart (float t, float b, float c, float d) {
    if ((t/=d/2) < 1) return c/2*t*t*t*t + b;
    return -c/2 * ((t-=2)*t*t*t - 2) + b;
  }

  static float easeInOutExpo (float t, float b, float c, float d) {
    if (t==0) return b;
    if (t==d) return b+c;
    if ((t/=d/2) < 1) return (float)(c/2 * Math.pow(2, 10 * (t - 1)) + b);
    return (float)(c/2 * (-Math.pow(2, -10 * --t) + 2) + b);
  }

  static float easeInExpo (float t, float b, float c, float d) {
    return (float)((t==0) ? b : c * Math.pow(2, 10 * (t/d - 1)) + b);
  }

  static float easeOutExpo (float t, float b, float c, float d) {
    return (t==d) ? b+c : (float)(c * (-Math.pow(2, -10 * t/d) + 1) + b);
  }

  static float easeOutQuad (float t, float b, float c, float d) {
    return -c *(t/=d)*(t-2) + b;
  }

  static float easeInQuad (float t, float b, float c, float d) {
    return c*(t/=d)*t + b;
  }

  static float easeOutBounce(float x) {
    float n1 = 7.5625;
    float d1 = 2.75;

    if (x < 1 / d1) {
      return n1 * x * x;
    } else if (x < 2 / d1) {
      return n1 * (x -= 1.5 / d1) * x + 0.75;
    } else if (x < 2.5 / d1) {
      return n1 * (x -= 2.25 / d1) * x + 0.9375;
    } else {
      return n1 * (x -= 2.625 / d1) * x + 0.984375;
    }
  }

  static float easeOutElastic(float x) {
    float c4 = (2 * PI) / 3;

    return x == 0
      ? 0
      : x == 1
      ? 1
      : pow(2, -10 * x) * sin((x * 10 - 0.75) * c4) + 1;
  }

  static float easeOutCubicT(float x) {
    return 1 - pow(1 - x, 3);
  }

  static float easeOutExpoT(float x) {
    return x == 1 ? 1 : 1 - pow(2, -10 * x);
  }
} 

class Rectangle {
  float x, y, w, h;

  Rectangle (float _x, float _y, float _w, float _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
  }

  boolean inside (PVector point) {
    return inside(point.x, point.y);
  }

  boolean inside (float px, float py) {
    return px > x && px < x + w && py > y && py < y + h;
  }
}

class SimpleTXTParser {

  String txt;
  boolean errors;

  SimpleTXTParser(String path) {
    init(path, false);
  }

  SimpleTXTParser(String path, boolean errors) {
    init(path, errors);
  }

  void init (String path, boolean errors) {
    if (path.endsWith(".txt")) {
      String[] arr = loadStrings(path);
      if (arr != null) {
        txt = String.join("\n", arr);
      } else {
        throw new java.lang.RuntimeException("configs parser: couldn't `loadStrings` this file");
      }
    } else { // string isn't a path, it's already a delimited config string
      txt = path;
    }
  }

  boolean getBoolean (String _key, boolean _default) {
    boolean result = _default;
    String[] m = match(txt, _key + ":\\s*(\\w+)");
    if (m != null) {
      if (m[1].equalsIgnoreCase("true")) result = true;
      if (m[1].equalsIgnoreCase("false")) result = false;
    } else {
      if (errors) println("getBool no match: ", _key);
    }
    return result;
  }

  float getFloat (String _key, float _default) {
    float result = _default;
    String[] m = match(txt, _key + ":\\s*([+-]?\\d*\\.?\\d*)");
    if (m != null) {
      try {
        result = Float.parseFloat(m[1]);
      } 
      catch(Exception e) {
      }
    } else {
      if (errors) println("getBool no match: ", _key);
    }
    return result;
  }

  int getInt (String _key, int _default) {
    int result = _default;
    String[] m = match(txt, _key + ":\\s*(\\d+)");
    if (m != null) {
      try {
        result = Integer.parseInt(m[1]);
      } 
      catch(Exception e) {
      }
    } else {
      if (errors) println("getBool no match: ", _key);
    }
    return result;
  }

  char getChar (String _key, char _default) {
    char result = _default;
    //String[] m = match(txt, _key + ":\\s*(\\w+)");
    //String[] m = match(txt, _key + ":\\s*([\\w+\\"])");
    String[] m = match(txt, _key + ":\\s*\"?(.)");
    if (m != null) {
      try {
        result = m[1].charAt(0);
      } 
      catch(Exception e) {
      }
    } else {
      if (errors) println("getChar no match: ", _key);
    }
    return result;
  }

  String getString (String _key, String _default) {
    String result = _default;
    //String[] m = match(txt, _key + ":\\s*(\\w+)");
    //String[] m = match(txt, _key + ":\\s*([\\w+\\"])");
    String[] m = match(txt, _key + ":\\s*([^\"])");
    if (m != null) {
      try {
        result = m[1];
      } 
      catch(Exception e) {
      }
    } else {
      if (errors) println("getString no match: ", _key);
    }
    return result;
  }

  String[] getStrings (String _key, String[] _default) {
    String[] result = _default;
    String[] line = match(txt, _key + ":([^\n\r]+)$"); // get the whole text line. the dot would consume line terminators apparently
    String[][] m = null;
    if (line!=null) {
      m = matchAll(line[1], "\"([^\"]+)\""); // within that line, find all strings (character sequences enclosed in double quotes)
    }
    if (m != null) {
      result = new String[m.length];
      for (int i = 0; i < m.length; i++) {
        result[i] = m[i][1];
      }
    } else {
      if (errors) println("getStrings no match: ", _key);
    }
    return result;
  }
}
