void objectOps() {
  putPlatesToZero();                     //@ messyObjStuff
  movePlates();
  twoPlatesAvoiding();                   //@ messyObjStuff

  putWallsToZero();                      //@ messyObjStuff

  checkFacadeCompleteness();             //@ messyObjStuff
  moveInnerWalls();
  runGenerator();
  kissTheCorner();
}

void renderObjects() {
  hint(ENABLE_DEPTH_TEST);
  for (Plate p : plates) p.update();     //@ classPlate
  for (Wall  w : walls)  w.update();     //@ classWall
  for (Inner i : inners) i.update();     //@ classInnerWall
  for (Roof  r : roofs)  r.update();     //@ classRoof
  hint(DISABLE_DEPTH_TEST);
}

//////////////////////////////////////METHODS ON Plates////////////////////////////////////////////////////

void addingPlates() {
  if (plates.size() <2) {
    Plate newP = new Plate(0, 0, 0, 4, 0.5, 4, gridSpacing);
    plates.add(newP);
    newP.isActive = true;
    for (Plate oldP : plates){
      if (oldP != newP) oldP.isActive = false;
    }
    buttonHasChanged = true;
    for (Button b : buttons) {
      if (b.name == "plates") {
        b.activated = true;
        for (Button p : b.myPals) p.activated=false;
        snapOnWalls =false;
        snapOnInners=false;
        snapOnPlates= true;
      }
    }
  }
}

void removePlate() {
  int i = 0;
  Plate tempPlate = null;
  if (plates.size()>0) {
    for (Plate p : plates) {
      if (p.isActive) tempPlate = p;
    }
  }

  if (tempPlate != null) plates.remove(tempPlate);
  for (Plate w : plates) {
    w.index = i;
    i++;
  }
  for (Plate p : plates) {
    p.getMyPrev();
    p.getMyFoll();
  }
}

void putPlatesToZero() {
  float tMinX, tMaxX, tMinZ, tMaxZ;
  tMinX=tMaxX=tMinZ=tMaxZ=0;
  if (plates.size() > 0) {
    tMinX = (plates.get(0).pos.x-plates.get(0).b/2 < plates.get(plates.size()-1).pos.x-plates.get(plates.size()-1).b/2)? plates.get(0).pos.x-plates.get(0).b/2 : plates.get(plates.size()-1).pos.x-plates.get(plates.size()-1).b/2;
    tMaxX = (plates.get(0).pos.x+plates.get(0).b/2 > plates.get(plates.size()-1).pos.x+plates.get(plates.size()-1).b/2)? plates.get(0).pos.x+plates.get(0).b/2 : plates.get(plates.size()-1).pos.x+plates.get(plates.size()-1).b/2;
    tMinZ = (plates.get(0).pos.z-plates.get(0).d/2 < plates.get(plates.size()-1).pos.z-plates.get(plates.size()-1).d/2)? plates.get(0).pos.z-plates.get(0).d/2 : plates.get(plates.size()-1).pos.z-plates.get(plates.size()-1).d/2;
    tMaxZ = (plates.get(0).pos.z+plates.get(0).d/2 > plates.get(plates.size()-1).pos.z+plates.get(plates.size()-1).d/2)? plates.get(0).pos.z+plates.get(0).d/2 : plates.get(plates.size()-1).pos.z+plates.get(plates.size()-1).d/2;
  }
  float cX = (tMinX+tMaxX)/2;
  float cZ = (tMinZ+tMaxZ)/2;
  for (Plate p : plates) {
    p.pos.x -=cX;
    p.pos.z -=cZ;
  }
}

void switchPlatesIfNecessary() {
  if (plates.size() > 1) {
    Plate p1 = plates.get(0);
    Plate p2 = plates.get(1);
    if (p1.pos.x-p1.b/2 == p2.pos.x+p2.b/2) {
      if (plates.size() >= 2) { // Make sure the ArrayList has at least two elements
        Plate temp = plates.get(0); // Store the first element in a temporary variable
        plates.set(0, plates.get(1)); // Set the first element to be the second element
        plates.set(1, temp); // Set the second element to be the first element stored in temp
      }
    }
  }
}

