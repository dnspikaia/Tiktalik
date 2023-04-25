/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////GLOBAL VARIABLES////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
CameraState state0;
public int gridSpacing = 50;
public int normWidth = 3;
public int indexOfInitiallyActiveWall;
public int indexOfFinallyActiveWall;
public int indexOfInitiallyActiveInner;
public int indexOfFinallyActiveInner;
public float bOfChangedWall;
public boolean camState       =  true;
public boolean backToYaw      = false;
public boolean lookAt         = false;
public boolean makeMov        = false;
public boolean movePlate      = false;
public boolean justaNewWall   = false;
public boolean wallHasChanged = false;
public boolean innerHasChanged= false;
public boolean buttonHasChanged=false;
public boolean snapOnPlates   = false;
public boolean snapOnWalls    =  true;  // not quite clean: at the moment walls can be activeted right from start
public boolean snapOnInners   = false;
public boolean snapOnRoofs    = false;
public boolean dragging       = false;  // this one is to convert the mouseDragged() function into boolean value/ set back to false again on mouseReleased
public boolean facadeComplete = false;
public boolean keepSnapped    = false;  // not to lose contact with objects to move
public boolean getMPos        =  true;  // a boolean to get the relative position of the mouse towards an item
ArrayList<Wall>  imageWalls  = new ArrayList <Wall>();
ArrayList<Inner> imageInners = new ArrayList<Inner>();
//system settings for screeen positions  and size
int  sc1X, sc1Y;
int  sc2X, sc2Y;
int  sc1w, sc1h;
int  sc2w, sc2h;
float[] camRot;

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////DISPLAY SETTINGS////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////


void sizeOfDisplay() {
  sc1X  = ceil(0.05*displayWidth);
  sc1Y  = ceil(0.1*displayHeight);
  sc2X  =                      0;
  sc2Y  = ceil(0.1*displayHeight);
  sc1w  = ceil(0.9*displayWidth);
  sc1h  = ceil(0.8*displayHeight);
  sc2w  = ceil(0.25*displayWidth);
  sc2h  = ceil(0.9*displayHeight);
  size(sc1w, sc1h, P3D);  //Lateron this is supposed to be Browser Application. So no, to fullscreen mode
}

void positionOfDisplay() {
  //surface.setLocation(sc1X, sc1Y);
}

void cameraSettings() {
  cam = new PeasyCam(this, sc1h);
  cam.setMinimumDistance(sc1w*.2);
  cam.setMaximumDistance(sc1w*2);
  cam.setYawRotationMode();  //at half_pi and -half_pi pitch and roll rotation switch between 0 and pi
  //could be that happens to yaw and roll as well when constrained to Pitch
  //cam.setSuppressRollRotationMode();  // this guy does not work at all
  // for a proper view control this flipping needs to be implemented in a setRotation(camRot[0],camRot[1],0);
  cam.setResetOnDoubleClick(false);
  cam.pan(0, -sc1h/3);
}

void switchYawAndPitch() {
  if (camState) {
    camState = false;
    state0 = cam.getState();
  }
  if (key==CODED) if (keyCode == SHIFT) {
    cam.setPitchRotationMode();
  }
  if (backToYaw) {
    cam.setYawRotationMode();
  }
  if (mousePressed && (mouseButton == RIGHT)) cam.setState(state0);
}

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////GLOBAL METHODS//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
void getInitials() {
  indexOfInitiallyActiveWall=-1; //null does not work here/ asssuming there won´t be a negative number of walls
  imageWalls = walls;            // doesn´t make me happy to have imagewalls always, but it turns out I can´t transfer a value from the old frame to a new one except within a class -> except writing a buffer-class
  for (Wall w : walls) {
    if (w.isActive) {
      indexOfInitiallyActiveWall=w.index;
      bOfChangedWall=w.b;
    }
  }
  indexOfInitiallyActiveInner=-1; //null does not work here/ asssuming there won´t be a negative number of walls
  imageInners = inners;            // doesn´t make me happy to have imagewalls always, but it turns out I can´t transfer a value from the old frame to a new one except within a class -> except writing a buffer-class
  for (Inner in : inners) {
    if (in.isActive) {
      indexOfInitiallyActiveInner=in.index;
    }
  }
}

