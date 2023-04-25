boolean isOverAnyHUD = false;

class HUD {
  //geometric section
  PVector pos = new PVector();
  float myWidth;
  float myHeight;
  // coords for the controller´s board
  float x1, x2, x3;
  float y1, y2, y3;

  // appeareance section
  int textHeight;
  float myR, myG, myB, myHue, myTint;
  color baseColor, pathColor, fillColorOver, fillColorPassive, fillColorPressed, liteColor, darkLiteColor, shadeColor, transpShade;
  boolean showName, showLabel;

  // operational section
  String name;          // identifyer and/or headline
  String label;         // Text on the item, linebreak with textbox: text(s, 40, 40, 280, 320);
  String[] clabel;      // Text on the item, linebreak as list items
  String iconOrLabel;   // for a boolean decision if there is an icon displaed instead of a Label
  String myIcon;
  int rePass;           // a number that can be linked to elements of the controlpanel, e.G. The tWS that knows about the plates orientation, the slider that knows the length of a wall, ....
  boolean isMouseOver;  // knows if the mouse is over a specific controller item
  boolean shownAndActive; // if an item isn´t shown, it is not supposed to work
  boolean notInStandBy;   // same for standby mode, if it isn´t shown, it is not supposed to work
  boolean wake;
  boolean keepExecuting;  // This is for items with moveable elements -> when dragging the mouse smaller items will fail. This guy keeps items executing as long as mouse is over the item´s board

  Block myBlock;

  HUD(float posX, float posY, float myW, float myH, String myN) {
    pos = new PVector (posX, posY);
    myWidth = myW;
    myHeight= myH;
    name    = myN;
    myIcon = null;
    textHeight = ceil(width/80);
    changeColorScheme(60,188,255); //actually this is supposed to be a function of return type float[], but...
    rePass  = 0; // by default, nothing is linked
    isMouseOver    = false; // by Default
    shownAndActive = false; // by Default everything is there upon setup, but is being called only on demand
    notInStandBy   = true;  // by Default
    wake           = true;  // by Default
  }

  void changeColorScheme(float newR, float newG, float newB) {
    float[] newColorScheme = new float[3];
    newColorScheme[0] = newR;
    newColorScheme[1] = newG;
    newColorScheme[2] = newB;
    float mx = max(newColorScheme);
    myR =    map(newR, 0, mx, 0, 25.5);
    myG =    map(newG, 0, mx, 0, 25.5);
    myB =    map(newB, 0, mx, 0, 25.5);
    myTint = map( 128, 0, mx, 0, 25.5);
    baseColor        =    color(myR, myG, myB);
    pathColor        =  7*color(myR, myG, myB, myTint);
    fillColorOver    =  8*baseColor;
    fillColorPassive =  6*color(myR, myG, myB, myTint*1.5);
    fillColorPressed = 10*color(myR, myG, myB, myTint);
    liteColor        = 10*baseColor;
    darkLiteColor    =  6*baseColor;
    shadeColor       =  3*color(myR, myG, myB);
    transpShade      =    color(0, 0, 0, myTint*12);
  }

  void createBoard() {
    x1 = pos.x;
    x2 = pos.x+myWidth-2*hudG;
    x3 = pos.x+myWidth;
    y1 = pos.y;
    y2 = pos.y+myHeight-2*hudG;
    y3 = pos.y+myHeight;
    // just check if the arc radius isn`t bigger than the button
    x2 = x2>=x1? x2:x1;
    y2 = y2>=y1? y2:y1;
    //showName = true; // usually there is a flag, except there is a multiple choice function indicated by a lead-label
  }

  void drawBoard() {
    createBoard();
    fill(fillColor());
    stroke(lowerStroke());
    strokeWeight(3);
    // faked light from upper left > starting outline clockwise from lower left
    line(x1, y3, x1, y1);
    line(x1, y1, x3, y1);
    stroke(upperStroke());
    line(x3, y1, x3, y2);
    arc(x2, y2, hudG*4, hudG*4, 0, HALF_PI); //should work since all coords are calculated with hudgies, if not: stroke around the shape
    line(x2, y3, x1, y3);
    // filling shape clockwise from lower left - just to be nsync
    noStroke();
    beginShape();
    vertex(x1, y3);
    vertex(x1, y1);
    vertex(x3, y1);
    vertex(x3, y2);
    vertex(x2, y2);
    vertex(x2, y3);
    vertex(x1, y3);
    endShape(CLOSE);
  }

