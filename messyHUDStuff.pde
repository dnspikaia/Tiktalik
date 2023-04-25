ArrayList<Trigger> ts = new ArrayList<Trigger>(); // the once-created Triggers need a pass outside the t: loop
ArrayList<Button>  bt = new ArrayList<Button>(); // the once-created Triggers need a pass outside the t: loop

// A Grid to help creatin HUD items of equal size and position
void controlPanelSetup() {
  hudG = sc2h/hudYs.length; // use height for definition as HUD does not cover full screen width
  for (int i=0; i<hudXs.length; i++) {
    hudXs[i] = round(i*(hudG));
  }
  for (int i=0; i<hudYs.length; i++) {
    hudYs[i] = round(i*(hudG));
  }
}

void controlPanelStartOff() {
  // add and delete
  addDoubleTriggerIcon("pldz", "plwg", "addPlate", "delPlate", hudG*3, hudG*2);
  addDoubleTriggerIcon("wldz", "wlwg", "addWall", "delWall", hudG*3, hudG*2);
  addDoubleTriggerIcon("iwldz", "iwlwg", "addInner", "delInner", hudG*3, hudG*2);
  addDoubleTriggerIcon("rfdz", "rfwg", "addRoof", "delRoof", hudG*3, hudG*2);
  // generating
  addDoubleTriggerIcon("addgWalls", "delgWalls", "addgWall", "delgWall", hudG*3, hudG*2);
  // operating
  addTripleTriggerIcon ("G", "F", "T", "closed", "window", "door", hudG*3, hudG*2);
  addTripleTriggerLabel("S", "M", "L", "S", "M", "L", hudG*3, hudG*2);
  for (Trigger t : triggers) if (t.name == "pldz" || t.name == "plwg") t.shownAndActive = true;

  addDoubleButtonIcon("plates", "walls", "plate", "closed", hudXs[36], hudYs[2], hudG*3, hudG*2, "noActivationMode");
  addDoubleButtonIcon("inners", "roofs", "inner", "roof", hudXs[42], hudYs[2], hudG*3, hudG*2, "noActivationMode");
  buttonsPals.append("plates");
  buttonsPals.append("walls");
  buttonsPals.append("inners");
  buttonsPals.append("roofs");
  ButtonsMakePals(buttonsPals);

  addDoubleButtonIcon("sequenz", "einzeln", "subSeqTurn", "singleTurn", hudXs[24], hudYs[2], hudG*3, hudG*2, "non");  //@ messyHUDStuff shoud add pos
 

 

  Slider bS = new Slider(0, 0, hudG*9, hudG*2, "Breite"); // played @ HUDinDaHood
  bS.setRange(0.5, 4.5);
  bS.ticks = 8;
  sliders.add(bS);

  Slider wS = new Slider(0, hudYs[3], hudG*2, hudG*5, "Höhe"); // played @ HUDinDaHood
  wS.setRange(2.4, 3.2);
  wS.ticks=2;
  sliders.add(wS);

  TwoWaySelector tws = new TwoWaySelector(0, hudYs[4], hudG*5, hudG*5, "Ausrichtung");
  tws.showName = true;
  twoWaySelectors.add(tws);

  fourWaySelectors.add(new FourWaySelector(hudXs[3], hudYs[3], hudG*5, hudG*5, "Drehung "));
}

// this should not be required - it is to keep the facade closed if a wall is rotated
void keepFacadeClosed(Wall w) {
  if (w.noStretch && (w.rotation ==0 || w.rotation==PI) )  w.b = abs(w.myPrev.pos.x-w.myFoll.pos.x)-w.myPrev.b/2-w.myFoll.b/2;
  if (w.noStretch && (w.rotation ==HALF_PI || w.rotation==HALF_PI+PI) )  w.b = abs(w.myPrev.pos.z-w.myFoll.pos.z)-w.myPrev.b/2-w.myFoll.b/2;
  //requires a method to a wall in front of the mo-stretch-wall, otherwise it beocomes to long || re-rwrite addNewWall to gWall
}