void getFinals() {
  indexOfFinallyActiveWall=-1;
  for (Wall w : walls) {
    if (w.isActive) {
      indexOfFinallyActiveWall=w.index;
    }
  }
  wallHasChanged = (indexOfInitiallyActiveWall!=indexOfFinallyActiveWall)? true:false;
  //
  indexOfFinallyActiveInner=-1;
  for (Inner in : inners) {
    if (in.isActive) {
      indexOfFinallyActiveInner = in.index;
    }
  }
  innerHasChanged = (indexOfInitiallyActiveInner!=indexOfFinallyActiveInner)? true:false;
}

// if the active wall is changed all sliders need to reset to the values of the newly chosen object
void resetHUD() {
  try {
    // reset for Walls
    if (walls.size() > 0 && wallHasChanged) {
      for (Slider s : sliders) {
        if (s.name == "Breite") {
          s.setTab(imageWalls.get(indexOfFinallyActiveWall).b/100);  // littlebit unfortunate: /100 means Slider shows meters, w.b is in cm
        }
        if (s.name == "Höhe") {
          s.setTab(imageWalls.get(indexOfFinallyActiveWall).h/100);
        }
      }
      doFWSrePass(imageWalls.get(indexOfFinallyActiveWall));
    }
    // reset for Inners
    if (inners.size() > 0 && innerHasChanged) {
      for (Slider s : sliders) {
        if (s.name == "Breite") {
          s.setTab(imageInners.get(indexOfFinallyActiveInner).b/100);  // littlebit unfortunate: /100 means Slider shows meters, w.b is in cm
        }
        if (s.name == "Höhe") {
          s.setTab(imageInners.get(indexOfFinallyActiveInner).h/100);
        }
      }
      doFWSrePass(imageInners.get(indexOfFinallyActiveInner));
    }
    if (buttonHasChanged) {
      for (Button b : buttons) {
        if (b.activated && b.name == "plates") {
        }
        //
        if (b.activated && b.name == "walls") {
          for (Slider s : sliders) {
            if (s.name == "Breite" && walls.size()>0) if (walls.size() == 1) {
              s.setTab((normWidth*gridSpacing)/100);
            } else {
              s.setTab(walls.get(walls.size()-2).b/100); //couldUse myPrev instead of size()-2...
            }
          }
        }
        //
        if (b.activated && b.name == "inners") {
          for (Slider s : sliders) {
            if (s.name == "Breite" && inners.size()>0) s.setTab((normWidth*gridSpacing)/100); // just use normWidth for inner walls
          }
        }
        //
        if (b.activated && b.name == "roofs") {
        }
      }
      buttonHasChanged = false;
    }
  }
  catch(Exception e) {
    println("Jacky doubt: sum thinks ronk @ resetSliders() "+jd);
    jd++;
    //known Exceptions: something about doFWSrePass
    //                  deactivation without activation produces an exception
  }
  executeOnce      = false;
}

int jd=0;
void doFWSrePass(Wall w) {
  for (FourWaySelector fws : fourWaySelectors) {
    if (fws.name == "Drehung ") {
      fws.rePass=(w.rotation==0)? 1: (w.rotation==HALF_PI)? 2: (w.rotation==PI)? 3: 4;
    }
  }
}

void doFWSrePass(Inner in) {
  for (FourWaySelector fws : fourWaySelectors) {
    if (fws.name == "Drehung ") {
      fws.rePass=(in.rotation==0)? 1: (in.rotation==HALF_PI)? 2: (in.rotation==PI)? 3: 4;
    }
  }
}

void makeMov(boolean mM) {
  if (mM) {
    stroke(60);
    int sW = (mousePressed)? 4:2;
    strokeWeight(sW);
    fill(30, 128, 94, 128);
    beginShape();
    vertex(mouseX, mouseY);
    vertex(mouseX+12, mouseY);
    vertex(mouseX+8, mouseY+4);
    vertex(mouseX+15, mouseY+12);
    vertex(mouseX+12, mouseY+15);
    vertex(mouseX+4, mouseY+8);
    vertex(mouseX, mouseY+12);
    endShape(CLOSE);
    saveFrame("Bildsequenz/######.png");
  }
}
