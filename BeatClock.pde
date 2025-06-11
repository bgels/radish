class BeatClock {
// ------------------------------------------------------------
// Simple beat-tracker that works with a fixed BPM.
//
//  • tick()     – call every frame to update internal state
//  • everyOnce(n)  – true once on the first frame of each n-beat bar
//  • phase()    – 0-1 progress inside the current beat
// ------------------------------------------------------------
  float    bpm, beatLenSec;
  float    songOffsetSec;          // SM #OFFSET support  (can be ±)
  SoundFile song;

  int   currentBeat;   // whole beats elapsed
  float currentFrac;   // 0-1 progress through the current beat

  int      lastWholeBeat = -1;
  boolean[] once         = new boolean[17];   // 1..16

  BeatClock(float bpm, float songOffsetSec, SoundFile song) {
    this.bpm          = bpm;
    this.songOffsetSec = songOffsetSec;
    this.song         = song;
    this.beatLenSec   = 60.0f / bpm;
  }

  // ----------------------------------------------------------
  void tick() {
    float songSec = (song != null)
                  ? song.position()
                  : millis() / 1000.0f;

    // compensate SM offset
    float t = (songSec + songOffsetSec) / beatLenSec;
    int wholeBeat = int(t);
    float fracBeat  = t - wholeBeat;

    if (wholeBeat != lastWholeBeat) {       // new beat crossed
      lastWholeBeat = wholeBeat;
      for (int i = 1; i < once.length; i++) {
        once[i] = (wholeBeat % i == 0);
      }
    } else {
      for (int i = 1; i < once.length; i++) once[i] = false;
    }
  }

  boolean everyOnce(int n) {                // same signature as before
    return n >= 1 && n < once.length && once[n];
  }

  float getBPM() { return bpm; }

  // ----------------------------------------------------------
  void phase() {
    float tSec = song.position() + songOffsetSec; // Option A
    float tBeats = tSec / beatLenSec;

    currentBeat = int(tBeats);
    currentFrac = tBeats - currentBeat; // 0-1
  }

  public int   getBeat()      { return currentBeat; }
  public float getFracBeat()  { return currentFrac;  }
}
