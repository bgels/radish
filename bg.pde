import processing.data.*;

enum Style { HEXAGON, RAIN }
// ─────────────────────────────────────────────────────────────
class BackgroundAnimator {

  /* ---------- external knobs ---------- */
  private Style style = Style.RAIN;           // default

  void toggleVisualMode() {
    style = (style == Style.HEXAGON) ? Style.RAIN : Style.HEXAGON;
  }
  void setRainMode(boolean on){ style = on?Style.RAIN:Style.HEXAGON; }

  /* ---------- refs & basic data ---------- */
  final BeatClock beat;
  String          songName;

  /* shared colour list (JSON-configurable) */
  final ArrayList<Integer> bgColors = new ArrayList<Integer>();
  color currentBgColor;

  /* ---------- HEXAGON / STAR visual ---------- */
  final ArrayList<Hexagon> hexagons = new ArrayList<Hexagon>();
  final ArrayList<Star>    stars    = new ArrayList<Star>();

  final float SHRINK_RATE    =  2.0;     // px / frame
  final int   STARS_PER_RING = 50;
  final int   SPAWN_BEATS    =  1;       // every beat

  /* ---------- RAIN visual ---------- */
  final ArrayList<Raindrop> raindrops = new ArrayList<Raindrop>();
  final int   NUM_DROPS    = 120;
  final int   TRAIL_LEN    = 6;

  /* ---------- geometry helpers ---------- */
  final float centreX, centreY, maxRadius;

  final color carrotCol  = color(255,147,41);
  final color darkCarrot = darkenColor(carrotCol,0.70);

  final PGraphics pg;                      // off-screen buffer

  /* ───────────────────────────────────────────────────────── */
  BackgroundAnimator(BeatClock beat, String songName) {
    this.beat     = beat;
    this.songName = songName;

    /* two safe fallback colours (overwritten by JSON) */
    bgColors.add(color(57, 54, 70));
    bgColors.add(color(244,238,224));
    currentBgColor = bgColors.get(0);

    centreX   = width  * .5;
    centreY   = height * .5;
    maxRadius = dist(0,0, centreX, centreY) * 1.5;

    hexagons.add(new Hexagon(maxRadius, carrotCol));   // first ring

    /* build rain pool */
    for (int i=0;i<NUM_DROPS;i++) raindrops.add(new Raindrop());

    pg = createGraphics(width, height, P3D);
  }

  /* ----------- config from JSON ----------- */
  void applyConfig(JSONObject cfg){
    if (cfg.hasKey("background")){
      JSONObject bg = cfg.getJSONObject("background");
      if (bg.hasKey("colors")){
        bgColors.clear();
        JSONArray arr = bg.getJSONArray("colors");
        for (int i=0;i<arr.size();i++){
          JSONArray c = arr.getJSONArray(i);
          bgColors.add(color(c.getInt(0),c.getInt(1),c.getInt(2)));
        }
        currentBgColor = bgColors.get(0);
      }
    }
  }

  /* ───────────────────────────────────────────────────────── */
  void update(){

    // colour beat flash (shared)
    if (beat.everyOnce(1) && !bgColors.isEmpty())
      currentBgColor = bgColors.get(int(random(bgColors.size())));

    if (style == Style.HEXAGON){
      if (beat.everyOnce(SPAWN_BEATS)) spawnHexRing();
      redrawHexagonPG();
    } else {                          // RAIN
      redrawRainPG();
    }

    // push buffer to screen
    image(pg,0,0);

    /* song title */
    hint(DISABLE_DEPTH_TEST);
    fill(255); textSize(48); textAlign(LEFT,TOP);
    text(songName,20,20);
    hint(ENABLE_DEPTH_TEST);
  }

  /* ──────── HEXAGON logic ────────────────────────────────── */
  void spawnHexRing(){
    color col = (hexagons.size()%2==0)?carrotCol:darkCarrot;
    hexagons.add(new Hexagon(maxRadius,col));

    float visible = max(width,height)*0.6;
    for(int i=0;i<STARS_PER_RING;i++){
      float ang=random(TWO_PI);
      float r  =random(visible);
      float sx =centreX+cos(ang)*r;
      float sy =centreY+sin(ang)*r;
      stars.add(new Star(new PVector(sx,sy),
                         PVector.random2D().mult(0.5),
                         random(1,3),
                         color(255)));
    }
  }

  void redrawHexagonPG(){
    pg.beginDraw();
    pg.background(currentBgColor);

    for (int i=stars.size()-1;i>=0;i--){
      Star s=stars.get(i); s.update(); s.display(pg);
      if (s.isGone()) stars.remove(i);
    }

    for (int i=hexagons.size()-1;i>=0;i--){
      Hexagon h=hexagons.get(i); h.update(); h.display(pg);
      if (h.isGone()) hexagons.remove(i);
    }
    pg.endDraw();
  }

  /* ──────── RAIN logic ───────────────────────────────────── */
  void redrawRainPG(){
    pg.beginDraw();
    pg.background(currentBgColor);

    for (Raindrop d: raindrops){
      d.update();
      d.display(pg);
    }
    pg.endDraw();
  }

  /* ──────── inner types ──────────────────────────────────── */
  class Hexagon{
    float r; color col;
    Hexagon(float r,color c){this.r=r;col=c;}
    void update(){ r -= SHRINK_RATE; }
    boolean isGone(){ return r<=500; }
    void display(PGraphics g){
      g.stroke(col); g.noFill();
      g.beginShape();
      for(int i=0;i<6;i++){
        float a=radians(60*i);
        g.vertex(centreX+cos(a)*r, centreY+sin(a)*r);
      }
      g.endShape(CLOSE);
    }
  }

  class Star{
    PVector pos,vel; float sz; color col;
    Star(PVector p,PVector v,float s,color c){pos=p.copy();vel=v;sz=s;col=c;}
    void update(){ pos.add(vel); vel.add(PVector.random2D().mult(0.02)); }
    boolean isGone(){return pos.x<-10||pos.x>width+10||pos.y<-10||pos.y>height+10;}
    void display(PGraphics g){ g.stroke(col); g.strokeWeight(sz); g.point(pos.x,pos.y); }
  }

  /* ========== RAIN classes ========== */
  class Raindrop{
    float x,y,speed,angle,len;
    final ArrayList<PVector> trail = new ArrayList<PVector>();
    Raindrop(){ reset(); }
    void reset(){
      x=random(width);
      y=random(-height,0);
      speed=random(5,15);
      angle=random(-PI/6, PI/6);
      len=random(10,20);
      trail.clear();
    }
    void update(){
      trail.add(new PVector(x,y));
      if (trail.size()>TRAIL_LEN) trail.remove(0);

      y += speed * cos(angle);
      x += speed * sin(angle);

      if (y>height || x<0 || x>width) reset();
    }
    void display(PGraphics g){
      g.noFill();
      for(int i=0;i<trail.size();i++){
        float a = map(i,0,TRAIL_LEN,120,0);   // fade
        g.stroke(255,a); g.strokeWeight(2);
        PVector p = trail.get(i);
        g.line(p.x,p.y,
               p.x+len*sin(angle)*0.5,
               p.y+len*cos(angle)*0.5);
      }
      g.stroke(255); g.strokeWeight(2);
      g.line(x,y, x+len*sin(angle), y+len*cos(angle));
    }
  }
}
