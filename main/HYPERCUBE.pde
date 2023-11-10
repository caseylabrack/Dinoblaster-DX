// Daniel Shiffman
// http://youtube.com/thecodingtrain
// http://codingtra.in

// Coding Challenge #113: 4D Hypercube
// https://youtu.be/XE3YDVdQSPo

// Matrix Multiplication
// https://youtu.be/tzsgS19RRc8

class Hypercube extends Entity {

  float angle = 0;
  final int w = 500;
  final int h = 500;
  PGraphics pg;

  final static float hypercubeLead = 17;
  final static float hypercubeOffset = -150;

  final static float DEFAULT_HYPERSPACE_DURATION = 15e3;
  float hyperspaceDuration = DEFAULT_HYPERSPACE_DURATION;

  final static float DEFAULT_MIN_SPAWN = 10e3;
  final static float DEFAULT_MAX_SPAWN = 80e3;
  float minSpawn = DEFAULT_MIN_SPAWN;
  float maxSpawn = DEFAULT_MAX_SPAWN;
  float spawnCountDown;
  float stateStart;

  final static int COUNTING_DOWN = 0;
  final static int READY = 1;
  final static int NORM = 2;
  final static int HYPERSPACE = 3;
  final static int HYPERSPACE_DONE = 4;
  int state;

  final static float BOUNDING_CIRCLE_RADIUS = 75;

  boolean enabled = false;

  P4Vector[] points = new P4Vector[16];

  Hypercube() {

    points[0] = new P4Vector(-1, -1, -1, 1);
    points[1] = new P4Vector(1, -1, -1, 1);
    points[2] = new P4Vector(1, 1, -1, 1);
    points[3] = new P4Vector(-1, 1, -1, 1);
    points[4] = new P4Vector(-1, -1, 1, 1);
    points[5] = new P4Vector(1, -1, 1, 1);
    points[6] = new P4Vector(1, 1, 1, 1);
    points[7] = new P4Vector(-1, 1, 1, 1);
    points[8] = new P4Vector(-1, -1, -1, -1);
    points[9] = new P4Vector(1, -1, -1, -1);
    points[10] = new P4Vector(1, 1, -1, -1);
    points[11] = new P4Vector(-1, 1, -1, -1);
    points[12] = new P4Vector(-1, -1, 1, -1);
    points[13] = new P4Vector(1, -1, 1, -1);
    points[14] = new P4Vector(1, 1, 1, -1);
    points[15] = new P4Vector(-1, 1, 1, -1);

    pg = createGraphics(w, h, P3D);
  }

  void startCountDown () {
    enabled = true;
    stateStart = millis();
    state = COUNTING_DOWN;
    spawnCountDown = random(minSpawn, maxSpawn);
  }

  void goHyperspace () {
    state = HYPERSPACE;
    stateStart = millis();
  }

  void update (float shiftX, float shiftY) {
    if (!enabled) return;

    switch(state) {

    case COUNTING_DOWN:
      if (millis() - stateStart > spawnCountDown) {
        state = READY;
      }
      break;

    case NORM:
      x -= shiftX;
      y -= shiftY;
      break;

    case HYPERSPACE:
      if (millis() - stateStart > hyperspaceDuration) {
        state = HYPERSPACE_DONE;
      }
      x -= shiftX;
      y -= shiftY;
      break;
    }
  }

