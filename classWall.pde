ArrayList<Wall> walls = new ArrayList<Wall>();
boolean wallRotationSequence = false; // by default: if a wall is turned only this wall is turned
int wallAlpha = 255;

class Wall extends Base {
  float e, l, p;                 // For door/window, we need distances for (e)mbrasure, (l)edge and (p)arapet
  // Wall´s vertices
  PVector loleftout, loriteout, upriteout, upleftout;
  PVector loleftin, loritein, upritein, upleftin;
  // Opening´s vertices
  PVector ololeftout, oloriteout, oupriteout, oupleftout;
  PVector ololeftin, oloritein, oupritein, oupleftin;
  float winOff;               // window offset from facade
  PVector ololeftmid, oloritemid, oupritemid, oupleftmid;
  //
  boolean hasDoor;            //does it have a window or a door opening
  boolean hasWindow;
  //
  boolean isgWall;
  boolean gCorrect;
  boolean noStretch;
  boolean getCorner;     // "corner comes in with the gWall-Method, but it should become general
  boolean isCorner;     // "corner comes in with the gWall-Method, but it should become general
  boolean redStroke;     // tester for whatever
  //
  Window window;
  Door door;
  Wall myPrev, myFoll;        // since walls can be inserted inbetween others, list doesnt work, so we need to keep track of connected walls

  Wall(float px, float py, float pz, float sx, float sy, float sz, int gz) {
    super( px, py, pz, sx, sy, sz, gz);

    //just to have some default values
    e=12;
    l=25;
    p=100;
    winOff = 6; // again, just some default value
    calcMeasures(e, l, p, winOff);
    hasDoor   = false;
    hasWindow = false;
    isgWall   = false;
    noStretch = false;
    gCorrect  = false;
    getCorner = false;
    isCorner  = false;
    redStroke = false;
    getMyPrev();
    getMyFoll();
    getFillings();
    walls.add(this);
  }

  void calcMeasures(float tempE, float tempL, float tempP, float tempWoff) {
    e=tempE;
    l=tempL;
    p=tempP;
    winOff = tempWoff;

    loleftout = new PVector(-b/2, +h/2, +d/2);
    loriteout = new PVector(+b/2, +h/2, +d/2);
    upriteout = new PVector(+b/2, -h/2, +d/2);
    upleftout = new PVector(-b/2, -h/2, +d/2);
    loleftin  = new PVector(-b/2, +h/2, -d/2);
    loritein  = new PVector(+b/2, +h/2, -d/2);
    upritein  = new PVector(+b/2, -h/2, -d/2);
    upleftin  = new PVector(-b/2, -h/2, -d/2);

    ololeftout = new PVector(-b/2+e, +h/2-p, +d/2);
    oloriteout = new PVector(+b/2-e, +h/2-p, +d/2);
    oupriteout = new PVector(+b/2-e, -h/2+l, +d/2);
    oupleftout = new PVector(-b/2+e, -h/2+l, +d/2);
    ololeftin  = new PVector(-b/2+e, +h/2-p, -d/2);
    oloritein  = new PVector(+b/2-e, +h/2-p, -d/2);
    oupritein  = new PVector(+b/2-e, -h/2+l, -d/2);
    oupleftin  = new PVector(-b/2+e, -h/2+l, -d/2);

    ololeftmid = new PVector(-b/2+e, +h/2-p, +d/2-winOff);
    oloritemid = new PVector(+b/2-e, +h/2-p, +d/2-winOff);
    oupritemid = new PVector(+b/2-e, -h/2+l, +d/2-winOff);
    oupleftmid = new PVector(-b/2+e, -h/2+l, +d/2-winOff);
  }

  void update() {
    alignInRow();
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    rotateY(rotation);
    drawWall();
    popMatrix();
  }

