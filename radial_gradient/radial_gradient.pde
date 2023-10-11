void setup() {
  size(1920, 1080);
  noStroke();
  ellipseMode(RADIUS);
}

void draw() {
  background(20, 70, 28);
  drawLights();
  frameRate(1);
  //saveFrame("frames/####.tif");
}

void drawLights() {
  // fits the screen
  //int radius = min(width, height) / 2;
  
  //fills the screen 
  int radius = max(width, height) / 2;
  
   //bakcground color divided to red, green and blue
   int red = 20;
   int green = 70;
   int blue = 28;
   
   int targetRed = 0;
   int targetGreen = 100;
   int targetBlue = 17;
   
   int gradientStep = 1;
   
    for (int r = radius; r > 0; --r) {
      fill(red, green, blue);
      ellipse(width/2, height/2, r, r);
      
      //two / more lines of same color each, to have slower blend
      if (r % 8 == 0) {
        if (red != targetRed && red < targetRed) {
          red = red + gradientStep;
        } else if (red != targetRed && red > targetRed) {
          red = red - gradientStep;
        }
        if (green != targetGreen && green < targetGreen) {
          green = green + gradientStep;
        } else if (green != targetGreen && green > targetGreen) {
          green = green - gradientStep;
        }
        if (blue != targetBlue && blue < targetBlue) {
          blue = blue + gradientStep;
        } else if (blue != targetBlue && blue > targetBlue) {
          blue = blue - gradientStep;
        }
      }
    }
}
