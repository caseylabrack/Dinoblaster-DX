class EventManager {
  ArrayList<gameOverEvent> gameOverSubscribers = new ArrayList<gameOverEvent>();
  ArrayList<roidImpactEvent> roidImpactSubscribers = new ArrayList<roidImpactEvent>();
  ArrayList<abductionEvent> abductionSubscribers = new ArrayList<abductionEvent>();
  ArrayList<playerSpawnedEvent> playerSpawnedSubscribers = new ArrayList<playerSpawnedEvent>();
  ArrayList<playerDiedEvent> playerDiedSubscribers = new ArrayList<playerDiedEvent>();
  ArrayList<playerRespawnedEvent> playerRespawnedSubscribers = new ArrayList<playerRespawnedEvent>();
  ArrayList<levelChangeEvent> levelChangeSubscribers = new ArrayList<levelChangeEvent>();
  ArrayList<nebulaEvents> nebulaStartSubscribers = new ArrayList<nebulaEvents>();  
  ArrayList<gameFinaleEvent> gameFinaleSubscribers = new ArrayList<gameFinaleEvent>();

  void dispatchGameOver () {
    for (gameOverEvent g : gameOverSubscribers) g.gameOverHandle();
  }

  void dispatchRoidImpact(PVector p) {
    for (roidImpactEvent r : roidImpactSubscribers) r.roidImpactHandle(p);
  }

  void dispatchAbduction(PVector p) {
    for (abductionEvent a : abductionSubscribers) a.abductionHandle(p);
  }

  void dispatchPlayerSpawned(Player p) {
    for (playerSpawnedEvent s : playerSpawnedSubscribers) s.playerSpawnedHandle(p);
  }

  void dispatchPlayerDied(PVector position) {
    for (playerDiedEvent s : playerDiedSubscribers) s.playerDiedHandle(position);
  }

  void dispatchPlayerRespawned(PVector position) {
    for (playerRespawnedEvent s : playerRespawnedSubscribers) s.playerRespawnedHandle(position);
  }

  void dispatchLevelChanged(int stage) {
    for (levelChangeEvent l : levelChangeSubscribers) l.levelChangeHandle(stage);
  }

  void dispatchNebulaStarted () {
    for (nebulaEvents n : nebulaStartSubscribers) n.nebulaStartHandle();
  }

  void dispatchNebulaEnded () {
    for (nebulaEvents n : nebulaStartSubscribers) n.nebulaStopHandle();
  }

  void dispatchGameFinale () {
    for (gameFinaleEvent g : gameFinaleSubscribers) g.finaleHandle();
  }

  void dispatchFinaleTrexPositioned (PVector p) {
    for (gameFinaleEvent g : gameFinaleSubscribers) g.finaleTrexHandled(p);
  }

  void dispatchFinaleImpact () {
    for (gameFinaleEvent g : gameFinaleSubscribers) g.finaleImpact();
  }

  void dispatchFinaleClose () {
    for (gameFinaleEvent g : gameFinaleSubscribers) g.finaleClose();
  }
} 

interface gameOverEvent {
  void gameOverHandle();
}

interface roidImpactEvent {
  void roidImpactHandle(PVector p);
}

interface abductionEvent {
  void abductionHandle(PVector p);
}

interface playerSpawnedEvent {
  void playerSpawnedHandle(Player p);
}

interface playerDiedEvent {
  void playerDiedHandle(PVector position);
}

interface playerRespawnedEvent {
  void playerRespawnedHandle(PVector position);
}

interface levelChangeEvent {
  void levelChangeHandle(int stage);
}

interface gameFinaleEvent {
  void finaleClose();
  void finaleHandle();
  void finaleTrexHandled(PVector p);
  void finaleImpact();
}

interface nebulaEvents {
  void nebulaStartHandle();
  void nebulaStopHandle();
}

interface gameWinEvent {
  void gameWinHandle();
}
