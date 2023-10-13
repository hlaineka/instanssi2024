class ChaosTimer {
	
	int startChaos = 5000;
	int middleChaosIntervall = 15000;
	int middleChaosDuration = 6000;
	int start;
	int blinkstart;
  float dt = 1;
  int prevTime;
	
	ChaosTimer() {
	  start = millis();
    prevTime = start;
	  blinkstart = 0;
	}

  void update() {
    int t = millis();
    dt = (t - prevTime) / 1000.0;
    prevTime = t;
  }
  
  float getdt() {
    return dt;
  }
	
	boolean checkIsCornerTime() {
    int currentTime = prevTime;
	  if (currentTime - start < startChaos) {
	   return false;
	  }
	  if (currentTime - start > startChaos + middleChaosIntervall && currentTime - start < startChaos + middleChaosIntervall + middleChaosDuration) {
	    return false;
	  }
	  if (currentTime - start > startChaos + middleChaosIntervall + middleChaosDuration + middleChaosIntervall) {
	    return false;
	  }
	  return true;
	}
	
	boolean checkIsEyesOpen() {
  int currentTime = prevTime;
	  if (blinkstart == 0 || (currentTime - blinkstart) > 300) {
	    float random = random(1, 1000);
	    if (random < 30 && checkIsCornerTime()) {
	      blinkstart = currentTime;
	      return(true);
	    }
	    else if (random < 3) {
	      blinkstart = currentTime;
	      return(true);
	    }
	    return(false);
	  }
	  return(true);
	}
	
}