  void rectImprintLine(float posX, float posY, float myW, float myH) { // pos = Center
    fill(shadeColor);
    pushMatrix();
    translate(posX-1, posY-1);
    beginShape();
    vertex(-myW/2, -myH/2);
    vertex( myW/2+2, -myH/2);
    vertex( myW/2+2, myH/2+2);
    vertex(-myW/2, myH/2+2);
    endShape(CLOSE);
    translate(2, 2);
    fill(darkLiteColor);
    beginShape();
    vertex(-myW/2-2, -myH/2-2);
    vertex( myW/2, -myH/2-2);
    vertex( myW/2, myH/2);
    vertex(-myW/2-2, myH/2);
    endShape(CLOSE);
    translate(-1, -1);
    fill(baseColor);
    beginShape();
    vertex(-myW/2, -myH/2);
    vertex( myW/2, -myH/2);
    vertex( myW/2, myH/2);
    vertex(-myW/2, myH/2);
    endShape(CLOSE);
    popMatrix();
  }

  // TO KEEP IN MIND:
  // The superclass HUD is supposed to contain any method and function that either
  // defines the appearance of the overall panel setup (like the color scheme) or
  // the generic functionality of control panel items

  // the easiest way for short labels, just enter the text
  String label(String theLabel) {
    return theLabel;
  }

  boolean mouseOverMe() {
    boolean imo;
    imo = (pos.x < mouseX && mouseX < pos.x+myWidth && pos.y < mouseY && mouseY < pos.y+myHeight)? true:false;
    if (imo) isOverAnyHUD=true;
    return (shownAndActive)? imo:false;
  }

  color fillColor() {
    color col = mouseOverMe()? fillColorOver:fillColorPassive;
    col = (mousePressed && mouseOverMe())? fillColorPressed:col;
    return col;
  }

  color upperStroke() {
    color col = liteColor;
    col = (mousePressed && mouseOverMe())? shadeColor:col;
    return col;
  }

  color lowerStroke() {
    color col = shadeColor;
    col = (mousePressed && mouseOverMe())? liteColor:col;
    return col;
  }

  boolean singleEvent() {
    controlEvent = (mouseOverMe() && executeOnce)? true:false;
    return controlEvent;
  }

  boolean longerEvent() {
    controlEvent = (mouseOverMe() && execution)? true:false;
    return controlEvent;
  }

  // remnant of the very beginning, sometimes useful while building a panel - does something immediately
  void check() {
    fill(fillColor());
    rect(pos.x, pos.y, myWidth, myHeight);
    if (longerEvent()) pos.x+=5;
  }
}

////////////////////////////////////BUTTON////////////////////////////////////////////
class Button extends HUD {
  boolean activated;
  boolean noActivationMode = false;
  ArrayList <Button>  myPals = new ArrayList <Button>();
  color fillC;

  Button(float posX, float posY, float myW, float myH, String myN) {
    super( posX, posY, myW, myH, myN);
    createBoard();
    activated = false;
  }



  //local singleEvent to overwrite superclass routine
  // differences: a) the button stays activated after the control event - there is a way that no button of a group is activated whatsoever, e.g.: not any object can be selected
  boolean singleEvent() {
    controlEvent = (mouseOverMe() && executeOnce)? true:false;
    boolean isActivated = activated;
    if (controlEvent && !activated) activated = true;
    if (controlEvent && isActivated && noActivationMode) activated = false;
    return controlEvent;
  }

  // local drawBoard: difference: dark-opaque if activated
  void drawBoard() {
    createBoard();
    fill((activated)? darkLiteColor:fillColor());
    stroke(lowerStroke());
    strokeWeight(3);
    // faked light from upper left > starting outline clockwise from lower left
    line(x1, y3, x1, y1);
    line(x1, y1, x3, y1);
    stroke(upperStroke());
    line(x3, y1, x3, y2);
    arc(x2, y2, hudG*4, hudG*4, 0, HALF_PI); //should work since all coords are calculated with hudgies, if not: stroke around the shape
    line(x2, y3, x1, y3);
    // filling shape clockwise from lower left - just to be nsync
    noStroke();
    beginShape();
    vertex(x1, y3);
    vertex(x1, y1);
    vertex(x3, y1);
    vertex(x3, y2);
    vertex(x2, y2);
    vertex(x2, y3);
    vertex(x1, y3);
    endShape(CLOSE);
  }

