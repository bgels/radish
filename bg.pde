// BackgroundAnimator.pde
import processing.data.JSONObject;
import processing.data.JSONArray;
import java.util.ArrayList;
import processing.core.PApplet;

class BackgroundAnimator{
      
// --- Fields to hold BPM tracker and song title
BeatClock     beat;
String         songName;

// --- Simple background colors list
ArrayList<Integer> bgColors   = new ArrayList<Integer>();
color              currentBgColor;

// --- Simple cube colors list
ArrayList<Integer> cubeColors = new ArrayList<Integer>();

// --- Constructor
BackgroundAnimator(BeatClock beat, String songName) {
  this.beat     = beat;
  this.songName = songName;

  // Add cube colors manually
  addCubeColor(color(79, 69, 87));    // 1st cube color
  addCubeColor(color(109, 93, 110));  // 2nd cube color
  // Add background colors manually
  addBgColor(color(57, 54, 70));      // background color 1
  addBgColor(color(244, 238, 224));   // background color 2

  if (!bgColors.isEmpty()) {
    currentBgColor = bgColors.get(0);
  }
}

void setSongName(String name) {
  songName = name;
}

void applyConfig(JSONObject config) {
  if (config.hasKey("background")) {
    JSONObject bg = config.getJSONObject("background");
    if (bg.hasKey("colors")) {
      bgColors.clear();
      JSONArray arr = bg.getJSONArray("colors");
      for (int i = 0; i < arr.size(); i++) {
        JSONArray c = arr.getJSONArray(i);
        addBgColor(color(c.getInt(0), c.getInt(1), c.getInt(2)));
      }
    }
  }
  if (config.hasKey("shapes")) {
    JSONObject sh = config.getJSONObject("shapes");
    if (sh.hasKey("cubeColors")) {
      cubeColors.clear();
      JSONArray arr = sh.getJSONArray("cubeColors");
      for (int i = 0; i < arr.size(); i++) {
        JSONArray c = arr.getJSONArray(i);
        addCubeColor(color(c.getInt(0), c.getInt(1), c.getInt(2)));
      }
    }
  }
  if (!bgColors.isEmpty()) {
    currentBgColor = bgColors.get(0);
  }
}

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
  if (beat.everyOnce(1)) {
    int idx = int(random(bgColors.size()));
    currentBgColor = bgColors.get(idx);
  }
  background(currentBgColor);

  float phase = beat.getBPM() * TWO_PI;
  float angle = (frameCount * 0.01) % TWO_PI;

  pushMatrix();
    translate(width/2, height/2, 0);
    rotateX(angle + phase * 0.1);
    rotateY(angle * .5 + phase * 0.05);
    fill(cubeColors.get(0));
    noStroke();
    box(200);
  popMatrix();
  
  pushMatrix();
    translate(width/2 - 100, height/2, 0);
    rotateX(angle * .5 + phase * 0.05);
    fill(cubeColors.get(1));
    noStroke();
    square(0, 200, 200);
  popMatrix();

  pushMatrix();
    translate(width/2, height/2, 0);
    rotateY(angle * 2 + phase * 0.1);
    hint(DISABLE_DEPTH_TEST);
    blendMode(INVERT);
    stroke(cubeColors.get(1));
    noFill();
    box(500);
    blendMode(BLEND);
    hint(ENABLE_DEPTH_TEST);
  popMatrix();

  hint(DISABLE_DEPTH_TEST);
  pushMatrix();
    camera();
    textAlign(LEFT, TOP);
    textSize(48);
    fill(255);
    text(songName, 20, 20);
  popMatrix();
  hint(ENABLE_DEPTH_TEST);
}

}