// for now there won´t be more than two plates - later on this can be replaced by the same algorithm as innerWall-avoidance
void twoPlatesAvoiding() {
  if (plates.size()==2) {
    Plate p1 = plates.get(0);
    Plate p2 = plates.get(1);
    if (p1.pos.x-p2.pos.x == p1.pos.z-p2.pos.z) p1.pos.z+=1; // to make shure, there is clear decision where to move
    boolean onMinXblkd, onMaxXblkd, onMinYblkd, onMaxYblkd, onBlocked;
    boolean movX = false;
    boolean movZ = false;
    onMinXblkd = (p1.pos.x-p1.b/2 < p2.pos.x+p2.b/2)? true:false;
    onMaxXblkd = (p1.pos.x+p1.b/2 > p2.pos.x-p2.b/2)? true:false;
    onMinYblkd = (p1.pos.z-p1.d/2 < p2.pos.z+p2.d/2)? true:false;
    onMaxYblkd = (p1.pos.z+p1.d/2 > p2.pos.z-p2.d/2)? true:false;
    onBlocked  = (onMinXblkd && onMaxXblkd && onMinYblkd && onMaxYblkd && !mousePressed)?  true:false; // !mousePressed in case of oSnap-shifting of plates
    if (onBlocked) {
      if (abs(p1.pos.x-p2.pos.x) > abs(p1.pos.z-p2.pos.z)) {
        movX = true;
        p1.pos.x = (p1.pos.x < p2.pos.x)? p1.pos.x-gridSpacing/5:p1.pos.x+gridSpacing/5;
      } else {
        movZ = true;
        p1.pos.z = (p1.pos.z < p2.pos.z)? p1.pos.z-gridSpacing/5:p1.pos.z+gridSpacing/5;
      }
    }

    if (abs(p1.pos.x-p2.pos.x)-(p1.b+p1.b)/2< gridSpacing && movX) {
      p1.pos.x = (p1.pos.x < p2.pos.x)? p2.pos.x-(p1.b+p2.b)/2 : p2.pos.x+(p1.b+p2.b)/2;
    }
    if (abs(p1.pos.z-p2.pos.z)-(p1.d+p1.d)/2< gridSpacing && movZ) {
      p1.pos.z = (p1.pos.z < p2.pos.z)? p2.pos.z-(p1.d+p2.d)/2 : p2.pos.z+(p1.d+p2.d)/2;
    }
    p1.goToGrid();
    p2.goToGrid();
  }
}

void movePlates() {
  for (Plate p : plates) if (p.isActive) {
    if (p.pos.x >= p.minX() && p.pos.x <= p.maxX()) {
      movePlateX(p);         // @oSnap
    } else {
      bringBackInX(p);
    }
    if (p.pos.z >= p.minZ() && p.pos.z <= p.maxZ()) {
      movePlateZ(p);         // @oSnap
    } else {
      bringBackInZ(p);
    }
  }
}

void bringBackInX(Plate p) {
  p.pos.x = (p.pos.x < 0)? p.pos.x+gridSpacing/2 : p.pos.x-gridSpacing/2;
  cam.setState(state);
}

void bringBackInZ(Plate p) {
  p.pos.z = (p.pos.z < 0)? p.pos.z+gridSpacing/2 : p.pos.z-gridSpacing/2;
  cam.setState(state);
}

void setPlateSize(int b, int d) {
  for (Plate p : plates) if (p.isActive) {
    p.b = p.gridToMeasure(b);
    p.d = p.gridToMeasure(d);
    p.sizeChosen = true;     // Check one day if it is really required. idea: you cannot work on a plate with no size chosen
    p.setPlateOrientation(p.myOrientation);
  }
}

//////////////////////////////////////METHODS ON WALLS////////////////////////////////////////////////////