  void display() {
    if (shownAndActive && notInStandBy && wake) {
      drawBoard();
      int tW =ceil(textWidth(name))+6;
      float lx = pos.x+textHeight/2;
      float ly = (y1+y3)/2-textHeight/4;
      color c = (mouseOverMe()&&mousePressed)? 255:0;

      textAlign(LEFT, CENTER);
      textSize(textHeight-1);
      // Text by default
      if (iconOrLabel!="icon") {
        label= (label!=null)? label:"Bitte labeln";
        fill(10*baseColor);
        text(label, lx-1, ly-1);
        fill(c);
        text(label, lx, ly);
      }
      if (iconOrLabel=="icon") {
        if (myIcon != null) {
          float f = (myWidth<myHeight)? myWidth:myHeight;
          setIcon(myIcon, pos, f, baseColor);
        }
      }
      // "box" for the button´s name
      if (showName) {
        float nx1 = pos.x;
        float nx2 = pos.x+tW+2;
        float ny1 = pos.y-2;
        float ny3 = pos.y-textHeight-2;
        fill(fillColorOver);
        rect(nx1, ny3, tW+2, textHeight);
        strokeWeight(2);
        stroke(shadeColor);
        line(nx1, ny1, nx2, ny1);
        line(nx2, ny1, nx2, ny3);
        stroke(liteColor);
        line(nx2, ny3, nx1, ny3);
        line(nx1, ny3, nx1, ny1);
        fill(0);
        textAlign(LEFT, BOTTOM);
        fill(10*baseColor);
        text(name, nx1+4, pos.y+1);
        fill(0);
        text(name, nx1+3, pos.y);
      }
    }
  }
}

////////////////////////////////////TRIGGER//////////////////////////////////////////
class Trigger extends HUD {

  ArrayList <Trigger>  myPals = new ArrayList <Trigger>();

  Trigger(float posX, float posY, float myW, float myH, String myN) {
    super( posX, posY, myW, myH, myN);
    createBoard();
  }

  void display() {
    if (shownAndActive && notInStandBy && wake) {
      drawBoard();
      int tW =ceil(textWidth(name))+6;
      float lx = pos.x+textHeight/2;
      float ly = (y1+y3)/2-textHeight/4;
      color c = (mouseOverMe()&&mousePressed)? 255:0;

      textAlign(LEFT, CENTER);
      textSize(textHeight-1);
      // Text by default
      if (iconOrLabel!="icon") {
        label= (label!=null)? label:"Bitte labeln";
        fill(10*baseColor);
        text(label, lx-1, ly-1);
        fill(c);
        text(label, lx, ly);
      }
      if (iconOrLabel=="icon") {
        if (myIcon != null) {
          float f = (myWidth<myHeight)? myWidth:myHeight;
          setIcon(myIcon, pos, f, baseColor);
        }
      }
      // "box" for the button´s name
      if (showName) {
        float nx1 = pos.x;
        float nx2 = pos.x+tW+2;
        float ny1 = pos.y-2;
        float ny3 = pos.y-textHeight-2;
        fill(fillColorOver);
        rect(nx1, ny3, tW+2, textHeight);
        strokeWeight(2);
        stroke(shadeColor);
        line(nx1, ny1, nx2, ny1);
        line(nx2, ny1, nx2, ny3);
        stroke(liteColor);
        line(nx2, ny3, nx1, ny3);
        line(nx1, ny3, nx1, ny1);
        fill(0);
        textAlign(LEFT, BOTTOM);
        fill(10*baseColor);
        text(name, nx1+4, pos.y+1);
        fill(0);
        text(name, nx1+3, pos.y);
      }
    }
  }
}

////////////////////////////////2-WAY SELECTOR///////////////////////////////////////
class TwoWaySelector extends HUD {
  // we need to get the grid and grid spacing into coordinates for items
  float x1, x2;
  float y1, y2;
  // tentative knobs
  float hx1, hx2, vx1, vx2; //centers of tentative knobs
  float hy1, hy2, vy1, vy2;
  float dtk; //diameter tentative knob;
  boolean mouseOverV, mouseOverH;

  TwoWaySelector(float posX, float posY, float myW, float myH, String myN) {
    super( posX, posY, myW, myH, myN);
    x1 = posX;
    x2 = posX+myWidth;
    y1 = posY;
    y2 = posY+myHeight;
    //coords of tentative knobs
    hx1= posX+0.75*myWidth;
    hx2= posX+0.72*myWidth;
    vx1= posX+0.25*myWidth;
    vx2= posX+0.22*myWidth;
    hy1= posY+0.25*myHeight;
    hy2= posY+0.22*myHeight;
    vy1= posY+0.75*myHeight;
    vy2= posY+0.72*myHeight;
    dtk= (myWidth+myHeight)/10;
  }

  void reCalcPos() {
    x1 = pos.x;
    x2 = pos.x+myWidth;
    y1 = pos.y;
    y2 = pos.y+myHeight;
    //coords of tentative knobs
    hx1= pos.x+0.75*myWidth;
    hx2= pos.x+0.72*myWidth;
    vx1= pos.x+0.25*myWidth;
    vx2= pos.x+0.22*myWidth;
    hy1= pos.y+0.25*myHeight;
    hy2= pos.y+0.22*myHeight;
    vy1= pos.y+0.75*myHeight;
    vy2= pos.y+0.72*myHeight;
    dtk= (myWidth+myHeight)/10;
  }

