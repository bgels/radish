class BeatClock {
  float    bpm;
  float    beatLenSec;       // seconds per beat
  SoundFile song;            // can be null
  float    offsetSec;        // shift the timeline
  int      lastBeat = -1;
  boolean[] once     = new boolean[17];

  //default offset 0
  BeatClock(float bpm, SoundFile song) {
    this(bpm, song, 0);
  }

  //constructor with offset
  BeatClock(float bpm, SoundFile song, float offsetSec) {
    this.bpm        = bpm;
    this.song       = song;
    this.offsetSec  = offsetSec;
    beatLenSec      = 60.0 / bpm;
  }

  void tick() {
    // read song.position() in seconds, then apply offset
    float s = (song != null) 
            ? song.position() 
            : millis() / 1000.0;
    float t = s + offsetSec;    // shift time
    int   beat = int(t / beatLenSec);

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
    return (n >= 1 && n < once.length) ? once[n] : false;
  }

  float getBPM() {
    return bpm;
  }
}
