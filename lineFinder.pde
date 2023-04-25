// for more plates: delete double and quadruple corners
// to prevent killin first point/switch 1st and 2nd plate, when second plate point 2 equals first plate starting point

ArrayList<PVector> firstPlate = new ArrayList<>();
ArrayList<PVector> secondPlate= new ArrayList<>();

// lines as they come
ArrayList<Line> inputLines = new ArrayList<>();
ArrayList<Line> directedLines = new ArrayList<>();
// lines to be stored during the process
ArrayList<Line> tempLines= new ArrayList<>();
// line when they are done
ArrayList<Line> orderedLines = new ArrayList<>();
ArrayList<Line> outerLines= new ArrayList<>();
ArrayList<Line> finalLines= new ArrayList<>();
ArrayList<Line> outputLines= new ArrayList<>();

int cDelay;
int cDelFix;

boolean imaVirgin = true;

PVector startingPoint;
ArrayList<PVector> corners;

void findInputLines() {
  switchPlatesIfNecessary(); // @ messyObjStuff
  if (inputLines.size()==0) {
    if (plates.size()>0) {
      for (Plate p : plates) {
        PVector p1 = new PVector(p.pos.x-p.b/2, p.pos.y-p.h/2, p.pos.z+p.d/2);
        PVector p2 = new PVector(p.pos.x+p.b/2, p.pos.y-p.h/2, p.pos.z+p.d/2);
        PVector p3 = new PVector(p.pos.x+p.b/2, p.pos.y-p.h/2, p.pos.z-p.d/2);
        PVector p4 = new PVector(p.pos.x-p.b/2, p.pos.y-p.h/2, p.pos.z-p.d/2);
        inputLines.add(new Line (p1, p2));
        inputLines.add(new Line (p2, p3));
        inputLines.add(new Line (p3, p4));
        inputLines.add(new Line (p4, p1));
      }
      //starting point fails if second plate shares it : possible way out: switch plates
      startingPoint = new PVector(inputLines.get(0).start.x, inputLines.get(0).start.y, inputLines.get(0).start.z);
      for (Line l : inputLines) {
        l.checkOrientation();
      }
      setDirection(inputLines);
      eraseInnerLines(directedLines);
    }
  }
}

void reOrganiseLines() {
  orderLines(tempLines);
  redirectLines(orderedLines);
}

void cleanLines() {
  cleanUpTheMess(orderedLines);
  reverseLines(orderedLines);
}

void shiftLines() {
  shiftInwards(outerLines);
}

void cutLines() {
  reConnect(finalLines);
  chopSuey(finalLines);
  getCornerPoints(outputLines);
}

////////////////////////////////////CLASS DEFINITIONS///////////////////////////////////////////////
class Line {
  int index;
  PVector start = new PVector();
  PVector end = new PVector();
  boolean isTaken;
  boolean horizontal, vertical;
  boolean startIsCorner;
  boolean gottaTurn;
  boolean toBeReversed;
  boolean shifted;
  boolean chopped;

  Line(PVector s, PVector e) {

    start = s;
    end = e;
    isTaken = false;
    horizontal = false;
    vertical = false;
    startIsCorner = false;
    isTaken = false;
    gottaTurn = false;
    toBeReversed = false;
    shifted = false;
    chopped = false;
  }

  //  Helper Method to show the direction of Lines
  void checkDir() {
    checkOrientation();
    if (horizontal) {
      float p1 = (start.x*9.5+end.x*10.5)/20;
      float p2 = (start.x*10.5+end.x*9.5)/20;
      line(p1, start.y, start.z, p2, start.y, start.z-20);
    }
    if (vertical) {
      float p1 = (start.z*9.5+end.z*10.5)/20;
      float p2 = (start.z*10.5+end.z*9.5)/20;
      line(start.x, start.y, p1, start.x-20, start.y, p2);
    }
  }

  void checkOrientation() {
    if (start.z == end.z) horizontal = true;
    if (start.x == end.x) vertical = true;
  }

  float myDir() {
    PVector dir = new PVector(end.x-start.x, end.y-start.y, end.z-start.z);
    dir.normalize();
    float md = 0;
    if (dir.x == 1 && dir.z == 0) {
      md = 0;
    } else if (dir.x == 0 && dir.z ==-1) {
      md = HALF_PI;
    } else if (dir.x ==-1 && dir.z == 0) {
      md = PI;
    } else if (dir.x == 0 && dir.z == 1) {
      md = HALF_PI+PI;
    }
    return md;
  }
}