  boolean mouseOverV() {
    mouseOverV = (vx1-dtk/2 < mouseX && mouseX < vx1+dtk/2 && vy1-dtk/2 < mouseY && mouseY < vy1+dtk/2)? true:false;
    return (shownAndActive && notInStandBy && wake)? mouseOverV:false;
  }

  boolean mouseOverH() {
    mouseOverH = (hx1-dtk/2 < mouseX && mouseX < hx1+dtk/2 && hy1-dtk/2 < mouseY && mouseY < hy1+dtk/2)? true:false;
    return (shownAndActive && notInStandBy && wake)? mouseOverH:false;
  }

  void display() {
    reCalcPos();
    if (shownAndActive && notInStandBy && wake) {
      fill(fillColor());
      stroke(lowerStroke());
      strokeWeight(3);
      // faked light from upper left > starting outline clockwise from lower left
      line(x1, y2, x1, y1);
      line(x1, y1, x2, y1);
      stroke(upperStroke());
      arc(x1, y1, myWidth*2, myHeight*2, 0, HALF_PI); //should work since all coords are calculated with hudgies, if not: stroke around the shape
      // directional lines
      //     stroke(fillColorPassive);
      // line(vx1, hy1, hx2, hy1);
      noStroke();
      rectImprintLine(vx1+myWidth/4, hy1, myWidth/2, 2);
      rectImprintLine(vx1, hy1+myHeight/4, 2, myHeight/2);
      //
      // tentative knob Horizontal
      color outCol = (mouseOverH())? liteColor:shadeColor;
      color inCol  = (mouseOverH())? shadeColor:liteColor;
      // if there is an active, oriented plate
      if (rePass==1) {
        noFill();
        stroke(liteColor);
        strokeWeight(2);
        circle(hx1, hy1, dtk+2);
      }
      if (rePass==2) {
        noFill();
        stroke(liteColor);
        strokeWeight(2);
        circle(vx1, vy1, dtk+2);
      }
      noStroke();
      //
      for (int i=0; i<5; i++) {
        float f = i;
        fill(lerpColor(outCol, inCol, f/4));
        float dia = lerp(dtk, dtk/3, f/4);
        PVector c = new PVector(lerp(hx1, hx2, f/4), lerp(hy1, hy2, f/4));
        circle(c.x, c.y, dia);
      }
      //
      // tentative knob vertical
      outCol = (mouseOverV())? liteColor:shadeColor;
      inCol  = (mouseOverV())? shadeColor:liteColor;
      for (int i=0; i<5; i++) {
        float f = i;
        fill(lerpColor(outCol, inCol, f/4));
        float dia = lerp(dtk, dtk/3, f/4);
        PVector c = new PVector(lerp(vx1, vx2, f/4), lerp(vy1, vy2, f/4));
        circle(c.x, c.y, dia);
      }
      //
      // filling shape clockwise from lower left - just to be nsync
      int tW =ceil(textWidth(name))+6;
      color c = (mouseOverMe()&&mousePressed)? 255:0;
      fill(c);
      textAlign(LEFT, CENTER);
      textSize(textHeight);
      // "box" for the item´s name
      if (showName) {
        float nx1 = pos.x;
        float nx2 = pos.x+tW;
        float ny1 = pos.y-2;
        float ny3 = pos.y-textHeight-2;
        fill(fillColorOver);
        rect(nx1, ny3, tW, textHeight);
        strokeWeight(2);
        stroke(shadeColor);
        line(nx1, ny1, nx2, ny1);
        line(nx2, ny1, nx2, ny3);
        stroke(liteColor);
        line(nx2, ny3, nx1, ny3);
        line(nx1, ny3, nx1, ny1);
        fill(0);
        textAlign(LEFT, BOTTOM);
        fill(10*baseColor);
        text(name, nx1+4, pos.y+1);
        fill(0);
        text(name, nx1+3, pos.y);
      }
    }
  }
}

////////////////////////////////4-WAY SELECTOR///////////////////////////////////////
class FourWaySelector extends HUD {
  // tentative knobs
  float x1R, x2R, x1L, x2L, x1M, x2M; //centers of tentative knobs
  float y1U, y2U, y1D, y2D, y1M, y2M;
  float dtk; //diameter tentative knob;
  boolean mouseOverV, mouseOverH;

