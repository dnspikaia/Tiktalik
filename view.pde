PImage panorama;
PImage lawn;
PImage reflection;
PShape globe;
PShape ground;
PShape pane;

void setUpEnvironment() {
  panorama=loadImage("x_Landscape2.jpeg");
  lawn    =loadImage("x_Herbstrasen.png");
  reflection=loadImage("x_pane.png");
  globe = createShape(SPHERE, 5000);
  globe.setStroke(false);
  globe.setTexture(panorama);
  ground = createShape(RECT, -2000, -2000, 4000, 4000);
  ground.setTexture(lawn);
  ground.setStroke(false);
  //does not belong to "environment" - but it has to be setUp only once...
  pane = createShape(RECT, 0, 0, 100, 100);
  pane.setTexture(reflection);
  pane.setStroke(false); 
}

void drawEnvironment() {
  background(208);
  lights();
  ambientLight(80, 80, 80);
  directionalLight(160, 160, 160, 1, 1, 1);
  pushMatrix();
  rotateY(-HALF_PI);
  shape(globe);
  popMatrix();
  pushMatrix();
  rotateX(HALF_PI);
  shape(ground);
  popMatrix();
}
