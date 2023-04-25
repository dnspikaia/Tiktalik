//implemented   libraries
import peasy.*;

//library objects
PeasyCam cam;
CameraState state; //public state of the cam to restore after operating the HUD with a pressed mouse dragged @ end of HUD method

// for some reason the display cannot be defined in setup() - as it usually would be mandatory
public void settings() {
  sizeOfDisplay();      //@Meth Display
  smooth(4);
}

void setup() {
  positionOfDisplay();  //@Meth Display   Position of the App Window on the Computer screen
  cameraSettings();     //@Meth Display   Initial values of the camera within the app window
  setUpHUD();
  setUpBlox();
  setUpEnvironment();
}


void draw() {


  switchYawAndPitch();
  state = cam.getState();                // Operating the HUD may alter the view settings, saving the cam.state to restore if necessary
  getInitials();
  //@ globalMeth
  objectOps();                           //@ messyObjStuff
  HUDinDaHood();                         //@ HUD
  blockOps();                            //@ Blocks

  // render Functions
  drawEnvironment();
  // 3D Instances
  renderObjects();
  // 2D controls
  cam.beginHUD();
  renderHUD();
  renderBlocks();
  cam.endHUD();
  oSnap();                               //@...oSnap

  getFinals();                           //@ globalMeth
  resetHUD();
  if (isOverAnyHUD) cam.setState(state);    // restore view settings when operating the HUD
}
