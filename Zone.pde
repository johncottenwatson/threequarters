class Zone {
  
  public static final int MAX_SUB_ZONES = 10;
  
  PVector[] bounds;
  Zone[] subZones;
  Zone superZone;
  
  boolean subsGenerated;
  int zoneType;
  int depth;
  float minX, maxX, minY, maxY;
  float camBox;
  int id;
  
  boolean colored;
  
  public Zone(int zoneType, int depth, int id, Zone superZone) {
    this.subZones = new Zone[0];
    this.bounds = new PVector[0];
    this.subsGenerated = false;
    this.zoneType = zoneType;
    this.depth = depth;
    this.id = id;
    this.superZone = superZone;
    
    colored = false;
    camBox = 0;
  }
  
  public Zone(int zoneType, int depth, int id, PVector[] bounds, Zone superZone) {
    this.subZones = new Zone[0];
    this.bounds = bounds;
    this.subsGenerated = false;
    this.zoneType = zoneType;
    this.depth = depth;
    this.id = id;
    this.superZone = superZone;
    
    colored = false;
    camBox = 0;
  }
  
  public void generateSubZones() {
    // Temporary: disables subZones after certain depth
    if (depth > 12) {
      calculateMinMax();
      camBox = sqrt(pow(maxX - minX, 2) + pow(maxY - minY, 2));
      return;
    }
    randomSeed(id);
    // Generate nextZoneType
    int nextZoneType = ZoneType.WORLD;
    switch(zoneType) {
      case ZoneType.WORLD:
        nextZoneType = ZoneType.DISTRICT;
        break;
      case ZoneType.DISTRICT:
        if (random(1.0) < .65) {
          nextZoneType = ZoneType.DISTRICT;
        } else if (random(1.0) < 0.1) {
          //nextZoneType = ZoneType.SPOT;
        }
        break;
      case ZoneType.SPOT:
        if (random(1.0) < 0.1) {
          nextZoneType = ZoneType.SPOT;
        }
        break;
    }
    int numSubZones;
    int numVertices; 
      
    // Generate subZones according to nextZoneType
    switch(nextZoneType) {
      case ZoneType.DISTRICT:
        numSubZones = 4;
        subZones = new Zone[numSubZones];
        for (int i = 0; i < numSubZones; i++) {
          float edge = (bounds[1].x - bounds[0].x) / 2.0;
          float xCorner = bounds[0].x + float(i % 2) * edge;
          float yCorner = bounds[0].y + float(i % 4 <= 1 ? 0 : 1) * edge;
          Zone next = new Zone(ZoneType.DISTRICT, depth + 1, (int) random(100000), this);
          numVertices = 4;
          next.bounds = new PVector[numVertices];
          /**
          next.bounds[0] = new PVector(xCorner, yCorner);
          next.bounds[1] = new PVector(xCorner + edge, yCorner);
          next.bounds[2] = new PVector(xCorner + edge, yCorner + edge);
          next.bounds[3] = new PVector(xCorner, yCorner + edge);
          */
          ///**
          next.bounds[0] = new PVector(xCorner + edge * .1, yCorner + edge * .1);
          next.bounds[1] = new PVector(xCorner + edge * .9, yCorner + edge * .1);
          next.bounds[2] = new PVector(xCorner + edge * .9, yCorner + edge * .9);
          next.bounds[3] = new PVector(xCorner + edge * .1, yCorner + edge * .9);
          //*/
          subZones[i] = next;
        }
        break;
      case ZoneType.SPOT:
        numSubZones = 1;
        subZones = new Zone[numSubZones];
        for (int i = 0; i < numSubZones; i++) {
          PVector center = new PVector(0, 0); 
          for (int j = 0; j < bounds.length; j++) {
            center.add(bounds[j]);
          }
          center.div(bounds.length);
          float radius = PVector.sub(center, bounds[0]).mag() / random(2.0, 4.0);
          float xNucleus = center.x + random(-radius / 2.0, radius / 2.0);
          float yNucleus = center.y + random(-radius / 2.0, radius / 2.0);
          Zone next = new Zone(ZoneType.SPOT, depth + 1, (int) random(100000), this);
          numVertices = 64;
          next.bounds = new PVector[numVertices];
          for (int j = 0; j < numVertices; j++) {
            next.bounds[j] = new PVector(xNucleus + radius * cos((float(j) / float(numVertices)) * 2.0 * PI),
              yNucleus + radius * sin((float(j) / float(numVertices)) * 2.0 * PI));
          }
          subZones[i] = next;
        }
        break;
    }
    calculateMinMax();
    camBox = sqrt(pow(maxX - minX, 2) + pow(maxY - minY, 2));
  }

  // Calculates minX, maxX, minY, maxY
  private void calculateMinMax() {
    minX = bounds[0].x;
    maxX = bounds[0].x;
    minY = bounds[0].y;
    maxY = bounds[0].y;
    // Skip first vertex because min, max trackers
    // are initialized to values of first vertex
    for (int i = 1; i < bounds.length; i++) {
      if (bounds[i].x < minX)
        minX = bounds[i].x;
      if (bounds[i].x > maxX)
        maxX = bounds[i].x;
      if (bounds[i].y < minY)
        minY = bounds[i].y;
      if (bounds[i].y > maxY)
        maxY = bounds[i].y;
    }
  }
  
  // Whether the given PVector position is located within
  // the bounds of the Zone
  public boolean contains(PVector p) {
      int crossings = 0;
      for (int i = 0; i < bounds.length; i++) {
          int j = (i + 1) % bounds.length;
          boolean cond1 = (bounds[i].y <= p.y) && (p.y < bounds[j].y);
          boolean cond2 = (bounds[j].y <= p.y) && (p.y < bounds[i].y);
          if (cond1 || cond2) {
              if (p.x < (bounds[j].x - bounds[i].x) * (p.y - bounds[i].y)
                  / (bounds[j].y - bounds[i].y) + bounds[i].x)
                crossings++;
          }
      }
      if (crossings % 2 == 1) {
        return true;
      } else {
        return false; 
      }
  }
  
  public PVector getCenter() {
    PVector center = new PVector(0, 0); 
    for (int j = 0; j < bounds.length; j++) {
      center.add(bounds[j]);
    }
    center.div(bounds.length);
    return center;
  }
}
