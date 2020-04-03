// Constant scale factor for camera
final float CAMERA_SCALE = 3.0;
// Edge size of world
final float WORLD_SIZE = pow(2.0, 30); 
// Constant scale factor for player movement
final float MOVEMENT_FACTOR = 1.0 / 60.0;

int count;
Zone world;

PVector pos;
Zone currentZone;

Camera cam;
boolean[] keys;

void setup() {
  // Graphics settings
  //size(600, 600);
  fullScreen();
  frameRate(60);
  noCursor();
  smooth(4);
  
  // Game settings
  world = new Zone(ZoneType.WORLD, 0, int(random(0, 10000)), new PVector[]{
    new PVector(0, 0),
    new PVector(WORLD_SIZE, 0),
    new PVector(WORLD_SIZE, WORLD_SIZE),
    new PVector(0, WORLD_SIZE)}, null);
  pos = new PVector(WORLD_SIZE / 2.0, WORLD_SIZE / 2.0);
  currentZone = world;
  cam = new Camera(pos.x, pos.y, CAMERA_SCALE * currentZone.camBox,
    CAMERA_SCALE * currentZone.camBox * float(height) / float(width));
   
  // Keystroke settings
  keys = new boolean[20];
  for (int i = 0; i < keys.length; i++) {
    keys[i] = false;
  }
}

void draw() { 
  handleInput();
  
   // Find currentZone
  currentZone = searchForCurrentZone(world); 
  
  // Update camera
  cam.x = lerp(cam.x, pos.x, .5);
  cam.y = lerp(cam.y, pos.y, .5);
  cam.sizeX = lerp(cam.sizeX, CAMERA_SCALE * currentZone.camBox, .05);
  cam.sizeY = cam.sizeX * float(height) / float(width);
  cam.transform();
  strokeWeight(cam.sizeX / width);
  System.out.println(frameRate);
  background(180); 
  drawZone(world, 0);

  // Draw player sprite
  //fill(0);
  //noStroke();
  noFill();
  strokeWeight(cam.sizeX / 1200.0);
  ellipse(pos.x, pos.y, cam.sizeX / 100.0, cam.sizeX / 100.0);
  
  if (currentZone.subZones.length == 0 && !currentZone.colored) {
    handleColoring();
  }
  
  //System.out.println(countChildren(world));
}

int countChildren(Zone z) {
  int count = 1;
  for (int i = 0; i < z.subZones.length; i++) {
    count += countChildren(z.subZones[i]);
  }
  return count;
}

Zone searchForCurrentZone(Zone zoneToSearch) {
  if (!zoneToSearch.contains(pos)) { 
    return null;
  } else {
    for (int i = 0; i < zoneToSearch.subZones.length; i++) {
      Zone zone = searchForCurrentZone(zoneToSearch.subZones[i]);
      if (zone != null) {
        return zone;
      }
    }
  }
  return zoneToSearch;
}

void drawZone(Zone zoneToDraw, int scale) {
  if (zoneToDraw.colored) {
    fill(120, 130, 140);
  } else {
    fill(140, 136, 128);
  }
  stroke(0);
  strokeWeight(zoneToDraw.camBox / 160.0);
  if (zoneToDraw.bounds.length != 4) {
    beginShape();
    for (int vertexCount = 0; vertexCount < zoneToDraw.bounds.length; vertexCount++) {
      vertex(zoneToDraw.bounds[vertexCount].x, zoneToDraw.bounds[vertexCount].y);
    }
    vertex(zoneToDraw.bounds[0].x, zoneToDraw.bounds[0].y);
    endShape();
  } else {
    rect(zoneToDraw.bounds[0].x, zoneToDraw.bounds[0].y,
      zoneToDraw.bounds[2].x - zoneToDraw.bounds[0].x,
      zoneToDraw.bounds[2].y - zoneToDraw.bounds[0].y);
  }
  
  if (frameRate < 30)
    return;
  if (scale > currentZone.depth + 2 && frameRate < 40)
    return;
  if (scale > currentZone.depth + 5)
    return;
  if (!zoneToDraw.subsGenerated) {
    //System.out.println("Generating subs...");
    zoneToDraw.generateSubZones();
    zoneToDraw.subsGenerated = true;
  }
  if (cam.intersects(zoneToDraw)) {
    for (int subZonesIdx = 0; subZonesIdx < zoneToDraw.subZones.length; subZonesIdx++) {
        drawZone(zoneToDraw.subZones[subZonesIdx], scale + 1);
    }
  }
}

void handleInput() {
  PVector oldPos = pos.copy();

  if ( keys[0] )
    pos.x -= currentZone.camBox * MOVEMENT_FACTOR;
  if ( keys[1] )
    pos.x += currentZone.camBox * MOVEMENT_FACTOR;
  if ( keys[2] )
    pos.y -= currentZone.camBox * MOVEMENT_FACTOR;
  if ( keys[3] )
    pos.y += currentZone.camBox * MOVEMENT_FACTOR;

  if (currentZone.subZones.length != 0) {
    if (keys[4]) {
      pos = currentZone.subZones[0].getCenter();
      keys[4] = false;
    }
    if (keys[5]) {
      pos = currentZone.subZones[1].getCenter();
      keys[5] = false;
    }
    if (keys[7]) {
      pos = currentZone.subZones[2].getCenter();
      keys[7] = false;
    }
    if (keys[6]) {
      pos = currentZone.subZones[3].getCenter();
      keys[6] = false;
    }
  }
  
  if (keys[8] && currentZone.superZone != null) {
      pos = currentZone.superZone.getCenter();
      keys[8] = false;
  }

  // Handle boundaries and collisions
  if (pos.x < 0)
    pos.x = 100;
  if (pos.x >= WORLD_SIZE - 1)
    pos.x = WORLD_SIZE - 100;
  if (pos.y < 0)
    pos.y = 100;
  if (pos.y >= WORLD_SIZE - 1)
    pos.y = WORLD_SIZE - 100; 
  /**
  if (keys[8] || pos.equals(oldPos))
    return;
  
  PVector collisionPoint = checkMovementCollisions(oldPos);
  if (collisionPoint != null) {
    System.out.println("ko: " + collisionPoint);
    pos.set(PVector.add(collisionPoint, PVector.mult(PVector.sub(oldPos, collisionPoint).normalize(), 2000.0)));
  }*/
}

