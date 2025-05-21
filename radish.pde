import processing.sound.*;
SoundFile file;

void setup() {
  size(960,720);
  background(255);
    
  // Load a soundfile from the /data folder of the sketch and play it back
  file = new SoundFile(this, "ost/test.wav");
  file.play();
}      

void draw() {
  
}