public void addNewWall(float tpx, float tpy, float tpz, float b, float h, float d) {
  int actW = -1;
  int[] ind = new int[walls.size()];
  boolean withdraw = false;
  for (int i=0; i<walls.size(); i++) {
    ind[i] = walls.get(i).index;
    if (walls.get(i).isActive) actW = i;
  }
  Wall w = null;
  // this is if walls are added manually and the facade is not closed yet
  if (actW == walls.size()-1 || actW == -1) {
    if (!facadeComplete) {
      w = new  Wall(tpx, tpy, tpz, b, h, d, gridSpacing);
      w.index = (ind.length>0)? max(ind)+1:0;
      w.isActive = true;
      for (Wall nw : walls) if (nw!=w) nw.isActive = false;
      // rotation of the the new wall should be accordingly to the recent
      w.rotation = (ind.length>1)? walls.get(walls.size()-2).rotation:0;
      w.alignInRow();
      w.getMyPrev();
      w.getMyFoll();
      for (Slider s : sliders) {
        if (s.name == "Höhe")   s.myVal=h*gridSpacing/100;
      }
    }
  // this is if the facade is closed and walls are added in between
  } else {
    Wall oldW = walls.get(actW);
    // this says: if the duplicated wall is a corner or only has one chamber, nothing should happen
    if ( oldW.b <= gridSpacing) {
      walls.remove(w);
      withdraw = true;
    } else {
      w = new  Wall(tpx, tpy, tpz, 1, h, d, gridSpacing);
      float newB1 = (oldW.b % (gridSpacing*2) == 0)? oldW.b/2 : oldW.b/2+gridSpacing/2;
      float newB2 = (oldW.b % (gridSpacing*2) == 0)? oldW.b/2 : oldW.b/2-gridSpacing/2;
      if (newB2>0) {
        oldW.isActive=false;
        oldW.b = newB1;
        w.rotation = oldW.rotation;
        w.b = newB2;
        if (oldW.noStretch) {
          oldW.noStretch = false;
          w.noStretch = true;
        }
        for (int i = actW+1; i<walls.size(); i++) {
          walls.get(i).index = i+1;
        }
        w.index = actW+1;
        ArrayList<Wall>tempWalls = new ArrayList<>();
        for (Wall ow : walls) tempWalls.add(ow);
        walls.clear();
        for (int i=0; i<tempWalls.size(); i++) {
          for (Wall tw : tempWalls) {
            if (tw.index == i) walls.add(tw);
          }
        }
        for (Wall nw : walls) {
          nw.getMyPrev();
          nw.getMyFoll();
          nw.alignInRow();
        }
      } else {
        walls.remove(w);
        withdraw = true;
      }
    }
  }
  for (Button bt : buttons) {
    if (bt.name == "walls") {
      buttonHasChanged = true;
      bt.activated = true;
      snapOnWalls  = true;
      snapOnInners =false;
      snapOnPlates =false;
      for (Button p : bt.myPals) p.activated=false;
    }
    justaNewWall = true;
  }
  if (withdraw) {
   // walls.get(actW).b = gridSpacing;
    walls.get(actW).isActive = false;
  }
}

void removeWall() { 
  int i = 0;
  int tempIndex = 0;
  Wall tempWall = null;
  if (walls.size()>0) {
    for (Wall w : walls) {
      if (w.isActive) {
        tempWall  = w;
        tempIndex = w.index;
      }
    }
  }
    // anything below should happen only if there is a temporary Wall
  if (tempWall != null && facadeComplete) { 
    float newPrevB = tempWall.myPrev.b;
    float newFollB = tempWall.myFoll.b;
    if (!tempWall.myPrev.isCorner && !tempWall.myFoll.isCorner) {
      newPrevB = ((tempWall.b/2) % gridSpacing == 0)? tempWall.myPrev.b+tempWall.b/2 : tempWall.myPrev.b+tempWall.b/2+gridSpacing/2;
      newFollB = ((tempWall.b/2) % gridSpacing == 0)? tempWall.myFoll.b+tempWall.b/2 : tempWall.myFoll.b+tempWall.b/2-gridSpacing/2;
    } else if (tempWall.myPrev.isCorner && !tempWall.myFoll.isCorner) {
      newFollB = tempWall.b+tempWall.myFoll.b; 
    } else if (!tempWall.myPrev.isCorner && tempWall.myFoll.isCorner) {
      newPrevB = tempWall.b+tempWall.myPrev.b;
    }
  
    if ((tempWall.myPrev.isCorner && tempWall.myFoll.isCorner) || tempWall.isCorner){
     // if you are in between two corners or you are a corner; do nothing
    } else {
      tempWall.myPrev.b = newPrevB;
      tempWall.myFoll.b = newFollB;
      walls.remove(tempWall);
    }
  }
  for (Wall w : walls) {
    w.index = i;
    i++;
  }
  for (Wall w : walls) {
    w.getMyPrev();
    w.getMyFoll();
    w.alignInRow();
  }
}