void addDoubleTriggerLabel(String name1, String name2, String label1, String label2, float widthX, float heightY) {

  for (int i=0; i<2; i++) {
    String nz = (i==0)? name1 : name2;
    String lz = (i==0)? label1: label2;
    ts.add(new Trigger(hudG*3*i, 0, widthX, heightY, nz));
    ts.get(i).showName = false;
    ts.get(i).label = lz;
  }
  ts.get(0).myPals.add(ts.get(1));
  ts.get(1).myPals.add(ts.get(0));
  triggers.add(ts.get(0));
  triggers.add(ts.get(1));
  ts.clear();
}

void addTripleTriggerLabel( String name1, String name2, String name3, String label1, String label2, String label3, float widthX, float heightY) {
  for (int i=0; i<3; i++) {
    String nz = (i==0)? name1 :(i==1)?  name2: name3;
    String lz = (i==0)? label1:(i==1)? label2:label3;
    ts.add(new Trigger(hudG*3*i, 0, widthX, heightY, nz));
    ts.get(i).shownAndActive = false;
    ts.get(i).showName = false;
    ts.get(i).label = lz;
    triggers.add(ts.get(i));
  }
  ts.clear();
}

void addDoubleTriggerIcon(String name1, String name2, String icon1, String icon2, float widthX, float heightY) {
  for (int i=0; i<2; i++) {
    String tIcon = (i==0)? icon1 : icon2;
    String nz    = (i==0)? name1 : name2;
    ts.add(new Trigger(hudG*3*i, 0, widthX, heightY, nz));
    ts.get(i).showName       = false;
    ts.get(i).shownAndActive = false;
    ts.get(i).iconOrLabel    = "icon";
    ts.get(i).myIcon         = tIcon;
  }
  ts.get(0).myPals.add(ts.get(1));
  ts.get(1).myPals.add(ts.get(0));
  triggers.add(ts.get(0));
  triggers.add(ts.get(1));
  ts.clear();
}

void addTripleTriggerIcon(String name1, String name2, String name3, String icon1, String icon2, String icon3, float widthX, float heightY) {
  for (int i=0; i<3; i++) {
    String tIcon = (i==0)? icon1:(i==1)? icon2:icon3;
    String sz = (i==0)? name1:(i==1)? name2:name3;
    ts.add(new Trigger(hudG*3*i, 0, widthX, heightY, sz));
    ts.get(i).iconOrLabel = "icon";
    ts.get(i).myIcon = tIcon;
    ts.get(i).showName = false;
    ts.get(i).shownAndActive = false;
    triggers.add(ts.get(i));
  }
  ts.clear();
}

void addDoubleButtonIcon(String name1, String name2, String icon1, String icon2, float startX, float startY, float buttX, float buttY, String nam) {
  doesItExist=false;
  for (Button b : buttons) {
    if (b.name == name1) doesItExist = true;
  }
  if (!doesItExist) {
    for (int i=0; i<2; i++) {
      String tIcon = (i==0)? icon1:icon2;
      String sz = (i==0)? name1:name2;
      bt.add(new Button(buttX*i, 0, buttX, buttY, sz));
      bt.get(i).iconOrLabel = "icon";
      bt.get(i).myIcon = tIcon;
      bt.get(i).showName = false;
      bt.get(i).shownAndActive=false;
      if (nam == "noActivationMode") bt.get(i).noActivationMode=true;
    }
    bt.get(0).myPals.add(bt.get(1));
    bt.get(0).activated = true;
    bt.get(1).myPals.add(bt.get(0));
    buttons.add(bt.get(0));
    buttons.add(bt.get(1));
    bt.clear();
  }
}

//////////////////////A ROUTINE TO ASSOCIATE MORE THAN THREE BUTTONS/////////////////////////
StringList buttonsPals = new StringList();
void ButtonsMakePals(StringList myPals) {
  ArrayList<Button> bts = new ArrayList<>();
  for (Button bt : buttons) {
    bt.myPals.clear();
    for (String str : myPals) {
      if (bt.name == str) bts.add(bt);
    }
  }
  for (Button bt : bts) {
    for (Button pl : bts) {
      if (bt.name != pl.name) bt.myPals.add(pl);
    }
    bt.activated=false;
  }
}