  //color facade, interior, leftSide, riteSide, sillIn, sillOut;
  color rite () {
    color col = riteSide;
    if (myFoll!=null && !isCorner) {
      col =
        (rotation == 0 && myFoll.rotation == HALF_PI)? facade :
        (rotation == 0 && myFoll.rotation == PI)? facade :
        (rotation == HALF_PI && myFoll.rotation == 0)? interior :
        (rotation == HALF_PI && myFoll.rotation == HALF_PI+PI)? facade :
        (rotation == PI && myFoll.rotation==0)? facade :
        (rotation ==PI && myFoll.rotation ==HALF_PI+PI)?facade:
        (rotation ==HALF_PI+PI && myFoll.rotation == HALF_PI)? facade:
        (rotation ==HALF_PI+PI&&myFoll.rotation==PI)?interior:riteSide;
    }
    if (myFoll!=null && isCorner) {
      col =
        (rotation == 0 && myFoll.rotation == HALF_PI)? facade :
        (rotation == 0 && myFoll.rotation == HALF_PI+PI)? interior :
        (rotation == HALF_PI && myFoll.rotation == PI)? facade :
        (rotation == HALF_PI && myFoll.rotation == 0)? interior :
        (rotation == PI && myFoll.rotation==HALF_PI)? interior :
        (rotation == PI && myFoll.rotation==HALF_PI+PI)? facade :
        (rotation == HALF_PI+PI && myFoll.rotation == PI)? interior :
        (rotation == HALF_PI+PI && myFoll.rotation == 0)? facade : riteSide;
    }
    return col;
  }

  color left () {
    color col = leftSide;
    if (myPrev!=null && !isCorner) {
      col =
        (rotation == 0 && myPrev.rotation == PI)? facade :
        (rotation == 0 && myPrev.rotation == HALF_PI+PI)? facade :
        (rotation == HALF_PI && myPrev.rotation == PI)? interior :
        (rotation == HALF_PI && myPrev.rotation == HALF_PI+PI)? facade :
        (rotation == PI && myPrev.rotation==HALF_PI)? facade :
        (rotation ==PI && myPrev.rotation ==HALF_PI+PI)?facade:
        (rotation ==HALF_PI+PI && myPrev.rotation == 0)? interior:
        (rotation ==HALF_PI+PI && myPrev.rotation == HALF_PI)? facade:riteSide;
    }
    if (myPrev!=null && isCorner) {
      col =
      (rotation == 0 && myPrev.rotation == HALF_PI)? interior :
      (rotation == 0 && myPrev.rotation == HALF_PI+PI)? facade :
      (rotation == HALF_PI && myPrev.rotation == 0)? facade :
      (rotation == HALF_PI && myPrev.rotation == PI)? interior :
      (rotation == PI && myPrev.rotation==HALF_PI)? facade :
      (rotation == PI && myPrev.rotation==HALF_PI+PI)? interior :
      (rotation ==HALF_PI+PI && myPrev.rotation == 0)? interior:
      (rotation ==HALF_PI+PI && myPrev.rotation == PI)? facade: leftSide;
    }
    return col;
  }