  FourWaySelector(float posX, float posY, float myW, float myH, String myN) {
    super( posX, posY, myW, myH, myN);
    // apart from the standard board lower right arc is always half division of w&h
    x2 = posX+myW/2;
    y2 = posY+myW/2;
    createBoard();
    //coords of tentative knobs
    x1R= posX+0.75*myWidth;
    x2R= posX+0.72*myWidth;
    x1L= posX+0.25*myWidth;
    x2L= posX+0.22*myWidth;
    x1M= posX+0.50*myWidth;
    x2M= posX+0.47*myWidth;
    y1U= posY+0.25*myHeight;
    y2U= posY+0.22*myHeight;
    y1D= posY+0.75*myHeight;
    y2D= posY+0.72*myHeight;
    y1M= posY+0.50*myHeight;
    y2M= posY+0.47*myHeight;
    dtk= (myWidth+myHeight)/10;
  }

  void reCalcPos() {
     x2 = pos.x+myWidth/2;
    y2 = pos.y+myWidth/2;
    createBoard();
    //coords of tentative knobs
    x1R= pos.x+0.75*myWidth;
    x2R= pos.x+0.72*myWidth;
    x1L= pos.x+0.25*myWidth;
    x2L= pos.x+0.22*myWidth;
    x1M= pos.x+0.50*myWidth;
    x2M= pos.x+0.47*myWidth;
    y1U= pos.y+0.25*myHeight;
    y2U= pos.y+0.22*myHeight;
    y1D= pos.y+0.75*myHeight;
    y2D= pos.y+0.72*myHeight;
    y1M= pos.y+0.50*myHeight;
    y2M= pos.y+0.47*myHeight;
    dtk= (myWidth+myHeight)/10;
  }

  boolean mouseOverUp() {
    mouseOverV = (x1M-dtk/2 < mouseX && mouseX < x1M+dtk/2 && y1U-dtk/2 < mouseY && mouseY < y1U+dtk/2)? true:false;
    return (shownAndActive && notInStandBy && wake)? mouseOverV:false;
  }

  boolean mouseOverLo() {
    mouseOverV = (x1M-dtk/2 < mouseX && mouseX < x1M+dtk/2 && y1D-dtk/2 < mouseY && mouseY < y1D+dtk/2)? true:false;
    return (shownAndActive && notInStandBy && wake)? mouseOverV:false;
  }

  boolean mouseOverLe() {
    mouseOverH = (x1L-dtk/2 < mouseX && mouseX < x1L+dtk/2 && y1M-dtk/2 < mouseY && mouseY < y1M+dtk/2)? true:false;
    return (shownAndActive && notInStandBy && wake)? mouseOverH:false;
  }

  boolean mouseOverRi() {
    mouseOverH = (x1R-dtk/2 < mouseX && mouseX < x1R+dtk/2 && y1M-dtk/2 < mouseY && mouseY < y1M+dtk/2)? true:false;
    return (shownAndActive && notInStandBy && wake)? mouseOverH:false;
  }

