class Boid {
	
	PVector position;
	PVector velocity;
	PVector acceleration;
	float r1 = 10;
	float r2 = 15;
	float maxforce;    // Maximum steering force
	float maxspeed;    // Maximum speed
	color black = color(39, 39, 39);
	color white = color(240, 240, 240);
	float cornerseeking = 1.5;
	ChaosTimer timer;
	boolean isCornerTime = false;
	PVector steer_seek;
	PVector sum_align;
	PVector sum_coh;
	int count_separate = 0;
	int count_alig_coh = 0;
	int currentTime = 0;
	
	Boid(float x, float y) {
		acceleration = new PVector(0, 0);
		
		// This is a new PVector method not yet implemented in JS
		// velocity = PVector.random2D();
		
		// Leaving the code temporarily this way so that this example runs in JS
		float angle = random(TWO_PI);
		velocity = new PVector(cos(angle), sin(angle));
		
		position = new PVector(x, y);
		maxspeed = 5;
		maxforce = 0.05;
		timer = new ChaosTimer(millis()); 
		
		steer_seek = new PVector(0, 0, 0);
		sum_align = new PVector(0, 0);
		sum_coh = new PVector(0, 0);
	}
	
	void run(ArrayList<Boid> boids, boolean cornerTime, int time) {
		currentTime = time;
		isCornerTime = cornerTime;
		calculate(boids);
		flock();
		borders();
		update();
		render();
	}
	
	void calculate(ArrayList<Boid> boids) {
		 float desiredseparation = 50.0f;
		if (isCornerTime) {
		  desiredseparation = 0.2f;
		}
	  float neighbordist = 5000;
		steer_seek = steer_seek.mult(0); //steer_seek vector to null
		count_separate = 0;
	  count_alig_coh = 0;
		sum_align = sum_align.mult(0);
		sum_coh = sum_coh.mult(0);
		
		for (Boid other : boids) {
		  float d = PVector.dist(position, other.position);
		  // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
		  if ((d > 0) && (d < desiredseparation)) {
		    // Calculate vector pointing away from neighbor
		    PVector diff = PVector.sub(position, other.position);
		    diff.normalize();
		    diff.div(d);        // Weight by distance
		    steer_seek.add(diff);
		    sum_align.add(other.velocity);
		    sum_coh.add(other.position);
		    count_separate++;            // Keep track of how many
		  }
	    if ((d > 0) && (d < neighbordist)) {
	      sum_align.add(other.velocity);
	      sum_coh.add(other.position);
	      count_alig_coh++;            // Keep track of how many
	    }
		}
	      if (count_separate > 0) {
	    steer_seek.div((float)count_separate);
	      }
		if (count_alig_coh > 0) {
		  sum_align.div((float)count_alig_coh);
		  // First two lines of code below could be condensed with new PVector setMag() method
		  // Not using this method until Processing.js catches up
		  // sum.setMag(maxspeed);
			
		  // Implement Reynolds: Steering = Desired - Velocity
		  sum_align.normalize();
		  sum_align.mult(maxspeed);
		}
		  
	}
	
	void applyForce(PVector force) {
		// We could add mass here if we want A = F / M{
		  acceleration.add(force);
	}
	
	// We accumulate a new acceleration each time based on three rules
	void flock() {
		PVector sep = separate();   // Separation
		PVector ali = align();      // Alignment
		PVector coh = cohesion();   // Cohesion
		// Arbitrarily weight these forces
		sep.mult(4.0);
		ali.mult(1.0);
		coh.mult(1.0);
		// Add the force vectors to acceleration
		applyForce(sep);
		applyForce(ali);
		applyForce(coh);
	}
	
	// Method to update position
	void update() {
		// Update velocity
		velocity.add(acceleration);
		// Limit speed
		velocity.limit(maxspeed);
		position.add(velocity);
		// Reset accelertion to 0 each cycle
		acceleration.mult(0);
	}
	