// Note: ts is a supportive class. if a bunch of triggers is required
// they be generated in a loop, added to "ts" after the loop, and ts is cleared afterwards, so ts can be used again.
void cleaningUpLists() {
  if (ts.size()>0) {
    for (Trigger t : ts) {
      triggers.add(t);
    }
  }
  if (ts.size()>0) ts.clear();

  if (bt.size()>0) {
    for (Button b : bt) {
      buttons.add(b);
    }
  }
  if (bt.size()>0) bt.clear();
}

void wallChangedInTheMess() {
  if (!justaNewWall) {
    justaNewWall = false;
    for (Wall w : walls) {
      try {
        if (w.isActive && w.b != bOfChangedWall && w.myFoll != null) {
          float change = bOfChangedWall-w.b;
          if (w.rotation == w.myFoll.rotation) {
            if ((w.myFoll.b > gridSpacing && change < 0) || (w.myFoll.b < gridSpacing*8 && change > 0)) {
              w.myFoll.b += (bOfChangedWall-w.b);
            } else if ((w.myPrev.b > gridSpacing && change < 0) || (w.myPrev.b < gridSpacing*8 && change > 0)) {
              w.myPrev.b += (bOfChangedWall-w.b);
            } else {
              w.b = bOfChangedWall;
            }
          }
        }
      }
      catch(Exception e) {
        w.b = bOfChangedWall;
      }
    }
  }
}

