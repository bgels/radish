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
    Note(NoteEvent evt, float beatLen) {
      this.evt      = evt;
      this.hitSec   = evt.beat * beatLen;
      this.spawnSec = hitSec - LEAD_SEC;
    }
  
    // --------------------------------------------------------------------
  void updateAndDraw(float songSec) {
  
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
    float r = lerp(width*0.55, JUDGE_RADIUS, prog);
  
    pushMatrix();
      translate(width/2 + cos(a)*r, height/2 + sin(a)*r);
      rotate(a);
      noStroke();
      fill(0, 200, 255, 220);
      arc(0, 0, NOTE_DIAMETER, NOTE_DIAMETER, -PI/8, PI/8);
    popMatrix();
  }

}