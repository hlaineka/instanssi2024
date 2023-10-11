// The Boid class

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
  int x = 640;
  int y = 360;
  float cornerseeking = 1.5;
  ChaosTimer timer;

    Boid(float x, float y) {
    acceleration = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    position = new PVector(x, y);
    maxspeed = 3;
    maxforce = 0.03;
    timer = new ChaosTimer(millis()); 
  }

  void run(ArrayList<Boid> boids) {
    flock(boids);
    borders();
    update();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M{
      acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
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
      if (position.x < r2) velocity.x = velocity.x * -1;
      if (position.y < r2) velocity.y = velocity.y * -1;
      if (position.x > width-r2) velocity.x = velocity.x * -1;
      if (position.y > height-r2) velocity.y = velocity.y * -1;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 50.0f;
    if (timer.checkIsCornerTime(millis())) {
      desiredseparation = 0.2f;
    }
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      
      /*if (timer.checkIsCornerTime(millis())) {
        float distanceFromCornerX = position.x;
        float distanceFromCornerY = position.y;
        if (position.x > x / 2) {
          distanceFromCornerX = x - position.x;
        }
        if (position.y > y / 2) {
          distanceFromCornerY = y - position.y;
        }
        
        float maxforceCorrectorX = distanceFromCornerX / (x / 200);
        float maxforceCorrectorY = distanceFromCornerY / (y / 200);
        float maxforceCorrector =  maxforceCorrectorY;
        if (maxforceCorrectorX < maxforceCorrectorY) {
          maxforceCorrector =  maxforceCorrectorX;
        }
        maxforce = maxforce * maxforceCorrector;
    }*/
      
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 1000;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 5000;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      
      if (timer.checkIsCornerTime(millis())) {
        if (sum.x > x / 2) {
          sum.x = sum.x * cornerseeking;
        }
        else {
          sum.x = sum.x / cornerseeking;
        }
        if (sum.y > y / 2) {
          sum.y = sum.y * cornerseeking;
        }
        else {
          sum.y = sum.y / cornerseeking;
        }
      }else {
      if (sum.x > x / 2) {
          sum.x = sum.x / cornerseeking;
        }
        else {
          sum.x = sum.x * cornerseeking;
        }
        if (sum.y > y / 2) {
          sum.y = sum.y / cornerseeking;
        }
        else {
          sum.y = sum.y * cornerseeking;
        }
      }
      return seek(sum);  // Steer towards the position
    } 
    else {
      return new PVector(0, 0);
    }
  }
  
  void star(float x, float y, float radius1, float radius2, int npoints) {
    float angle = TWO_PI / npoints;
    float halfAngle = angle/2.0;
    pushMatrix();
    translate(position.x, position.y);
    beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = cos(a) * radius2;
      float sy = sin(a) * radius2;
      vertex(sx, sy);
      sx = cos(a+halfAngle) * radius1;
      sy = sin(a+halfAngle) * radius1;
      vertex(sx, sy);
    }
    endShape(CLOSE);
    
    if (timer.checkIsEyesOpen(millis())) {
      //eyes
      fill(white);
      circle((radius2 - radius1 - 4) / 2, (radius2 - radius1) / 2, 8);
      circle((radius2 - radius1 + 12) / 2, (radius2 - radius1) / 2, 8);
      
      fill(black);
      circle((radius2 - radius1 - 1) / 2, (radius2 - radius1) / 2, 2);
      circle((radius2 - radius1 + 9) / 2, (radius2 - radius1) / 2, 2);
    }
    
    popMatrix();
  }

}
