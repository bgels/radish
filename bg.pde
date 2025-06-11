// BackgroundAnimator.pde ----------------------------------------
import processing.data.*;

// ----------------------------------------------------------------
// Renders the heavy rotating 3-D scene once per beat into a
// PGraphics (bgPG) to lighten the main draw() load.
// Only lightweight beat-synced overlays are done live.
// ----------------------------------------------------------------
class BackgroundAnimator {

  BeatClock beat;
  String    songName;

  // colour lists -------------------------------------------------
  ArrayList<Integer> bgColors   = new ArrayList<Integer>();
  color              currentBgColor;
  ArrayList<Integer> cubeColors = new ArrayList<Integer>();

  // cached graphics ---------------------------------------------
  PGraphics bgPG;            // holds 3-D background

  BackgroundAnimator(BeatClock beat, String songName) {
    this.beat     = beat;
    this.songName = songName;

    // default colours (will be overwritten by JSON if provided)
    addCubeColor(color(79,  69,  87));
    addCubeColor(color(109, 93, 110));
    addBgColor  (color(57,  54,  70));
    addBgColor  (color(244, 238, 224));
    currentBgColor = bgColors.get(0);

    bgPG = createGraphics(width, height, P3D);
    redrawPG();             // draw first frame immediately
  }

  // config -------------------------------------------------------
  void setSongName(String s) {
    songName = s;
  }

  void applyConfig(JSONObject cfg) {
    // -- parse "background" → "colors" array of [r,g,b]
    if (cfg.hasKey("background")) {
      JSONObject bg = cfg.getJSONObject("background");
      if (bg.hasKey("colors")) {
        bgColors.clear();
        JSONArray arr = bg.getJSONArray("colors");
        for (int i = 0; i < arr.size(); i++) {
          JSONArray c = arr.getJSONArray(i);
          int r = c.getInt(0);
          int g = c.getInt(1);
          int b = c.getInt(2);
          addBgColor(color(r, g, b));
        }
      }
    }

    // -- parse "shapes" → "cubeColors" array of [r,g,b]
    if (cfg.hasKey("shapes")) {
      JSONObject sh = cfg.getJSONObject("shapes");
      if (sh.hasKey("cubeColors")) {
        cubeColors.clear();
        JSONArray arr = sh.getJSONArray("cubeColors");
        for (int i = 0; i < arr.size(); i++) {
          JSONArray c = arr.getJSONArray(i);
          int r = c.getInt(0);
          int g = c.getInt(1);
          int b = c.getInt(2);
          addCubeColor(color(r, g, b));
        }
      }
    }

    // set initial background colour to the first entry, if any
    if (!bgColors.isEmpty()) {
      currentBgColor = bgColors.get(0);
    }

  }

  void addBgColor(int c) {
    bgColors.add(c);
  }

  void addCubeColor(int c) {
    cubeColors.add(c);
  }

  // --------------------------------------------------------------
  void update() {
    // 1) change background colour once per whole beat
    if (beat.everyOnce(1)) {
      int idx = int(random(bgColors.size()));
      currentBgColor = bgColors.get(idx);
    }

    redrawPG();
    // 3) blit the cached 3-D scene
    image(bgPG, 0, 0);

    // 4) lightweight overlays (song title)
    hint(DISABLE_DEPTH_TEST);
    fill(255);
    textSize(48);
    textAlign(LEFT, TOP);
    text(songName, 20, 20);
    hint(ENABLE_DEPTH_TEST);
  }

  // --------------------------------------------------------------
  void redrawPG() {
    bgPG.beginDraw();
      bgPG.background(currentBgColor);

      // compute “phase” inside current beat (0…1)
      beat.phase();
      float ang = TWO_PI * beat.getBeat();

      // first rotating cube -------------------------------------
      bgPG.pushMatrix();
        bgPG.translate(width/2, height/2, 0);
        bgPG.rotateX(ang + 0.1);
        bgPG.rotateY(ang * 0.5 + 0.05);
        bgPG.fill(cubeColors.get(0));
        bgPG.noStroke();
        bgPG.box(200);
      bgPG.popMatrix();

      // wireframe cube ------------------------------------------
      bgPG.pushMatrix();
        bgPG.translate(width/2, height/2, 0);
        bgPG.rotateY(ang * 2 + 0.1);
        bgPG.noFill();
        bgPG.stroke(cubeColors.get(1));
        bgPG.strokeWeight(3);
        bgPG.box(300);
      bgPG.popMatrix();

    bgPG.endDraw();
  }
}
