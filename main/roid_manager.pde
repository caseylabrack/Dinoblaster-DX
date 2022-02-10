class RoidManager {
  final static float DEFAULT_SPAWN_RATE = 300;
  final static float DEFAULT_SPAWN_DEVIATION = 100;
  final int ROID_POOL_SIZE = 100;
  final int SPLODES_POOL_SIZE = 100;
  final float SPAWN_DIST = 720;
  float minSpawnInterval; 
  float maxSpawnInterval; 
  float lastFire;
  float spawnInterval = DEFAULT_SPAWN_RATE;

  Roid[] roids = new Roid[ROID_POOL_SIZE];
  int roidindex = 0;

  Explosion[] splodes = new Explosion[25];
  int splodeindex = 0;

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
    if (clock - lastFire > spawnInterval) {
      lastFire = clock;
      spawnInterval = random(minSpawnInterval, maxSpawnInterval);

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
    for (Roid r : roids) {
      if (!r.enabled) continue;
      r.x += r.dx * delta;
      r.y += r.dy * delta;
      r.r += Roid.dr * delta;

      //if (PVector.dist(r.globalPos(), earth.globalPos()) < Earth.EARTH_RADIUS ) {
      //  r.enabled = false;
      //  Explosion splode = splodes[splodeindex++ % splodes.length]; // increment splode index and wrap to length of pool
      //  events.dispatchRoidImpact(r.globalPos());

      //  splode.enabled = true;
      //  splode.start = time.getClock();
      //  float angle = utils.angleOfRadians(earth.globalPos(), r.globalPos());
      //  float offset = 20;
      //  PVector adjustedPosition = new PVector(earth.x + cos(angle) * (Earth.EARTH_RADIUS + offset), earth.y + sin(angle) * (Earth.EARTH_RADIUS + offset));
      //  splode.setPosition(earth.globalToLocalPos(adjustedPosition));
      //  splode.r = utils.angleOf(earth.localPos(), splode.localPos()) + 90;

      //  assets.roidStuff.hits[floor(random(0, 5))].play();
      //}
    }
  }

  void updateExplosions (float clock) {
    for (Explosion s : splodes) {
      if (!s.enabled) continue;

      float elapsed = clock - s.start;

      if (elapsed < Explosion.duration) {
        s.model = s.frames[round((elapsed / Explosion.duration) * (assets.roidStuff.explosionFrames.length - 1))];
      } else {
        s.enabled = false;
      }
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
    splode.parent = null;
    splode.start = clock;

    return splode;
  }

  Explosion newExplosionFromRoid (float clock, Roid roid) {
    Explosion splode = newExplosion(clock);


    return splode;
  }

  void renderRoids () {
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
  //PImage model;
  PImage[] frames;
  float start;
  final static float duration = 500;
  final static float OFFSET_FROM_EARTH = 20;
  boolean enabled = false;
}

//class RoidManager implements updateable, renderable, gameFinaleEvent {

//  EventManager events;
//  Time time;  
//  Earth earth;

//  float spawnInterval;
//  float minSpawnInterval;//70;
//  float maxSpawnInterval;//400;
//  final static float DEFAULT_SPAWN_RATE = 300;
//  final static float DEFAULT_SPAWN_DEVIATION = 100;
//  final static float spawnDist = 720;
//  Roid[] roids = new Roid[100];
//  float lastFire;
//  int roidindex = 0;

//  Explosion[] splodes = new Explosion[25];
//  int splodeindex = 0;

//  public boolean enabled;
//  boolean isFinale = false;

//  class Explosion extends Entity {
//    PImage model;
//    float start;
//    final static float duration = 500;
//    boolean enabled = false;
//  }

//  class Roid extends Entity {
//    int modelIndex;
//    final static float speed = 2.5;
//    boolean enabled = false;
//    PImage trail;
//    float angle;
//    PVector trailPosition;
//    final static float dr = .1;
//  }

//  void finaleClose () {
//    isFinale = true;
//  }

//  void finaleHandle() {
//    //isFinale = true;
//  }

//  void finaleTrexHandled(PVector _) {
//  }

//  void finaleImpact() {
//  }

//  RoidManager (Earth earf, EventManager _events, Time t) {
//    earth = earf;
//    events = _events;
//    time = t;

//    events.gameFinaleSubscribers.add(this);

//    for (int i = 0; i < roids.length; i++) {
//      roids[i] = new Roid();
//    }

//    for (int j = 0; j < splodes.length; j++) {
//      splodes[j] = new Explosion();
//      earth.addChild(splodes[j]);
//    }

//    enabled = settings.getBoolean("roidsEnabled", true);
//    minSpawnInterval = settings.getFloat("roidImpactRateInMilliseconds", DEFAULT_SPAWN_RATE) - settings.getFloat("roidImpactRateVariation", DEFAULT_SPAWN_DEVIATION)/2;
//    maxSpawnInterval = settings.getFloat("roidImpactRateInMilliseconds", DEFAULT_SPAWN_RATE) + settings.getFloat("roidImpactRateVariation", DEFAULT_SPAWN_DEVIATION)/2;

//    // convert to frames
//    //minSpawnInterval = minSpawnInterval / 16.666;
//    //maxSpawnInterval = maxSpawnInterval / 16.666;

//    //roids[roidindex % roids.length].fire();
//    //roidindex++;
//  }

//  void update () {

//    if (!enabled) return;

//    if (!isFinale) {
//      if (time.getClock() - lastFire > spawnInterval) {
//        lastFire = time.getClock();
//        spawnInterval = random(minSpawnInterval, maxSpawnInterval);

//        Roid r = roids[roidindex++ % roids.length]; // increment roid index and wrap to length of pool
//        r.enabled = true;
//        r.angle = random(0, 359);
//        r.x = earth.x + cos(radians(r.angle)) * spawnDist;
//        r.y = earth.y + sin(radians(r.angle)) * spawnDist;
//        r.dx = cos(radians(r.angle+180)) * Roid.speed;
//        r.dy = sin(radians(r.angle+180)) * Roid.speed;
//      };
//    }

//    for (Roid r : roids) {
//      if (!r.enabled) continue;
//      r.x += r.dx * time.getTimeScale();
//      r.y += r.dy * time.getTimeScale();
//      r.r += Roid.dr * time.getTimeScale();

//      if (PVector.dist(r.globalPos(), earth.globalPos()) < Earth.EARTH_RADIUS ) {
//        r.enabled = false;
//        Explosion splode = splodes[splodeindex++ % splodes.length]; // increment splode index and wrap to length of pool
//        events.dispatchRoidImpact(r.globalPos());

//        splode.enabled = true;
//        splode.start = time.getClock();
//        float angle = utils.angleOfRadians(earth.globalPos(), r.globalPos());
//        float offset = 20;
//        PVector adjustedPosition = new PVector(earth.x + cos(angle) * (Earth.EARTH_RADIUS + offset), earth.y + sin(angle) * (Earth.EARTH_RADIUS + offset));
//        splode.setPosition(earth.globalToLocalPos(adjustedPosition));
//        splode.r = utils.angleOf(earth.localPos(), splode.localPos()) + 90;

//        assets.roidStuff.hits[floor(random(0, 5))].play();
//      }
//    }

//    for (Explosion s : splodes) {
//      if (!s.enabled) continue;

//      float elapsed = time.getClock() - s.start;

//      if (elapsed < Explosion.duration) {
//        s.model = assets.roidStuff.explosionFrames[round((elapsed / Explosion.duration) * (assets.roidStuff.explosionFrames.length - 1))];
//      } else {
//        s.enabled = false;
//      }
//    }
//  }

//  void render () {

//    if (!enabled) return;

//    for (Roid r : roids) {
//      if (!r.enabled) continue;
//      pushMatrix();
//      imageMode(CENTER);
//      translate(r.x, r.y);

//      pushMatrix();
//      rotate(radians(r.angle+90));
//      image(assets.roidStuff.trail, 0, -25);
//      popMatrix();

//      rotate(r.r);
//      image(assets.roidStuff.roidFrames[r.modelIndex], 0, 0);
//      //image(model, 0, 0, model.width/2, model.height/2);
//      popMatrix();
//    }
//    for (Explosion s : splodes) {
//      if (!s.enabled) continue;
//      s.simpleRenderImage(s.model);
//    }
//  }
//}
