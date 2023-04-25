float[] rotations;

void oSnap() {
  rotations = cam.getRotations();
  if (snapOnWalls)  catchAny( walls);
  if (snapOnInners) catchAny(inners);
  if (snapOnPlates) catchAny(plates);
  if (snapOnRoofs)  catchAny( roofs);
}

// the way it works now: if the object is activated you may still click on it and do sth, if you click somwhere else, it becomes deactivated
// which is a bit unfortunate, since clikcking into the window for view control will de-activate objects - dragging the mouse over objects will hilight them and releasing the mouse
// over an object is interpreted as "mouseClicked" and will activate another one
/////////////////
//sth else to improve: I did not manage to create a generic object class, that should be passed in the "toCatch()" array and then feed into the catchAnyThing procedure
// boo serves: while chosing walls, only one will be hilighted.
void catchAny(ArrayList toCatch) {
  boolean boo = true;
  if (toCatch == walls) {
    for (Wall w : walls) {
      if (catchAnyThing(w.pos.x, w.pos.y, w.pos.z, w.b, w.h, boo)) {
        boo = false;
        w.myStrokeWeight=6;
        if (mousePressed) w.isActive = true;
      } else {
        w.myStrokeWeight=2;
        if (mousePressed && !isOverAnyHUD) w.isActive = false;
      }
    }
  } else {
    for (Wall w : walls) w.isActive = false;
  }
  if (toCatch == inners) {
    for (Inner in : inners) {
      if (catchAnyThing(in.pos.x, in.pos.y, in.pos.z, in.b, in.h, boo)) {
        boo = false;
        in.myStrokeWeight=6;
        if (mousePressed) in.isActive = true;
      } else {
        in.myStrokeWeight=2;
        if (mousePressed && !isOverAnyHUD) in.isActive = false;  //keep an eye on this - it will be template for the others - but no reason to change everything unless this one is not 100% satisfactory
      }
    }
  } else {
    for (Inner in : inners) in.isActive = false;
  }
  if (toCatch == plates) {
    for (Plate p : plates) {
      if (catchAnyThing(p.pos.x, p.pos.y, p.pos.z, p.b, p.h, boo)) {
        boo = false;
        p.myStrokeWeight=6;
        if (mousePressed) p.isActive = true;
      } else {
        p.myStrokeWeight=2;
        if (mousePressed && !isOverAnyHUD) p.isActive = false;
      }
    }
  } else {
    for (Plate p : plates) p.isActive = false;
  }
}

////////////////////////////MOVING PLATES///////////////////////////////
void movePlateX(Plate p) {
  if (key==CODED) if (keyCode == RIGHT && movePlate) {
    p.pos.x += gridSpacing;
    movePlate=false;
  }
  if (key==CODED) if (keyCode == LEFT && movePlate) {
    p.pos.x -= gridSpacing;
    movePlate=false;
  }
}

void movePlateZ(Plate p) {
  if (key==CODED) if (keyCode == UP && movePlate) {
    p.pos.z -= gridSpacing;
    movePlate=false;
  }
  if (key==CODED) if (keyCode == DOWN && movePlate) {
    p.pos.z += gridSpacing;
    movePlate=false;
  }
}

////////////////////////////MOVING INNER WALLS///////////////////////////////
void moveItX(Inner it) {
    if (key==CODED) if (keyCode == RIGHT && movePlate) {
    it.pos.x += gridSpacing/2;
    movePlate=false;
  }
  if (key==CODED) if (keyCode == LEFT && movePlate) {
    it.pos.x -= gridSpacing/2;
    movePlate=false;
  }
  
  // the actual movement method - not quite satisfactory at the moment - therefore replaced for movement through keys
  //if (dragging && keyPressed && it.pos.x >= it.minX && it.pos.x <= it.maxX) it.pos.x -= screenX(it.pos.x, it.pos.y, it.pos.z)-mouseX;
  //if (it.pos.x <= it.minX || it.pos.x >= it.maxX) it.pos.x = (abs(it.pos.x-it.minX) < abs(it.pos.x-it.maxX))? it.minX:it.maxX;
  //cam.setState(state);
}

void moveItZ(Inner it) {
   if (key==CODED) if (keyCode == UP && movePlate) {
    it.pos.z -= gridSpacing/2;
    movePlate=false;
  }
  if (key==CODED) if (keyCode == DOWN && movePlate) {
    it.pos.z += gridSpacing/2;
    movePlate=false;
  } 
    // the actual movement method - not quite satisfactory at the moment - therefore replaced for movement through keys
  //if (dragging && keyPressed && it.pos.z >= it.minZ && it.pos.z <= it.maxZ) it.pos.z -= screenY(it.pos.x, it.pos.y, it.pos.z)-mouseY;
  //if (it.pos.z <= it.minZ || it.pos.z >= it.maxZ) it.pos.z = (abs(it.pos.z-it.minZ) < abs(it.pos.z-it.maxZ))? it.minZ:it.maxZ;
  //cam.setState(state);
}

boolean keyTyped=false;
void keyTyped() {
  keyTyped=true;
}

void keyReleased() {
  movePlate=true;
  backToYaw=true;
}


// as long as there is only yaw rotation this one works pretty well - dunno what happens if pitch comes on top, probably constrain pitch...
boolean catchAnyThing(float posX, float posY, float posZ, float theB, float theH, boolean theBoo) {
  boolean freak = false;
  float b = theB/2;
  float h = theH/2;
  if (rotations[2] <= 0.1&&rotations[2] >= -0.1) {
    if (mouseX>screenX(posX-b, posY-h, posZ) && mouseX<screenX(posX+b, posY+h, posZ) &&
      mouseY>screenY(posX-b, posY-h, posZ) && mouseY<screenY(posX+b, posY+h, posZ) && theBoo) freak=true;
  } else {
    if (mouseX>screenX(posX+b, posY+h, posZ) && mouseX<screenX(posX-b, posY-h, posZ) &&
      mouseY>screenY(posX-b, posY-h, posZ) && mouseY<screenY(posX+b, posY+h, posZ) && theBoo) freak=true;
  }
  return freak;
}
