//// Helping Classes without implementation
///////////////////////////////////// FLAG //////////////////////////////////////////////
class Flag {
  PVector pos;
  float myWidth;
  float myHeight;
  int delay;
  int tH;
  color bkgrd;
  String[] myLines;
  Flag(String myText) {
    pos = new PVector(0, 0, 0);
    delay = 20;
    bkgrd = color(240, 240, 240, 220);
    tH   = ceil(width/80);
    myLines = cutString(myText, round(hudG*1.5));
    myWidth = getMaxLineLength();
    myHeight = tH* myLines.length;
  }

  void display(float tX, PVector tPos) {
    noStroke();
    textAlign(LEFT, BOTTOM);
    if (delay > 0) {
      delay--;
    } else {
      float x1 = pos.x-hudG/2;
      float y1 = pos.y-hudG/2;
      float wX = myWidth+hudG*1.5;
      float wY = myHeight+hudG;
      fill(bkgrd);
      pushMatrix();
      translate(tPos.x+ tX, tPos.y, 5);
      rect(x1, y1, wX, wY);
      strokeWeight(3);
      stroke(255);
      line(x1, y1, x1, y1+wY);
      line(x1, y1, x1+wX, y1);
      stroke(180);
      line(x1+wX, y1, x1+wX, y1+wY);
      line(x1, y1+wY, x1+wX, y1+wY);
      fill(255);
      for (int i=0; i<myLines.length; i++) {
        text(myLines[i], pos.x+1, pos.y+(tH*(i+1))+1);
      }
      fill(0);
      for (int i=0; i<myLines.length; i++) {
        text(myLines[i], pos.x, pos.y+(tH*(i+1)));
      }
      popMatrix();
    }
  }

  String[] cutString(String str, int maxLength) {
    ArrayList<String> substrings = new ArrayList<String>();
    int index = 0;

    while (index < str.length()) {
      int endIndex = index + maxLength;

      if (endIndex >= str.length()) {
        endIndex = str.length();
      } else {
        endIndex = str.lastIndexOf(" ", endIndex);
        if (endIndex == -1 || endIndex <= index) {
          endIndex = index + maxLength;
        }
      }

      String substring = str.substring(index, endIndex);
      substrings.add(substring);

      index = endIndex + 1;
    }

    return substrings.toArray(new String[0]);
  }

  float getMaxLineLength() {
    float f =0;
    for (int i=0; i<myLines.length; i++) {
      if (textWidth(myLines[i]) > f) f = textWidth(myLines[i]);
    }
    return f;
  }
}

/////////////////////////////////////////////////////////////BLOCK//////////////////////////////////////////////////////////////
////////////////////////////////////////Now this is basically the level of notation for/////////////////////////////////////////
/////////////////////////////////////////reading the user´s input/writing the design////////////////////////////////////////////
///////////////////////////////////////which is to be understood literally, as some of//////////////////////////////////////////
/////////////////////////////////////////those will generate the hash for storing the///////////////////////////////////////////
/////////////////////////////////////////////////////////////data///////////////////////////////////////////////////////////////
/////////////////////// But also might be the place where the global meth or generative algorithms run//////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
ArrayList<Block> allBlocks = new ArrayList<>();

class Block {
  int index;
  String name;
  String label;
  StringList myItems;
  ArrayList<Trigger> myTriggers;
  ArrayList<Button>  myButtons;
  boolean sleep;
  boolean moveTheBlock;
  boolean onBlocked;
  boolean freeze;
  PVector pos;
  float relX, relY;
  float absX, absY;
  float tW, tH;
  float dotXdist;
  float flagWidth;
  ArrayList<PVector> myItemsPos; //positions of all associated Items relative to a Block´s position
  color baseColor, shadeColor, darkLiteColor, liteColor, fillColorOver;
  float myTint;
  Flag myFlag;

  Block(float posX, float posY, String myN, String myL ) {
    name = myN;
    label = myL;
    tH   = ceil(width/80);
    textSize(tH-1);
    tW = ceil(textWidth(label))+6;
    dotXdist = tW+tH/1.2;
    myItems = new StringList();
    pos  =    new PVector(posX, posY);
    relX = relY = 0;
    absX = absY = 0;
    flagWidth = 0;
    myItemsPos = new ArrayList<PVector>();
    moveTheBlock = false;
    onBlocked    = false;
    sleep        = false;
    changeColorScheme(60, 188, 255);
    myTint = 25;
    allBlocks.add(this);
    index = allBlocks.size();
  }

  void blockMyArea() {
    getMySize();
    addMySize();
    avoidBlockedAreas();
  }

