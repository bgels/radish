  import processing.sound.*;
import nl.genart.bpm.*;
import nl.genart.bpm.arduinocontrols.*;
import nl.genart.bpm.frequencyanalyzer.*;
import nl.genart.bpm.beatsperminute.*;


BeatsPerMinute      bpm;
SoundFile           song;
BackgroundAnimator  bgAnim;
String              songName = "test";

void setup() {
  fullScreen(P3D);
  // 1 init BPM & audio
  bpm  = new BeatsPerMinute(this);
  song = new SoundFile(this, "ost/" + songName + ".wav");
  song.play();

  // 2 hand off to our animator
  bgAnim = new BackgroundAnimator(bpm, songName);
}

void draw() {
  bgAnim.update();
}
