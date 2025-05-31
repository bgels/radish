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


// Note.pde  ── fixed
class Note {
  NoteEvent evt;
  float  hitSec, spawnSec;
  boolean hit = false, missed = false;

  // beatLen  = 60 / BPM   (passed in by Play when it creates the Note)
  Note(NoteEvent evt, float beatLen) {
    this.evt = evt;
    hitSec   = evt.beat * beatLen;     // exact hit time in seconds
    spawnSec = hitSec - LEAD_SEC;      // LEAD_SEC comes from Constants.pde
  }

  void updateAndDraw(float songSec) {
    if (hit || missed) return;
    if (songSec < spawnSec) return;              // not on screen yet

    float t = 1 - (songSec - spawnSec) / LEAD_SEC;   // 1 → 0 shrink factor
    if (t < 0) {                                   // flew past centre
      missed = true;
      laneUI[evt.lane].pulse(false);               // flash red on miss
      return;
    }

    pushMatrix();
      float angle = laneAngle(evt.lane);
      float r = lerp(width*0.55,
                     evt.special ? SPECIAL_RADIUS : JUDGE_RADIUS,
                     1 - t);
      translate(width/2 + cos(angle)*r,
                height/2 + sin(angle)*r);
      rotate(angle + HALF_PI);
      noStroke();
      if (evt.special) {
        fill(255, 200, 0, 200);
        ellipse(0, 0, r*2*t, r*2*t);               // shrinking circle
      } else {
        fill(0, 200, 255, 200);
        arc(0, 0, r*2*t, r*2*t, -PI/8, PI/8);      // 1/8-slice
      }
    popMatrix();
  }
}

// unchanged helper
float laneAngle(int lane) {
  return new float[]{
    PI, HALF_PI, -HALF_PI, 0,
    3*PI/4, -3*PI/4, PI/4, -PI/4
  }[lane];
}