  void drawWall() {
    calcMeasures(e, l, p, winOff);
    noFill();
    strokeWeight(myStrokeWeight);
    stroke((isActive)? 255:0);
    if (redStroke) stroke(255, 0, 0);
    // Outline of Interior wall surface
    beginShape();
    vertex(loleftin.x, loleftin.y, loleftin.z);
    vertex(loritein.x, loritein.y, loritein.z);
    vertex(upritein.x, upritein.y, upritein.z);
    vertex(upleftin.x, upleftin.y, upleftin.z);
    endShape(CLOSE);
    //outline of interior door/window opening
    if (hasWindow||hasDoor) {
      beginShape();
      vertex(oupleftin.x, oupleftin.y, oupleftin.z);
      vertex(oupritein.x, oupritein.y, oupritein.z);
      vertex(oloritein.x, oloritein.y, oloritein.z);
      vertex(ololeftin.x, ololeftin.y, ololeftin.z);
      endShape(CLOSE);
    }
    // Outline of Exterior wall surface
    beginShape();
    vertex(loleftout.x, loleftout.y, loleftout.z);
    vertex(loriteout.x, loriteout.y, loriteout.z);
    vertex(upriteout.x, upriteout.y, upriteout.z);
    vertex(upleftout.x, upleftout.y, upleftout.z);
    endShape(CLOSE);
    //outline of exterior door/window opening
    if (hasWindow||hasDoor) {
      beginShape();
      vertex(oupleftout.x, oupleftout.y, oupleftout.z);
      vertex(oupriteout.x, oupriteout.y, oupriteout.z);
      vertex(oloriteout.x, oloriteout.y, oloriteout.z);
      vertex(ololeftout.x, ololeftout.y, ololeftout.z);
      endShape(CLOSE);
    }
    // and just because it looks a little awkward with no edge in the corner
    // outer
    line(upleftout.x, upleftout.y, upleftout.z, upleftin.x, upleftin.y, upleftin.z);
    line(upriteout.x, upriteout.y, upriteout.z, upritein.x, upritein.y, upritein.z);
    line(loriteout.x, loriteout.y, loriteout.z, loritein.x, loritein.y, loritein.z);
    line(loleftout.x, loleftout.y, loleftout.z, loleftin.x, loleftin.y, loleftin.z);
    if (hasWindow||hasDoor) {
      line(oupleftout.x, oupleftout.y, oupleftout.z, oupleftin.x, oupleftin.y, oupleftin.z);
      line(oupriteout.x, oupriteout.y, oupriteout.z, oupritein.x, oupritein.y, oupritein.z);
      line(oloriteout.x, oloriteout.y, oloriteout.z, oloritein.x, oloritein.y, oloritein.z);
      line(ololeftout.x, ololeftout.y, ololeftout.z, ololeftin.x, ololeftin.y, ololeftin.z);
    }
    // now the filling (and just because I`ll be wondering one day:
    // 5 vertices for 4 lines in between)
    noStroke();
    // Filling of Exterior wall surface
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    fill(facade);
    //    println(alpha(facade));
    //    println(wallAlpha);
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    if (!snapOnInners) {
      beginShape();
      vertex(loleftout.x, loleftout.y, loleftout.z);
      vertex(loriteout.x, loriteout.y, loriteout.z);
      vertex(upriteout.x, upriteout.y, upriteout.z);
      vertex(upleftout.x, upleftout.y, upleftout.z);
      vertex(loleftout.x, loleftout.y, loleftout.z);
      //outline of exterior door/window opening
      if (hasWindow||hasDoor) {
        vertex(oupleftout.x, oupleftout.y, oupleftout.z);
        vertex(oupriteout.x, oupriteout.y, oupriteout.z);
        vertex(oloriteout.x, oloriteout.y, oloriteout.z);
        vertex(ololeftout.x, ololeftout.y, ololeftout.z);
        vertex(oupleftout.x, oupleftout.y, oupleftout.z);
      }
      endShape(CLOSE);

      // Filling of Interior wall surface
      fill(interior);
      beginShape();
      vertex(loleftin.x, loleftin.y, loleftin.z);
      vertex(loritein.x, loritein.y, loritein.z);
      vertex(upritein.x, upritein.y, upritein.z);
      vertex(upleftin.x, upleftin.y, upleftin.z);
      vertex(loleftin.x, loleftin.y, loleftin.z);
      //inline of interior door/window opening
      if (hasWindow||hasDoor) {
        vertex(oupleftin.x, oupleftin.y, oupleftin.z);
        vertex(oupritein.x, oupritein.y, oupritein.z);
        vertex(oloritein.x, oloritein.y, oloritein.z);
        vertex(ololeftin.x, ololeftin.y, ololeftin.z);
        vertex(oupleftin.x, oupleftin.y, oupleftin.z);
      }
      endShape(CLOSE);
      //laterals
      // leftSides
      fill(left());
      beginShape();
      vertex(loleftin.x, loleftin.y, loleftin.z);
      vertex(upleftin.x, upleftin.y, upleftin.z);
      vertex(upleftout.x, upleftout.y, upleftout.z);
      vertex(loleftout.x, loleftout.y, loleftout.z);
      endShape(CLOSE);
      //left embrasure of door/window opening
      if (hasWindow||hasDoor) {
        //inner
        fill(interior);
        beginShape();
        vertex(ololeftin.x, ololeftin.y, ololeftin.z);
        vertex(oupleftin.x, oupleftin.y, oupleftin.z);
        vertex(oupleftmid.x, oupleftmid.y, oupleftmid.z);
        vertex(ololeftmid.x, ololeftmid.y, ololeftmid.z);
        endShape(CLOSE);
        //outer
        fill(facade);
        beginShape();
        vertex(ololeftmid.x, ololeftmid.y, ololeftmid.z);
        vertex(oupleftmid.x, oupleftmid.y, oupleftmid.z);
        vertex(oupleftout.x, oupleftout.y, oupleftout.z);
        vertex(ololeftout.x, ololeftout.y, ololeftout.z);
        endShape(CLOSE);
      }
      // rightSides
      fill(rite());
      beginShape();
      vertex(loritein.x, loritein.y, loritein.z);
      vertex(upritein.x, upritein.y, upritein.z);
      vertex(upriteout.x, upriteout.y, upriteout.z);
      vertex(loriteout.x, loriteout.y, loriteout.z);
      endShape(CLOSE);
      //right embrasure of door/window opening
      if (hasWindow||hasDoor) {
        // inner
        fill(interior);
        beginShape();
        vertex(oloritein.x, oloritein.y, oloritein.z);
        vertex(oupritein.x, oupritein.y, oupritein.z);
        vertex(oupritemid.x, oupritemid.y, oupritemid.z);
        vertex(oloritemid.x, oloritemid.y, oloritemid.z);
        endShape(CLOSE);
        //outer
        fill(facade);
        beginShape();
        vertex(oloritemid.x, oloritemid.y, oloritemid.z);
        vertex(oupritemid.x, oupritemid.y, oupritemid.z);
        vertex(oupriteout.x, oupriteout.y, oupriteout.z);
        vertex(oloriteout.x, oloriteout.y, oloriteout.z);
        endShape(CLOSE);
      }
      // upperSides
      fill(28);
      beginShape();
      vertex(upriteout.x, upriteout.y, upriteout.z);
      vertex(upritein.x, upritein.y, upritein.z);
      vertex(upleftin.x, upleftin.y, upleftin.z);
      vertex(upleftout.x, upleftout.y, upleftout.z);
      endShape(CLOSE);
      //blabla
      if (hasWindow||hasDoor) {
        // inner
        fill(interior);
        beginShape();
        vertex(oupritemid.x, oupritemid.y, oupritemid.z);
        vertex(oupritein.x, oupritein.y, oupritein.z);
        vertex(oupleftin.x, oupleftin.y, oupleftin.z);
        vertex(oupleftmid.x, oupleftmid.y, oupleftmid.z);
        endShape(CLOSE);
        //oute
        fill(interior);
        beginShape();
        vertex(oupriteout.x, oupriteout.y, oupriteout.z);
        vertex(oupritemid.x, oupritemid.y, oupritemid.z);
        vertex(oupleftmid.x, oupleftmid.y, oupleftmid.z);
        vertex(oupleftout.x, oupleftout.y, oupleftout.z);
        endShape(CLOSE);
      }
      // lowerSides
      fill(28);
      beginShape();
      vertex(loriteout.x, loriteout.y, loriteout.z);
      vertex(loritein.x, loritein.y, loritein.z);
      vertex(loleftin.x, loleftin.y, loleftin.z);
      vertex(loleftout.x, loleftout.y, loleftout.z);
      endShape(CLOSE);
      // the silly sill, if you will
      if (hasWindow||hasDoor) {
        // inner
        fill(sillIn);
        beginShape();
        vertex(oloritemid.x, oloritemid.y, oloritemid.z);
        vertex(oloritein.x, oloritein.y, oloritein.z);
        vertex(ololeftin.x, ololeftin.y, ololeftin.z);
        vertex(ololeftmid.x, ololeftmid.y, ololeftmid.z);
        endShape(CLOSE);
        // outer
        fill(metal);
        beginShape();
        vertex(oloriteout.x, oloriteout.y, oloriteout.z);
        vertex(oloritemid.x, oloritemid.y, oloritemid.z);
        vertex(ololeftmid.x, ololeftmid.y, ololeftmid.z);
        vertex(ololeftout.x, ololeftout.y, ololeftout.z);
        endShape(CLOSE);
      }
    }
    // ok, this should be a classy window, then. but for now, a frame will do.
    if ((hasWindow||hasDoor) && !snapOnInners) {
    if (b<=150){
      drawMeAFrame(oupleftout, b-2*e, h-l-p, 8, 5, winOff, 248, isActive);
   } else {
      pushMatrix();
      drawMeAFrame(oupleftout,(b-2*e)/2, h-l-p, 8, 5, winOff, 248, isActive);
      translate((b-2*e)/2,0,0);
      drawMeAFrame(oupleftout,(b-2*e)/2, h-l-p, 8, 5, winOff, 248, isActive);
      popMatrix();
      }
    }
  }

