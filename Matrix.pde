class Matrix {

  public static final int KEYS_COUNT = 16;

  public static final int LEFT_RIGHT_UP_DOWN = 0; // default
  public static final int LEFT_RIGHT_DOWN_UP = 1;
  public static final int UP_DOWN_LEFT_RIGHT = 2;
  public static final int DOWN_UP_LEFT_RIGHT = 3; 

  private int offset2dX;
  private int offset2dY;

  private boolean projection3d;

  private int offset3dX;
  private int offset3dY;

  private int rotation3dX;
  private int rotation3dY;
  private int rotation3dZ;

  private Key[] keys;

  Matrix(int disposition, color colorFill, String prefix, 
    int offset2dX, int offset2dY, int offset3dX, int offset3dY, 
    int rotation3dX, int rotation3dY, int rotation3dZ) {

    // set matrix variables

    this.offset2dX = offset2dX;
    this.offset2dY = offset2dY;

    projection3d = false;

    this.offset3dX = offset3dX;
    this.offset3dY = offset3dY;

    this.rotation3dX = rotation3dX;
    this.rotation3dY = rotation3dY;
    this.rotation3dZ = rotation3dZ;

    // init keys
    keys = new Key[16];

    int spacing = 40;
    int offsetCenter = 60;

    int x3D, y3D;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        switch (disposition) {
        case LEFT_RIGHT_DOWN_UP:
          x3D = i * spacing;
          y3D = (3-j) * spacing;
          break;
        case UP_DOWN_LEFT_RIGHT:
          x3D = j * spacing;
          y3D = (3-i) * spacing;
          break;
        case DOWN_UP_LEFT_RIGHT:
          x3D = j * spacing;
          y3D = i * spacing;
          break;
        case LEFT_RIGHT_UP_DOWN:
        default:
          x3D = i * spacing;
          y3D = j * spacing;
          break;
        }

        x3D -= offsetCenter;
        y3D -= offsetCenter;

        keys[j * 4 + i] = new Key(
          i * spacing - offsetCenter, 
          j * spacing - offsetCenter, 
          x3D, 
          y3D, 
          offset2dX, 
          offset2dY, 
          colorFill, 
          prefix + (j * 4 + i + 1)
          );
      }
    }
  }

  public void draw() {
    pushMatrix();

    if (projection3d) {
      translate(offset3dX, offset3dY, 100);
      rotateX(radians(rotation3dX));
      rotateY(radians(rotation3dY));
      rotateZ(radians(rotation3dZ));
    } else {
      translate(offset2dX, offset2dY, 100);
    }

    for (int i = 0; i < KEYS_COUNT; i++) {
      keys[i].draw();
    }
    popMatrix();
  }

  public Key onMove(float relativeMouseX, float relativeMouseY) {
    Key k = null;
    for (int i = 0; i < KEYS_COUNT; i++) {
      if (keys[i].onMove(relativeMouseX, relativeMouseY)) {
        k = keys[i];
      }
    }
    return k;
  }

  public void setProjection3d(boolean b) {
    projection3d = b;
    for (int i = 0; i < KEYS_COUNT; i++) {
      keys[i].setProjection3d(projection3d);
    }
  }
  
  public Key[] getKeys() {
    return keys;
  }
  
  public void clean() {
    for (int i = 0; i < KEYS_COUNT; i++) {
      keys[i].setPress(false);
    }
  }
}
