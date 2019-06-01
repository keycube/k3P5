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
    textSize(12);
    text(mTextSmall, mX + mWidth/2, mY + mHeight/3);
    textSize(16);
    text(mTextBig, mX + mWidth/2, mY + mHeight/1.25);
  }
}