  void alignInRow() {  // colors (leftColor, riteColor should be defined here
    try {
      if (index>0 && !isCorner) {
        Wall p = myPrev;
        // since, for now, there are 4 rotations only and PI is a constant in processing, we can make boolean decisions for alignment
        // ...despite the pitiful lack of elegance. Some hero might one day improve this.
        // avoiding corner-conflict: either walls are winding, which makes cutting openings a little weird or theres is priority to a direction
        // be it smart or not: right now the long axis (building-X) has priority, walls are 25cm thick. The two outer walls add up to subtract one grid step
        // in this, outer dimensions as well as clearance in between outer walls keep the integrity of the grid.
        if (p.rotation == 0 && rotation == 0) {
          pos.x = p.pos.x+p.b/2+b/2;
          pos.y = p.pos.y; // in case walls should ever be of different height: +(p.h/2-h/2);
          pos.z = p.pos.z;
        }
        if (p.rotation == 0 && rotation == HALF_PI) {
          pos.x = p.pos.x+p.b/2-d/2;
          pos.y = p.pos.y;
          pos.z = p.pos.z-p.d/2-b/2;
        }
        // However unlikely it is, someone wants to build walls back to back...
        if (p.rotation == 0 && rotation == PI) {
          pos.x = p.pos.x+p.b/2-b/2;
          pos.y = p.pos.y;
          pos.z = p.pos.z-p.d/2-d/2;
        }
        if (p.rotation == 0 && rotation == HALF_PI+PI) {
          pos.x = p.pos.x+p.b/2+d/2;
          pos.y = p.pos.y;
          pos.z = p.pos.z-p.d/2+b/2;
        }
        if (p.rotation == HALF_PI && rotation == 0) {
          pos.x = p.pos.x+p.d/2+b/2;
          pos.y = p.pos.y;
          pos.z = p.pos.z-p.b/2+d/2;
        }
        if (p.rotation == HALF_PI && rotation == HALF_PI) {
          pos.x = p.pos.x;
          pos.y = p.pos.y;
          pos.z = p.pos.z-p.b/2-b/2;
        }
        if (p.rotation == HALF_PI && rotation == PI) {
          pos.x = p.pos.x+p.d/2-b/2;
          pos.y = p.pos.y;
          pos.z = p.pos.z-p.b/2-d/2;
        }
        if (p.rotation == HALF_PI && rotation == HALF_PI+PI) {
          pos.x = p.pos.x-p.d/2-d/2;
          pos.y = p.pos.y;
          pos.z = p.pos.z-p.b/2+b/2;
        }
        if (p.rotation == PI && rotation == 0) {
          pos.x = p.pos.x-p.b/2+b/2;
          pos.y = p.pos.y;
          pos.z = p.pos.z+p.d/2+d/2;
        }
        if (p.rotation == PI && rotation == HALF_PI) {
          pos.x = p.pos.x-p.b/2-d/2;
          pos.y = p.pos.y;
          pos.z = p.pos.z+p.d/2-b/2;
        }
        if (p.rotation == PI && rotation == PI) {
          pos.x = p.pos.x-p.b/2-b/2;
          pos.y = p.pos.y;
          pos.z = p.pos.z;
        }
        if (p.rotation == PI && rotation == HALF_PI+PI) {
          pos.x = p.pos.x-p.b/2+d/2;
          pos.y = p.pos.y;
          pos.z =  p.pos.z+p.d/2+b/2;
        }
        if (p.rotation == HALF_PI+PI && rotation == 0) {
          pos.x = p.pos.x-p.d/2+b/2;
          pos.y = p.pos.y;
          pos.z = p.pos.z+p.b/2+d/2;
        }
        if (p.rotation == HALF_PI+PI && rotation == HALF_PI) {
          pos.x = p.pos.x+p.d/2+d/2;
          pos.y = p.pos.y;
          pos.z = p.pos.z+p.b/2-b/2;
        }
        if (p.rotation == HALF_PI+PI && rotation == PI) {
          pos.x = p.pos.x-p.d/2-b/2;
          pos.y = p.pos.y;
          pos.z = p.pos.z+p.b/2-d/2;
        }
        if (p.rotation == HALF_PI+PI && rotation == HALF_PI+PI) {
          pos.x = p.pos.x;
          pos.y = p.pos.y;
          pos.z = p.pos.z+p.b/2+b/2;
        }
      }
    }
    catch(Exception e) {
    }
  }