  void display() {
    reCalcPos();
    // use drawboard()
    if (shownAndActive && notInStandBy && wake) {
      drawBoard();
      rectImprintLine(pos.x+myWidth/2, pos.y+myHeight/2, 2, myHeight/2);
      rectImprintLine(pos.x+myWidth/2, pos.y+myHeight/2, myWidth/2, 2);
      //
      //if repass 1 draw confirmation circle on right knob
      if (rePass==1) {
        noFill();
        stroke(liteColor);
        strokeWeight(2);
        circle(x1R, y1M, dtk+2);
      }
      //if repass 2 draw confirmation circle on upper knob
      if (rePass==2) {
        noFill();
        stroke(liteColor);
        strokeWeight(2);
        circle(x1M, y1U, dtk+2);
      }
      //if repass 3 draw confirmation circle on left knob
      if (rePass==3) {
        noFill();
        stroke(liteColor);
        strokeWeight(2);
        circle(x1L, y1M, dtk+2);
      }
      //if repass 4 draw confirmation circle on lower knob
      if (rePass==4) {
        noFill();
        stroke(liteColor);
        strokeWeight(2);
        circle(x1M, y1D, dtk+2);
      }
      //
      // draw upper tentative knob
      color outCol = (mouseOverUp())? liteColor:shadeColor;
      color inCol  = (mouseOverUp())? shadeColor:liteColor;
      noStroke();
      for (int i=0; i<5; i++) {
        float f = i;
        fill(lerpColor(outCol, inCol, f/4));
        float dia = lerp(dtk, dtk/3, f/4);
        PVector c = new PVector(lerp(x1M, x2M, f/4), lerp(y1U, y2U, f/4));
        circle(c.x, c.y, dia);
      }
      //
      // draw right tentative knob
      outCol = (mouseOverRi())? liteColor:shadeColor;
      inCol  = (mouseOverRi())? shadeColor:liteColor;
      for (int i=0; i<5; i++) {
        float f = i;
        fill(lerpColor(outCol, inCol, f/4));
        float dia = lerp(dtk, dtk/3, f/4);
        PVector c = new PVector(lerp(x1R, x2R, f/4), lerp(y1M, y2M, f/4));
        circle(c.x, c.y, dia);
      }
      //
      // draw lower tentative knob
      outCol = (mouseOverLo())? liteColor:shadeColor;
      inCol  = (mouseOverLo())? shadeColor:liteColor;
      for (int i=0; i<5; i++) {
        float f = i;
        fill(lerpColor(outCol, inCol, f/4));
        float dia = lerp(dtk, dtk/3, f/4);
        PVector c = new PVector(lerp(x1M, x2M, f/4), lerp(y1D, y2D, f/4));
        circle(c.x, c.y, dia);
      }
      //
      // draw left tentative knob
      outCol = (mouseOverLe())? liteColor:shadeColor;
      inCol  = (mouseOverLe())? shadeColor:liteColor;
      for (int i=0; i<5; i++) {
        float f = i;
        fill(lerpColor(outCol, inCol, f/4));
        float dia = lerp(dtk, dtk/3, f/4);
        PVector c = new PVector(lerp(x1L, x2L, f/4), lerp(y1M, y2M, f/4));
        circle(c.x, c.y, dia);
      }
      //
      // "box" for the item´s name
      /////////////////////////////////IF I EVER make a generic name-box, this one is most develoFped so far
      int tW =ceil(textWidth(name))+6;
      float myWi = (tW<myWidth)? myWidth:tW; // looks better if nameBox aligns with board, unless name is too long to fit in
      color c = (mouseOverMe()&&mousePressed)? 255:0;
      fill(c);
      textAlign(LEFT, CENTER);
      textSize(textHeight);

      if (showName) {
        float nx1 = pos.x;
        float nx2 = pos.x+myWi;
        float ny1 = pos.y-2;
        float ny3 = pos.y-textHeight-2;
        fill(fillColorOver);
        rect(nx1, ny3, myWi, textHeight);
        strokeWeight(2);
        stroke(shadeColor);
        line(nx1, ny1, nx2, ny1);
        line(nx2, ny1, nx2, ny3);
        stroke(liteColor);
        line(nx2, ny3, nx1, ny3);
        line(nx1, ny3, nx1, ny1);
        fill(0);
        textAlign(LEFT, BOTTOM);
        fill(10*baseColor);
        text(name, nx1+4, pos.y+1);
        fill(0);
        text(name, nx1+3, pos.y);
      }
    }
  }
}

////////////////////////////////////SLIDER//////////////////////////////////////////
class Slider extends HUD {
  float slitX1, slitX2;
  float slitY1, slitY2;
  float inSlitX, inSlitY;
  float tabX, tabY, tabDX, tabDY;
  float tabXL, tabXR, tabYup, tabYlo;
  float tabXmin, tabXmax, tabYmin, tabYmax;
  boolean XbiggerY;
  boolean isOperated;
  color slitColor, inSlitColor;
  int   ticks;  // if tickSlider, this is the number of increments
  float myMin, myMax, myVal;
  String myValOut;

  Slider(float posX, float posY, float myW, float myH, String myN) {

    super(posX, posY, myW, myH, myN);
    XbiggerY = (myW > myH);
    createBoard();
    createSlitnTab();
    isOperated=false;
    myMin = 0;
    myMax = 10;
    myVal = .5;
    myValOut = nf(myVal, 0, 2);
  }

  void setRange(float tMin, float tMax) {
    myMin = tMin;
    myMax = tMax;
  }

  void isOperated() {
    if (shownAndActive && notInStandBy && wake) {
      //single Event always works but only once per click
      if (mouseOverMe() && executeOnce) reposTab(mouseX, mouseY);

      // longer event sets a generic boolean for this one item
      if (mouseOverTab() && execution) keepExecuting = true;

      // this item keeps working now as long as mouse is over the socket, otherwise tab and mouse may lose each other while dragging
      if (keepExecuting && mouseOverMe()) reposTab(mouseX, mouseY);

      // but it stops working as soon as mouse is released or not over the item`s socket
      if (!mousePressed || !mouseOverMe()) keepExecuting = false;

      // in principle those should be functions, but maybe later
      myVal = (XbiggerY)? map(tabX, tabXmin, tabXmax, myMin, myMax):map(tabY, tabYmin, tabYmax, myMin, myMax);

      if (ticks != 0) goToTicks();
      myValOut = nf(myVal, 0, 2);
    }
  }

  // release mouse function for this subclass only
  void mouseReleased() {
    keepExecuting=false;
  }

  void goToTicks() {
    int theT= round(map(myVal, myMin, myMax, 0, ticks));
    float tVal = map(theT, 0, ticks, myMin, myMax);
    if  (XbiggerY) tabX = map(theT, 0, ticks, tabXmin, tabXmax);
    if (!XbiggerY) tabY = map(theT, 0, ticks, tabYmin, tabYmax);
    myVal = float(round(tVal*100))/100;
  }

