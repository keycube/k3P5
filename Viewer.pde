/*
** Import 
 */

import java.awt.Robot;
import java.awt.event.KeyEvent;

/*
** Interface
 */

interface ViewerCallback {
  void onSelect(Key k);
}

class Viewer extends Controller<Viewer> {

  private ViewerCallback callback;

  private final int MATRICES_COUNT = 5;

  private final int FIRST_DELAY_KEY_REPEAT = 500;
  private final int REGULAR_DELAY_KEY_REPEAT = 100;

  private final int WHITE = 0;
  private final int BLUE = 1;
  private final int RED = 2;
  private final int GREEN = 3;
  private final int YELLOW = 4;
  private final String colorsPrefix = "wbrgy";

  private Matrix[] matrices;

  private boolean mapping = false;
  private boolean emulate = false;

  private Key keyHover;
  private Key keyPress;

  Robot robot = null;

  long timer;

  int currentKeyPressedColor = -1;
  int currentKeyPressedNumber = -1;
  int previousKeyPressedColor = -1;
  int previousKeyPressedNumber = -1;
  
  private boolean CAPS_LOCK = false; 

  // Constructor
  Viewer(ControlP5 cp5, String name) {
    super(cp5, name);
    setSize(484, 484);

    try {
      robot = new Robot();
    }
    catch (Exception e) {
      e.printStackTrace();
      exit();
    }
  }

  // Draw
  public void draw(PGraphics p) {
    for (int i = 0; i < MATRICES_COUNT; i++) {
      matrices[i].draw();
    }

    if (millis() > timer) {
      timer = millis() + REGULAR_DELAY_KEY_REPEAT;
      //println("timer x 5s");
      if ((currentKeyPressedColor != -1) && (currentKeyPressedNumber != -1)) {
        // Should send callback event instead
        /*textConsole += matrices[currentKeyPressedColor].getKeys()[currentKeyPressedNumber].getCharacter();
         textAreaConsole.setText(textConsole);*/
        if (emulate) {
          robot.keyPress(matrices[currentKeyPressedColor].getKeys()[currentKeyPressedNumber].getCodeRobot());
        }
      }
    }
  }

  public Viewer setMatrices() {
    int x = (int) getPosition()[0] + 82;
    int y = (int) getPosition()[1] + 82;

    matrices = new Matrix[5];

    matrices[WHITE] = new Matrix(Matrix.UP_DOWN_LEFT_RIGHT, 
      #F5F5F5, "w", 
      x + 0, y + 160, 
      x + 103, y + 257, 
      -45, -45, 0);

    matrices[BLUE] = new Matrix(Matrix.LEFT_RIGHT_DOWN_UP, 
      #2196F3, "b", 
      x + 160, y + 0, 
      x + 73, y + 73, 
      -45, 45, 0);

    matrices[RED] = new Matrix(Matrix.LEFT_RIGHT_UP_DOWN, 
      #F44336, "r", 
      x + 160, y + 160, 
      x + 160, y + 160, 
      -45, 0, -45);

    matrices[GREEN] = new Matrix(Matrix.LEFT_RIGHT_UP_DOWN, 
      #4CAF50, "g", 
      x + 160, y + 320, 
      x + 217, y + 257, 
      -45, 45, 0);

    matrices[YELLOW] = new Matrix(Matrix.DOWN_UP_LEFT_RIGHT, 
      #FFEB3B, "y", 
      x + 320, y + 160, 
      x + 247, y + 73, 
      -45, -45, 0);

    return this;
  }

  public void loadLayout(String[] data) {
    for (int i = 0; i < data.length; i++) {
      String[] line = data[i].split("\t");
      Key k = matrices[colorsPrefix.indexOf(line[0])].getKeys()[Integer.parseInt(line[1])];
      k.setCodeASCII(Integer.parseInt(line[2]));
      k.setCharacter(line[3]);
      k.setCodeRobot(Integer.parseInt(line[4]));
    }
  }

  public void saveLayout(String fileName) {
    String[] data = new String[MATRICES_COUNT*Matrix.KEYS_COUNT];
    for (int i = 0; i < MATRICES_COUNT; i++) {
      Key[] keys = matrices[i].getKeys();
      for (int j = 0; j < Matrix.KEYS_COUNT; j++) {
        data[i * 16 + j] = colorsPrefix.substring(i, i+1) + "\t" + j + "\t" + keys[j].getCodeASCII() + "\t" + keys[j].getCharacter() + "\t" + keys[j].getCodeRobot();
      }
    }
    saveStrings(fileName, data);
  }

