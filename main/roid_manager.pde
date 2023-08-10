class RoidManager {
  final static float DEFAULT_SPAWN_RATE = 3;
  //final static float DEFAULT_SPAWN_RATE = 300;
  final int ROID_POOL_SIZE = 100;
  final int SPLODES_POOL_SIZE = 25;
  final float SPAWN_DIST = 720;
  float minSpawnInterval; 
  float maxSpawnInterval; 
  float fireRate;
  float lastFire;
  float spawnInterval = DEFAULT_SPAWN_RATE;

  Roid[] roids = new Roid[ROID_POOL_SIZE];
  int roidindex = 0;

  Explosion[] splodes = new Explosion[SPLODES_POOL_SIZE];
  int splodeindex = 0;

  boolean enabled = true;

  Explosion killer = null;

  private ArrayList<Roid> hits = new ArrayList<Roid>();

  void initRoidPool (PImage[] frames) {
    for (int i = 0; i <  ROID_POOL_SIZE; i++) {
      roids[i] = new Roid();
      roids[i].model = frames[int(random(0, 4))];
      //roids[i].modelIndex = int(random(0, 4));
    }
  }

  void initSplodePool(PImage[] frames) {
    for (int j = 0; j < splodes.length; j++) {
      splodes[j] = new Explosion();
      splodes[j].model = frames[0];
      splodes[j].frames = frames;
      //earth.addChild(splodes[j]);
    }
  }

  void fireRoids (float clock, PVector target) {
    if (!enabled) return;
    if (clock - lastFire > spawnInterval) {
      lastFire = clock;
      spawnInterval = fireRate * 1e3;//DEFAULT_SPAWN_RATE * 1e3;//random(minSpawnInterval, maxSpawnInterval);

      Roid r = roids[roidindex++ % roids.length]; // increment roid index and wrap to length of pool
      r.enabled = true;
      r.angle = random(0, 359);
      r.x = target.x + cos(radians(r.angle)) * SPAWN_DIST;
      r.y = target.y + sin(radians(r.angle)) * SPAWN_DIST;
      r.dx = cos(radians(r.angle+180)) * Roid.speed;
      r.dy = sin(radians(r.angle+180)) * Roid.speed;
    }
  }

  void updateRoids (float delta) {
    if (!enabled) return;
    for (Roid r : roids) {
      if (!r.enabled) continue;
      r.x += r.dx * delta;
      r.y += r.dy * delta;
      r.r += Roid.dr * delta;
    }
  }

  void updateExplosions (float clock) {
    for (Explosion s : splodes) {
      if (!s.enabled) continue;

      float progress = (clock - s.start) / Explosion.DURATION;

      if (progress > 1 && s.isDeadly) s.isDeadly = false;
      if (progress > .33 && progress < .66) s.model = s.frames[1];
      if (progress > .66 && progress <= 1) s.model = s.frames[2];
      if (progress > 1) s.enabled = false;
    }
  }

  // circle hit check against all roids. assumes global coords.
  ArrayList<Roid> anyRoidsHittingThisCircle (float cx, float cy, float radius) {
    //ArrayList<Roid> hits = new ArrayList<Roid>();
    hits.clear();
    for (Roid r : roids) {
      if (!r.enabled) continue;
      if (dist(cx, cy, r.x, r.y) < radius) {
        hits.add(r);
      }
    }
    return hits;
  }

  Explosion newExplosion (float clock) {
    Explosion splode = splodes[splodeindex++ % splodes.length]; // increment splode index and wrap to length of pool
    splode.enabled = true;
    splode.isDeadly = true;
    splode.parent = null;
    splode.start = clock;
    splode.model = splode.frames[0];

    return splode;
  }

  void renderRoids () {
    if (!enabled) return;
    for (Roid r : roids) {
      if (!r.enabled) continue;
      pushMatrix();
      imageMode(CENTER);
      translate(r.x, r.y);

      pushMatrix();
      rotate(radians(r.angle+90));
      image(assets.roidStuff.trail, 0, -25);
      popMatrix();

      rotate(r.r);
      //image(r.model, 0, 0);
      image(assets.roidStuff.roidFrames[r.modelIndex], 0, 0);
      //image(model, 0, 0, model.width/2, model.height/2);
      popMatrix();
    }
  }

  void renderSplodes () {
    for (Explosion s : splodes) {
      if (!s.enabled) continue;
      s.simpleRenderImage(s.model);
    }
  }

  void restart () {
    for (Roid r : roids) {
      r.enabled = false;
    }

    for (Explosion e : splodes) {
      e.enabled = false;
    }
  }
}

class Roid extends Entity {
  int modelIndex;
  //PImage model
  final static float speed = 2.5;
  boolean enabled = false;
  PImage trail;
  float angle;
  PVector trailPosition;
  final static float dr = .1;
}

class Explosion extends Entity {
  PImage[] frames;
  float start;
  final static float DURATION = 500;
  final static float DEADLY_DURATION = 100;
  final static float OFFSET_FROM_EARTH = 20;
  final static float BOUNDING_ARC = 10;
  boolean enabled = false;
  boolean isDeadly = false;
}
