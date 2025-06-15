class LaneUI {
  int lane;                 // which of the 8 octants this UI belongs to
  float alpha = 255;         //  opacity of the outline
  float pulse = 0;          // fades from ±1 → 0 to show hit (blue) or miss (red)

  LaneUI(int lane){
    this.lane = lane;
  }

  /** Call when a note in this lane is judged. */
  void pulse(boolean good){
    // good = true  → blue flash
    // good = false → red  flash
    pulse = good ? 1.0 : -1.0;
  }

  void draw(){
    pushMatrix();
      float a = laneAngle(lane);       // helper from Constants.pde
      translate(width/2, height/2);
      rotate(a);

      // persistent faint outline so the player always sees the lane
      noFill();
      stroke(20, alpha);              // white @ baseline alpha
      strokeWeight(20);
      arc(0, 0, JUDGE_RADIUS*2, JUDGE_RADIUS*2,
          -PI/8, PI/8);

      //  overlay flash that fades out each frame
      if (abs(pulse) > 0.01) {
        stroke(pulse > 0 ? color(152, 166, 154, 200 * pulse)
                         : color(255, 0, 0,   200 * -pulse));
        arc(0, 0, JUDGE_RADIUS*2, JUDGE_RADIUS*2,
            -PI/8, PI/8);
        pulse *= 0.90;                // exponential decay
      }
    popMatrix();
  }
}


class SpecialUI {
  float alpha = 60;          // baseline opacity for the static ring
  float pulse = 0;           // +/-1 → 0 flash value

  void pulse(boolean good){
    pulse = good ? 1.0 : -1.0;
  }

  void draw(){
    //persistent faint outline so timing is visible even when idle
    noFill();
    stroke(50, alpha);
    strokeWeight(24);
    ellipse(width/2, height/2, SPECIAL_RADIUS*2, SPECIAL_RADIUS*2);

    // overlay flash
    if (abs(pulse) > 0.01) {
      stroke(pulse > 0 ? color(255, 200, 0, 200 * pulse)
                       : color(255, 0, 0, 200 * -pulse));
      ellipse(width/2, height/2, SPECIAL_RADIUS*2, SPECIAL_RADIUS*2);
      pulse *= 0.90;
    }
  }
}
