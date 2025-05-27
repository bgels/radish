class BeatClock {
  float    bpm, beatLenSec;
  SoundFile song;
  int      lastBeat = -1;
  boolean[] once     = new boolean[17];

  BeatClock(float bpm, SoundFile song) {
    this.bpm       = bpm;
    this.song      = song;
    this.beatLenSec = 60.0f / bpm;
  }

  void tick() {
    float s = (song != null)
            ? song.position()         // in seconds already
            : millis() / 1000.0f;
    int beat = int(s / beatLenSec);
    if (beat != lastBeat) {
      lastBeat = beat;
      for (int i = 1; i < once.length; i++) {
        once[i] = (beat % i == 0);
      }
    } else {
      for (int i = 1; i < once.length; i++) {
        once[i] = false;
      }
    }
  }

  boolean everyOnce(int n) {
    return n >= 1 && n < once.length && once[n];
  }

  float getBPM() {
    return bpm;
  }
}
