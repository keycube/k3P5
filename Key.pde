import java.awt.event.KeyEvent;

class Key {
  private int mX2D, mY2D;
  private int mX3D, mY3D;
  
  private boolean mProjection3D = false;
    
  private int mWidth, mHeight;
  
  private int mOffSetX, mOffSetY;
  
  private color mColorDefault;
  private color mColorText;
  private color mColorActual;
  
  private boolean mPress;
  private String mCodeK3;
  private String mText;
  
  private int mCodeRobot;
  private int mCodeASCII;
  
  color colorFont = 0;

  Key(int x, int y, int x3d, int y3d, int offSetX, int offSetY, color colorDefault, String code) {
    mX2D = x + mWidth/2;
    mY2D = y + mHeight/2;
    
    mX3D = x3d + mWidth / 2;
    mY3D = y3d + mHeight / 2;
    
    mWidth = 30;
    mHeight = 30;
    mColorDefault = colorDefault;
    
    mPress = false;
    
    mCodeK3 = code;
    mText = code;
    
    mCodeASCII = -1;
    mCodeRobot = -1;
    
    mOffSetX = offSetX;
    mOffSetY = offSetY;
  }
  
  /*
  ** GETTERS
  */
  
  boolean getPress() {
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
  ** SETTERS
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
  
  void setProjection3D(boolean b) {
    mProjection3D = b;
  }
  
  /*
  ** MISC
  */

  boolean togglePress() {
    mPress = !mPress;
    return mPress;
  }
  
  void display() {
    noStroke();
    
    if (mPress) {
      fill(0);
      colorFont = 255;
    } else {
      fill(mColorDefault);
      colorFont = 0;
    }
    
    if (overRect()) {
      fill(128); 
    }
    
    rectMode(CENTER);
    textAlign(CENTER);
    if (mText.length() > 3)
      textSize(11);
    else
      textSize(16);
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

  public boolean overRect() {
    if ((mouseX - mOffSetX) >= mX2D - mWidth/2 && (mouseX - mOffSetX) <= mX2D + mWidth/2 && 
      (mouseY - mOffSetY) >= mY2D - mHeight/2 && (mouseY - mOffSetY) <= mY2D + mHeight/2) {
      return true;
    } else {
      return false;
    }
  }
}
