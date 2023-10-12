// The Flock (a list of Boid objects)

class Flock {
	ArrayList<Boid> boids; // An ArrayList for all the boids
	ChaosTimer timer;
	int time;
	
	Flock() {
	  boids = new ArrayList<Boid>(); // Initialize the ArrayList
	  time = millis();
	  timer = new ChaosTimer(time); 
	}
	
	void run() {
	  time = millis();
	  boolean isCornerTime = timer.checkIsCornerTime(time);
	  for (Boid b : boids) {
	    b.run(boids, isCornerTime, time);  // Passing the entire list of boids to each boid individually
	  }
	}
	
	void addBoid(Boid b) {
	  boids.add(b);
	}
	
}