  void wakeAndSleep() { 
    for (String str : myItems) {
      for (Button b : buttons) {
        if (b.name == str)
          b.wake= (sleep)? false:true;
      }
      for (Trigger t : triggers) {
        if (t.name == str)
          t.wake= (sleep)? false:true;
      }
      for (TwoWaySelector tws : twoWaySelectors) {
        if (tws.name == str)
          tws.wake= (sleep)? false:true;
      }
      for (FourWaySelector fws : fourWaySelectors) {
        if (fws.name == str)
          fws.wake= (sleep)? false:true;
      }
      for (Slider s : sliders) {
        if (s.name == str)
          s.wake= (sleep)? false:true;
      }
    }
  }

  void setMyItemsActive() { // only on setup and after ordering
    executeOnce = true;
    for (String str : myItems) {
      for (Button b : buttons) {
        if (b.name == str) {
          b.wake= true;
          b.shownAndActive= true;
          b.notInStandBy= true;
        }
      }
      for (Trigger t : triggers) {
        if (t.name == str) {
          t.wake= true;
          t.shownAndActive= true;
          t.notInStandBy= true;
        }
      }
      for (TwoWaySelector tws : twoWaySelectors) {
        if (tws.name == str) {
          tws.wake= true;
          tws.shownAndActive= true;
          tws.notInStandBy= true;
        }
      }
      for (FourWaySelector fws : fourWaySelectors) {
        if (fws.name == str) {
          fws.wake= true;
          fws.shownAndActive= true;
          fws.notInStandBy= true;
        }
      }
      for (Slider s : sliders) {
        if (s.name == str) {
          s.wake= true;
          s.shownAndActive= true;
          s.notInStandBy= true;
        }
      }
    }
  }

  // this just adds the Block´s position to the item´s position
  void setMyItemsPos() {
    //myItemsPos.clear();    // always start with an empty list
    for (String str : myItems) {
      for (Button b : buttons) {
        if (b.name == str)
          b.pos.add(pos);
      }
      for (Trigger t : triggers) {
        if (t.name == str)
          t.pos.add(pos);
      }
      for (TwoWaySelector tws : twoWaySelectors) {
        if (tws.name == str)
          tws.pos.add(pos);
      }
      for (FourWaySelector fws : fourWaySelectors) {
        if (fws.name == str)
          fws.pos.add(pos);
      }
      for (Slider s : sliders) {
        if (s.name == str)
          s.pos.add(pos);
      }
    }
  }

  // makes an ArrayList of PVectors where all positions of the block´s Items are stored relative to the block´s position
  void getMyItemsPos() { // only on setup and after ordering
    myItemsPos.clear();    // always start with an empty list
    for (String str : myItems) {
      // and then hope that maintaining the order of things is good enough
      for (Button b : buttons) {
        if (b.name == str)
          myItemsPos.add(new PVector(b.pos.x - pos.x, b.pos.y - pos.y));
      }
      for (Trigger t : triggers) {
        if (t.name == str)
          myItemsPos.add(new PVector(t.pos.x - pos.x, t.pos.y - pos.y));
      }
      for (TwoWaySelector tws : twoWaySelectors) {
        if (tws.name == str)
          myItemsPos.add(new PVector(tws.pos.x - pos.x, tws.pos.y - pos.y));
      }
      for (FourWaySelector fws : fourWaySelectors) {
        if (fws.name == str)
          myItemsPos.add(new PVector(fws.pos.x - pos.x, fws.pos.y - pos.y));
      }
      for (Slider s : sliders) {
        if (s.name == str)
          myItemsPos.add(new PVector(s.pos.x - pos.x, s.pos.y - pos.y));
      }
    }
  }

