Flock flock;

color greenLight = color(96, 255, 124);
color greenDark = color(0, 100,17);

ChaosTimer timer;

PImage img_light;
PImage img_dark;

void setup() {
	size(1920, 1080);
	flock = new Flock();
	timer = new ChaosTimer();
	img_dark = loadImage("wall_1.png");
	img_light = loadImage("wall_2.png");
	frameRate(60);
	// Add an initial set of boids into the system
	for (int i = 0; i < 15; i++) {
	  flock.addBoid(new Boid(width/2, height/2));
	}
}

void draw() {
  timer.update();
	PImage img;
	if (timer.checkIsCornerTime()) {
	 //lights are on
	 img = img_light;
	 
} else {
	 //lights are off
	 img = img_dark;
}
	background(img);
	flock.run();
	//saveFrame("frames/####.tif");
}