  void setTab(float newVal) {
    if  (XbiggerY) tabX = map(newVal, myMin, myMax, tabXmin, tabXmax);
    if (!XbiggerY) tabY = map(newVal, myMin, myMax, tabYmin, tabYmax);
    tabXL = pos.x+tabX-hudG/2;
    tabXR = pos.x+tabX+hudG/2;
    tabYup= pos.y+tabY-hudG*.7;
    tabYlo= pos.y+tabY+hudG*.7;
    tabDX =  (XbiggerY)? hudG:hudG*1.4;
    tabDY = (!XbiggerY)? hudG:hudG*1.4;
  }

  boolean mouseOverTab() {
    boolean imo;
    imo = (tabXL < mouseX && mouseX < tabXR && tabYup < mouseY && mouseY < tabYlo)? true:false;
    if (imo) isOverAnyHUD=true;
    return (shownAndActive && notInStandBy && wake)? imo:false;
  }


  void display() {
    if (shownAndActive && notInStandBy && wake) {
      drawBoard(); // @superclass: boards/sockets are pretty common among those control items
      drawTicks();
      drawSlit();  // @here below: only the slider has a slit

      // Tab definition
      color inCol  = (mouseOverTab())? slitColor:liteColor;
      color outCol = (mouseOverTab())? liteColor:slitColor;
      pushMatrix();
      translate(pos.x, pos.y);
      fill(transpShade);
      float tX = (XbiggerY)? tabX+3:tabX;  //shadow changes direction which is not cool, but otherwise tab seem tilted
      float tY = (XbiggerY)? tabY:tabY+3;  // might correct this with rotate, but somehow that is just too round for my angular mind
      ellipse(tX, tY, tabDX, tabDY);
      for (int i=0; i<8; i++) {
        float f = i;
        fill(lerpColor(outCol, inCol, f/7));
        float diaX = lerp(tabDX, tabDX/4, f/7);
        float diaY = lerp(tabDY, tabDY/4, f/7);
        float ctrX = lerp(tabX, tabX-tabDX/6, f/7);
        float ctrY = lerp(tabY, tabY-tabDY/6, f/7);
        //  PVector c = new PVector(lerp(hx1, hx2, f/4), lerp(hy1, hy2, f/4));
        ellipse(ctrX, ctrY, diaX, diaY);
      }
      popMatrix();

      //NameBox & ValueDisplay -> namebox could also go to superclass, one day
      // but this one is different because of the value display
      String valDisp = myValOut+"m ";
      float nx1, nx2, ny1, ny2;
      if (keepExecuting) {
        if (XbiggerY){
        nx1 = mouseX;
        nx2 = mouseX+textWidth(valDisp)+8;;
        ny1 = pos.y+hudG-2;
        ny2 = pos.y+hudG-textHeight-2;
      } else {
        nx2 = pos.x;
        nx1 = pos.x-textWidth(valDisp)-8;       
        ny1 = mouseY;
        ny2 = mouseY-hudG;
      }
      noStroke();
      fill(8*baseColor);
      rect(nx1, ny1, nx2-nx1, ny2-ny1);
      strokeWeight(2);
      stroke(shadeColor);
      line(nx1, ny1, nx2, ny1);
      line(nx2, ny1, nx2, ny2);
      stroke(liteColor);
      line(nx2, ny2, nx1, ny2);
      line(nx1, ny2, nx1, ny1);
     
        textAlign(RIGHT, BOTTOM);
        fill(10*baseColor);
        text(valDisp, nx2-4, ny1+2);
        fill(0);
        text(valDisp, nx2-3, ny1+1);
      //} else {

      //  textAlign(LEFT, BOTTOM);
      //  fill(10*baseColor);
      //  text(valDisp, nx1+5, ny1+3);
      //  fill(0);
      //  text(valDisp, nx1+4, ny1+2);
      }
    }
  }

  color inSlitColor() {
    return inSlitColor = (keepExecuting && mousePressed)? 6*baseColor:2*baseColor;
  }

  void createSlitnTab() {
    slitX1 = (XbiggerY)? hudG*.75: hudG-4;
    slitX2 = (XbiggerY)? myWidth-hudG*1.25: hudG+4;
    slitY1 = (XbiggerY)? hudG-4:hudG*.75;
    slitY2 = (XbiggerY)? hudG+4:myHeight-hudG*1.25;
    inSlitX= slitX1+3;
    inSlitY= slitY1+3;

    // constants for tab;
    tabXmin = slitX1+2;
    tabXmax = slitX2-2;
    tabYmin = slitY2-2;
    tabYmax = slitY1+2;

    // Variables, to give them an initial value
    tabX  = (XbiggerY)? tabXmin:hudG; // -1 is a correctional thing because of the shadow
    tabY  = (!XbiggerY)? tabYmin:hudG;

    tabXL = pos.x+tabX-hudG/2;
    tabXR = pos.x+tabX+hudG/2;
    tabYup= pos.y+tabY-hudG*.7;
    tabYlo= pos.y+tabY+hudG*.7;
    tabDX =  (XbiggerY)? hudG:hudG*1.4;
    tabDY = (!XbiggerY)? hudG:hudG*1.4;

    slitColor = baseColor*4;
    inSlitColor = baseColor*2;
  }


