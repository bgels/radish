// ---------------------------------------------------------------
// LaneUI – translucent 1/8-ring that flashes on hit / miss
// ---------------------------------------------------------------
class LaneUI {
  int lane;
  float alpha = 80;           // base alpha
  float pulse = 0;            // 0→1 animates flash

  LaneUI(int lane){ this.lane=lane; }

  void pulse(boolean good){
    // good = blue flash, bad = red flash
    pulse = good ? 1.0 : -1.0;
  }

  void draw(){
    if(abs(pulse) > 0.01){
      pulse *= 0.90;          // decay
    }

    pushMatrix();
      float a = laneAngle(lane);
      translate(width/2, height/2);
      rotate(a);
      noFill();
      stroke( pulse>0 ? color(0,200,255,200*pulse)
                      : color(255,0,0,-200*pulse));
      strokeWeight(10);
      arc(0,0, JUDGE_RADIUS*2, JUDGE_RADIUS*2,
          -PI/8, PI/8);
    popMatrix();
  }
}

// ---------------------------------------------------------------
// SpecialUI – outer circular band for space-bar notes
// ---------------------------------------------------------------
class SpecialUI {
  float pulse = 0;

  void pulse(boolean good){
    pulse = good ? 1.0 : -1.0;
  }

  void draw(){
    if(abs(pulse) > 0.01) pulse *= 0.90;

    noFill();
    stroke( pulse>0 ? color(255,200,0,200*pulse)
                    : color(255,0,0,-200*pulse) );
    strokeWeight(12);
    ellipse(width/2, height/2, SPECIAL_RADIUS*2, SPECIAL_RADIUS*2);
  }
}
