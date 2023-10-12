class ChaosTimer {
	
	int startChaos = 5000;
	int middleChaosIntervall = 15000;
	int middleChaosDuration = 6000;
	int start;
	int blinkstart;
	
	ChaosTimer(int startTime) {
	  start = startTime;
	  blinkstart = 0;
	}
	
	boolean checkIsCornerTime(int currentTime) {
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
	
	boolean checkIsEyesOpen(int currentTime) {
	  if (blinkstart == 0 || (currentTime - blinkstart) > 300) {
	    float random = random(1, 1000);
	    if (random < 30 && checkIsCornerTime(currentTime)) {
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
