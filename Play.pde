import processing.sound.*;
import processing.data.JSONObject;
import processing.core.PApplet;
import java.io.File;
import java.util.ArrayList;

class Play {

  SongEntry entry;
  SoundFile song;

  ArrayList<NoteEvent> chart;
  ArrayList<Note>      live = new ArrayList<Note>();
  BeatClock            beat;

  final float PARALLAX_MAG    = 40;   // px (before uiScale)
  final float SHAKE_INTENSITY = 8;    // px (before uiScale)
  PVector cameraShift = new PVector();
  PVector cameraShake = new PVector();

  ArrayList<Flare> flares = new ArrayList<Flare>();
  BackgroundAnimator bgAnim;
  LaneUI[] laneUI = new LaneUI[LANES];
  SpecialUI specialUI = new SpecialUI();

  SoundFile sfxHit;
  SoundFile sfxMiss;
  SoundFile sfxSpecial;

  int hitReg, missReg, hitSpec, missSpec;
  int combo = 0, maxCombo = 0;
  boolean finished = false;          // set true once song + notes done

  int   shieldLane    = 0;
  final float SHIELD_WINDOW = HIT_WINDOW;
  Note  nextToHit;
  PApplet parent;

  ///
  Play(PApplet parent, SongEntry entry,
       float musicVol, float sfxVol) {

    this.parent = parent;
    this.entry  = entry;

    // read optional colours 
    JSONObject cfg = parent.loadJSONObject(entry.jsonFile.getAbsolutePath());
    if (cfg == null) cfg = new JSONObject();

    // chart + music
    SMChart data = readSM(entry.smFile);
    song = new SoundFile(parent, entry.audioFile.getAbsolutePath());
    song.amp(musicVol);
    song.play();

    beat   = new BeatClock(data.bpm, data.offsetSec, song);
    chart  = data.events;

    // bg 
    bgAnim = new BackgroundAnimator(beat, entry.folderName);
    bgAnim.applyConfig(cfg);

    for (int i = 0; i < LANES; i++) laneUI[i] = new LaneUI(i);

    // LOAD SFX do b4 amp
    sfxHit     = new SoundFile(parent, "hit/hit.wav");
    sfxMiss    = new SoundFile(parent, "hit/miss.wav");
    sfxSpecial = new SoundFile(parent, "hit/special.wav");
    sfxHit.amp(.1);
    sfxMiss.amp(.8);
    sfxSpecial.amp(.1);
  }

  boolean isFinished() { return finished; }
  float   getAccuracy() {
    int all = hitReg + missReg + hitSpec + missSpec;
    return all == 0 ? 100 : 100.0f * (hitReg + hitSpec) / all;
  }
  int     getMaxCombo() { return maxCombo; }
  int     getHitReg()   { return hitReg;   }
  int     getMissReg()  { return missReg;  }
  int     getHitSpec()  { return hitSpec;  }
  int     getMissSpec() { return missSpec; }

  void moveShieldTo(int lane) { shieldLane = lane; }

  void trySpecialHit() {
    float now = song.position();
    for (Note n : live) {
      if (n.evt.special && abs(now - n.hitSec) <= HIT_WINDOW) {
        n.hit = true;
        hitSpec++;
        combo++;  maxCombo = max(maxCombo, combo);
        specialUI.pulse(true);
        cameraShake.add(PVector.random2D().mult(SHAKE_INTENSITY*uiScale));
        sfxSpecial.play();
        return;
      }
    }
    // fail
    missSpec++;
    combo = 0;
    specialUI.pulse(false);
    sfxMiss.play();
  }

  void update() {

    float now = song.position();
    beat.tick();

    // camera
    PVector pTarget = PVector.fromAngle(laneAngle(shieldLane))
                      .mult(PARALLAX_MAG * uiScale);
    cameraShift.lerp(pTarget, 0.15);
    cameraShift.limit(PARALLAX_MAG * uiScale);
    cameraShake.mult(0.88);

    //notes len
    float beatLen   = 60.0f / beat.getBPM();
    float musicBeat = (now + beat.songOffsetSec) / beatLen;

    while (!chart.isEmpty() &&
           chart.get(0).beat - musicBeat <= LEAD_SEC / beatLen) {

      Note note = new Note(chart.remove(0), beatLen, beat.songOffsetSec);
      live.add(note);

      if (note.evt.special) continue;     // no flare

      // flare for regular note
      float a = laneAngle(note.evt.lane);
      float r = max(width, height) * 0.55 * uiScale;
      flares.add(new Flare(
        new PVector(width/2 + cos(a)*r, height/2 + sin(a)*r),
        note.evt.lane));
    }

    updateNextToHit();
    pushMatrix();
      translate(cameraShift.x + cameraShake.x,
                cameraShift.y + cameraShake.y);

      bgAnim.update();

      // flares (BROKEN RN)
      for (int i = flares.size()-1; i >= 0; i--) {
        Flare f = flares.get(i);
        f.updateAndDraw();
        if (f.dead()) flares.remove(i);
      }

      // Notes
      for (int i = live.size()-1; i >= 0; i--) {
        Note n = live.get(i);
        n.updateAndDraw(now, n == nextToHit);

        if (!n.evt.special) {
          // hit
          if (!n.hit && n.evt.lane == shieldLane &&
              abs(now - n.hitSec) <= SHIELD_WINDOW) {
            n.hit = true;
            hitReg++; combo++; maxCombo = max(maxCombo, combo);
            laneUI[n.evt.lane].pulse(true);
            cameraShake.add(PVector.random2D().mult(SHAKE_INTENSITY*uiScale));
            sfxHit.play();
          }
          // miss
          if (!n.hit && now > n.hitSec + HIT_WINDOW) {
            n.missed = true;
            missReg++; combo = 0;
            laneUI[n.evt.lane].pulse(false);
            sfxMiss.play();
          }
        }
        if (n.hit || n.missed) live.remove(i);
      }

      // Ui
      for (LaneUI ui : laneUI) ui.draw();
      specialUI.draw();
      drawShield();

      // live combo display
      fill(255);
      textAlign(CENTER, TOP);
      textSize(32 * uiScale);
      text(combo > 0 ? "Combo: " + combo : "", width/2, 40);
    popMatrix();

    // finished?
    if (!finished && chart.isEmpty() && live.isEmpty()) {
      finished = true;
      song.stop();
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

  void updateNextToHit() {
    float now = song.position();
    nextToHit = null;
    for (Note n : live)
      if (!n.hit && n.hitSec >= now) { nextToHit = n; break; }
  }

  void stopSong() {
    if (song != null && song.isPlaying()) song.stop();
  }
}

// Why is it not wokring? check `updateAndDraw()` in Note.pde
class Flare {
  PVector pos; float life = 3f; color col;
  Flare(PVector p, int lane) { pos = p.copy(); col = LANE_NOTE_COLOR[lane]; }
  void updateAndDraw() {
    hint(DISABLE_DEPTH_TEST);
    blendMode(ADD);
      noStroke();
      float r = map(life, 1, 0, 0, 300 * uiScale);
      fill(col, 220 * life);
      ellipse(pos.x, pos.y, r*2, r*2);
    blendMode(BLEND); // reset blend mode
    hint(ENABLE_DEPTH_TEST); // re-enable depth test
    life -= 0.04; // decay
  }
  boolean dead() { return life <= 0; }
}
