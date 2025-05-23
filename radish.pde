import nl.genart.bpm.*;
import nl.genart.bpm.arduinocontrols.*;
import nl.genart.bpm.frequencyanalyzer.*;
import nl.genart.bpm.beatsperminute.*;

import nl.genart.bpm.beatsperminute.*;
import processing.sound.*;

BeatsPerMinute bpm;
SoundFile      song;
String         songName = "test";
int            seed = 1;
color          cubeColor;

void setup() {
  fullScreen(P3D);
  
  bpm  = new BeatsPerMinute(this);
  song = new SoundFile(this, "ost/" + songName + ".wav");
  song.play();
  
  cubeColor = color(255, 0, 0);
}

void draw() {
  // A) every 4 beats → new random background
  if (bpm.every_once[4]) {
    bgSeed = int(random(100000));
  }
  randomSeed(bgSeed);
  background(random(255), random(255), random(255));
  
  // B) every single beat → new cube color
  if (bpm.every_once[1]) {
    cubeColor = color(random(255), random(255), random(255));
  }
  
  // C) draw our 3D cube in the center
  pushMatrix();
    // move to center
    translate(width/2, height/2, 0);
    // rotate slowly plus a little by the beat position
    rotateX(frameCount * 0.01 + bpm.getBeatPosition() * TWO_PI * 0.1);
    rotateY(frameCount * 0.008 + bpm.getBeatPosition() * TWO_PI * 0.05);
    
    // color & box
    fill(cubeColor);
    noStroke();
    box(200);
    popMatrix();
  
  // D) overlay 2D text on top
    //hint(DISABLE_DEPTH_TEST);       // ensure text isn’t occluded
    camera();                       // reset any 3D camera transforms
    textAlign(LEFT, TOP);
    textSize(48);
    fill(255);
    text(songName, 20, 20);
    hint(ENABLE_DEPTH_TEST);
}