// for the generator
public void addNewgWall(float tpx, float tpy, float tpz, float b, float h, float d, Line l, boolean isC) {
  int actW = -1;
  int[] ind = new int[walls.size()];
  boolean withdraw = false;
  for (int i=0; i<walls.size(); i++) {
    ind[i] = walls.get(i).index;
    if (walls.get(i).isActive) actW = i;
  }
  //  if (actW == -1 && walls.size()!=0) walls.get(ind.length-1).isActive=true;
  Wall w = null;
  if (actW == walls.size()-1 || actW == -1) {
    if (!facadeComplete) {
      w = new  Wall(tpx, tpy, tpz, b, h, d, gridSpacing);
      w.index = (ind.length>0)? max(ind)+1:0;
      //  w.isActive = true;
      for (Wall nw : walls) if (nw!=w) nw.isActive = false;
      w.rotation  = l.myDir();
      w.alignInRow();
      w.getMyPrev();
      w.getMyFoll();
      w.isgWall = true;
      if (isC) {
        w.getCorner = true;
        //   w.alignCorners();
      }

      for (Slider s : sliders) {
        if (s.name == "Höhe")   s.myVal=h*gridSpacing/100;
      }
    }
  }
  for (Button bt : buttons) {
    if (bt.name == "walls") {
      buttonHasChanged = true;
      bt.activated = true;
      snapOnWalls  = true;
      snapOnInners =false;
      snapOnPlates =false;
      for (Button p : bt.myPals) p.activated=false;
    }
    justaNewWall = true;
  }
  if (withdraw) {
    walls.get(actW).b = gridSpacing;
    walls.get(actW).isActive = false;
  }
}

void alignFirstWall() {
  if (plates.size()>0) {
    Plate pete=plates.get(0);
    if (walls.size()>0) {
      Wall walley=walls.get(0);
      walley.pos.x = pete.pos.x+walley.b/2-pete.b/2;
      walley.pos.y = pete.pos.y-walley.h/2-pete.h/2;
      walley.pos.z = pete.pos.z-walley.d/2+pete.d/2;
    }
  }
}

void putWallsToZero() {
  PVector av = new PVector(0, 0, 0);
  if (plates.size() == 0) {
    for (Wall w : walls) av.add(w.pos);
    av.div(walls.size());
    for (Wall w : walls) w.pos.sub(av);
  } else {
    alignFirstWall();
  }
}

void kissTheCorner() {
  for (Wall w : walls) {
    //checkCorners(w);
    if (w.myPrev != null && myFoll != null) {
      if (w.myPrev.isCorner || w.myFoll.isCorner) {
        float f = w.b;
        if (w.rotation == 0 || w.rotation == PI) {
          f = abs(w.myPrev.pos.x-w.myFoll.pos.x)-w.myPrev.b/2-w.myFoll.b/2;
        }
        if (w.rotation == HALF_PI || w.rotation == HALF_PI+PI) {
          f = abs(w.myPrev.pos.z-w.myFoll.pos.z)-w.myPrev.b/2-myFoll.b/2;
        }
        w.b = f;
      }
    }
    ///////////////////////this is actually a bit misplaced: it is just to set the corners to the ground
    if (w.isCorner) {
      if (w.myPrev != null) {
        w.pos.y = w.myPrev.pos.y;
      } else if (myFoll != null) {
        w.pos.y = w.myFoll.pos.y;
      }
    }
  }
}

