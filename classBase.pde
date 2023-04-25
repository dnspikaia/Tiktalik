// basic Class for any box-shaped instance on the field
ArrayList<Base> bases = new ArrayList<Base>();

class Base {
  PVector pos = new PVector();
  // HALF_PI and its multiples are built-in float constants
  float rotation;
  // using Integers here since it does not seem appropriate to plan with fractions of millimeters
  float b, h, d;                     // breadth, height, depth in cm
  int gs;                          // grid spacing
  int gb, gh, gd;                  // breadth, height, depth in steps of the grid

  // operating variables
  int index;                       // identifyer for calling objects without loop
  int myStrokeWeight;              // Stroke weight may change e. g. as indicator for o-snap
  int myStrokeColor;               // Stroke color may change e. g. as indicator for selected items
  boolean isActive         = false;
  boolean selectionDefault = true; // pre-defined behaviour for o-snap & selected items
  boolean isMouseOver      = false;// pre-defined behaviour for o-snap

  // rendering parameters
  color frontC, backC, leftC, rightC, upsideC, downSideC;
  color facade, interior, leftSide, riteSide, sillIn, doorJamb, floor, metal;

  float myOrientation;             // beyond rotation there may be orientation e.g. for orienting textures
  // PImage outside;

  Base(float px, float py, float pz, float sx, float sy, float sz, int gz) {
    pos.x = px;
    pos.y = py;
    pos.z = pz;
    gs = gz;
    b = round(sx*gz);
    h = round(sy*gz);
    d = round(sz*gz);
    // Default settings for default Colors:
    getFillings();
    myOrientation = 0;
    myStrokeWeight=2;
    // outside = loadImage("https://thumbs.dreamstime.com/b/old-dried-wood-background-natural-dry-wooden-texture-vintage-high-resolution-132318551.jpg");
  }
  void getFillings() {
    frontC   = color(128);
    backC    = color(128);
    leftC    = color(128);
    rightC   = color(128);
    upsideC  = color(128);
    downSideC= color(128);
    facade   = color(108);
    interior = color(228);
    leftSide = riteSide = color(28);
    sillIn   = color(220, 180, 140);
    doorJamb = color(220, 180, 140);
    floor    = color(220, 180, 140);
    metal    = color(170, 190, 200);
  }

  float gridToMeasure(int gridSteps) {
    float measure = gridSteps * gs;
    return measure;
  }
}
