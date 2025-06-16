
import processing.sound.*;

class SongMap {
  PApplet parent;
  final int TILE = 280;

  HashMap<String, Node> grid = new HashMap<String, Node>();
  ArrayList<Node>       nodes;
  Node                  cur, prev;
  PFont                 tipFont;

  float viewX=0, viewY=0, targetX=0, targetY=0;
  float tipAlpha = 0;

  SongMap(PApplet parent, ArrayList<SongEntry> entries) {
    this.parent = parent;
    nodes = new ArrayList<Node>();
    int cols=5, col=0, row=0;
    for (SongEntry se: entries) {
      Node n=new Node(se,col,row);
      nodes.add(n);
      grid.put(key(col,row),n);
      if(++col>=cols){col=0;row++;}
    }
    cur = nodes.isEmpty()?null:nodes.get(0);
    prev=cur;
    targetX = parent.width/2 - cur.x();
    targetY = parent.height/2 - cur.y();
    viewX=targetX; viewY=targetY;

    for (Node n: nodes) {
      n.up    = grid.get(key(n.c,n.r-1));
      n.down  = grid.get(key(n.c,n.r+1));
      n.left  = grid.get(key(n.c-1,n.r));
      n.right = grid.get(key(n.c+1,n.r));
    }
    tipFont = parent.createFont("Arial",20,true);
  }

  String key(int c,int r){ return c+","+r; }

  void move(int dx,int dy){
    if(cur==null) return;
    Node nxt = (dx==1)?cur.right:
               (dx==-1)?cur.left:
               (dy==1)?cur.down:
               (dy==-1)?cur.up:null;
    if(nxt!=null){
      prev=cur; cur=nxt;
      targetX = parent.width/2 - cur.x();
      targetY = parent.height/2 - cur.y();
      tipAlpha=0;
    }
  }

  SongEntry getSelected(){ return cur==null?null:cur.song; }

  void update(){
    drawBackground();
    viewX = parent.lerp(viewX, targetX, 0.12f);
    viewY = parent.lerp(viewY, targetY, 0.12f);

    // white connection lines
    parent.stroke(255);
    parent.strokeWeight(4);
    for(Node n: nodes){
      if(n.right!=null)
        parent.line(n.x()+viewX,n.y()+viewY,
                    n.right.x()+viewX,n.right.y()+viewY);
      if(n.down!=null)
        parent.line(n.x()+viewX,n.y()+viewY,
                    n.down.x()+viewX,n.down.y()+viewY);
    }

    // nodes
    parent.noStroke();
    for(Node n: nodes){
      parent.fill(n==cur?255:180);
      parent.ellipse(n.x()+viewX,n.y()+viewY,
                     n==cur?56:48,
                     n==cur?56:48);
    }

    // cursor ring
    parent.noFill();
    parent.stroke(255);
    parent.strokeWeight(4);
    parent.ellipse(parent.width/2,parent.height/2,72,72);

    drawTooltip();
  }

  //pulsating bg…
  void drawBackground(){
    parent.background(0);
    float pulse = parent.sin(parent.frameCount*0.05f)*50;
    float eW=400+pulse, eH=100+pulse*0.4f;
    int layers=50;
    for(int i=layers;i>=0;i--){
      float t=i/(float)layers;
      int c=parent.lerpColor(
        parent.color(57, 54, 70),
        parent.color(0),
        t
      );
      parent.fill(c,255*(1-t));
      parent.ellipse(parent.width/2,parent.height/2,
                     eW+i*50,eH+i*30);
    }
    parent.fill(0,50); parent.noStroke();
    parent.rect(0,0,parent.width,parent.height/4f);
    parent.rect(0,parent.height*3/4f,parent.width,parent.height/4f);
    parent.rect(0,0,parent.width/4f,parent.height);
    parent.rect(parent.width*3/4f,0,parent.width/4f,parent.height);
  }

  void drawTooltip(){
    if(cur==null) return;
    // fade in
    tipAlpha = parent.lerp(tipAlpha,255,0.1f);

    // load metadata + difficulty
    SongEntry s = cur.song;
    SMChart ch = readSM(s.smFile);
    float bpm=ch.bpm;
    float len=0;
    try {
      SoundFile tmp=new SoundFile(parent,s.audioFile.getAbsolutePath());
      len=tmp.duration(); tmp.stop();
    } catch(Exception e){ }
    String diff = ch.difficulty;

    // screen coords
    float sx=cur.x()+viewX, sy=cur.y()+viewY;
    int w=340,h=140;
    int x = (int)(sx - w/2);
    int y = (int)(sy - h - 40);

    // —— difficulty label above box —— 
    parent.textFont(tipFont);
    parent.textAlign(LEFT, BOTTOM);
    parent.fill(255, tipAlpha);
    parent.text(diff, x, y-8);
    // colored square next to it
    int dc;
    switch(diff.toLowerCase()){
      case "novice": dc=parent.color(128,0,128); break;
      case "easy":   dc=parent.color(0,255,0);    break;
      case "medium": dc=parent.color(255,165,0);  break;
      case "hard":   dc=parent.color(255,0,0);    break;
      case "expert": dc=parent.color(0,0,0);      break;
      default:       dc=parent.color(200);        break;
    }
    parent.noStroke();
    parent.fill(dc, tipAlpha);
    parent.rect(x + parent.textWidth(diff) + 24, y-24, 16, 16, 4);

    // —— info box —— 
    parent.fill(57, 54, 70);
    parent.noStroke();
    parent.rect(x, y, w, h, 10);

    parent.fill(255, tipAlpha);
    parent.textAlign(LEFT, TOP);
    parent.text(s.folderName,        x+14, y+12);
    parent.text("BPM   : "+parent.nf(bpm,0,1), x+14, y+44);
    parent.text("Length: "+parent.nf(len,0,1)+" s", x+14, y+72);
    parent.text("SPACE to play",          x+14, y+102);
  }

  class Node {
    int c,r; SongEntry song;
    Node up,down,left,right;
    Node(SongEntry s,int c,int r){ song=s; this.c=c; this.r=r; }
    float x(){return c*TILE;}
    float y(){return r*TILE;}
  }
}
