import processing.sound.*;
import processing.data.JSONObject;
import processing.core.PApplet;
import java.io.File;
import java.util.ArrayList;

class Play {
  
  // ─────────────────────────────────────────────────────────────────
  // Fields
  // ─────────────────────────────────────────────────────────────────
  SongEntry            entry;
  SoundFile            song;
  ArrayList<NoteEvent> chart;
  ArrayList<Note>      live = new ArrayList<Note>();
  BeatClock            beat;

  final float PARALLAX_MAG    = 40;   // px (before uiScale)
  final float SHAKE_INTENSITY = 8;    // px (before uiScale)
  PVector cameraShift = new PVector();
  PVector cameraShake = new PVector();

  ArrayList<Flare>    flares  = new ArrayList<Flare>();
  BackgroundAnimator  bgAnim;
  LaneUI[]            laneUI  = new LaneUI[LANES];
  SpecialUI           specialUI = new SpecialUI();

  SoundFile sfxHit;
  SoundFile sfxMissReg;    // regular-note miss
  SoundFile sfxMissSpec;   // special-note miss
  SoundFile sfxSpecial;    // special hit

  int hitReg, missReg, hitSpec, missSpec;
  int combo = 0, maxCombo = 0;
  boolean finished = false;          // true once song + notes done

  int   shieldLane    = 0;
  final float SHIELD_WINDOW = HIT_WINDOW;
  Note  nextToHit;
  PApplet parent;

  // ─────────────────────────────────────────────────────────────────
  // Constructor
  // ─────────────────────────────────────────────────────────────────
  Play(PApplet parent, SongEntry entry, float musicVol, float sfxVol) {
    this.parent = parent;
    this.entry  = entry;

    // Read optional colours
    JSONObject cfg = parent.loadJSONObject(entry.jsonFile.getAbsolutePath());
    if (cfg == null) cfg = new JSONObject();

    // Chart + music
    SMChart data = readSM(entry.smFile);
    song = new SoundFile(parent, entry.audioFile.getAbsolutePath());
    song.play();
    song.amp(musicVol);
    
    

    beat  = new BeatClock(data.bpm, data.offsetSec, song);
    chart = data.events;

    // Background
    bgAnim = new BackgroundAnimator(beat, entry.folderName);
    bgAnim.applyConfig(cfg);

    for (int i = 0; i < LANES; i++) {
      laneUI[i] = new LaneUI(i);
    }

    // Load SFX
    sfxHit      = new SoundFile(parent, "hit/hit.wav");
    sfxMissReg  = new SoundFile(parent, "hit/miss_reg.wav");
    sfxMissSpec = new SoundFile(parent, "hit/miss_spec.wav");
    sfxSpecial  = new SoundFile(parent, "hit/special.wav");

    sfxHit.amp(sfxVol);
    sfxMissReg.amp(sfxVol);
    sfxMissSpec.amp(sfxVol);
    sfxSpecial.amp(sfxVol);
  }

  // ─────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────
  boolean isFinished() { 
    return finished; 
  }

  float getAccuracy() {
    int total = hitReg + missReg + hitSpec + missSpec;
    return (total == 0) 
      ? 100 
      : 100.0f * (hitReg + hitSpec) / total;
  }

  int getMaxCombo()  { return maxCombo; }
  int getHitReg()    { return hitReg;   }
  int getMissReg()   { return missReg;  }
  int getHitSpec()   { return hitSpec;  }
  int getMissSpec()  { return missSpec; }

  void moveShieldTo(int lane) { 
    shieldLane = lane; 
  }