  void alignCorners() {
    if (isCorner) {
      if (walls.indexOf(this) != 0) {
        pos.y = walls.get(0).pos.y;
      }
    }
  }

  void getMyPrev() {
    try {
      myPrev = (walls.size()>1)? walls.get(index-1):null;
    }
    catch(Exception e) {
    }
  }

  void getMyFoll() {
    try {
      myPrev.myFoll = this;
    }
    catch (Exception e) {
    }
  }

  void transferWAllParameters(Wall w2){
    // pos = assuming pos comes with align in Row 
    w2.rotation=rotation;
    w2.b = b;
    w2.h = h;
    w2.d = d;             
    w2.index = index+1;                       // identifyer for calling objects without loop
    w2.e = e;
    w2.l = l;
    w2.p = p;                 // For door/window, we need distances for (e)mbrasure, (l)edge and (p)arapet
    w2.winOff = winOff;               // window offset from facade
    w2.isgWall = isgWall;
    noStretch =  (myFoll.isCorner)? true:false;
    w2.noStretch = (w2.myFoll.isCorner)? true:false;
    //Window window;
    //  Door door;
  }
}

// Windows and wall should be classes of their own to better control their attributes and keep the code more clear
class Window {
  Wall myWall;
  PVector pos;
  float myWidth;
  float myHeight;
  float myDepth;

