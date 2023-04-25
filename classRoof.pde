ArrayList<Roof> roofs = new ArrayList<Roof>();

class Roof extends Base {

  float atticHeight, atticWidth;
  float outerLeftX, innerLeftX, innerRightX, outerRightX;
  float outerFrontZ, innerFrontZ, innerBackZ, outerBackZ;
  float onWallY, rfSurfY, atticInY, atticOutY;

  Roof(float px, float py, float pz, float sx, float sy, float sz, int gz) {
    super( px, py, pz, sx, sy, sz, gz);

    atticHeight = 15;
    atticWidth  = 25;
    roofs.add(this);
  }

  void calcMeasures() {
    outerLeftX  = -b/2;
    innerLeftX  = -b/2 +atticWidth;
    innerRightX = +b/2 -atticWidth;
    outerRightX = +b/2;

    outerFrontZ = -d/2;
    innerFrontZ = -d/2 +atticWidth;
    innerBackZ  = +d/2 -atticWidth;
    outerBackZ  = +d/2;

    onWallY     = 0;
    rfSurfY     = -h;
    atticInY    = -h -atticHeight +atticWidth/5;
    atticOutY   = -h -atticHeight;
  }

  void update() {
    if (selectionDefault) {
      //    myStrokeWeight = (isMouseOver)? 6 : 2;
      myStrokeColor  = isActive?  255 : 0;
    }
    pushMatrix();
    drawRoof();
    rotateY(rotation);
    translate(pos.x, pos.y, pos.z);
    popMatrix();
  }

  void drawRoof() {
    calcMeasures();
    strokeWeight(myStrokeWeight);
    stroke(myStrokeColor);
    noFill();
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    //outlines
    //roofSurface
    if (!snapOnInners) fill(128);
    beginShape();
    vertex(innerLeftX, rfSurfY, innerFrontZ);
    vertex(innerLeftX, rfSurfY, innerBackZ);
    vertex(innerRightX, rfSurfY, innerBackZ);
    vertex(innerRightX, rfSurfY, innerFrontZ);
    endShape(CLOSE);

    //atticUpside
    if (!snapOnInners) fill(metal);
    beginShape();
    vertex(outerLeftX, atticOutY, outerFrontZ);
    vertex(outerLeftX, atticOutY, outerBackZ);
    vertex(outerRightX, atticOutY, outerBackZ);
    vertex(outerRightX, atticOutY, outerFrontZ);
    beginContour();
    vertex(innerRightX, atticInY, innerFrontZ);
    vertex(innerRightX, atticInY, innerBackZ);
    vertex(innerLeftX, atticInY, innerBackZ);
    vertex(innerLeftX, atticInY, innerFrontZ);
    endContour();
    endShape(CLOSE);
    line(outerLeftX, atticOutY, outerFrontZ, innerLeftX, atticInY, innerFrontZ);
    line(outerRightX, atticOutY, outerFrontZ, innerRightX, atticInY, innerFrontZ);
    line(outerLeftX, atticOutY, outerBackZ, innerLeftX, atticInY, innerBackZ);
    line(outerRightX, atticOutY, outerBackZ, innerRightX, atticInY, innerBackZ);

    //downside
    if (!snapOnInners) fill(interior);
    beginShape();
    vertex(outerLeftX, onWallY, outerFrontZ);
    vertex(outerLeftX, onWallY, outerBackZ);
    vertex(outerRightX, onWallY, outerBackZ);
    vertex(outerRightX, onWallY, outerFrontZ);
    endShape(CLOSE);

    // ...and all around
    //left
    if (!snapOnInners) fill(facade);
    beginShape();
    vertex(outerLeftX, onWallY, outerFrontZ);
    vertex(outerLeftX, onWallY, outerBackZ);
    vertex(outerLeftX, atticOutY, outerBackZ);
    vertex(outerLeftX, atticOutY, outerFrontZ);
    endShape(CLOSE);
    if (!snapOnInners) fill(metal);
    beginShape();
    vertex(innerLeftX, rfSurfY, innerFrontZ);
    vertex(innerLeftX, rfSurfY, innerBackZ);
    vertex(innerLeftX, atticInY, innerBackZ);
    vertex(innerLeftX, atticInY, innerFrontZ);
    endShape(CLOSE);
    //right
    if (!snapOnInners) fill(facade);
    beginShape();
    vertex(outerRightX, onWallY, outerFrontZ);
    vertex(outerRightX, onWallY, outerBackZ);
    vertex(outerRightX, atticOutY, outerBackZ);
    vertex(outerRightX, atticOutY, outerFrontZ);
    endShape(CLOSE);
    if (!snapOnInners) fill(metal);
    beginShape();
    vertex(innerRightX, rfSurfY, innerFrontZ);
    vertex(innerRightX, rfSurfY, innerBackZ);
    vertex(innerRightX, atticInY, innerBackZ);
    vertex(innerRightX, atticInY, innerFrontZ);
    endShape(CLOSE);
    // front
    if (!snapOnInners) fill(facade);
    beginShape();
    vertex(outerRightX, onWallY, outerFrontZ);
    vertex(outerLeftX, onWallY, outerFrontZ);
    vertex(outerLeftX, atticOutY, outerFrontZ);
    vertex(outerRightX, atticOutY, outerFrontZ);
    endShape(CLOSE);
    if (!snapOnInners) fill(metal);
    beginShape();
    vertex(innerRightX, rfSurfY, innerFrontZ);
    vertex(innerLeftX, rfSurfY, innerFrontZ);
    vertex(innerLeftX, atticInY, innerFrontZ);
    vertex(innerRightX, atticInY, innerFrontZ);
    endShape(CLOSE);
    // back
    if (!snapOnInners) fill(facade);
    beginShape();
    vertex(outerRightX, onWallY, outerBackZ);
    vertex(outerLeftX, onWallY, outerBackZ);
    vertex(outerLeftX, atticOutY, outerBackZ);
    vertex(outerRightX, atticOutY, outerBackZ);
    endShape(CLOSE);
    if (!snapOnInners) fill(metal);
    beginShape();
    vertex(innerRightX, rfSurfY, innerBackZ);
    vertex(innerLeftX, rfSurfY, innerBackZ);
    vertex(innerLeftX, atticInY, innerBackZ);
    vertex(innerRightX, atticInY, innerBackZ);
    endShape(CLOSE);
    popMatrix();
  }
}
