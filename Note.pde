// ------------------------------------------------------------------------
// NoteEvent and Note classes – radius‑accurate timing, colour‑fade,
// missed‑fade that continues toward the centre of the screen.
// ------------------------------------------------------------------------

class NoteEvent {
  int lane;
  float beat;
  boolean special;
  
  NoteEvent(int l, float b, boolean spec) {
    lane    = l;
    beat    = b;
    special = spec;
  }
}

class Note {
  // ── immutable ────────────────────────────────────────────────
  final NoteEvent evt;
  final float hitSec;              // centre coincides with judge ring
  final float spawnSec;            // = hitSec – LEAD_SEC
  final float travelSec;           // pre‑ring travel duration (== LEAD_SEC)

  // ── runtime state ────────────────────────────────────────────
  boolean hit = false;
  boolean missed = false;
  boolean dead = false;

  // cache when the miss was registered (centre passed ring + window)
  float missBeginSec = 0;

  boolean justMissed = false;
  

    Note(NoteEvent evt, float beatLen, float offsetSec) {
        this.evt = evt;
        this.hitSec = offsetSec + (evt.beat * beatLen);
        this.spawnSec = hitSec - LEAD_SEC;
        this.travelSec = LEAD_SEC;
    }


  // -------------------------------------------------------------------
  // Per‑frame update & draw. Called by Play.update(). Marks itself dead
  // when finished so caller can remove it from the list.
  // -------------------------------------------------------------------
  boolean updateAndDraw(float songSec, boolean highlight) {
    if (dead) return true;

    // 1) was it hit by player? ------------------------------------------------
    if (hit) { dead = true; return true; }

    // 2) if still waiting to spawn, do nothing --------------------------------
    if (songSec < spawnSec) return false;

    // ── compute radius r from spawn → ring → centre ─────────────────────────
    float rStart = max(width, height) * 0.55 * uiScale;
    float rRing  = JUDGE_RADIUS * uiScale;

    float r;            // current radius for drawing
    float alpha = 255;  // fade value

    if (!hit && !missed && songSec > hitSec + HIT_WINDOW_LATE) {
      missed = true;
      missBeginSec = songSec;
    }

    if (!missed) {
      // BEFORE judge ring ----------------------------------------------------
      float prog = constrain((songSec - spawnSec) / travelSec, 0, 1);
      r = lerp(rStart, rRing, prog);
    } else {
      // AFTER miss – continue inward & fade out ------------------------------
      float progMiss = constrain((songSec - missBeginSec) / missFadeSecs, 0, 1);
      r     = lerp(rRing, 0, progMiss);
      alpha = lerp(255, 0, progMiss);
      if (progMiss >= 1) { dead = true; return true; }
    }

    // ── SPECIAL NOTE (wave) ─────────────────────────────────────────────────
    if (evt.special) {
      float rWave = map(songSec, spawnSec, hitSec + missFadeSecs, WAVE_START_RADIUS * uiScale, SPECIAL_RADIUS * uiScale);
      noFill();
      stroke(WAVE_STROKE, alpha);
      strokeWeight(2 * uiScale);
      pushMatrix();
        translate(width/2, height/2);
        ellipse(0, 0, rWave*2, rWave*2);
      popMatrix();
      return false;
    }

    // ── REGULAR NOTE (slice) ────────────────────────────────────────────────
    float theta = laneAngle(evt.lane);
    float d     = NOTE_DIAMETER * uiScale;

    // colour change distance: grey until within COLOUR_SWITCH px of ring
    float distanceToRing = max(r - rRing, 0);
    color laneCol = LANE_NOTE_COLOR[evt.lane];
    color baseCol = NOTE_BASE_COLOR;
    float fadeAmt = (distanceToRing > COLOUR_SWITCH * uiScale)
                  ? 0
                  : 1 - (distanceToRing / (COLOUR_SWITCH * uiScale));
    color c = lerpColor(baseCol, laneCol, fadeAmt);

    // draw wedge -------------------------------------------------------------
    pushMatrix();
      translate(width/2 + cos(theta)*r, height/2 + sin(theta)*r);
      rotate(theta);
      noStroke();
      fill(red(c), green(c), blue(c), alpha);
      arc(0, 0, d, d, -PI/8, PI/8);

      // highlight outline if next‑to‑hit and not missed
      if (highlight && !missed) {
        stroke(NOTE_OUTLINE_COL, alpha);
        strokeWeight(4 * uiScale);
        noFill();
        arc(0, 0, d + 6*uiScale, d + 6*uiScale, -PI/8, PI/8);
      }
    popMatrix();

    return false;   // still alive
  }
}
