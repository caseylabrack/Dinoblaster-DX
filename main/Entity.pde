class Entity {
  float x, y, r, dx, dy, dr;
  int facing = 1;
  float scale = 1;
  Entity parent = null;
  PImage model;
  PShape modelVector;

  void addChild (Entity child) {
    child.setPosition(globalToLocalPos(child.globalPos()));
    child.r = child.globalRote() - r;
    child.parent = this;
  } 

  public PVector globalToLocalPos (PVector globalPoint) {
    PVector mypos = globalPos();
    float d = dist(mypos.x, mypos.y, globalPoint.x, globalPoint.y);
    float a = atan2(globalPoint.y - mypos.y, globalPoint.x - mypos.x);
    float rote = a - radians(globalRote());

    return new PVector(cos(rote) * d, sin(rote) * d);
  }

  PVector globalPos() {
    if (parent!=null) {
      float a = atan2(y, x) + radians(parent.r);
      float d = dist(x, y, 0, 0);
      return new PVector(parent.x + cos(a) * d, parent.y + sin(a) * d);
    }
    return new PVector(x, y);
  }

  float globalRote() {
    if (parent!=null) {
      return parent.r + r;
    }
    return r;
  }

  void setPosition (PVector pos) {
    x = pos.x;
    y = pos.y;
  }

  void setPosition (float x, float y) {
    this.x = x;
    this.y = y;
  }

  PVector localPos () {
    return new PVector(x, y);
  }

  float localRote() {
    return r;
  }

  void pushTransforms () {
    sb.pushMatrix();
    PVector pos = globalPos();
    sb.scale(facing, 1);
    sb.translate(pos.x * facing, pos.y);
    sb.rotate(radians(globalRote() * facing));
    sb.scale(scale);
  }

  void simpleRenderImage (PImage im) {
    pushTransforms();
    sb.image(im, 0, 0);
    sb.popMatrix();
  }

  void simpleRenderImage () {
    simpleRenderImage(model);
  }

  void simpleRenderImage (PShape im) {
    pushTransforms();
    pushStyle();
    strokeWeight(assets.STROKE_WIDTH / scale);
    shapeMode(CENTER);
    shape(im, 0, 0);
    popStyle();
    popMatrix();
  }

  void simpleRenderImageVector () {
    pushTransforms();
      sb.pushStyle();
      sb.strokeWeight(assets.STROKE_WIDTH / scale);
      sb.shapeMode(CENTER);
      sb.shape(modelVector, 0, 0);
      sb.popStyle();
    sb.popMatrix();
  }

  void identity () {
    x = 0;
    y = 0;
    r = 0;
    dx = 0;
    dy = 0;
    dr = 0;
    facing = 1;
    scale = 1;
    parent = null;
  }
}