void correctWidthAfterGen() {
  for (Wall w : walls) {
    try {
      float aberration = w.b % gridSpacing;
      if (!w.isCorner && !w.myFoll.isCorner && !w.gCorrect) {
        w.b = w.b-aberration;
        w.gCorrect = true;
      }
      if (!w.isCorner && w.myFoll.isCorner && !w.gCorrect) {
        if (w.rotation == 0  || w.rotation == PI) {
          w.b = abs(w.myPrev.pos.x-w.myFoll.pos.x)-w.myPrev.b/2-w.myFoll.b/2;
          w.noStretch = true;
        }
        if (w.rotation == HALF_PI  || w.rotation == HALF_PI+PI) {
          w.b = abs(w.myPrev.pos.z-w.myFoll.pos.z)-w.myPrev.b/2-w.myFoll.b/2;
          w.noStretch = true;
        }
      }
    }
    catch (Exception e) {
    }
  }
}

boolean closed = false;
void closeTheCorner() {
  if (walls.size()>1 && !closed) {
    if (walls.get(walls.size()-1).myFoll == null && walls.get(walls.size()-1).isgWall) {
      walls.get(walls.size()-1).myFoll = walls.get(0);
      closed = true;
    }
  }
}

PVector getWallsMinPos() {
  PVector minPos = new PVector(0, 0, 0);
  float minX =0, minZ =0;
  float tX[] = new float[walls.size()*4]; // the four corners of any wall´s base
  float tZ[] = new float[walls.size()*4];
  int i = 0;
  for (Wall w : walls) {
    tX[i] = (w.rotation == 0 || w.rotation == PI)? w.loriteout.x+w.pos.x:w.loriteout.z+w.pos.x;
    tZ[i] = (w.rotation == 0 || w.rotation == PI)? w.loriteout.z+w.pos.z:w.loriteout.x+w.pos.z;
    i+=1;
    tX[i] = (w.rotation == 0 || w.rotation == PI)? w.loritein.x+w.pos.x:w.loritein.z+w.pos.x;
    tZ[i] = (w.rotation == 0 || w.rotation == PI)? w.loritein.z+w.pos.z:w.loritein.x+w.pos.z;
    i+=1;
    tX[i] = (w.rotation == 0 || w.rotation == PI)? w.loleftout.x+w.pos.x:w.loleftout.z+w.pos.x;
    tZ[i] = (w.rotation == 0 || w.rotation == PI)? w.loleftout.z+w.pos.z:w.loleftout.x+w.pos.z;
    i+=1;
    tX[i] = (w.rotation == 0 || w.rotation == PI)? w.loleftin.x+w.pos.x:w.loleftin.z+w.pos.x;
    tZ[i] = (w.rotation == 0 || w.rotation == PI)? w.loleftin.z+w.pos.z:w.loleftin.x+w.pos.z;
    i+=1;
  }
  minX = min(tX);
  minZ = min(tZ);
  return minPos.set(minX, 0, minZ);
}

PVector getWallsMaxPos() {
  PVector maxPos = new PVector(0, 0, 0);
  float maxX =0, maxZ =0;
  float tX[] = new float[walls.size()*4]; // the four corners of any wall´s base
  float tZ[] = new float[walls.size()*4];
  int i = 0;
  for (Wall w : walls) {
    tX[i] = (w.rotation == 0 || w.rotation == PI)? w.loriteout.x+w.pos.x:w.loriteout.z+w.pos.x;
    tZ[i] = (w.rotation == 0 || w.rotation == PI)? w.loriteout.z+w.pos.z:w.loriteout.x+w.pos.z;
    i+=1;
    tX[i] = (w.rotation == 0 || w.rotation == PI)? w.loritein.x+w.pos.x:w.loritein.z+w.pos.x;
    tZ[i] = (w.rotation == 0 || w.rotation == PI)? w.loritein.z+w.pos.z:w.loritein.x+w.pos.z;
    i+=1;
    tX[i] = (w.rotation == 0 || w.rotation == PI)? w.loleftout.x+w.pos.x:w.loleftout.z+w.pos.x;
    tZ[i] = (w.rotation == 0 || w.rotation == PI)? w.loleftout.z+w.pos.z:w.loleftout.x+w.pos.z;
    i+=1;
    tX[i] = (w.rotation == 0 || w.rotation == PI)? w.loleftin.x+w.pos.x:w.loleftin.z+w.pos.x;
    tZ[i] = (w.rotation == 0 || w.rotation == PI)? w.loleftin.z+w.pos.z:w.loleftin.x+w.pos.z;
    i+=1;
  }
  maxX = max(tX);
  maxZ = max(tZ);
  return maxPos.set(maxX, 0, maxZ);
}

