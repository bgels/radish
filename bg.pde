import processing.sound.*;
import nl.genart.bpm.*;
import nl.genart.bpm.arduinocontrols.*;
import nl.genart.bpm.frequencyanalyzer.*;
import nl.genart.bpm.beatsperminute.*;

class BackgroundAnimator {
  BeatsPerMinute bpm;
  String         songName;
  int            bgSeed;
  color          cubeColor;

  // Constructor takes your BPM tracker and the song title
  BackgroundAnimator(BeatsPerMinute bpm, String songName) {
    this.bpm      = bpm;
    this.songName = songName;
    this.bgSeed   = 1;
    this.cubeColor = color(255, 0, 0);
  }

  // Call once per frame from draw()
  void update() {
    // 1) change background every 4 beats
    if (bpm.every_once[4]) {
      bgSeed = int(random(100000));
    }
    randomSeed(bgSeed);
    background(random(255), random(255), random(255));

    // 2) change cube color on every beat
    if (bpm.every_once[1]) {
      cubeColor = color(random(255), random(255), random(255));
    }

    // 3) draw & rotate cube in center
    pushMatrix();
      translate(width/2, height/2, 0);
      // combine a slow spin with a little beat‐sync “nudge”
      float phase = bpm.getBPM() * TWO_PI;
      rotateX(frameCount * 0.01 + phase * 0.1);
      rotateY(frameCount * 0.008 + phase * 0.05);
      fill(cubeColor);
      noStroke();
      box(200);
    popMatrix();

    // 4) overlay song name as 2D text
    hint(DISABLE_DEPTH_TEST);
    camera();                    // reset any 3D transforms
    textAlign(LEFT, TOP);
    textSize(48);
    fill(255);
    text(songName, 20, 20);
    hint(ENABLE_DEPTH_TEST);
  }
}