  // defines a rectangle that cannot be taken by any other block than this
  void getMySize() {
    float tX=pos.x;
    float tY=pos.y;
    absX = flagWidth;
    absY = 0;
    if (!sleep) {
      for (String str : myItems) {
        for (Button b : buttons) {
          if (b.name == str && b.shownAndActive && b.notInStandBy) {
            tX = (b.pos.x+b.myWidth > tX)? b.pos.x+b.myWidth : tX;
            tY = (b.pos.y+b.myHeight> tY)? b.pos.y+b.myHeight: tY;
          }
        }
        for (Trigger t : triggers) {
          if (t.name == str && t.shownAndActive && t.notInStandBy) {
            tX = (t.pos.x+t.myWidth > tX)? t.pos.x+t.myWidth : tX;
            tY = (t.pos.y+t.myHeight> tY)? t.pos.y+t.myHeight: tY;
          }
        }
        for (TwoWaySelector tws : twoWaySelectors) {
          if (tws.name == str  && tws.shownAndActive && tws.notInStandBy) {
            tX = (tws.pos.x+tws.myWidth > tX)? tws.pos.x+tws.myWidth : tX;
            tY = (tws.pos.y+tws.myHeight> tY)? tws.pos.y+tws.myHeight: tY;
          }
        }
        for (FourWaySelector fws : fourWaySelectors) {
          if (fws.name == str && fws.shownAndActive && fws.notInStandBy) {
            tX = (fws.pos.x+fws.myWidth > tX)? fws.pos.x+fws.myWidth : tX;
            tY = (fws.pos.y+fws.myHeight> tY)? fws.pos.y+fws.myHeight: tY;
          }
        }
        for (Slider s : sliders) {
          if (s.name == str && s.shownAndActive && s.notInStandBy) {
            tX = (s.pos.x+s.myWidth > tX)? s.pos.x+s.myWidth : tX;
            tY = (s.pos.y+s.myHeight> tY)? s.pos.y+s.myHeight: tY;
          }
        }
      }
    }
    absX = (tX > flagWidth)? tX : flagWidth;
    absY = tY+tH;
  }
  void addMySize() {
    absX += hudG;
    absY += hudG;
  }

  // moves this Block if another one comes too close
  void avoidBlockedAreas() {
    boolean onMinXblkd, onMaxXblkd, onMinYblkd, onMaxYblkd;
    for (Block b : allBlocks) {
      if (b!=this) {
        onMinXblkd = (pos.x < b.absX)? true:false;
        onMaxXblkd = (absX  > b.pos.x)? true:false;
        onMinYblkd = (pos.y < b.absY)? true:false;
        onMaxYblkd = (absY  > b.pos.y)? true:false;
        b.onBlocked = (onMinXblkd && onMaxXblkd && onMinYblkd && onMaxYblkd && !mousePressed)?  true:false;
      }
    }
    for (Block b : allBlocks) {
      if (b!=this) {
        if (b.onBlocked) {
          PVector dia = new PVector((absX-pos.x)+(b.absX-b.pos.x), (absY-pos.y)+(b.absY-b.pos.y));
          dia.normalize();
          PVector sit = new PVector(abs((pos.x+absX)/2-(b.pos.x+b.absX)/2), abs((pos.y+absY)/2-(b.pos.y+b.absY)/2));
          sit.normalize();
          if (dia.x/sit.x < dia.y/sit.y) {
            pos.x = (pos.x < b.pos.x)? pos.x-hudG:pos.x+hudG;
            pos.y = (pos.y > b.pos.y)? b.pos.y:pos.y;
          } else {
            //   pos.x = (pos.x > b.pos.x)? b.pos.x:pos.x;
            pos.y = (pos.y < b.pos.y)? pos.y-hudG:pos.y+hudG;
          }
        }
      }
    }
    if (pos.x < hudG) pos.x =hudG;
    if (pos.y < 2*hudG) pos.y = 2*hudG;
  }

  // moves this block´s items relative to its position
  void moveMyItems() {
    int i =0;
    for (String myI : myItems) {
      for (Button b : buttons) {
        if (myI == b.name) {
          b.pos.x = pos.x+myItemsPos.get(i).x;
          b.pos.y = pos.y+myItemsPos.get(i).y;
          i+=1;
        }
      }
      for (Trigger t : triggers) {
        if (myI == t.name) {
          t.pos.x = pos.x+myItemsPos.get(i).x;
          t.pos.y = pos.y+myItemsPos.get(i).y;
          i+=1;
        }
      }
      for (TwoWaySelector tws : twoWaySelectors) {
        if (myI == tws.name) {
          tws.pos.x = pos.x+myItemsPos.get(i).x;
          tws.pos.y = pos.y+myItemsPos.get(i).y;
          i+=1;
        }
      }
      for (FourWaySelector fws : fourWaySelectors) {
        if (myI == fws.name) {
          fws.pos.x = pos.x+myItemsPos.get(i).x;
          fws.pos.y = pos.y+myItemsPos.get(i).y;
          i+=1;
        }
      }
      for (Slider s : sliders) {
        if (myI == s.name) {
          s.pos.x = pos.x+myItemsPos.get(i).x;
          s.pos.y = pos.y+myItemsPos.get(i).y;
          i+=1;
        }
      }
    }
  }