void checkFacadeCompleteness() {
  if (walls.size()>1) {
    Wall a = walls.get(0);
    Wall z = walls.get(walls.size()-1);
    // Yes, it` only true, if rot#a is 0 and z hPi+Pi but good enough for now
    int zX = round(z.pos.x-z.d/2);
    int zZ = round(z.pos.z+z.b/2);

    int aX = round(a.pos.x-a.b/2);
    int aZ = round(a.pos.z-a.d/2);

    int azx = zX-aX;
    int azz = zZ-aZ;

    if (azx==0 && azz==0 && !facadeComplete) {
      a.myPrev = z;
      z.myFoll = a;
      executeOnce    = true;
      facadeComplete = true;
    }
  }
}

//////////////////////////////////////METHODS ON INNER WALLS////////////////////////////////////////////////////

public void addNewInnerWall(float tpx, float tpy, float tpz, float b, float h, float d) {
  Inner in = new  Inner(tpx, tpy, tpz, b, h, d, gridSpacing);
  adjustNewInner();
  in = inners.get(inners.size()-1);
  in.index = inners.size()-1;
  //in case an innerwall incidentally takes the center as position, the new one gets a different angle
  for (Inner er : inners) if (in != er && PVector.dist(in.pos, er.pos) <gridSpacing/2) in.rotation = er.rotation+HALF_PI;
  buttonHasChanged = true;
  for (Slider s : sliders) {
    if (s.name == "Breite") s.myVal = b*gridSpacing/100;
    if (s.name == "Höhe")   s.myVal = h*gridSpacing/100;
  }
  for (Button bt : buttons) {
    if (bt.name == "inners") {
      bt.activated = true;
      for (Button p : bt.myPals) p.activated=false;
      snapOnWalls = false;
      snapOnInners=  true;
      snapOnPlates= false;
    }
  }
}

void removeInnerWall() {
  int i = 0;
  Inner tempWall = null;
  if (inners.size()>0) {
    for (Inner in : inners) {
      if (in.isActive) tempWall = in;
    }
  }
  if (tempWall != null) inners.remove(tempWall);
  for (Inner in : inners) {
    in.index = i;
    i++;
  }
  for (Inner in : inners) {
    //  w.getMyPrev();
    //w.getMyFoll();
    // w.alignInRow();
  }
}

void adjustNewInner() {
  if (walls.size()>0) {
    Wall walley=walls.get(0);
    if (inners.size()>0) {
      Inner inga =inners.get(0);
      inga.pos.y = walley.pos.y;
      inga.h = walley.h;
    }
  }
  if (plates.size()>0) {
    Plate pete=plates.get(0);
    if (inners.size()>0) {
      Inner inga =inners.get(inners.size()-1);
      inga.pos.y = -inga.h/2-pete.h/2;
    }
  }
}

void moveInnerWalls() {
  for (Inner in : inners) if (in.isActive) {
    if (allowMoveX(in)) {
      moveItX(in);         // @oSnap
    } else {
      bringBackInX(in);
    }
    if (allowMoveZ(in)) {
      moveItZ(in);         // @oSnap
    } else {
      bringBackInZ(in);
    }
    in.pos=in.stayInTheGrid();
  }
}

///////////////////////INNER WALL MOVEMENT CONSTRAINT X//////////////////////////////////////
void bringBackInX(Inner it) {
  it.pos.x = it.pos.x*0.999;
  cam.setState(state);
}
void bringBackInZ(Inner it) {
  it.pos.z = it.pos.z*0.999;
  cam.setState(state);
}

