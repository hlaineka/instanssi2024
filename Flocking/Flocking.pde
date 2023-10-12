Flock flock;

color greenLight = color(96, 255, 124);
color greenDark = color(0, 100,17);

ChaosTimer timer;

PImage img_light;
PImage img_dark;

void setup() {
	size(1920, 1080);
	flock = new Flock();
	timer = new ChaosTimer(millis());
	img_light = loadImage("lightsOn.png");
	img_dark = loadImage("lightsOff.png");
	frameRate(60);
	// Add an initial set of boids into the system
	for (int i = 0; i < 15; i++) {
	  flock.addBoid(new Boid(width / 2,height / 2));
	}
}

void draw() {
	PImage img;
	if (timer.checkIsCornerTime(millis())) {
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