  // to switch standBy Mode on and off
  void switchMyItems() {
    for (String myI : myItems) {
      for (Button b : buttons) {
        if (myI == b.name) {
          if (standBy())   b.notInStandBy =   (b.notInStandBy)? false:true;
        }
      }
      for (Trigger t : triggers) {
        if (myI == t.name) {
          if (standBy())   t.notInStandBy =   (t.notInStandBy)? false:true;
        }
      }
      for (TwoWaySelector tws : twoWaySelectors) {
        if (myI == tws.name) {
          if (standBy()) tws.notInStandBy = (tws.notInStandBy)? false:true;
        }
      }
      for (FourWaySelector fws : fourWaySelectors) {
        if (myI == fws.name) {
          if (standBy()) fws.notInStandBy = (fws.notInStandBy)? false:true;
        }
      }
      for (Slider s : sliders) {
        if (myI == s.name) {
          if (standBy())   s.notInStandBy =   (s.notInStandBy)? false:true;
        }
      }
    }
  }

  // tells all items on List myItems, this is the Block they belong to
  void makeFriends() {
    for (String myI : myItems) {
      for (Button b : buttons) {
        if (myI == b.name) b.myBlock = this;
      }
      for (Trigger t : triggers) {
        if (myI == t.name) t.myBlock = this;
      }
      for (TwoWaySelector tws : twoWaySelectors) {
        if (myI == tws.name) tws.myBlock = this;
      }
      for (FourWaySelector fws : fourWaySelectors) {
        if (myI == fws.name) fws.myBlock = this;
      }
      for (Slider s : sliders) {
        if (myI == s.name) s.myBlock = this;
      }
    }
  }

  //counts all shownAndActive Buttons on List myItems and aligns them in List order
  void orderMultipleButtons() {
    float f = 0;
    float w = 0;
    for (String myI : myItems) {
      for (Button b : buttons) {
        w = b.myWidth;
        if (myI == b.name && b.shownAndActive) {
          b.pos.x = pos.x+f;
          f += w;
        }
      }
    }
    getMyItemsPos();
  }

  //counts all shownAndActive Triggers on List myItems and aligns them in List order
  void orderMultipleTriggers() {
    float f = 0;
    float w = 0;
    try {
      for (String myI : myItems) {
        for (int i=0; i<triggers.size(); i++) {
          Trigger t = triggers.get(i);
          w=t.myWidth;
          if (myI == t.name && t.shownAndActive ) {
            if (i>0 ) w = (t.name != triggers.get(i-1).myPals.get(triggers.get(i-1).myPals.size()-1).name)?  t.myWidth : t.myWidth+hudG;
            t.pos.x = pos.x+f;
            f += w;
          }
        }
      }
      getMyItemsPos();
    }
    catch(Exception e) {
    }
  }

  void drawLabel() {
   //noStroke();
   // fill((mouseOverLabel())? darkLiteColor:fillColorOver);
   float x1 = 0;
   float y1 = 0;
   float x2 = tH+4;
    float y2 = -tH-3;
    pushMatrix();
    translate(pos.x, pos.y);
  //  rect(x1, y1, x2, y2);
  noFill();
    strokeWeight(2);
    stroke(185,230,250);
    beginShape();
    vertex(0,0);
    vertex(0,y2);
    vertex(x2,y2);
    endShape();
    stroke(shadeColor);
    strokeWeight(4);
    line(0, 0, absX-pos.x-hudG, 0);
    strokeWeight(2);
    stroke(liteColor);
   // line(tW+4, -tH-1, 0, -tH-3);
  //  line(0, -tH-1, 0, 0);
    textAlign(LEFT, BOTTOM);
    fill((mouseOverLabel())? baseColor:10*baseColor);
    text(label, 3, 1);
    fill((mouseOverLabel())? 200:0);
    text(label, 2, 0);
    drawStandBy();
    drawInfoDot();
    popMatrix();
  }

  void drawStandBy() {
    pushMatrix();
    translate(tH+4, -2);
    strokeWeight(2);
    stroke(( mouseOverStandBy())? shadeColor:liteColor);
    noFill();
    arc(dotXdist, -tH/2, tH, tH, PI, PI+HALF_PI);
    stroke((!mouseOverStandBy())? shadeColor:liteColor);
    arc(dotXdist, -tH/2, tH, tH, 0, HALF_PI);
    stroke(darkLiteColor);
    arc(dotXdist, -tH/2, tH, tH, HALF_PI+PI, TWO_PI);
    arc(dotXdist, -tH/2, tH, tH, HALF_PI, PI);
    noStroke();
    fill(fillColor(mouseOverStandBy()));
    circle(dotXdist, -tH/2, tH);
    noFill();
    strokeWeight(4);
    stroke((!mouseOverStandBy())? 255:0);
    circle(dotXdist, -tH/2, tH/2);
    line(dotXdist, -tH/2, dotXdist, -tH);
    strokeWeight(2);
    stroke((mouseOverStandBy())? 255:0);
    circle(dotXdist, -tH/2, tH/2);
    line(dotXdist, -tH/2, dotXdist, -tH);
    popMatrix();
    flagWidth = pos.x + tW + 1.5*tH;
  }

