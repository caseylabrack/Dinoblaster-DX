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

  static float easeLinear (float t, float b, float c, float d) { 
    return b + c * (t/d);
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
