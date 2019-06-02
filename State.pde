class State extends Canvas {
  private int mX, mY;
  private int mWidth, mHeight;
  private color mColorDefault;
  private color mColorText; 
  private color mColorActual;
  
  private String mText;
  
  /*
   * SETTERS
   */

  public void setState(color colorActual, String text) {
    mColorActual = colorActual;
    mText = text;
  }
  
  public void reset() {
    mColorActual = mColorDefault;
    mText = "";
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
    mText = "";
  }

  public void setup(PGraphics pg) {
  }
  
  public void update(PApplet p) {
  }
  
  public void draw(PGraphics pg) {
    pg.fill(mColorActual);
    pg.rect(mX, mY, mWidth, mHeight);
    pg.fill(mColorText);
    pg.textAlign(CENTER);
    pg.textSize(12);
    pg.text(mText, mX + mWidth/2, mY + mHeight/2);
  }
}