// generic: to attribute any Icon with any ctrl-Item
void setIcon(String theI, PVector iPos, float maxSize, color col) {

  color CollIns = 6*col;
  color liteCol = 10*col;
  color shadeCol = 3*col;
  fill(CollIns);
  stroke(shadeCol);
  pushMatrix();
  translate(iPos.x+maxSize/2-1, iPos.y+maxSize/2+2, iPos.z);
  scale((maxSize/148));
  strokeWeight(6);

  if (theI == "closed" || theI == "addWall" || theI == "delWall") {
    beginShape();
    vertex(-25, -40);
    vertex(25, -40);
    vertex(25, 40);
    vertex(-25, 40);
    endShape(CLOSE);
    stroke(liteCol);
    line(-25, -40, 25, -40);
    line(-25, -40, -25, 40);
    stroke(shadeCol);
    line(25, 40, 25, -40);
    line(25, 40, -25, 40);
    if (theI=="addWall") {
      makeAnAdd(5*col);
    }
    if (theI=="delWall") {
      makeADelete(5*col);
    }
  } else if (theI == "window") {
    beginShape();
    vertex(-25, -40);
    vertex(25, -40);
    vertex(25, 40);
    vertex(-25, 40);
    beginContour();
    vertex(-15, -30);
    vertex(-15, 5);
    vertex(15, 5);
    vertex(15, -30);
    endContour();
    endShape(CLOSE);
    stroke(liteCol);
    line(-25, -40, 25, -40);
    line(-25, -40, -25, 40);
    line(15, 5, 15, -30);
    line(15, 5, -15, 5);
    stroke(shadeCol);
    line(25, 40, 25, -40);
    line(25, 40, -25, 40);
    line(-15, -30, 15, -30);
    line(-15, -30, -15, 5);
  } else if (theI == "door") {
    beginShape();
    vertex(-25, -40);
    vertex(25, -40);
    vertex(25, 40);
    vertex(15, 40);
    vertex(15, -30);
    vertex(-15, -30);
    vertex(-15, 40);
    vertex(-25, 40);
    endShape(CLOSE);
    stroke(liteCol);
    line(-25, -40, 25, -40);
    line(-25, -40, -25, 40);
    line(15, -30, 15, 40);
    stroke(shadeCol);
    line(25, 40, 25, -40);
    line(25, 40, 15, 40);
    line(15, 40, 25, 40);
    line(-15, -30, 15, -30);
  } else if (theI == "subSeqTurn") {
    noStroke();
    beginShape();
    vertex(-35, 25);
    vertex(  5, 25);
    vertex(  5, -40);
    vertex( 20, -40);
    vertex( 20, 40);
    vertex(-35, 40);
    endShape(CLOSE);
    stroke(liteCol);
    line(-35, 25, 5, 25);
    line(5, 40, 5, -40);
    line(5, 0, 20, 0);
    stroke(shadeCol);
    line(-35, 40, 20, 40);
    line(20, 40, 20, -40);
    line(5, -6, 20, -6);
    line(-1, 25, -1, 40);
  } else if (theI == "singleTurn") {
    noStroke();
    beginShape();
    vertex(-35, 20);
    vertex( -0, 20);
    vertex( -0, -35);
    vertex( 45, -35);
    vertex( 45, -20);
    vertex( 15, -20);
    vertex( 15, 35);
    vertex(-35, 35);
    endShape(CLOSE);
    stroke(liteCol);
    line(-35, 20, -5, 20);
    line(-1, 20, -1, -35);
    line(-0, -35, 40, -35);
    line(-0, -14, 10, -14);
    line(-1, 20, -1, 35);
    stroke(shadeCol);
    line(-35, 35, 15, 35);
    line(-6, 20, -6, 35);
    line(-0, -20, 45, -20);
    line(15, -20, 15, 35);
  } else if (theI == "plate" || theI=="addPlate" || theI=="delPlate") {
    fill(8*col);
    noStroke();
    pushMatrix();
    translate(10, -15);
    beginShape();
    vertex(-60, 30);
    vertex( 60, 30);
    vertex( 25, -10);
    vertex(-25, -10);
    endShape(CLOSE);
    fill(5*col);
    beginShape();
    vertex(-60, 30);
    vertex( 60, 30);
    vertex( 60, 45);
    vertex(-60, 45);
    endShape(CLOSE);
    stroke(shadeCol);
    line(60, 30, 60, 45);
    line(60, 45, -60, 45);
    stroke(6*col);
    line(60, 30, 25, -10);
    stroke(liteCol);
    line(-60, 45, -60, 30);
    line(-60, 30, 60, 30);
    line(-60, 30, -25, -10);
    popMatrix();
    if (theI=="addPlate") {
      makeAnAdd(5*col);
    }
    if (theI=="delPlate") {
      makeADelete(5*col);
    }
  } else if (theI == "roof" || theI == "addRoof" || theI == "delRoof") {
    fill(5*col);
    noStroke();
    pushMatrix();
    translate(10, 15);
    beginShape();
    vertex(-60, -30);
    vertex( 60, -30);
    vertex( 25, 10);
    vertex(-25, 10);
    endShape(CLOSE);
    fill(7*col);
    beginShape();
    vertex(-60, -30);
    vertex( 60, -30);
    vertex( 60, -45);
    vertex(-60, -45);
    endShape(CLOSE);
    stroke(shadeCol);
    line(60, -30, 60, -45);
    line(-60, -30, 60, -30);
    line(60, -30, 25, 10);
    stroke(liteCol);
    line(-60, -45, -60, -30);
    line(-60, -30, -25, 10);
    line(60, -45, -60, -45);
    popMatrix();
    if (theI=="addRoof") {
      makeAnAdd(5*col);
    }
    if (theI=="delRoof") {
      makeADelete(5*col);
    }
  } else if (theI == "inner" || theI == "addInner" || theI == "delInner") {
    fill(7*col);
    noStroke();
    beginShape();
    vertex(-10, 50);
    vertex( 0, 50);
    vertex( 0, -30);
    vertex(-10, -30);
    endShape(CLOSE);
    fill(4*col);
    beginShape();
    vertex(0, 50);
    vertex( 20, 30);
    vertex( 20, -45);
    vertex(0, -30);
    endShape(CLOSE);
    fill(liteCol);
    beginShape();
    vertex(-10, -30);
    vertex(0, -30);
    vertex( 20, -45);
    vertex(10, -45);
    endShape(CLOSE);
    stroke(liteCol);
    line(-10, 50, -10, -30);
    line(-10, -30, 20, -45);
    stroke(col);
    line(-45, -25, 45, -25);
    line(-45, 45, 45, 45);
    if (theI=="addInner") {
      makeAnAdd(5*col);
    }
    if (theI=="delInner") {
      makeADelete(5*col);
    }
  } else if (theI == "addgWall" || theI == "delgWall") {
    noStroke();
    fill(4*col);
    beginShape();
    vertex(-20, -35);
    vertex(-20, 30);
    vertex(-45, 45);
    vertex(-45, -20);
    endShape(CLOSE);
    fill(8*col);
    beginShape();
    vertex(-20, -35);
    vertex(-20, 30);
    vertex(15, 50);
    vertex(15, -15);
    endShape(CLOSE);
    fill(4*col);
    beginShape();
    vertex(15, -15);
    vertex(15, 50);
    vertex(50, 30);
    vertex(50, -35);
    endShape(CLOSE);
    stroke(8*col);
    line(-45, 45, -45, -20);
    stroke(10*col);
    line(-45, -20, -20, -35);
    line(-20, -35, 15, -15);
    line(15, -15, 50, -35);
    if (theI=="addgWall") {
      makeAnAdd(5*col);
    }
    if (theI=="delgWall") {
      makeADelete(5*col);
    }
  } else if (theI == "generic1") {
    fill(CollIns);
    stroke(liteCol);
    translate(-2, -2);
    circle(0, 0, 40);
    stroke(shadeCol);
    translate(4, 4);
    circle(0, 0, 40);
  } else if (theI == "generic2") {
    stroke(liteCol);
    rect(-42, -42, 80, 80);
    stroke(shadeCol);
    rect(-38, -38, 80, 80);
  }
  popMatrix();
}