	// A method that calculates and applies a steering force towards a target
	// STEER = DESIRED MINUS VELOCITY
	PVector seek(PVector target) {
		PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
		// Scale to maximum speed
		desired.normalize();
		desired.mult(maxspeed);
		
		// Above two lines of code below could be condensed with new PVector setMag() method
		// Not using this method until Processing.js catches up
		// desired.setMag(maxspeed);
		
		// Steering = Desired minus Velocity
		PVector steer = PVector.sub(desired, velocity);
		steer.limit(maxforce);  // Limit to maximum steering force
		return steer;
	}
	
	void render() {
		// Draw a triangle rotated in the direction of velocity
		
		// heading2D() above is now heading() but leaving old syntax until Processing.js catches up
		fill(black);
		stroke(black);
		star(position.x, position.y, r2, r1, 20);
	}
	
	// Wraparound
	void borders() {
		  if (position.x < r2) velocity.x = velocity.x * - 1;
		  if (position.y < r2) velocity.y = velocity.y * - 1;
		  if (position.x > width - r2) velocity.x = velocity.x * - 1;
		  if (position.y > height - r2) velocity.y = velocity.y * - 1;
	}
	
	// Separation
	// Method checks for nearby boids and steers away
	PVector separate() {
		
		// As long as the vector is greater than 0
		if (steer_seek.mag() > 0) {
		  // First two lines of code below could be condensed with new PVector setMag() method
		  // Not using this method until Processing.js catches up
		  // steer.setMag(maxspeed);
			
		  // Implement Reynolds: Steering = Desired - Velocity
		  steer_seek.normalize();
		  steer_seek.mult(maxspeed);
		  steer_seek.sub(velocity);
		  steer_seek.limit(maxforce);
		}
		return steer_seek;
	}
	
	// Alignment
	// For every nearby boid in the system, calculate the average velocity
	PVector align() {
		if (count_alig_coh > 0) {
		  PVector steer_align = PVector.sub(sum_align, velocity);
		  steer_align.limit(maxforce);
		  return steer_align;
		} else {
		  return new PVector(0, 0);
		}
	}
	
	// Cohesion
	// For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
	PVector cohesion() {
		
		if (count_alig_coh > 0) {
		  sum_coh.div(count_alig_coh);
		  
		  if (isCornerTime) {
		    if (sum_coh.x > width / 2) {
			     sum_coh.x = sum_coh.x * cornerseeking;
			   }
		    else {
			     sum_coh.x = sum_coh.x / cornerseeking;
			   }
		    if (sum_coh.y > height / 2) {
			     sum_coh.y = sum_coh.y * cornerseeking;
			   }
		    else {
			     sum_coh.y = sum_coh.y / cornerseeking;
			   }
		  } else {
		  if (sum_coh.x > width / 2) {
			     sum_coh.x = sum_coh.x / cornerseeking;
			   }
		    else {
			     sum_coh.x = sum_coh.x * cornerseeking;
			   }
		    if (sum_coh.y > height / 2) {
			     sum_coh.y = sum_coh.y / cornerseeking;
			   }
		    else {
			     sum_coh.y = sum_coh.y * cornerseeking;
			   }
		  }
		  return seek(sum_coh);  // Steer towards the position
		} 
		else {
		  return new PVector(0, 0);
		}
	}
	
	void star(float x, float y, float radius1, float radius2, int npoints) {
		float angle = TWO_PI / npoints;
		float halfAngle = angle / 2.0;
		pushMatrix();
		translate(position.x, position.y);
		beginShape();
		for (float a = 0; a < TWO_PI; a += angle) {
		  float sx = cos(a) * radius2;
		  float sy = sin(a) * radius2;
		  vertex(sx, sy);
		  sx = cos(a + halfAngle) * radius1;
		  sy = sin(a + halfAngle) * radius1;
		  vertex(sx, sy);
		}
		endShape(CLOSE);
		
		if (timer.checkIsEyesOpen(currentTime)) {
		  //eyes
		  fill(white);
		  circle((radius2 - radius1 - 4) / 2,(radius2 - radius1) / 2, 8);
		  circle((radius2 - radius1 + 12) / 2,(radius2 - radius1) / 2, 8);
		  
		  fill(black);
		  circle((radius2 - radius1 - 1) / 2,(radius2 - radius1) / 2, 2);
		  circle((radius2 - radius1 + 9) / 2,(radius2 - radius1) / 2, 2);
		}
		
		popMatrix();
	}
	
}
