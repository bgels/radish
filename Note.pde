// ------------------------------------------------------------------------
// NoteEvent and Note classes – each note handles its own timing and drawing.
// Regular notes now render as carrot slices via drawCarrotBase(); special
// waves remain manual (spacebar) hits.
// ------------------------------------------------------------------------

class NoteEvent {
  int   lane;
  float beat;
  boolean special;
  NoteEvent(int l, float b, boolean spec) {
    lane    = l;
    beat    = b;
    special = spec;
  }
}

class Note {
  final NoteEvent evt;   // lane · beat · special?
  final float     hitSec;// exact hit time (s)
  final float     spawnSec;// first visible   (s)

  boolean hit    = false;
  boolean missed = false;

  Note(NoteEvent evt, float beatLen, float offsetSec) {
    this.evt      = evt;
    this.hitSec   = evt.beat * beatLen - offsetSec;
    this.spawnSec = hitSec - LEAD_SEC;
  }

  void updateAndDraw(float songSec, boolean highlight) {
    if (hit || missed) return;
    if (songSec < spawnSec) return;

    float rawProg = (songSec - spawnSec) / LEAD_SEC;
    if (rawProg > 1) { return; }   // let Play() decide when it's a miss
    float prog = constrain(rawProg, 0, 1);

    if (evt.special) {
      // ----- special wave -----
      pushMatrix();
        translate(width/2, height/2, 0);
        noFill();
        stroke(WAVE_STROKE);
        strokeWeight(10 * uiScale);
        float rNow = lerp(WAVE_START_RADIUS, SPECIAL_RADIUS, prog) * uiScale;
        ellipse(0, 0, rNow*2, rNow*2);
      popMatrix();
      return;
    }

    // ----- regular arc note -----
    float a      = laneAngle(evt.lane);
    float rStart = max(width, height) * 0.55 * uiScale;
    float rEnd   = (JUDGE_RADIUS - NOTE_DIAMETER/2) * uiScale;
    float r      = lerp(rStart, rEnd, prog);

    // colour blend
    color laneCol = LANE_NOTE_COLOR[evt.lane];
    color c       = lerpColor(NOTE_BASE_COLOR, laneCol, prog);

    pushMatrix();
      translate(width/2 + cos(a)*r, height/2 + sin(a)*r);
      rotate(a);

      stroke(c);
      strokeWeight(20 * uiScale);
      noFill();
      float d = NOTE_DIAMETER * uiScale;
      arc(0, 0, d, d, -PI/8, PI/8);   // same shape as shield

      // highlight (next-to-hit)
      if (highlight) {
        stroke(color(NOTE_OUTLINE_COL));
        strokeWeight(5 * uiScale);
        arc(0, 0, d, d, -PI/8, PI/8);
      }
    popMatrix();

  }
}
