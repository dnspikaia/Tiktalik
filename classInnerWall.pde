ArrayList<Inner> inners = new ArrayList<Inner>();

// right now this is a precise copy of "Wall", let`s see how to adjust

class Inner extends Base {
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
  float minX, maxX, minZ, maxZ; // movement constraints
  Window window;
  Door door;
  Wall myPrev, myFoll;        // since walls can be inserted inbetween others, list doesnt work, so we need to keep track of connected walls

  Inner(float px, float py, float pz, float sx, float sy, float sz, int gz) {
    super( px, py, pz, sx, sy, sz, gz);

    //just to have some default values
    e=12;
    l=25;
    p=100;
    winOff = 6;
    minX = maxX = minZ = maxZ = 0; // just to initialize;
    calcMeasures(e, l, p, winOff);
    hasDoor=false;
    hasWindow = false;
    getFillings();
    inners.add(this);
    // myPrev myFoll are taken out - I guess innerWalls rather group than serialize
  }

  void calcMeasures(float tempE, float tempL, float tempP, float tempWoff) {
    e=tempE;
    l=tempL;
    p=tempP;
    winOff = tempWoff;

    loleftout = new PVector(-b/2, +h/2, +d);
    loriteout = new PVector(+b/2, +h/2, +d);
    upriteout = new PVector(+b/2, -h/2, +d);
    upleftout = new PVector(-b/2, -h/2, +d);
    loleftin  = new PVector(-b/2, +h/2, 0);
    loritein  = new PVector(+b/2, +h/2, 0);
    upritein  = new PVector(+b/2, -h/2, 0);
    upleftin  = new PVector(-b/2, -h/2, 0);

    ololeftout = new PVector(-b/2+e, +h/2-p, +d);
    oloriteout = new PVector(+b/2-e, +h/2-p, +d);
    oupriteout = new PVector(+b/2-e, -h/2+l, +d);
    oupleftout = new PVector(-b/2+e, -h/2+l, +d);
    ololeftin  = new PVector(-b/2+e, +h/2-p, 0);
    oloritein  = new PVector(+b/2-e, +h/2-p, 0);
    oupritein  = new PVector(+b/2-e, -h/2+l, 0);
    oupleftin  = new PVector(-b/2+e, -h/2+l, 0);

    ololeftmid = new PVector(-b/2+e, +h/2-p, +winOff);
    oloritemid = new PVector(+b/2-e, +h/2-p, +winOff);
    oupritemid = new PVector(+b/2-e, -h/2+l, +winOff);
    oupleftmid = new PVector(-b/2+e, -h/2+l, +winOff);
  }

  void update() {
    //  alignInRow();
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    rotateY(rotation);
    drawWall();
    popMatrix();
  }

  color rite () {
    // and if it should ever be different: ClassWall has the old attributions
    return interior;
  }


  /////////not done, need other stuff first
  color left () {
    return interior;
  }

  void drawWall() {
    calcMeasures(e, l, p, winOff);
    noFill();
    strokeWeight(myStrokeWeight);
    stroke((isActive)? 255:0);
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
    //window
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
    fill(interior);
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
      fill(interior);
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
      fill(interior);
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
      fill(sillIn);
      beginShape();
      vertex(oloriteout.x, oloriteout.y, oloriteout.z);
      vertex(oloritemid.x, oloritemid.y, oloritemid.z);
      vertex(ololeftmid.x, ololeftmid.y, ololeftmid.z);
      vertex(ololeftout.x, ololeftout.y, ololeftout.z);
      endShape(CLOSE);
    }
    // draw me a frame as doorjamb
  }

  PVector stayInTheGrid() {
    PVector discPos = new PVector(0, 0, 0);
    float minX = minZ =  1000000; //initialize bounds of grid
    float maxX = maxZ = -1000000;

    // at first: find the range, if there is a plate
    if (plates.size() > 0) {
      for (Plate p : plates) {
        minX = (p.pos.x-p.b/2 <= minX)? p.pos.x-p.b/2:minX; // ok, this works only if the house has no wall more than 10km away from its center...
        maxX = (p.pos.x+p.b/2 >= maxX)? p.pos.x+p.b/2:maxX;
        minZ = (p.pos.z-p.d/2 <= minZ)? p.pos.z-p.d/2:minZ;
        maxZ = (p.pos.z+p.d/2 >= maxZ)? p.pos.z+p.d/2:maxZ;
      }
    }
    // then: overwrite, if there are sufficiently walls
    if (walls.size() > 0) {
      PVector mini = getWallsMinPos(); // @messyObjStuff
      PVector maxi = getWallsMaxPos(); // dto.
      minX = (minX== 1000000)? mini.x:(minX > mini.x)? minX:mini.x; // if walls don´t stretch as far as the plate, the bounds are reduced
      maxX = (maxX==-1000000)? maxi.x:(maxX < maxi.x)? maxX:maxi.x;
      minZ = (minZ== 1000000)? mini.z:(minZ > mini.z)? minZ:mini.z;
      maxZ = (maxZ==-1000000)? maxi.z:(maxZ < maxi.z)? maxZ:maxi.z;
    }
    // get the amount of steps in either direction
    int gridX = round((maxX-minX)/(0.5*gridSpacing));                   // 0.5*... the inner grid should have at least one step inbetween 0.5m and 1m
    int gridZ = round((maxZ-minZ)/(0.5*gridSpacing));

    // now find the step next to inwall´s position
    int theGX= round(map(pos.x, minX, maxX, 0, gridX));
    int theGZ= round(map(pos.z, minZ, maxZ, 0, gridZ));

    // reverse and find the coordinates of the calculated step
    discPos.x = map(theGX, 0, gridX, minX, maxX);
    discPos.y = (walls.size() > 0)? walls.get(0).pos.y: (plates.size()>0)? plates.get(0).pos.y-plates.get(0).h/2-h/2: -h/2;
    discPos.z = map(theGZ, 0, gridZ, minZ, maxZ);

    // so far all works well, anything below makes a problem...
    // pos is the center, to get walls edge to edge. this one may need improvements
    //  discPos.z = (rotation == 0)? discPos.z-d/2 : (rotation == PI)? discPos.z+d/2 : discPos.z;
    //discPos.x = (rotation == HALF_PI)? discPos.x-d/2 : (rotation == HALF_PI+PI)? discPos.x+d/2 : discPos.x;

    // and a last filter: if the last routine kicked it out of the bounds, bring it back in.
    //  discPos.x = (discPos.x < minX)? discPos.x+gridSpacing : (discPos.x > maxX)? discPos.x-gridSpacing : discPos.x;
    //  discPos.z = (discPos.z < minZ)? discPos.z+gridSpacing : (discPos.z > maxZ)? discPos.z-gridSpacing : discPos.z;

    return discPos;
  }
}

/*
 class innerWindow {
 Inner myInner;
 PVector pos;
 float myWidth;
 float myHeight;
 float myDepth;
 
 innerWindow(Inner mI) {
 myInner   = mI;
 // all measures should be passed over from the wall
 }
 
 void display() {
 // faked Frame:
 strokeWeight(myInner.myStrokeWeight);
 stroke(255);
 // faked pane
 fill(128, 128, 128, 28);
 beginShape();
 vertex(0, 0, 0);
 vertex(myWidth, 0, 0);
 vertex(myWidth, myHeight, 0);
 vertex(0, myHeight, 0);
 endShape(CLOSE);
 translate(pos.x, pos.y, pos.z);
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
 */
