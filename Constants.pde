final float OUTER_DIAMETER    = 200;
final float INNER_DIAMETER    = 140;
final float ARC_SPAN_DEG      =  40;

final float LEAD_SEC         =   3;   // how early notes spawn
final float HIT_WINDOW       = .3;  // ± seconds for OK hit
final float HIT_WINDOW_PERF = .08f;
final float HIT_WINDOW_GOOD = .14f;
final int   LANES            =   8;

final float NOTE_DIAMETER   = 100;   // Ø of every regular slice (pixels)

final float WAVE_START_RADIUS = max(width, height) * .9; // off-screen
final int   WAVE_STROKE       = 0xFF0096FF;              // blue #0096FF

final float JUDGE_RADIUS     =  60;   // main judgement ring
final float SPECIAL_RADIUS   = 110;   // where special notes land

//  index : 0      1         2         3        4          5          6          7
//  lane  : LEFT , BOTTOM ,  TOP ,   RIGHT ,  TOP-LEFT , BOTTOM-LEFT , TOP-RIGHT , BOTTOM-RIGHT
float laneAngle(int ln){
  final float PI2 = PI*2;
  switch (ln){
    case 0:  return  PI;             // left
    case 1:  return  HALF_PI;        // bottom
    case 2:  return -HALF_PI;        // top
    case 3:  return  0;              // right

    case 4:  return -3*PI/4;         // top-left     (-135°)
    case 5:  return  3*PI/4;         // bottom-left  ( 135°)
    case 6:  return -PI/4;           // top-right    (-45°)
    case 7:  return  PI/4;           // bottom-right ( 45°)
  }
  return 0;                          // fallback – should never happen
}
