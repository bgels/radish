import nl.genart.bpm.beatsperminute.*;
import processing.sound.*;

BeatsPerMinute bpm;
SoundFile      song;
int            seed = 1;

void setup() {
  size(500, 500);
  bpm  = new BeatsPerMinute(this);
  song = new SoundFile(this, "your-music-file.mp3");
  song.play();
}

void draw() {
  // background changes every 4 beats
  if (bpm.every_once[4]) {
    seed = int(random(100000));
  }
  randomSeed(seed);
  background(random(255), random(255), random(255));

  // ... spawn and move your notes here, using bpm.beat or bpm.position …

  // optionally visualize amplitude or FFT
  float level = song.amp();
  ellipse(width/2, height/2, map(level, 0, 0.5, 50, 200), map(level, 0, 0.5, 50, 200));
}
