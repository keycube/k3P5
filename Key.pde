class Key {
  private int mX2D, mY2D;
  private int mX3D, mY3D;

  private boolean mProjection3D = false;

  private int mWidth, mHeight;

  private int mOffsetX, mOffsetY;

  private color mColorDefault;
  private color mColorText;
  private color mColorActual;

  private boolean mHover;
  private boolean mPress;
  private String mCodeK3;
  private String mText;

  private int mCodeRobot;
  private int mCodeASCII;
  
  color colorFont = 0;

  // Constructor
  Key(int x, int y, int x3d, int y3d, int offSetX, int offSetY, color colorDefault, String code) {
    mX2D = x + mWidth/2;
    mY2D = y + mHeight/2;

    mX3D = x3d + mWidth / 2;
    mY3D = y3d + mHeight / 2;

    mWidth = 36;
    mHeight = 36;
    mColorDefault = colorDefault;
    mColorActual = colorDefault;

    mPress = false;

    mCodeK3 = code;
    mText = code;

    mCodeASCII = -1;
    mCodeRobot = -1;

    mOffsetX = offSetX;
    mOffsetY = offSetY;
  }
  
  // Draw
  public void draw() {
    
    if (mPress) {
      fill(0); // black
      colorFont = 255;
    } else {
      colorFont = 0;
      if (mHover) {
        fill(128); // grey
      } else {
        fill(mColorDefault);
      }
    }
    
    rectMode(CENTER);
    textAlign(CENTER);
    if (mText.length() > 3)
      textSize(14);
    else
      textSize(18);
    hint(DISABLE_DEPTH_TEST);

    if (mProjection3D) {
      rect(mX3D, mY3D, mWidth, mHeight);
      fill(colorFont);
      text(mText, mX3D, mY3D+5);
    } else {
      rect(mX2D, mY2D, mWidth, mHeight);
      fill(colorFont);
      text(mText, mX2D, mY2D+5);
    }

    hint(ENABLE_DEPTH_TEST);
    rectMode(CORNER);
  }
  
  boolean togglePress() {
    mPress = !mPress;
    return mPress;
  }

  /*
  ** Get
   */

  boolean isPressed() {
    return mPress;
  }

  String getCode() {
    return mCodeK3;
  }

  color getColorBackground() {
    return mColorDefault;
  }

  String getCharacter() {
    return mText;
  }

  int getCodeRobot() {
    return mCodeRobot;
  }

  int getCodeASCII() {
    return mCodeASCII;
  }

  /*
  ** Set
   */

  void setCharacter(String s) {
    mText = s;
  }

  void setPress(boolean b) {
    mPress = b;
  }

  void setCodeRobot(int i) {
    mCodeRobot = i;
  }

  void setCodeASCII(int i) {
    mCodeASCII = i;
  }

  void setProjection3d(boolean b) {
    mProjection3D = b;
  }

  /*
  ** Event
   */

  public boolean onMove(float relativeMouseX, float relativeMouseY) {
    if ((relativeMouseX - mOffsetX) >= mX2D - mWidth/2 && (relativeMouseX - mOffsetX) <= mX2D + mWidth/2 && 
      (relativeMouseY - mOffsetY) >= mY2D - mHeight/2 && (relativeMouseY - mOffsetY) <= mY2D + mHeight/2) {
      mHover = true;      
      return true;
    } else {
      mHover = false;   
      return false;
    }
  }
}
