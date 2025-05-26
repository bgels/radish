import processing.sound.*;
import nl.genart.bpm.*;
import nl.genart.bpm.arduinocontrols.*;
import nl.genart.bpm.frequencyanalyzer.*;
import nl.genart.bpm.beatsperminute.*;

class BackgroundAnimator {
  
  // --- Fields to hold BPM tracker and song title
  BeatsPerMinute bpm;
  String         songName;
  
  // --- Simple background colors list
  ArrayList<Integer> bgColors   = new ArrayList<Integer>();
  color            currentBgColor;
  
  // --- Simple cube colors list
  ArrayList<Integer> cubeColors = new ArrayList<Integer>();
  
  // --- Constructor
  BackgroundAnimator(BeatsPerMinute bpm, String songName) {
    this.bpm      = bpm;
    this.songName = songName;

    // --- Initialize colors
    // Add cube colors manually
    addCubeColor(color(79, 69, 87));    // 1st cube color
    addCubeColor(color(109, 93, 110));  // 2nd cube color
    // Add background colors manually
    addBgColor(color(57, 54, 70));      // background color 1
    addBgColor(color(244, 238, 224));   // background color 2

    // background color will be set to the first entry
    // in the list, if available
    if (!bgColors.isEmpty()) {
      currentBgColor = bgColors.get(0);
    }
  }

  // --- Registration methods

  // Add a single color to the background list
  void addBgColor(int c) {
    bgColors.add(c);
    if (bgColors.size() == 1) {
      currentBgColor = c;
    }
  }
 
  // Change to a specific background color by index
  void setBgColor(int idx) {
    int i = constrain(idx, 0, bgColors.size()-1);
    currentBgColor = bgColors.get(i);
  }

  // Add a single color for a cube layer (manual mapping by index)
  void addCubeColor(int c) {
    cubeColors.add(c);
  }
  
  /**
   * Main drawing update; call each frame from draw().
   */
  void update() {
    // 1) background color changes every 4 beats
    if (bpm.every_once[4]) {
      // pick random entry from bgColors
      int idx = int(random(bgColors.size()));
      currentBgColor = bgColors.get(idx);
    }
    background(currentBgColor);

    float phase = bpm.getBPM() * TWO_PI;
    float angle = (frameCount * 0.01) % TWO_PI;

    // --- 1st rotating cube ---
    pushMatrix();
      translate(width/2, height/2, 0);
      
      // customize rotation for cube 1
      rotateX(angle + phase * 0.1);
      rotateY(angle * .5 + phase * 0.05);
      fill(cubeColors.get(0));  // manual override per cube index
      noStroke();
      box(200);
    popMatrix();
    
    // --- 2nd (wireframe) cube ---
    pushMatrix();
      translate(width/2, height/2, 0);
      // customize rotation for cube 2
      rotateY(angle * 2 + phase * 0.1);
    
      hint(DISABLE_DEPTH_TEST);
      blendMode(INVERT);
    
      stroke(cubeColors.get(1));  // manual override per cube index
      noFill();
      box(500);

      blendMode(BLEND);
      hint(ENABLE_DEPTH_TEST);
    popMatrix();

    
    // overlay song name
    hint(DISABLE_DEPTH_TEST);
    camera();
    textAlign(LEFT, TOP);
    textSize(48);
    fill(255);
    text(songName, 20, 20);
    hint(ENABLE_DEPTH_TEST);
  }
}