boolean allowMoveX(Inner in) {

  float[] wallsMinX = new float[walls.size()];
  float[] wallsMaxX = new float[walls.size()];

  float realOutMinX = 0;
  float realOutMaxX = 0;

  if (walls.size() > 0) {
    for (int i=0; i<walls.size(); i++) {
      wallsMinX[i] = (walls.get(i).rotation == 0 ||walls.get(i).rotation == PI)? walls.get(i).pos.x-walls.get(i).b/2 : walls.get(i).pos.x-walls.get(i).d/2;
      wallsMaxX[i] = (walls.get(i).rotation == 0 ||walls.get(i).rotation == PI)? walls.get(i).pos.x+walls.get(i).b/2 : walls.get(i).pos.x+walls.get(i).d/2;
    }
    realOutMinX = min(wallsMinX);
    realOutMaxX = max(wallsMaxX);
  }

  float[] platesMinX = new float[plates.size()];
  float[] platesMaxX = new float[plates.size()];

  float realPltMinX = 0;
  float realPltMaxX = 0;

  if (plates.size() > 0) {
    for (int i=0; i<plates.size(); i++) {
      platesMinX[i] = plates.get(i).pos.x-plates.get(i).b/2;
      platesMaxX[i] = plates.get(i).pos.x+plates.get(i).b/2;
    }
    realPltMinX = min(platesMinX);
    realPltMaxX = max(platesMaxX);
  }

  in.minX = (realOutMinX<realPltMinX)? realOutMinX:realPltMinX;
  in.maxX = (realOutMaxX>realPltMaxX)? realOutMaxX:realPltMaxX;

  return (in.pos.x >= in.minX && in.pos.x <= in.maxX)? true:false;
}

boolean allowMoveZ(Inner in) {

  float[] wallsMinZ = new float[walls.size()];
  float[] wallsMaxZ = new float[walls.size()];

  float realOutMinZ = 0;
  float realOutMaxZ = 0;

  if (walls.size() > 0) {
    for (int i=0; i<walls.size(); i++) {
      wallsMinZ[i] = (walls.get(i).rotation == 0 ||walls.get(i).rotation == PI)? walls.get(i).pos.z-walls.get(i).d/2 : walls.get(i).pos.z-walls.get(i).b/2;
      wallsMaxZ[i] = (walls.get(i).rotation == 0 ||walls.get(i).rotation == PI)? walls.get(i).pos.z+walls.get(i).d/2 : walls.get(i).pos.z+walls.get(i).b/2;
    }
    realOutMinZ = min(wallsMinZ);
    realOutMaxZ = max(wallsMaxZ);
  }

  float[] platesMinZ = new float[plates.size()];
  float[] platesMaxZ = new float[plates.size()];
  float realPltMinZ = 0;
  float realPltMaxZ = 0;

  if (plates.size() > 0) {
    for (int i=0; i<plates.size(); i++) {
      platesMinZ[i] = plates.get(i).pos.z-plates.get(i).d/2;
      platesMaxZ[i] = plates.get(i).pos.z+plates.get(i).d/2;
    }
    realPltMinZ = min(platesMinZ);
    realPltMaxZ = max(platesMaxZ);
  }

  in.minZ = (realOutMinZ<realPltMinZ)? realOutMinZ:realPltMinZ;
  in.maxZ = (realOutMaxZ>realPltMaxZ)? realOutMaxZ:realPltMaxZ;

  return (in.pos.z >= in.minZ && in.pos.z <= in.maxZ)? true:false;
}

//////////////////////////////////////METHODS ON ROOFS////////////////////////////////////////////////////

void addRoofs() {
  for (Plate p : plates) {
    Roof rf = new Roof(p.pos.x, p.pos.y-p.h/2-walls.get(0).h, p.pos.z, p.b/gridSpacing, p.h/gridSpacing, p.d/gridSpacing, gridSpacing);
  }
}

