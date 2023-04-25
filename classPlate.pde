ArrayList<Plate> plates = new ArrayList<Plate>();

Plate myPrev;
Plate myFoll;

class Plate extends Base {
  float minX, minZ, maxX, maxZ;
  boolean sizeChosen = false; // once the size is chosen, this enables more controller panels

  Plate(float px, float py, float pz, float sx, float sy, float sz, int gz) {
    super( px, py, pz, sx, sy, sz, gz);
    minX=minZ=maxX=maxZ=0;
    getMyPrev();
    getMyFoll();
  }

  // this is not about rotation, plates do not have a direction, just longitude and latitude
  void setPlateOrientation(float ori) {
    if (ori == 0 || ori == 180 || ori == 360 ||ori == PI || ori == TWO_PI ) {
      myOrientation = 0;
      float s1 = b;
      float s2 = d;
      b = (s1<s2)? s2:s1;
      d = (s1>s2)? s2:s1;
    }
    if (ori == 90 || ori == 270 || ori == HALF_PI ||ori == HALF_PI + PI ) {
      myOrientation = 90;
      float s1 = b;
      float s2 = d;
      b = (s1>s2)? s2:s1;
      d = (s1<s2)? s2:s1;
    }
  }

  // as long as there are only two plates, these will do:
  float minX() {
    float tX = 0;
    for (Plate p : plates) {
      //actually this would be an Array to find the min(pos.x) except this.pos.x
      if (p!=this) tX=p.pos.x-p.b/2-b/2;
    }
    minX = tX;
      return minX;
  }
  
  float maxX() {
    float tX = 0;
    for (Plate p : plates) {
      if (p!=this) tX=p.pos.x+p.b/2+b/2;
    }
    maxX = tX;
      return maxX;
  }
  
  float minZ() {
    float tZ = 0;
     for (Plate p : plates) {
      if (p!=this) tZ=p.pos.z-p.d/2-d/2;
    }
    minZ = tZ;
      return minZ;
  }
  
  float maxZ() {
    float tZ = 0;
     for (Plate p : plates) {
      if (p!=this) tZ=p.pos.z+p.d/2+d/2;
    }
    maxZ = tZ;
      return maxZ;
  }
  
  void goToGrid() {
    pos.x = round(pos.x/(gridSpacing/2))*(gridSpacing/2);
    pos.z = round(pos.z/(gridSpacing/2))*(gridSpacing/2);
}

  void update() {
    if (selectionDefault) {
      //    myStrokeWeight = (isMouseOver)? 6 : 2;
      myStrokeColor  = isActive?  255 : 0;
    }
    // hoping it works like this:
    // rotation and translation work upon origin
    // repositioning and alignment are List-depending/outside class functions
    pushMatrix();
    drawPlate();
    rotateY(rotation);
    translate(pos.x, pos.y, pos.z);
    popMatrix();
  }

  void drawPlate() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    strokeWeight(myStrokeWeight);
    stroke(myStrokeColor);
    //upside
    fill(floor);
    beginShape();
    vertex(-(b/2), -(h/2), -(d/2));
    vertex(-(b/2), -(h/2), +(d/2));
    vertex(+(b/2), -(h/2), +(d/2));
    vertex(+(b/2), -(h/2), -(d/2));
    endShape();

    //downside
    fill(downSideC);
    beginShape();
    //   texture(outside);
    vertex(-(b/2), +(h/2), -(d/2));
    vertex(-(b/2), +(h/2), +(d/2));
    vertex(+(b/2), +(h/2), +(d/2));
    vertex(+(b/2), +(h/2), -(d/2));
    endShape();

    // ...and all around
    //left
    fill(leftC);
    beginShape();
    vertex(-(b/2), -(h/2), -(d/2));
    vertex(-(b/2), -(h/2), +(d/2));
    vertex(-(b/2), +(h/2), +(d/2));
    vertex(-(b/2), +(h/2), -(d/2));
    endShape();
    //right
    fill(rightC);
    beginShape();
    vertex(+(b/2), -(h/2), -(d/2));
    vertex(+(b/2), -(h/2), +(d/2));
    vertex(+(b/2), +(h/2), +(d/2));
    vertex(+(b/2), +(h/2), -(d/2));
    endShape();
    // front
    fill(frontC);
    beginShape();
    vertex(-(b/2), -(h/2), +(d/2));
    vertex(+(b/2), -(h/2), +(d/2));
    vertex(+(b/2), +(h/2), +(d/2));
    vertex(-(b/2), +(h/2), +(d/2));
    endShape();
    // beck
    fill(backC);
    beginShape();
    vertex(-(b/2), -(h/2), -(d/2));
    vertex(+(b/2), -(h/2), -(d/2));
    vertex(+(b/2), +(h/2), -(d/2));
    vertex(-(b/2), +(h/2), -(d/2));
    endShape();
    popMatrix();
  }

  void getMyPrev() {
    try {
      myPrev = (plates.size()>1)? plates.get(index-1):null;
    }
    catch(Exception e) {
    }
  }

  void getMyFoll() {
    try {
      //myPrev.myFoll = this;  //no idea why this works in walls but not in plates
      if (plates.size()>=index) myFoll=plates.get(index+1); // so it has to be done "by hand", anytime a new plate is created
    }
    catch (Exception e) {
    }
  }
}