  void reposTab(float newX, float newY) {
    // Variables, to give them an initial value
    float tabXold=tabX;
    float tabYold=tabY;
    tabX  = (XbiggerY)? newX-pos.x:hudG;
    tabY  = (!XbiggerY)? newY-pos.y:hudG;
    tabX = (!XbiggerY)? tabXold:(tabX<tabXmin)? tabXmin:(tabX>tabXmax)? tabXmax:tabX;
    tabY = (XbiggerY)? tabYold:(tabY>tabYmin)? tabYmin:(tabY<tabYmax)? tabYmax:tabY;
    tabXL = pos.x+tabX-hudG/2;
    tabXR = pos.x+tabX+hudG/2;
    tabYup= pos.y+tabY-hudG*.7;
    tabYlo= pos.y+tabY+hudG*.7;
    tabDX =  (XbiggerY)? hudG:hudG*1.4;
    tabDY = (!XbiggerY)? hudG:hudG*1.4;
    justaNewWall = false;
  }

  void drawTicks() {
    if (ticks>0) {
      noStroke();
      // supposed to be a function:
      float[] marX = new float[ticks+1];
      float marXA = (XbiggerY)? tabXmin-1:tabYmin-1; //is tabYmin up or down???
      float marXZ = (XbiggerY)? tabXmax-1:tabYmax-1; //is tabYmax up or down???
      for (int i=0; i<marX.length; i++) {
        float f = i;
        marX[i] = lerp(marXA, marXZ, f/ticks);
      }
      pushMatrix();
      translate(pos.x-1, pos.y-1);
      fill(shadeColor);
      for (int i=0; i<marX.length; i++) {
        beginShape();
        if (XbiggerY) {
          vertex(marX[i], tabY-hudG/2);
          vertex(marX[i]+4, tabY-hudG/2);
          vertex(marX[i]+4, tabY+hudG/2);
          vertex(marX[i], tabY+hudG/2);
        } else {
          vertex(tabX-hudG/2, marX[i]);
          vertex(tabX+hudG/2, marX[i]);
          vertex(tabX+hudG/2, marX[i]+4);
          vertex(tabX-hudG/2, marX[i]+4);
        }
        endShape(CLOSE);
      }
      translate(2, 2);
      fill(darkLiteColor);
      for (int i=0; i<marX.length; i++) {
        beginShape();
        if (XbiggerY) {
          vertex(marX[i]-2, tabY-hudG/2);
          vertex(marX[i]+2, tabY-hudG/2);
          vertex(marX[i]+2, tabY+hudG/2);
          vertex(marX[i]-2, tabY+hudG/2);
        } else {
          vertex(tabX-hudG/2, marX[i]-2);
          vertex(tabX+hudG/2, marX[i]-2);
          vertex(tabX+hudG/2, marX[i]+2);
          vertex(tabX-hudG/2, marX[i]+2);
        }
        endShape(CLOSE);
      }
      translate(-1, -1);
      fill(baseColor);
      for (int i=0; i<marX.length; i++) {
        beginShape();
        if (XbiggerY) {
          vertex(marX[i], tabY-hudG/2);
          vertex(marX[i]+2, tabY-hudG/2);
          vertex(marX[i]+2, tabY+hudG/2);
          vertex(marX[i], tabY+hudG/2);
        } else {
          vertex(tabX-hudG/2, marX[i]);
          vertex(tabX+hudG/2, marX[i]);
          vertex(tabX+hudG/2, marX[i]+2);
          vertex(tabX-hudG/2, marX[i]+2);
        }
        endShape(CLOSE);
      }
      popMatrix();
    }
  }

  void drawSlit() {
    pushMatrix();
    translate(pos.x, pos.y);
    fill(slitColor);
    rect(slitX1, slitY1, slitX2-slitX1, slitY2-slitY1);
    fill(inSlitColor());
    beginShape();
    vertex(slitX1, slitY1);
    vertex(slitX2, slitY1);
    vertex(slitX2, inSlitY);
    vertex(inSlitX, inSlitY);
    vertex(inSlitX, slitY2);
    vertex(slitX1, slitY2);
    endShape(CLOSE);
    popMatrix();
  }
}