void delRoofs() {
}
//////////////////////////////////////METHODS ON GENERATOR///////////////////////////////////////////////////
void runGenerator() {
  //////////////////////////////////////////
  if (cDelay>0) {
    if (cDelay==cDelFix) {
      findInputLines();   //@lineFinder
    }
    if (cDelay>cDelFix-inputLines.size()) {
      reOrganiseLines();
    }
    if (cDelay<cDelFix-inputLines.size()*2) {
      cleanLines();
    }
    if (cDelay<cDelFix-inputLines.size()*3) {
      shiftLines();
    }
    if (cDelay<cDelFix-inputLines.size()*4) {
      cutLines();
    }
    if (cDelay<cDelFix-inputLines.size()*5) {
      generateWalls();
    }
    if (cDelay<cDelFix-inputLines.size()*6) {
      reGenerateWalls();
    }
    if (cDelay<cDelFix-inputLines.size()*7) {
      lastGasp();
    }
    fill(0);
    textSize(18);
    stroke(0, 0, 255);
    strokeWeight(6);
    int c=0;
    for (Line l : outputLines) {
      c++;
      line(l.start.x, l.start.y, l.start.z, l.end.x, l.end.y, l.end.z);
      text(c, (l.start.x+l.end.x)/2, l.start.y-20, (l.start.z+l.end.z)/2);
      //    l.checkDir();
    }
    stroke(255, 0, 0);
    for (Line l : outputLines) {
      int weight = (l.startIsCorner)? 20:12;
      strokeWeight(weight);
      point(l.start.x, l.start.y, l.start.z);
    }
    cDelay--;
  }
}
/////////////////////////////////////////  ///////////////////////////////////////// GENERATE WALLS /////////////////////////////////////////  /////////////////////////////////////////

boolean makegWalls = false;
boolean actItems = false;
int justOnce = 1;
void generateWalls() {
  if (makegWalls && justOnce==1) {
    makegWalls=false;
    justOnce--;
    walls.clear();
    println(justOnce);
  //  executeOnce = true;
    mnpltW.setMyItemsActive();
    for (Button b : buttons) {
      if (b.name == "walls") {
        b.activated = true;
        b.shownAndActive = (walls.size() > 0)? true:false;
        buttonHasChanged = true;
        for (Button p : b.myPals) p.activated=false;
        snapOnWalls = true;
        snapOnInners=false;
        snapOnPlates=false;
        snapOnRoofs =false;
      }
      if (b.name == "einzeln") b.activated = true;
      if (b.name == "sequenz") b.activated = false;
      wallRotationSequence = false;
    }
    executeOnce = false;
    for (int i=0; i< outputLines.size(); i++) {
      Line prevL = (i==0)? outputLines.get(outputLines.size()-1):outputLines.get(i-1);
      Line currL = outputLines.get(i);
      Line nextL = (i>outputLines.size()-2)? outputLines.get(0):outputLines.get(i+1);
      boolean isC=false;
      float prevLen = lenOfLine(prevL);
      float currLen = lenOfLine(currL);
      float currB= 0;
      float prevB= 0;
      float b;
      if (currL.startIsCorner) {
        b = 0.5;
        isC = true;
      } else if (prevL.startIsCorner && !nextL.startIsCorner) {
        prevB = prevLen-gridSpacing/4;
        currB = currLen/2;
        b = (prevB + currB)/gridSpacing;
      } else if (!prevL.startIsCorner && nextL.startIsCorner) {
        prevB = prevLen/2;
        currB = currLen-gridSpacing/4;
        b = (prevB + currB)/gridSpacing;
      } else if (prevL.startIsCorner && nextL.startIsCorner) {
        prevB = prevLen-gridSpacing/4;
        currB = currLen-gridSpacing/4;
        b = (prevB + currB)/gridSpacing;
      } else {
        prevB = prevLen/2;
        currB = currLen/2;
        b = (prevB + currB)/gridSpacing;
      }
      addNewgWall(currL.start.x, currL.start.y-125+12.5, currL.start.z, b, 250, .5, currL, isC);
    }
  }
  // isCorner cannot be determined in the same loop as addWall
  for (Wall w : walls) {
    w.isCorner = w.getCorner;
  }
}

void lastGasp() {
  try {
    walls.get(walls.size()-1).isActive = true;
  }
  catch (Exception e) {
  }
}

void reGenerateWalls() {
  kissTheCorner();
  closeTheCorner();
  correctWidthAfterGen() ;
}

float lenOfLine (Line l) {
  PVector pv = new PVector(l.end.x, l.end.y, l.end.z);
  pv.sub(l.start);
  return pv.mag();
}
