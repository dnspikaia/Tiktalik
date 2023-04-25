Block   exist;
Block selectO;
//Block selectR;
Block selectC;
Block  mnpltP;
Block  mnpltW;
Block  genWall;

Block newBlockTo(String myN, String[] myI, String myL, float myX, float myY) {
  Block b = new Block(myX, myY, myN, myL);
  for (int i=0; i<myI.length; i++) {
    b.myItems.append(myI[i]);
  }
  b.getMyItemsPos();
  return b;
}

void setUpBlox() {
  //Geometric Operations
  String [] instances = {"pldz", "plwg", "iwldz", "iwlwg", "rfdz", "rfwg"};
  exist  = newBlockTo("generate", instances, " hin und weg ", hudXs[2], hudYs[2]); // to spare the label of triggers, they need to become icon-Triggers
  exist.setMyItemsPos();
  exist.myFlag = new Flag(flagExist);
  String [] types = {"plates", "walls", "inners", "roofs"};
  selectO = newBlockTo("select", types, "Objektauswahl", hudXs[24], hudYs[2]);
  selectO.setMyItemsPos();
  selectO.myFlag = new Flag(flagSelectO);
 // String [] modes = {"einzeln", "sequenz"};
 // selectR = newBlockTo("chose", modes, "Drehungsmodi", hudXs[27], hudYs[6]);
 // selectR.setMyItemsPos();
 // selectR.myFlag = new Flag(flagSelectR);
  String [] open = {"G", "F", "T"};
  selectC = newBlockTo("cut", open, "Öffnungen", hudXs[19], hudYs[6]);
  selectC.setMyItemsPos();
  selectC.myFlag = new Flag(flagSelectC);
  String [] size = {"S", "M", "L", "Ausrichtung"};
  mnpltP  = newBlockTo("set", size, "Plattenart", hudXs[2], hudYs[6]);
  mnpltP.setMyItemsPos();
  mnpltP.myFlag = new Flag(flagMnpltP);
  String [] measures = { "Breite", "Höhe", "Drehung "};
  mnpltW  = newBlockTo("define", measures, "Wandmaße", hudXs[11], hudYs[6]);
  mnpltW.setMyItemsPos();
  mnpltW.myFlag = new Flag(flagMnpltW);
  // logical Operations
  // generate Walls
  String [] gWalls = {"addgWalls", "delgWalls", "wldz", "wlwg"};
  genWall  = newBlockTo("generate", gWalls, "Autom. Wände", hudXs[14], hudYs[2]);
  genWall.setMyItemsPos();
  genWall.myFlag = new Flag(flagGenWall);
  //generate facade
  // generate roof topping
}

void blockOps() {
  runThrough(  exist);
  runThrough(selectO);
 // runThrough(selectR);
  runThrough(selectC);
  runThrough( mnpltP);
  runThrough( mnpltW);
  runThrough(genWall);
}

void renderBlocks() {
  renderBlock(  exist);
  renderBlock(selectO);
 // renderBlock(selectR);
  renderBlock(selectC);
  renderBlock( mnpltP);
  renderBlock( mnpltW);
  renderBlock(genWall);
  displayInfoFlags();
  makeMov(makeMov);                      //@ globalMeth
}

void runThrough(Block b) {
  b.switchMyItems();
  b.orderMultipleButtons();
  b.orderMultipleTriggers();
  b.blockMyArea();
  b.moveTheBlock();
  b.wakeAndSleep();
  checkAvailability();
}

void displayInfoFlags() {
  hint(ENABLE_DEPTH_TEST);
  exist.displayMyFlag();
  selectO.displayMyFlag();
 //selectR.displayMyFlag();
  selectC.displayMyFlag();
  mnpltP.displayMyFlag();
  mnpltW.displayMyFlag();
  genWall.displayMyFlag();
  hint(DISABLE_DEPTH_TEST);
}

void renderBlock(Block b) {
  b.drawLabel();
}

void checkAvailability() {
  if (snapOnPlates) {
    exist.sleep  =false;    //generating instances, always false
    selectO.sleep=false;  //object class selection, always false
   // selectR.sleep= true;   //rotation mode of walls and inner walls
    selectC.sleep= true; //cuts of walls
    mnpltP.sleep =false;   //orientation of plates
    mnpltW.sleep = true;    //rotation and width of walls
  }
  if (snapOnWalls) {
    exist.sleep  =false;    //generating instances, always false
    selectO.sleep=false;  //object class selection, always false
  //  selectR.sleep=false;   //rotation mode of walls and inner walls
    selectC.sleep=false; //cuts of walls
    mnpltP.sleep = true;   //orientation of plates
    mnpltW.sleep =false;    //rotation and width of walls
  }
  if (snapOnInners) {
    exist.sleep  =false;    //generating instances, always false
    selectO.sleep=false;  //object class selection, always false
  // selectR.sleep=false;   //rotation mode of walls and inner walls
    selectC.sleep=false; //cuts of walls
    mnpltP.sleep = true;   //orientation of plates
    mnpltW.sleep =false;    //rotation and width of walls
  }
  if (snapOnRoofs) {
    exist.sleep  =false;    //generating instances, always false
    selectO.sleep=false;  //object class selection, always false
   // selectR.sleep= true;   //rotation mode of walls and inner walls
    selectC.sleep= true; //cuts of walls
    mnpltP.sleep = true;   //orientation of plates
    mnpltW.sleep = true;    //rotation and width of walls
  }
}
