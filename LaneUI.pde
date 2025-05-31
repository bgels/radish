// LaneUI.pde
class LaneUI {
  int lane;
  color baseCol  = color(200,200,200,120);
  color flashCol = color(0,255,120);
  color missCol  = color(255,40,40);
  float flashT   = 0;          // 0..1 fades
  LaneUI(int lane){ this.lane=lane; }
  void pulse(boolean good){
    flashT = 1;
    baseCol = good ? flashCol : missCol;
  }
  void draw(){
    float angle = laneAngle(lane);
    pushMatrix();
      translate(width/2, height/2);
      rotate(angle);
      noFill();
      stroke(lerpColor(color(200,200,200,80), baseCol, flashT));
      strokeWeight(6);
      arc(0,0, JUDGE_RADIUS*2, JUDGE_RADIUS*2, -PI/8, PI/8);
    popMatrix();
    flashT = max(0, flashT - 0.2);
    if(flashT==0) baseCol = color(200,200,200,120);
  }
}

class SpecialUI {
  float flashT=0;
  void pulse(boolean good){ flashT=1; }
  void draw(){
    noFill();
    stroke( lerpColor(color(200,200,200,80), color(0,255,120), flashT) );
    strokeWeight(5);
    ellipse(width/2, height/2, SPECIAL_RADIUS*2, SPECIAL_RADIUS*2);
    flashT = max(0, flashT-0.1);
  }
}