////////////////////////Methods//////////////////////////////////

//int count;
//boolean turned = false;

void setDirection(ArrayList<Line> ipL) {
  for (Line l : ipL) {
    if (l.horizontal) {
      float sX = l.start.x;
      float eX = l.end.x;
      if (sX > eX) {
        PVector newStart = new PVector(l.end.x, l.end.y, l.end.z);
        PVector newEnd = new PVector(l.start.x, l.start.y, l.start.z);
        directedLines.add(new Line(newStart, newEnd));
      } else {
        directedLines.add(new Line(l.start, l.end));
      }
    }
    if (l.vertical) {
      float sZ = l.start.z;
      float eZ = l.end.z;
      if (sZ > eZ) {
        PVector newStart = new PVector(l.end.x, l.end.y, l.end.z);
        PVector newEnd = new PVector(l.start.x, l.start.y, l.start.z);
        directedLines.add(new Line(newStart, newEnd));
      } else {
        directedLines.add(new Line(l.start, l.end));
      }
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////
///adds too many lines
int hor = 0;
int ver = 0;
void eraseInnerLines(ArrayList<Line> inLines) {

  if (imaVirgin) {
    for (Line l : inLines) l.checkOrientation();
    for (Line l1 : inLines) {
      for (Line l2 : inLines) {
        if ((l1.horizontal && l2.horizontal) && l1 != l2) {

          if ( l1.end.z == l2.end.z) {
            if (abs(l1.end.x-l2.start.x) < abs(l1.start.x-l2.end.x)) {
              if (l1.end.x > l2.start.x) {
                l1.isTaken = true;
                l2.isTaken = true;
                PVector l2start = new PVector(l1.end.x, l1.start.y, l1.start.z);
                PVector l1end = new PVector(l2.start.x, l2.end.y, l2.end.z);
                tempLines.add (new Line(l1.start, l1end));//removed: if (!l2.start.equals(l2.end))
                tempLines.add (new Line(l2start, l2.end));//         if (!l2.start.equals(l2.end))
              }
            }

            if ((l1.start.x+l1.end.x)/2 == (l2.start.x+l2.end.x)/2 && hor ==0) {
              hor++;
              l1.isTaken = true;
              l2.isTaken = true;
              tempLines.add(new Line(l1.start, l2.start));
              tempLines.add(new Line(l1.end, l2.end));
            }
          }
        }
        if ((l1.vertical && l2.vertical) && l1 != l2) {
          if ( l1.end.x == l2.end.x) {
            if (abs(l1.end.z-l2.start.z) < abs(l1.start.z-l2.end.z)) {
              if (l1.end.z > l2.start.z) {
                l1.isTaken = true;
                l2.isTaken = true;
                PVector l2start = new PVector(l1.start.x, l1.start.y, l1.end.z);
                PVector l1end = new PVector(l2.end.x, l2.end.y, l2.start.z);
                if (!l1.start.equals(l1.end)) tempLines.add (new Line(l1.start, l1end));
                if (!l2.start.equals(l2.end)) tempLines.add (new Line(l2start, l2.end));
              }
            }
            if ((l1.start.z+l1.end.z)/2 == (l2.start.z+l2.end.z)/2 && ver ==0) {
              ver++;
              l1.isTaken = true;
              l2.isTaken = true;
              tempLines.add(new Line(l1.start, l2.start));
              tempLines.add(new Line(l1.end, l2.end));
            }
          }
        }
      }
    }
    for (Line l : inLines) if (!l.isTaken) tempLines.add(l);
    imaVirgin = false;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
////kills Lines on mirrored L
void orderLines(ArrayList<Line> unorderedLines) {
  Line firstLine = null;
  Line currentLine = null;
  for (Line line : unorderedLines) {
    line.checkOrientation();
    if (!line.isTaken && (line.start.equals(startingPoint)  || line.end.equals(startingPoint)) && line.horizontal) {
      firstLine = line;
      firstLine.isTaken = true;
      currentLine = firstLine;
      orderedLines.add(firstLine);
    }
  }
  while (orderedLines.size()<unorderedLines.size()) {
    if (orderedLines.size()>0) {
      currentLine = orderedLines.get(orderedLines.size()-1);
      for (Line l : unorderedLines) {
        if (!l.isTaken) {
          if (l.start.equals(currentLine.start) || l.start.equals(currentLine.end) || l.end.equals(currentLine.start) || l.end.equals(currentLine.end)) {
            l.isTaken = true;
            currentLine = l;
            orderedLines.add(l);
          }
        }
      }
    }
    break;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

boolean turned = false;
void redirectLines(ArrayList<Line> oL) {
  for (int dc=0; dc<oL.size(); dc++) {
    Line currentLine = null;
    Line previousLine = null;
    if (!turned) {
      if (oL.get(0).start.equals(oL.get(1).start) || oL.get(0).start.equals(oL.get(1).end)) {
        PVector newStart = oL.get(0).end;
        PVector newEnd = oL.get(0).start;
        oL.get(0).start=newStart;
        oL.get(0).end=newEnd;
        oL.get(0).gottaTurn=false;
      }
      boolean allturned = false;
      while (!allturned) {
        //   boolean gottaturn = false;
        for (Line l : oL) {
          for (int i=1; i<oL.size(); i++) {
            previousLine = oL.get(i-1);
            currentLine = oL.get(i);
            if (currentLine.end.equals(previousLine.end)) {
              PVector newStart = currentLine.end;
              PVector newEnd = currentLine.start;
              currentLine.start=newStart;
              currentLine.end=newEnd;
              currentLine.gottaTurn = false;
            }
          }
          for (Line l1 : oL) {
            for (Line l2 : oL) {
              if (l1.end.equals(l2.end) || l1.start.equals(l2.start)) l2.gottaTurn = true;
            }
          }
        }
        boolean gottaturn = false;
        for (Line l : oL) if (l.gottaTurn) gottaturn=true;
        allturned = (gottaturn)? false:true;
        break;
      }
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
void cleanUpTheMess(ArrayList<Line> mL) {
  try { // if there is something wrong with cDelay, this is where it fails . The problem is solved, but it seems a good idea to have a failsafe here
    for (Line l : mL) {
      l.checkOrientation();
      if ((l.horizontal && l.vertical) || (!l.horizontal && !l.vertical)) mL.remove(l);
    }
  }
  catch (Exception e) {
    println("cleaning is a mess");
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

void reverseLines(ArrayList<Line> mL) {
  try {
    for (Line tL : mL) {
      if (mL.get(0).start.x > mL.get(0).end.x) tL.toBeReversed=true;
    }
    if ( mL.get(0).toBeReversed) {

      ArrayList<Line> revL = new ArrayList<>();
      while (!mL.get(mL.size()-1).end.equals(startingPoint)) {
        if (mL.get(0).toBeReversed) revL.add(mL.get(0));
        for (int i=1; i<mL.size(); i++) {
          revL.add(mL.get(mL.size()-i));
        }
        for (Line l : revL) {
          PVector newStart = l.end;
          PVector newEnd = l.start;
          l.start=newStart;
          l.end=newEnd;
        }
        outerLines = revL;
        break;
      }
    } else {
      outerLines = mL;
    }
  }
  catch(Exception e) {
  }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
boolean shift = true;
void shiftInwards(ArrayList<Line> opL) {
  if (shift) {
    shift = false;
    for (Line l : opL) {
      if (!l.shifted) {
        PVector myDir = new PVector(0, 0, 0);
        myDir.set(l.end);
        myDir.sub(l.start);
        myDir.normalize();
        int lx=round(myDir.x);
        int lz=round(myDir.z);
        if  (lx== 1 && lz== 0) {
          myDir.set( 0, 0, -gridSpacing/4);
        } else if  (lx== 0 && lz==-1) {
          myDir.set(-gridSpacing/4, 0, 0);
        } else if (lx==-1 && lz== 0) {
          myDir.set( 0, 0, gridSpacing/4);
        } else if (lx== 0 && lz== 1) {
          myDir.set( gridSpacing/4, 0, 0);
        }
        l.start.add(myDir);
        l.end.add(myDir);
        l.shifted = true;
      }
    }
    for (Line l : opL) {
      finalLines.add(new Line(l.start, l.end));
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
boolean reCon = true;
void reConnect(ArrayList<Line> opL) {
  if (reCon) {
    reCon = false;
    for ( Line l : opL) l.checkOrientation();
    for (int i=0; i<opL.size(); i++) {
      Line prevLine = (i==0)? opL.get(opL.size()-1):opL.get(i-1);
      Line currLine = opL.get(i);
      Line nextLine = (i==opL.size()-1)?opL.get(0):opL.get(i+1);
      if (currLine.horizontal && prevLine.vertical) currLine.start.x = prevLine.end.x;
      if (currLine.horizontal && nextLine.vertical) currLine.end.x = nextLine.start.x;
      if (currLine.vertical && prevLine.horizontal) currLine.start.z = prevLine.end.z;
      if (currLine.vertical && nextLine.horizontal) currLine.end.z = nextLine.start.z;
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

boolean cut = true;
void chopSuey(ArrayList<Line> opL) {
  for (Line l : opL) {
    l.checkOrientation();
  }
  if (cut) {
    cut = false;
    for (Line l : opL) {

      if (!l.chopped) {
        PVector v = new PVector(0, 0, 0);
        v.set(l.end);
        v.sub(l.start);
        float lLength = v.mag();
        if (lLength == gridSpacing) {
          l.chopped=true;
          outputLines.add (new Line(l.start, l.end));
        } else if ( lLength > gridSpacing && lLength <= 5*gridSpacing) {
          l.chopped = true;
          PVector p = new PVector((l.start.x+l.end.x)/2, (l.start.y+l.end.y)/2, (l.start.z+l.end.z)/2);
          outputLines.add (new Line(l.start, p));
          outputLines.add (new Line(p, l.end));
        } else if ( lLength > 5*gridSpacing) {
          l.chopped = true;
          PVector pS1 = new PVector(l.start.x, l.start.y, l.start.z);
          PVector pS2 = new PVector(l.end.x-l.start.x, l.end.y-l.start.y, l.end.z-l.start.z);
          PVector pWalk = new PVector(pS2.x, pS2.y, pS2.z);
          PVector pE1 = new PVector(l.end.x, l.end.y, l.end.z);
          PVector pE2 = new PVector(l.start.x-l.end.x, l.start.y-l.end.y, l.start.z-l.end.z);

          pS2.normalize();
          pS2.mult(2.5*gridSpacing);
          pS2.add(l.start);
          pWalk.normalize();
          pE2.normalize();
          pE2.mult(2.5*gridSpacing);
          pE2.add(l.end);

          outputLines.add (new Line(pS1, pS2));

          int cuts = ceil(PVector.dist(pS2, pE2)/(4*gridSpacing));
          for (int i=0; i<cuts; i++) {
            if (cuts == 1) {
              outputLines.add (new Line(pS2, pE2));
            } else {
              float maxD = PVector.dist(pS2, pE2);
              float sN = 4*gridSpacing*i;
              float eN = 4*gridSpacing*(i+1);

              PVector pSP = new PVector(0, 0, 0);//;pWalk.mult(sN);
              PVector pEP = new PVector(0, 0, 0);//pWalk.mult(eN);
              pSP.set(pWalk);
              pEP.set(pWalk);
              pSP.mult(sN);
              pEP.mult(eN);

              if (pEP.mag() < maxD) {
                pSP.add(pS2);
                pEP.add(pS2);
                outputLines.add (new Line(pSP, pEP));
              } else {
                pSP.add(pS2);
                outputLines.add (new Line(pSP, pE2));
              }
            }
          }

          outputLines.add (new Line(pE2, pE1));
        }
      }
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

boolean getCorners = true;
void getCornerPoints(ArrayList<Line> opL) {
  if (getCorners) {
    getCorners = false;
    for (int i=0; i<opL.size(); i++) {
      Line prevLine = (i==0)? opL.get(opL.size()-1):opL.get(i-1);
      Line currLine = opL.get(i);
      currLine.checkOrientation();
      currLine.startIsCorner = ((prevLine.horizontal && currLine.horizontal) || (prevLine.vertical && currLine.vertical))? false:true;
    }
    makegWalls = true;
  }
}
