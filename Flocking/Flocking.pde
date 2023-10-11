Flock flock;

color greenLight = color(96, 255, 124);
color greenDark = color(0, 100,17);

ChaosTimer timer;

void setup() {
  size(1920, 1080);
  flock = new Flock();
  timer = new ChaosTimer(millis());
  // Add an initial set of boids into the system
  for (int i = 0; i < 20; i++) {
    flock.addBoid(new Boid(width/2,height/2));
  }
}

void draw() {
 PImage img;
 if (timer.checkIsCornerTime(millis())) {
   //lights are on
   img = loadImage("lightsOn.png");
   
 } else {
   //lights are off
   img = loadImage("lightsOff.png");
 }
 background(img);
  frameRate(24);
  flock.run();
  //saveFrame("frames/####.tif");
}
