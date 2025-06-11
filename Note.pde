class NoteEvent{
    int lane;
    float beat;
    boolean special;
    NoteEvent(int l, float b, boolean spec){
        this.lane = l;
        this.beat = b;
        this.special = spec;
    }
}

/* Note.pde  ----------------------------------------------------------------
 * A single in-game note (1/8 slice or special circle).
 *   · does its own timing / drawing
 *   · exposes hit / missed but NEVER talks to UI
 * ------------------------------------------------------------------------*/
class Note {

  // --- immutable data from SM file
  final NoteEvent evt;     // lane · beat · special?
  final float     hitSec;  // exact hit time  (s)
  final float     spawnSec;// first visible   (s)

  // --- runtime state
  boolean hit     = false;
  boolean missed  = false;

  // --------------------------------------------------------------------
      Note(NoteEvent evt, float beatLen, float offsetSec) {
        this.evt      = evt;
        this.hitSec   = evt.beat * beatLen - offsetSec;   // ← subtract (remember: offset may be –7)
        this.spawnSec = hitSec - LEAD_SEC;
      }
  
    // --------------------------------------------------------------------
  void updateAndDraw(float songSec, boolean highlight) {
  
    if (hit || missed) return;
    if (songSec < spawnSec) return;          // not visible yet
  
    float rawProg = (songSec - spawnSec) / LEAD_SEC; // Unconstrained progress
    if (rawProg > 1) { missed = true; return; }      // Flew past hit window
    float prog = constrain(rawProg, 0, 1);           // 0 → 1 for drawing
  
    if (evt.special) {         // ----------- SPECIAL WAVE -----------
      pushMatrix();
        translate(width/2, height/2, 0);
        noFill();
        stroke(WAVE_STROKE);
        strokeWeight(2);
        float rNow = lerp(WAVE_START_RADIUS, SPECIAL_RADIUS, prog);
        ellipse(0, 0, rNow*2, rNow*2);
      popMatrix();
      return;
    }
  
    // ----------------------- REGULAR SLICE -------------------------
    float a = laneAngle(evt.lane);

    // position between “far” and judgement ring, both scaled
    float rStart = max(width, height) * 0.55 * uiScale;
    float rEnd   = JUDGE_RADIUS * uiScale;
    float r = lerp(rStart, rEnd, prog);

    // 1) colour fades grey → lane colour
    color laneCol = LANE_NOTE_COLOR[evt.lane];
    color c       = lerpColor(NOTE_BASE_COLOR, laneCol, prog);

    float d = NOTE_DIAMETER * uiScale;

    pushMatrix();
      translate(width/2 + cos(a)*r, height/2 + sin(a)*r);
      rotate(a);

      noStroke();
      fill(red(c), green(c), blue(c), 220);
      arc(0, 0, d, d, -PI/8, PI/8);

      // 2) yellow outline on the note that’s next to hit
      if (highlight) {                       // ← new param, see Play.pde below
        stroke(NOTE_OUTLINE_COL);
        strokeWeight(4*uiScale);
        noFill();
        arc(0, 0, d + 6*uiScale, d + 6*uiScale, -PI/8, PI/8);
      }
    popMatrix();

  }

}