  void render (float dt, color funkyColor) {
    if (!enabled || state == COUNTING_DOWN) return;
    //if (state != NORM && state != HYPERSPACE) return;

    pg.beginDraw();
    pg.pushMatrix();
    pg.pushStyle();
    pg.stroke(funkyColor);
    pg.strokeWeight(3);
    pg.noFill();
    pg.clear();

    pg.translate(w/2, h/2);
    pg.rotateX(-PI/2);

    PVector[] projected3d = new PVector[16];

    for (int i = 0; i < points.length; i++) {
      P4Vector v = points[i];

      float[][] rotationXY = {
        {cos(angle), -sin(angle), 0, 0}, 
        {sin(angle), cos(angle), 0, 0}, 
        {0, 0, 1, 0}, 
        {0, 0, 0, 1}
      };

      float[][] rotationYZ = {
        {1, 0, 0, 0}, 
        {0, cos(PI/4), -sin(PI/4), 0}, 
        {0, sin(PI/4), cos(PI/4), 0}, 
        {0, 0, 0, 1}
      };

      float[][] rotationZW = {
        {1, 0, 0, 0}, 
        {0, 1, 0, 0}, 
        {0, 0, cos(angle), -sin(angle)}, 
        {0, 0, sin(angle), cos(angle)}
      };


      P4Vector rotated = matmul4D(rotationYZ, v, true);
      rotated = matmul4D(rotationXY, rotated, true);
      rotated = matmul4D(rotationZW, rotated, true);

      float distance = 2.75;
      float w = 1 / (distance - rotated.w);

      float[][] projection = {
        {w, 0, 0, 0}, 
        {0, w, 0, 0}, 
        {0, 0, w, 0}
      };

      PVector projected = matmul4D(projection, rotated);
      //projected.mult(width/8);
      projected.mult(WIDTH_REFERENCE/8);
      projected3d[i] = projected;
    }

    // Connecting
    for (int i = 0; i < 4; i++) {
      connect(0, i, (i+1) % 4, projected3d );
      connect(0, i+4, ((i+1) % 4)+4, projected3d);
      connect(0, i, i+4, projected3d);
    }

    for (int i = 0; i < 4; i++) {
      connect(8, i, (i+1) % 4, projected3d );
      connect(8, i+4, ((i+1) % 4)+4, projected3d);
      connect(8, i, i+4, projected3d);
    }

    for (int i = 0; i < 8; i++) {
      connect(0, i, i + 8, projected3d);
    }

    angle += 0.02 * dt;
    pg.popStyle();
    pg.popMatrix();
    pg.endDraw();
    pushTransforms();
    sb.image(pg, 0, 0);
    sb.popMatrix();
  }

  void connect(int offset, int i, int j, PVector[] points) {
    PVector a = points[i+offset];
    PVector b = points[j+offset];
    pg.line(a.x, a.y, a.z, b.x, b.y, b.z);
  }

  void restart() {
    enabled = false;
  }
}


class P4Vector {
  float  x, y, z, w;

  P4Vector(float x, float y, float z, float w) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;
  }
}

float[][] vecToMatrix4D(P4Vector v) {
  float[][] m = new float[4][1];
  m[0][0] = v.x;
  m[1][0] = v.y;
  m[2][0] = v.z;
  m[3][0] = v.w;
  return m;
}

PVector matrixToVec4D(float[][] m) {
  PVector v = new PVector();
  v.x = m[0][0];
  v.y = m[1][0];
  v.z = m[2][0];
  return v;
}

P4Vector matrixToVec4D4(float[][] m) {
  P4Vector v = new P4Vector(0, 0, 0, 0);
  v.x = m[0][0];
  v.y = m[1][0];
  v.z = m[2][0];
  v.w = m[3][0];
  return v;
}

PVector matmul4D(float[][] a, P4Vector b) {
  float[][] m = vecToMatrix4D(b);
  return matrixToVec4D(matmul4D(a, m));
}

P4Vector matmul4D(float[][] a, P4Vector b, boolean fourth) {
  float[][] m = vecToMatrix4D(b);
  return matrixToVec4D4(matmul4D(a, m));
}

float[][] matmul4D(float[][] a, float[][] b) {
  int colsA = a[0].length;
  int rowsA = a.length;
  int colsB = b[0].length;
  int rowsB = b.length;

  if (colsA != rowsB) {
    println("Columns of A must match rows of B");
    return null;
  }

  float result[][] = new float[rowsA][colsB];

  for (int i = 0; i < rowsA; i++) {
    for (int j = 0; j < colsB; j++) {
      float sum = 0;
      for (int k = 0; k < colsA; k++) {
        sum += a[i][k] * b[k][j];
      }
      result[i][j] = sum;
    }
  }
  return result;
}