  void stopSong() {
    if (song != null && song.isPlaying()) {
      song.stop();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Main update loop
  // ─────────────────────────────────────────────────────────────────
  void update() {
    float now = song.position();
    beat.tick();

    // Camera parallax + shake
    PVector target = PVector.fromAngle(laneAngle(shieldLane))
                            .mult(PARALLAX_MAG * uiScale);
    cameraShift.lerp(target, 0.15);
    cameraShift.limit(PARALLAX_MAG * uiScale);
    cameraShake.mult(0.88);

    // Spawn notes
    float beatLen   = 60.0f / beat.getBPM();
    float musicBeat = (now + beat.songOffsetSec) / beatLen;

    while (!chart.isEmpty() &&
           chart.get(0).beat - musicBeat <= LEAD_SEC / beatLen) {
      Note note = new Note(chart.remove(0), beatLen, beat.songOffsetSec);
      live.add(note);
      if (!note.evt.special) {
        float a = laneAngle(note.evt.lane);
        float r = max(width, height) * 0.55 * uiScale;
        flares.add(new Flare(
          new PVector(width/2 + cos(a)*r, height/2 + sin(a)*r),
          note.evt.lane));
      }
    }

    updateNextToHit();

    // Draw scene with camera transforms
    pushMatrix();
      translate(cameraShift.x + cameraShake.x,
                cameraShift.y + cameraShake.y);

      bgAnim.update();

      // Flares
      for (int i = flares.size()-1; i >= 0; i--) {
        Flare f = flares.get(i);
        f.updateAndDraw();
        if (f.dead()) flares.remove(i);
      }

      // Notes: hit & miss logic
      for (int i = live.size()-1; i >= 0; i--) {
        Note n = live.get(i);
        n.updateAndDraw(now, n == nextToHit);

        if (!n.evt.special) {
          // Regular hit
          if (!n.hit &&
              n.evt.lane == shieldLane &&
              abs(now - n.hitSec) <= SHIELD_WINDOW) {
            n.hit = true;
            hitReg++; 
            combo++;  
            maxCombo = max(maxCombo, combo);
            laneUI[n.evt.lane].pulse(true);
            cameraShake.add(
              PVector.random2D().mult(SHAKE_INTENSITY * uiScale)
            );
            sfxHit.play();
          }
          // Regular miss
          if (!n.hit && now > n.hitSec + HIT_WINDOW) {
            n.missed = true;
            missReg++; 
            combo = 0;
            laneUI[n.evt.lane].pulse(false);
            sfxMissReg.play();
          }
        }
        else {
          // Special-note miss
          if (!n.hit && now > n.hitSec + SPECIAL_LATE_WINDOW) {
            n.missed = true;
            missSpec++; 
            combo = 0;
            specialUI.pulse(false);
            sfxMissSpec.play();
          }
        }

        if (n.hit || n.missed) {
          live.remove(i);
        }
      }

      // UI
      for (LaneUI ui : laneUI) ui.draw();
      specialUI.draw();
      drawShield();

      if (debug) drawDebugMarkers();

      // Combo display
      fill(255);
      textAlign(CENTER, TOP);
      textSize(32 * uiScale);
      text(combo > 0 ? "Combo: " + combo : "", width/2, 40);

    popMatrix();

    // End-of-song check
    if (!finished) {
      if ((chart.isEmpty() && live.isEmpty()) || !song.isPlaying()) {
        finished = true;
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Special-hit handler
  // ─────────────────────────────────────────────────────────────────
  void trySpecialHit() {
    float now = song.position();

    for (Note n : live) {
      if (!n.evt.special) continue;

      float dt = now - n.hitSec;          // − = early, + = late

      if (dt >= -SPECIAL_EARLY_WINDOW && dt <=  SPECIAL_LATE_WINDOW) {
        /* ---------- HIT ---------- */
        n.hit = true;
        hitSpec++;
        combo++;  maxCombo = max(maxCombo, combo);
        specialUI.pulse(true);
        cameraShake.add(PVector.random2D().mult(SHAKE_INTENSITY*uiScale));
        sfxSpecial.play();
        return;
      }
    }

    /* ---------- MISS ---------- */
    missSpec++;
    combo = 0;
    specialUI.pulse(false);
    sfxMissSpec.play();
  }


  // ─────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────
  void updateNextToHit() {
    float now = song.position();
    nextToHit = null;
    for (Note n : live) {
      if (!n.hit && n.hitSec >= now) {
        nextToHit = n;
        break;
      }
    }
  }

  void drawShield() {
    pushMatrix();
      translate(width/2, height/2);
      rotate(laneAngle(shieldLane));
      stroke(255, 80);
      strokeWeight(10 * uiScale);
      noFill();
      float d = JUDGE_RADIUS * 2 * uiScale;
      arc(0, 0, d, d, -PI/8, PI/8);
    popMatrix();
  }

  void drawDebugMarkers() {
    pushMatrix();
      translate(width/2, height/2);

      // Regular-note hit spots
      stroke(255, 0, 0);
      strokeWeight(6 * uiScale);
      float rEnd = (JUDGE_RADIUS - NOTE_DIAMETER/2) * uiScale;
      for (int ln = 0; ln < LANES; ln++) {
        float a = laneAngle(ln);
        point(cos(a) * rEnd, sin(a) * rEnd);
      }

      // Special-wave hit ring
      noFill();
      stroke(255, 0, 0);
      strokeWeight(2 * uiScale);
      ellipse(
        0, 0,
        SPECIAL_RADIUS * 2 * uiScale,
        SPECIAL_RADIUS * 2 * uiScale
      );
    popMatrix();
  }
  // ------------------------------------------------------------------------
  // Flare – simple radial SFX puff for regular notes
  // ------------------------------------------------------------------------
  class Flare {
    PVector pos; 
    float   life = 3f; 
    color   col;

    Flare(PVector p, int lane) {
      pos = p.copy();
      col = LANE_NOTE_COLOR[lane];
    }

    void updateAndDraw() {
      hint(DISABLE_DEPTH_TEST);
      blendMode(ADD);
        noStroke();
        float r = map(life, 1, 0, 0, 100 * uiScale);
        fill(col, 220 * life);
        ellipse(pos.x, pos.y, r*2, r*2);
      blendMode(BLEND);
      hint(ENABLE_DEPTH_TEST);

      life -= 0.04; // decay
    }

    boolean dead() {
      return life <= 0;
    }
  }


}