  public void clean() {
    for (int i = 0; i < MATRICES_COUNT; i++) {
      matrices[i].clean();
    }
    keyPress = null;
  }

  public String keycubeEvent(int matrixColor, int n) {
    if (matrices[matrixColor].getKeys()[n].togglePress()) {
      if (emulate) {
        int vk = matrices[matrixColor].getKeys()[n].getCodeRobot();
        robot.keyPress(vk);
      }
      
      currentKeyPressedColor = matrixColor;
      currentKeyPressedNumber = n;
      timer = millis() + FIRST_DELAY_KEY_REPEAT;
      
      return (matrices[matrixColor].getKeys()[n].getCode() + "\t" + matrices[matrixColor].getKeys()[n].getCharacter() + "\t1");
    } else {
      if (emulate) {
        int vk = matrices[matrixColor].getKeys()[n].getCodeRobot();
        if (vk == KeyEvent.VK_CAPS_LOCK) {
          CAPS_LOCK = !CAPS_LOCK;
          if (!CAPS_LOCK) {
            robot.keyRelease(vk);
          }
        } else {
          robot.keyRelease(vk);
        }
      }
      currentKeyPressedColor = -1;
      currentKeyPressedNumber = -1;
      
      return (matrices[matrixColor].getKeys()[n].getCode() + "\t" + matrices[matrixColor].getKeys()[n].getCharacter() + "\t0");
    }
  }

  public String lookForKey(String s) {
    int n = -1;
    try {
      n = Integer.parseInt(s.substring(1, 2), 16);
    }
    catch (NumberFormatException nfe) {
      System.out.println("NumberFormatException: " + nfe.getMessage());
      n = -1;
    }

    if (n != -1) {
      switch (s.charAt(0)) {
        // refactor this into function/method
      case 'r':
        return keycubeEvent(RED, n);
      case 'g':
        return keycubeEvent(GREEN, n);
      case 'u': // instead of 'b'
        return keycubeEvent(BLUE, n);
      case 'y':
        return keycubeEvent(YELLOW, n);
      case 'w':
        return keycubeEvent(WHITE, n);
      default:
        println("weird");
        break;
      }
    }
    return null;
  }

  /*
  ** Get
   */

  private float getAbsoluteX(ControllerInterface c) {
    if (c.getParent().getName() == "default") {
      return c.getPosition()[0];
    }
    return getAbsoluteX(c.getParent()) + c.getPosition()[0];
  }

  private float getAbsoluteY(ControllerInterface c) {
    if (c.getParent().getName() == "default") {
      return c.getPosition()[1];
    }
    return getAbsoluteY(c.getParent()) + c.getPosition()[1];
  }

  public boolean isMapping() {
    return mapping;
  }

  public Key getKeyPress() {
    return keyPress;
  }

  /*
  ** Set
   */

  void setMapping(boolean b) {
    mapping = b;
  }

  void setEmulate(boolean b) {
    emulate = b;
  }

  public void setProjection3d(boolean b) {
    for (int i = 0; i < MATRICES_COUNT; i++) {
      matrices[i].setProjection3d(b);
    }
  }

  public void setCallback(ViewerCallback c) {
    callback = c;
  }


  /*
  ** Event
   */

  void onClick() {
    if (!mapping)
      return;

    if (keyHover == null) {
      return;
    }

    if (keyPress != null) {
      keyPress.togglePress();
      if (keyPress.equals(keyHover)) {
        callback.onSelect(keyPress);
        keyPress = null;
        return;
      }
    }

    keyPress = keyHover;
    keyPress.togglePress();
    keyPress.setCharacter(keyPress.getCode());
    keyPress.setCodeASCII(-1);
    callback.onSelect(keyPress);
  }


  void onMove() {
    keyHover = null;
    for (int i = 0; i < MATRICES_COUNT; i++) {
      Key k = matrices[i].onMove((mouseX - getAbsoluteX(this)), (mouseY - getAbsoluteY(this)));
      if (k != null) {
        keyHover = k;
      }
    }
  }
}