void handleColoring() {
  currentZone.colored = true;
  backColor(currentZone.superZone);
}

void backColor(Zone zoneToBackColor) {
  int count = 0;
  for (int i = 0; i < zoneToBackColor.subZones.length; i++) {
    if (zoneToBackColor.subZones[i].colored)
      count++;
  }
  if (float(count) / float(zoneToBackColor.subZones.length) >= .75) {
    zoneToBackColor.colored = true;
    zoneToBackColor.subZones = new Zone[0];
    
    if (zoneToBackColor.zoneType != ZoneType.WORLD)
      backColor(zoneToBackColor.superZone);
  }    
}


PVector checkMovementCollisions(PVector oldPos) {
  // ArrayList to store points for each intersection between
  // movement line and bounds (sub-)lines
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  // Look for intersections with bounds of current zone
  for (int vertexIndex = 0; vertexIndex < currentZone.bounds.length; vertexIndex++) {
    PVector currentIntersection = lineIntersection(oldPos, pos, currentZone.bounds[vertexIndex],
      currentZone.bounds[(vertexIndex + 1) % currentZone.bounds.length]);
    if (currentIntersection != null) {
      intersections.add(currentIntersection);
    }
  }
  // Look for intersections with bounds of sub-zones of current zone
  for (int subZoneIndex = 0; subZoneIndex < currentZone.subZones.length; subZoneIndex++) {
    for (int vertexIndex = 0; vertexIndex < currentZone.subZones[subZoneIndex].bounds.length; vertexIndex++) {
      PVector currentIntersection = lineIntersection(oldPos, pos, currentZone.subZones[subZoneIndex].bounds[vertexIndex],
        currentZone.subZones[subZoneIndex].bounds[(vertexIndex + 1) % currentZone.subZones[subZoneIndex].bounds.length]);
      if (currentIntersection != null) {
        intersections.add(currentIntersection);
      }
    }
  }
  
  // No intersections found
  if (intersections.size() == 0) {
    return null;
  }
  
  // Exactly one intersection found
  if (intersections.size() == 1) {
    return intersections.get(0);
  }
  
  // Find and return nearest intersection to player's oldPos
  PVector nearestIntersection = intersections.get(0);
  for (int i = 1; i < intersections.size(); i++) {
    if (PVector.dist(oldPos, intersections.get(i)) < PVector.dist(oldPos, nearestIntersection)) {
      nearestIntersection = intersections.get(i);
    }
  }
  return nearestIntersection;
  
}

// Returns intersection point of two lines (Chris Hallberg's work)
PVector lineIntersection(PVector v1, PVector v2, PVector v3, PVector v4) {
  float x1 = v1.x;
  float y1 = v1.y;
  float x2 = v2.x;
  float y2 = v2.y;
  float x3 = v3.x;
  float y3 = v3.y;
  float x4 = v4.x;
  float y4 = v4.y;
  
  // calculate the distance to intersection point
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

  // if uA and uB are between 0-1, lines are colliding
  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
    return new PVector(x1 + (uA * (x2-x1)), y1 + (uA * (y2-y1)));
  }
  return null;
}

void keyPressed() {
  if (keyCode == LEFT)
    keys[0] = true;
  if (keyCode == RIGHT)
    keys[1] = true;
  if (keyCode == UP)
    keys[2] = true;
  if (keyCode == DOWN)
    keys[3] = true;
  if (key == 'a')
    keys[0] = true;
  if (key == 'd')
    keys[1] = true;
  if (key == 'w')
    keys[2] = true;
  if (key == 's')
    keys[3] = true;
  if (key == '1')
    keys[4] = true;
  if (key == '2')
    keys[5] = true;
  if (key == '3')
    keys[7] = true;
  if (key == '4')
    keys[6] = true;
  if (key == '5')
    keys[8] = true;
  if (key == ' ')
    keys[8] = true;
}

void keyReleased() {
  if (keyCode == LEFT)
    keys[0] = false;
  if (keyCode == RIGHT)
    keys[1] = false;
  if (keyCode == UP)
    keys[2] = false;
  if (keyCode == DOWN)
    keys[3] = false;
  if (key == 'a')
    keys[0] = false;
  if (key == 'd')
    keys[1] = false;
  if (key == 'w')
    keys[2] = false;
  if (key == 's')
    keys[3] = false;
  if (key == '1')
    keys[4] = false;
  if (key == '2')
    keys[5] = false;
  if (key == '3')
    keys[7] = false;
  if (key == '4')
    keys[6] = false;
  if (key == '5')
    keys[8] = false;
  if (key == ' ')
    keys[8] = false;
}

void mouseClicked() {
  setup();
}
