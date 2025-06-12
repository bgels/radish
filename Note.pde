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
    if (rawProg > 1) { missed = true; return; }
    float prog = constrain(rawProg, 0, 1);

    if (evt.special) {
      // ----- special wave -----
      pushMatrix();
        translate(width/2, height/2, 0);
        noFill();
        stroke(WAVE_STROKE);
        strokeWeight(5 * uiScale);
        float rNow = lerp(WAVE_START_RADIUS, SPECIAL_RADIUS, prog) * uiScale;
        ellipse(0, 0, rNow*2, rNow*2);
      popMatrix();
      return;
    }

    // ----- regular carrot slice -----
    float a      = laneAngle(evt.lane);
    float rStart = max(width, height) * 0.55 * uiScale;
    float rEnd   = (JUDGE_RADIUS - NOTE_DIAMETER/2 - 70) * uiScale;
    float r      = lerp(rStart, rEnd, prog);

    // interpolated carrot color
    color laneCol = LANE_NOTE_COLOR[evt.lane];
    color c       = lerpColor(NOTE_BASE_COLOR, laneCol, prog);

    // draw carrot at (x,y) on its radial path
    float d = NOTE_DIAMETER;  // unscaled diameter
    pushMatrix();
      translate(width/2 + cos(a)*r, height/2 + sin(a)*r);
      rotate(a);

      // size parameter = (diameter / unit-diameter) * uiScale
      float size = (d / 100.0) * uiScale;
      // leaf color (static green — tweak as you like)
      color leafCol = color(50,205,50);
      drawCarrotBase(0, 0, size, c, leafCol);

      // highlight outline (next-to-hit)
      if (highlight) {
        stroke(NOTE_OUTLINE_COL);
        strokeWeight(10 * uiScale);
        noFill();
        // draw a faint arc as outline behind carrot
        point(0,0);
      }
    popMatrix();
  }
}
