// non-event interfaces in one place

interface updateable {
  void update();
}

interface renderable {
  void render();
} 

interface renderableScreen {
  void render();
}

interface deletable {
  void cleanupCheck();
}

//interface scene {
//  int update();
//  int render();
//}
