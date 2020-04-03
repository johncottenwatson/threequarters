class Camera {
  // x and y for center of the camera
  float x, y;
  float sizeX, sizeY;
  
  Camera(float x, float y, float sizeX, float sizeY) {
    this.x = x;
    this.y = y;
    this.sizeX = sizeX;
    this.sizeY = sizeY;
  }

  public void transform() {
    translate(width / 2.0, height / 2.0);
    scale(width / sizeX);
    translate(-this.x, -this.y);
  }
  
  public float getCornerX() {
    return this.x - 0.5 * sizeX;
  }
   
  public float getCornerY() {
    return this.y - 0.5 * sizeY;
  }
  
  /**
   * Returns whether there is any overlap between the rectangle
   * of this camera and the bounding box of the polygon of a zone
   */
  public boolean intersects(Zone zone) {      
    if (getCornerX() > zone.maxX || zone.minX > getCornerX() + sizeX)
      return false;
      
    if (getCornerY() > zone.maxY || zone.minY > getCornerY() + sizeY)
      return false;
    
    return true;
  }
  
  /**
   * Returns whether the entire area of the rectangle of this camera
   * is contained within a zone
   */
  public boolean isContainedIn(Zone zone) {
    float minX = getCornerX();
    float maxX = getCornerX() + sizeX;
    float minY = getCornerY();
    float maxY = getCornerY() + sizeY;
    return zone.contains(new PVector(minX, minY))
      && zone.contains(new PVector(maxX, minY))
      && zone.contains(new PVector(maxX, maxY))
      && zone.contains(new PVector(minX, maxY));
  }
}
