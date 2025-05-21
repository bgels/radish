import processing.soun

void setup() {
  size(800, 600);
  background(255);
  noStroke();
  fill(255, 0, 0);
  
  // Draw the radish
  ellipse(width/2, height/2, 100, 100); // Radish body
  fill(0, 255, 0);
  beginShape();
  vertex(width/2 - 20, height/2 - 50);
  vertex(width/2 + 20, height/2 - 50);
  vertex(width/2 + 10, height/2 - 80);
  vertex(width/2 - 10, height/2 - 80);
  endShape(CLOSE); // Radish leaves
}

void draw() {
  
}