  Window(Wall mW) {
    myWall   = mW;
    // all measures should be passed over from the wall
  }

  void display() {
    // faked Frame:
    strokeWeight(myWall.myStrokeWeight);
    stroke(255);
    // faked pane
    /*fill(128, 128, 128, 28);
    beginShape();
    vertex(0, 0, 0);
    vertex(myWidth, 0, 0);
    vertex(myWidth, myHeight, 0);
    vertex(0, myHeight, 0);
    endShape(CLOSE);
    translate(pos.x, pos.y, pos.z);*/
  }
}

class Door {
  Wall myWall;
  PVector myPos;
  float myWidth;
  float myHeight;
  float myDepth;

  Door(Wall mW) {
    myWall = mW;
    // all measures should be passed over from the wall
  }
  void display() {
    strokeWeight(myWall.myStrokeWeight);
  }
}

void drawMeAFrame(PVector pos, float myWidth, float myHeight, float myDepth, float myThick, float offset, color frCol, boolean isActive) {
 
  color frameColor = frCol;
  PVector loleftout = new PVector(pos.x, pos.y+myHeight, pos.z-offset);
  PVector loriteout = new PVector(pos.x+myWidth, pos.y+myHeight, pos.z-offset);
  PVector upriteout = new PVector(pos.x+myWidth, pos.y, pos.z-offset);
  PVector upleftout = new PVector(pos.x, pos.y, pos.z-offset);
  PVector loleftin  = new PVector(pos.x, pos.y+myHeight, pos.z-offset-myDepth);
  PVector loritein  = new PVector(pos.x+myWidth, pos.y+myHeight, pos.z-offset-myDepth);
  PVector upritein  = new PVector(pos.x+myWidth, pos.y, pos.z-offset-myDepth);
  PVector upleftin  = new PVector(pos.x, pos.y, pos.z-offset-myDepth);
  //
  PVector ololeftout = new PVector(pos.x+myThick, pos.y+myHeight-myThick, pos.z-offset);
  PVector oloriteout = new PVector(pos.x+myWidth-myThick, pos.y+myHeight-myThick, pos.z-offset);
  PVector oupriteout = new PVector(pos.x+myWidth-myThick, pos.y+myThick, pos.z-offset);
  PVector oupleftout = new PVector(pos.x+myThick, pos.y+myThick, pos.z-offset);
  PVector ololeftin  = new PVector(pos.x+myThick, pos.y+myHeight-myThick, pos.z-offset-myDepth);
  PVector oloritein  = new PVector(pos.x+myWidth-myThick, pos.y+myHeight-myThick, pos.z-offset-myDepth);
  PVector oupritein  = new PVector(pos.x+myWidth-myThick, pos.y+myThick, pos.z-offset-myDepth);
  PVector oupleftin  = new PVector(pos.x+myThick, pos.y+myThick, pos.z-offset-myDepth);
  noFill();
  strokeWeight(2);
  stroke((isActive)? 255:0);
  // Outline of Interior wall surface
  beginShape();
  vertex(loleftin.x, loleftin.y, loleftin.z);
  vertex(loritein.x, loritein.y, loritein.z);
  vertex(upritein.x, upritein.y, upritein.z);
  vertex(upleftin.x, upleftin.y, upleftin.z);
  endShape(CLOSE);
  //outline of interior door/window opening
  beginShape();
  vertex(oupleftin.x, oupleftin.y, oupleftin.z);
  vertex(oupritein.x, oupritein.y, oupritein.z);
  vertex(oloritein.x, oloritein.y, oloritein.z);
  vertex(ololeftin.x, ololeftin.y, ololeftin.z);
  endShape(CLOSE);

  // Outline of Exterior wall surface
  beginShape();
  vertex(loleftout.x, loleftout.y, loleftout.z);
  vertex(loriteout.x, loriteout.y, loriteout.z);
  vertex(upriteout.x, upriteout.y, upriteout.z);
  vertex(upleftout.x, upleftout.y, upleftout.z);
  endShape(CLOSE);
  //outline of exterior door/window opening

  beginShape();
  vertex(oupleftout.x, oupleftout.y, oupleftout.z);
  vertex(oupriteout.x, oupriteout.y, oupriteout.z);
  vertex(oloriteout.x, oloriteout.y, oloriteout.z);
  vertex(ololeftout.x, ololeftout.y, ololeftout.z);
  endShape(CLOSE);

  // and just because it looks a little awkward with no edge in the corner
  // outer
  line(upleftout.x, upleftout.y, upleftout.z, upleftin.x, upleftin.y, upleftin.z);
  line(upriteout.x, upriteout.y, upriteout.z, upritein.x, upritein.y, upritein.z);
  line(loriteout.x, loriteout.y, loriteout.z, loritein.x, loritein.y, loritein.z);
  line(loleftout.x, loleftout.y, loleftout.z, loleftin.x, loleftin.y, loleftin.z);
  // window
  line(oupleftout.x, oupleftout.y, oupleftout.z, oupleftin.x, oupleftin.y, oupleftin.z);
  line(oupriteout.x, oupriteout.y, oupriteout.z, oupritein.x, oupritein.y, oupritein.z);
  line(oloriteout.x, oloriteout.y, oloriteout.z, oloritein.x, oloritein.y, oloritein.z);
  line(ololeftout.x, ololeftout.y, ololeftout.z, ololeftin.x, ololeftin.y, ololeftin.z);

  // now the filling (and just because I`ll be wondering one day:
  // 5 vertices for 4 lines in between)
  noStroke();
  // Filling of Exterior wall surface
  fill(frameColor);
  beginShape();
  vertex(loleftout.x, loleftout.y, loleftout.z);
  vertex(loriteout.x, loriteout.y, loriteout.z);
  vertex(upriteout.x, upriteout.y, upriteout.z);
  vertex(upleftout.x, upleftout.y, upleftout.z);
  vertex(loleftout.x, loleftout.y, loleftout.z);
  //outline of exterior door/window opening
  vertex(oupleftout.x, oupleftout.y, oupleftout.z);
  vertex(oupriteout.x, oupriteout.y, oupriteout.z);
  vertex(oloriteout.x, oloriteout.y, oloriteout.z);
  vertex(ololeftout.x, ololeftout.y, ololeftout.z);
  vertex(oupleftout.x, oupleftout.y, oupleftout.z);
  endShape(CLOSE);
  // Filling of Interior wall surface
  beginShape();
  vertex(loleftin.x, loleftin.y, loleftin.z);
  vertex(loritein.x, loritein.y, loritein.z);
  vertex(upritein.x, upritein.y, upritein.z);
  vertex(upleftin.x, upleftin.y, upleftin.z);
  vertex(loleftin.x, loleftin.y, loleftin.z);
  //inline of interior door/window opening
  vertex(oupleftin.x, oupleftin.y, oupleftin.z);
  vertex(oupritein.x, oupritein.y, oupritein.z);
  vertex(oloritein.x, oloritein.y, oloritein.z);
  vertex(ololeftin.x, ololeftin.y, ololeftin.z);
  vertex(oupleftin.x, oupleftin.y, oupleftin.z);
  endShape(CLOSE);

  //laterals
  beginShape();
  vertex(loleftin.x, loleftin.y, loleftin.z);
  vertex(upleftin.x, upleftin.y, upleftin.z);
  vertex(upleftout.x, upleftout.y, upleftout.z);
  vertex(loleftout.x, loleftout.y, loleftout.z);
  endShape(CLOSE);

  beginShape();
  vertex(ololeftin.x, ololeftin.y, ololeftin.z);
  vertex(oupleftin.x, oupleftin.y, oupleftin.z);
  vertex(oupleftout.x, oupleftout.y, oupleftout.z);
  vertex(ololeftout.x, ololeftout.y, ololeftout.z);
  endShape(CLOSE);

  beginShape();
  vertex(loritein.x, loritein.y, loritein.z);
  vertex(upritein.x, upritein.y, upritein.z);
  vertex(upriteout.x, upriteout.y, upriteout.z);
  vertex(loriteout.x, loriteout.y, loriteout.z);
  endShape(CLOSE);

  beginShape();
  vertex(oloritein.x, oloritein.y, oloritein.z);
  vertex(oupritein.x, oupritein.y, oupritein.z);
  vertex(oupriteout.x, oupriteout.y, oupriteout.z);
  vertex(oloriteout.x, oloriteout.y, oloriteout.z);
  endShape(CLOSE);

  beginShape();
  vertex(upriteout.x, upriteout.y, upriteout.z);
  vertex(upritein.x, upritein.y, upritein.z);
  vertex(upleftin.x, upleftin.y, upleftin.z);
  vertex(upleftout.x, upleftout.y, upleftout.z);
  endShape(CLOSE);

  beginShape();
  vertex(oupriteout.x, oupriteout.y, oupriteout.z);
  vertex(oupritein.x, oupritein.y, oupritein.z);
  vertex(oupleftin.x, oupleftin.y, oupleftin.z);
  vertex(oupleftout.x, oupleftout.y, oupleftout.z);
  endShape(CLOSE);

  beginShape();
  vertex(loriteout.x, loriteout.y, loriteout.z);
  vertex(loritein.x, loritein.y, loritein.z);
  vertex(loleftin.x, loleftin.y, loleftin.z);
  vertex(loleftout.x, loleftout.y, loleftout.z);
  endShape(CLOSE);

  beginShape();
  vertex(oloriteout.x, oloriteout.y, oloriteout.z);
  vertex(oloritein.x, oloritein.y, oloritein.z);
  vertex(ololeftin.x, ololeftin.y, ololeftin.z);
  vertex(ololeftout.x, ololeftout.y, ololeftout.z);
  endShape(CLOSE);
  
  pushMatrix();
  scale(abs(oupriteout.x-oupleftout.x)/100, abs(oupriteout.y-oloriteout.y)/100);
  shape(pane);
  popMatrix();
  
}