  void drawInfoDot() {
    pushMatrix();
    translate(0, -2);
    strokeWeight(2);
    stroke((mouseOverInfoDot())? shadeColor:liteColor);
    noFill();
    arc(dotXdist, -tH/2, tH, tH, PI, PI+HALF_PI);
    stroke((!mouseOverInfoDot())? shadeColor:liteColor);
    arc(dotXdist, -tH/2, tH, tH, 0, HALF_PI);
    stroke(darkLiteColor);
    arc(dotXdist, -tH/2, tH, tH, HALF_PI+PI, TWO_PI);
    arc(dotXdist, -tH/2, tH, tH, HALF_PI, PI);
    noStroke();
    fill(fillColor(mouseOverInfoDot()));
    circle(dotXdist, -tH/2, tH);
    noFill();
    strokeWeight(4);
    stroke((!mouseOverInfoDot())? 255:0);
    line(dotXdist, -tH/6, dotXdist, -tH/1.5);
    point(dotXdist, -tH/1.2);
    strokeWeight(2);
    stroke((mouseOverInfoDot())? 255:0);
    line(dotXdist, -tH/6-1, dotXdist, -tH/1.5+1);
    point(dotXdist, -tH/1.2);
    //circle(dotXdist, -tH/2, tH/2);
    //line(dotXdist, -tH/2, dotXdist, -tH);
    popMatrix();
    flagWidth = pos.x + tW + 1.5*tH;
  }

  void displayMyFlag() {
    if (mouseOverInfoDot()) {
      myFlag.display(dotXdist, pos);
    } else {
      myFlag.delay = 30;
    }
  }

  void moveTheBlock() {
    if (getMPos && mouseOverLabel() && mousePressed) {
      getMPos = false;
      moveTheBlock = true;
      isOverAnyHUD = true;
      relX = pos.x - mouseX;
      relY = pos.y - mouseY;
    }
    if (moveTheBlock) {
      pos.x = mouseX+relX;
      pos.y = mouseY+relY;
    }
    if (!mousePressed) moveTheBlock = false;
    moveMyItems();
  }

  boolean mouseOverLabel() {
    boolean imo = (pos.x < mouseX && mouseX < pos.x+tW && pos.y-tH < mouseY && mouseY < pos.y)? true:false;
    if (imo) isOverAnyHUD=true;
    return imo;
  }

  boolean mouseOverStandBy() {
    boolean imo = (pos.x+tW+tH+8 < mouseX && mouseX < pos.x+tW+2*(tH+4) && pos.y-tH < mouseY && mouseY < pos.y)? true:false;
    if (imo) isOverAnyHUD=true;
    return imo;
  }

  boolean mouseOverInfoDot() {
    boolean imo = (pos.x+tW < mouseX && mouseX < pos.x+tW+tH+4 && pos.y-tH < mouseY && mouseY < pos.y)? true:false;
    if (imo) isOverAnyHUD=true;
    return imo;
  }

  boolean standBy() {
    boolean imo =  (mouseOverStandBy() && executeOnce)? true:false;
    return imo;
  }

  void changeColorScheme(float newR, float newG, float newB) {
    float[] newColorScheme = new float[3];
    newColorScheme[0] = newR;
    newColorScheme[1] = newG;
    newColorScheme[2] = newB;
    float mx = max(newColorScheme);
    float myR =    map(newR, 0, mx, 0, 25.5);
    float myG =    map(newG, 0, mx, 0, 25.5);
    float myB =    map(newB, 0, mx, 0, 25.5);

    baseColor        =  color(myR, myG, myB);
    shadeColor       =  3*baseColor;
    darkLiteColor    =  6*baseColor;
    fillColorOver    =  8*baseColor;
    liteColor        = 10*baseColor;
    // transpShade      =    color(0, 0, 0, myTint*12);
  }

  color fillColor(boolean isOver) {
    color col = (isOver)? fillColorOver:darkLiteColor;
    col = (mousePressed && mouseOverStandBy())? liteColor:col;
    return col;
  }
}
