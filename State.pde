class State {
  private int mX, mY;
  private int mWidth, mHeight;
  private color mColorDefault;
  private color mColorText; 
  private color mColorActual;
  
  private String mTextBig;
  private String mTextSmall;
  

  /*
   * SETTERS
   */

  public void setState(color colorActual, String textBig, String textSmall) {
    mColorActual = colorActual;
    mTextBig = textBig;
    mTextSmall = textSmall;
  }
  
  public void reset() {
    mColorActual = mColorDefault;
    mTextBig = "";
    mTextSmall = "";
  }

  /*
   * Constructor
   */
   
  State(int x, int y, int _width, int _height, color colorDefault) {
    mX = x;
    mY = y;
    mWidth = _width;
    mHeight = _height;
    mColorDefault = colorDefault;
    mColorActual = colorDefault;
    mTextBig = "";
    mTextSmall = "";
  }

  /*
   * MISC
   */
   
  void display() {
    noStroke();
    fill(mColorActual);
    rect(mX, mY, mWidth, mHeight);
    fill(mColorText);
    textAlign(CENTER);
    textSize(24);
    text(mTextSmall, mX + 120, mY + 35);
    textSize(48);
    text(mTextBig, mX + 120, mY + 80);
  }
}
