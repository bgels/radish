class EndScreen {
  String songTitle;
  float  acc;
  int hitR, missR, hitS, missS, maxCombo;

  EndScreen(Play p) {
    songTitle = p.entry.folderName;
    acc       = p.getAccuracy();
    hitR      = p.getHitReg();   missR = p.getMissReg();
    hitS      = p.getHitSpec();  missS = p.getMissSpec();
    maxCombo  = p.getMaxCombo();
  }

  void draw() {
    background(30);
    fill(255);
    textAlign(CENTER, CENTER);

    textSize(52);
    text(songTitle, width/2, 100);

    textSize(32);
    text("Accuracy: " + nf(acc,1,2) + " %", width/2, 200);
    text("Regular  hit/miss : " + hitR + " / " + missR, width/2, 260);
    text("Special  hit/miss : " + hitS + " / " + missS, width/2, 310);
    text("Max combo: " + maxCombo, width/2, 360);

    // button
    int bw=280, bh=70;
    int bx=width/2-bw/2, by=height-160;
    fill(over(bx,by,bw,bh)?120:70);
    rect(bx,by,bw,bh,10);
    fill(255); textSize(28);
    text("Return to Menu", width/2, by+bh/2);
  }

  boolean over(int x,int y,int w,int h) {
    return mouseX>x&&mouseX<x+w&&mouseY>y&&mouseY<y+h;
  }
  boolean onButton() {
    int bw=280,bh=70,bx=width/2-bw/2,by=height-160;
    return over(bx,by,bw,bh);
  }
}
