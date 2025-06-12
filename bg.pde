
import processing.data.*;

class BackgroundAnimator {


  BeatClock beat;
  String    songName;


  ArrayList<Integer> bgColors   = new ArrayList<Integer>();
  ArrayList<Integer> cubeColors = new ArrayList<Integer>(); // kept for JSON parsing
  color              currentBgColor;

  ArrayList<Hexagon> hexagons = new ArrayList<Hexagon>();
  ArrayList<Star>    stars    = new ArrayList<Star>();

  final float SHRINK_RATE     = 2.0;   // px per frame
  final int   STARS_PER_RING  = 50;
  final int   SPAWN_BEATS     = 1;     // ring every 4 beats

  float centreX, centreY, maxRadius;

  final color carrotCol  = color(255,147,41);
  final color darkCarrot = darkenColor(carrotCol,0.70);

  PGraphics bgPG;

  BackgroundAnimator(BeatClock beat, String songName) {
    this.beat     = beat;
    this.songName = songName;

    // two safe default colours (can be overwritten by JSON)
    addBgColor(color(57, 54, 70));     // slate
    addBgColor(color(244,238,224));    // parchment
    currentBgColor = bgColors.get(0);

    // geometry helpers
    centreX   = width  * 0.5;
    centreY   = height * 0.5;
    maxRadius = dist(0,0,centreX,centreY) * 1.5;

    // first wave already present
    hexagons.add(new Hexagon(maxRadius, carrotCol));

    bgPG = createGraphics(width, height, P3D);   // keep P3D to match old buffer
  }


  void setSongName(String s) { songName = s; }

  void addBgColor(int c)   { bgColors.add(c);   }
  void addCubeColor(int c) { cubeColors.add(c); }  // still parsed, just unused

  void applyConfig(JSONObject cfg) {

    //background colours
    if (cfg.hasKey("background")) {
      JSONObject bg = cfg.getJSONObject("background");
      if (bg.hasKey("colors")) {
        bgColors.clear();
        JSONArray arr = bg.getJSONArray("colors");
        for (int i=0;i<arr.size();i++) {
          JSONArray c = arr.getJSONArray(i);
          addBgColor(color(c.getInt(0), c.getInt(1), c.getInt(2)));
        }
      }
    }

    // (ignored visually but kept for legacy)
    if (cfg.hasKey("shapes")) {
      JSONObject sh = cfg.getJSONObject("shapes");
      if (sh.hasKey("cubeColors")) {
        cubeColors.clear();
        JSONArray arr = sh.getJSONArray("cubeColors");
        for (int i=0;i<arr.size();i++) {
          JSONArray c = arr.getJSONArray(i);
          addCubeColor(color(c.getInt(0), c.getInt(1), c.getInt(2)));
        }
      }
    }

    if (!bgColors.isEmpty()) currentBgColor = bgColors.get(0);
  }

  /* ─────────────────────────────────────────────────────────── */
  void update() {

    //  change background every beat
    if (beat.everyOnce(1) && !bgColors.isEmpty()) {
      currentBgColor = bgColors.get(int(random(bgColors.size())));
    }

    //  spawn a new ring every 4 beats
    if (beat.everyOnce(SPAWN_BEATS)) spawnRing();

    //  redraw into buffer
    redrawPG();

    //  blit buffer & song title overlay
    image(bgPG,0,0);

    hint(DISABLE_DEPTH_TEST);
    fill(255); textSize(48); textAlign(LEFT,TOP);
    text(songName,20,20);
    hint(ENABLE_DEPTH_TEST);
  }


  void spawnRing() {
    color col = (hexagons.size()%2==0)? carrotCol : darkCarrot;
    hexagons.add(new Hexagon(maxRadius, col));

    float visibleMax = max(width,height)*0.6;
    for (int i=0;i<STARS_PER_RING;i++){
      float ang = random(TWO_PI);
      float r   = random(visibleMax);
      float sx  = centreX + cos(ang)*r;
      float sy  = centreY + sin(ang)*r;
      stars.add(new Star(new PVector(sx,sy),
                         PVector.random2D().mult(0.5),
                         random(1,3),
                         color(0)));        // black debug dots
    }
  }

  void redrawPG(){
    bgPG.beginDraw();
      bgPG.background(currentBgColor);

      // ----- stars -----
      for (int i=stars.size()-1;i>=0;i--){
        Star s = stars.get(i);
        s.update();  s.display(bgPG);
        if (s.isGone()) stars.remove(i);
      }

      // ----- hex rings -----
      for (int i=hexagons.size()-1;i>=0;i--){
        Hexagon h = hexagons.get(i);
        h.update();  h.display(bgPG);
        if (h.isGone()) hexagons.remove(i);
      }

    bgPG.endDraw();
  }


  class Hexagon{
    float radius;  color col;
    Hexagon(float r,color c){ radius=r; col=c; }
    void update(){ radius -= SHRINK_RATE; }
    boolean isGone(){ return radius<=500; }
    void display(PGraphics g){
      g.stroke(col); g.noFill();
      g.beginShape();
      for (int i=0;i<6;i++){
        float a = radians(60*i);
        g.vertex(centreX+cos(a)*radius,
                 centreY+sin(a)*radius);
      }
      g.endShape(CLOSE);
    }
  }

  class Star{
    PVector pos,vel; float sz; color col;
    Star(PVector p,PVector v,float s,color c){
      pos=p.copy(); vel=v.copy(); sz=s; col=c;
    }
    void update(){
      pos.add(vel);
      vel.add(PVector.random2D().mult(0.02));
    }
    boolean isGone(){
      return pos.x<-10||pos.x>width+10||
             pos.y<-10||pos.y>height+10;
    }
    void display(PGraphics g){
      g.stroke(col); g.strokeWeight(sz);
      g.point(pos.x,pos.y);
    }
  }
}