// the green Plus for "add"-items
void makeAnAdd(color lC) {
  noStroke();
  fill(lC);
  pushMatrix();
  translate(80, -40);
  beginShape();
  vertex(-25, -8);
  vertex(-25, 8);
  vertex( -8, 8);
  vertex( -8, 25);
  vertex(  8, 25);
  vertex(  8, 8);
  vertex( 25, 8);
  vertex( 25, -8);
  vertex(  8, -8);
  vertex(  8, -25);
  vertex( -8, -25);
  vertex( -8, -8);
  endShape(CLOSE);
  fill(0, 180, 90);
  beginShape();
  vertex(-20, -3);
  vertex(-20, 3);
  vertex( -3, 3);
  vertex( -3, 20);
  vertex(  3, 20);
  vertex(  3, 3);
  vertex( 20, 3);
  vertex( 20, -3);
  vertex(  3, -3);
  vertex(  3, -20);
  vertex( -3, -20);
  vertex( -3, -3);
  endShape();
  popMatrix();
}

// the red Nope for "del"-items
void makeADelete(color lC) {
  noFill();
  stroke(lC);
  strokeWeight(15);
  pushMatrix();
  translate(80, -40);
  circle(0, 0, 40);
  line(-15, 15, 15, -15);
  stroke(80, 0, 0);
  strokeWeight(5);
  circle(0, 0, 40);
  line(-15, 15, 15, -15);
  popMatrix();
}

String flagExist   = "Nutzen Sie diese Schaltflächen, um Bodenplatten, Innenwände, oder das Dach hinzuzufügen, oder ausgewählte Objekte wieder zu entfernen.";
String flagSelectO = "Wählen Sie hier, ob Sie Bodenplatten, Wände, Innenwände, oder Dächer anklicken und bearbeiten möchten.";
//String flagSelectR = "Wenn Sie Wände nicht generieren, sondern einzeln einfügen, können Sie hier auswählen, ob Wanddrehungen nur einzelne Wände, oder die gesamte Sequenz aller weiteren angehängten Wandelemente betreffen.";
String flagSelectC = "Wählen Sie hier, ob ein Wandelement geschlossen bleibt, ein Fenster oder eine Tür eingeschnitten wird.";
String flagMnpltP  = "Wählen Sie hier, ob eine selektierte Bodenplatte längs oder quer ausgerichtet wird. Wählen Sie außerdem, ob Sie eine kleine, mittlere oder große Bodenplatte verwenden möchten.";
String flagMnpltW  = "Verwenden Sie diese Schaltflächen, um selektierte Wände zu verkleinern oder zu vergrößern. Dies entscheidet über die Breite von eingeschnittenen Fenstern oder Türen.";
String flagGenWall = "Verwenden Sie diese Schaltflächen, um automatisch Wände entlang des Außenrandes der Bodenplatten zu generieren. Sie können außerdem ausgewählte Wände teilen oder entfernen";
