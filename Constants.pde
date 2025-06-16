// ───────── Debug switch ─────────
final boolean debug = true;        // set false to hide all debug visuals



final float OUTER_DIAMETER    = 200;
final float INNER_DIAMETER    = 140;
final float ARC_SPAN_DEG      =  40;

final float LEAD_SEC         =   1.7;   // how early notes spawn
final float HIT_WINDOW       = .1;  // ± seconds for OK hit
final float HIT_WINDOW_PERF = .08f;
final float HIT_WINDOW_GOOD = .14f;
final int   LANES            =   8;


final float SPECIAL_EARLY_WINDOW = HIT_WINDOW * 0.50;   // tighter early
final float SPECIAL_LATE_WINDOW  = HIT_WINDOW * 1.50;   // looser late


final float NOTE_DIAMETER   = 250;

final float WAVE_START_RADIUS = max(width, height) * .9; // off-screen
final int   WAVE_STROKE       = 0xFF0096FF;              // blue #0096FF

final float JUDGE_RADIUS     =  150;   // main judgement ring
final float SPECIAL_RADIUS   = 300;   // where special notes land


// ───────── UI theming ─────────
float uiScale = 1.0;                          // change at run-time to resize everything

color NOTE_BASE_COLOR   = color(0);         // grey when it first spawns
color NOTE_OUTLINE_COL  =#000000; // yellow highlight (next-to-hit)

color[] LANE_NOTE_COLOR = {                   // one per lane   (edit freely) but yellolw is cool
#ff7b00, #ff7b00, #ff7b00, #ff7b00,
#fff79c, #fff79c, #fff79c, #fff79c
};

color SPECIALHIT = color(255, 200, 0);
color SPECIALMISS = color(255, 0, 0); 

color NORMALHIT = color(152, 166, 154); 
color NORMALMISS = color(255, 0, 0); 


// ───────── helper for octant angles ─────────
float laneAngle(int ln) {
  switch (ln) {
    case 0: return PI;           // left
    case 1: return HALF_PI;      // bottom
    case 2: return -HALF_PI;     // top
    case 3: return 0;            // right
    case 4: return -3*PI/4;      // top-left
    case 5: return 3*PI/4;       // bottom-left
    case 6: return -PI/4;        // top-right
    case 7: return PI/4;         // bottom-right
  }
  return 0;
}

color darkenColor(color c, float factor) {
  return color(
    red(c) * factor,
    green(c) * factor,
    blue(c) * factor,
    alpha(c)
  );
}


void drawCarrotBase(float x, float y, float size, color carrotColor, color leafColor) {
  pushMatrix();
    translate(x, y);
    rotate(2 * PI);
    scale(size);

    float R       = 50; 
    float arcSpan = PI/4;       // 45°

    // Carrot body (1/8 slice)
    noStroke();
    fill(carrotColor);
    arc(0, 0, R*2, R*2, -arcSpan/2, arcSpan/2);

    // Leaves just outside the rim
    float leafDist = R * 1.05;
    float mid      = 0;        
    float leafW    = R * 0.4;
    float leafH    = R * 0.6;

    pushMatrix();
      translate(cos(mid)*leafDist, sin(mid)*leafDist);
      rotate(PI/2);            // make them stick up from the rim
      fill(darkenColor(carrotColor, .7));
      noStroke();
      ellipse(0,         0, leafW,       leafH);
      ellipse(-leafW*0.7, 0, leafW*0.7,   leafH*0.7);
      ellipse( leafW*0.7, 0, leafW*0.7,   leafH*0.7);
    popMatrix();

  popMatrix();
}
