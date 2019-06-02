/*
** Import
 */
import controlP5.*;
import processing.serial.*;

import java.awt.Robot;
import java.awt.event.KeyEvent;

/*
** Const
 */
final int WHITE = 0;
final int BLUE = 1;
final int RED = 2;
final int GREEN = 3;
final int YELLOW = 4;

final int MATRIX_NUMBER = 5;
final int KEYS_NUMBER_PER_MATRIX = 16;

final String LAYOUT_EXTENSION = ".layout";

final int FIRST_DELAY_KEY_REPEAT = 500;
final int REGULAR_DELAY_KEY_REPEAT = 200;

/*
** ControlP5 variable
 */
ControlP5 cp5;
Textarea mainTextarea;
Textfield mTextfieldLayout;
Toggle toggleListening;

/*
** Settings variable
 */
boolean mListening = false;
boolean mEmulate = false;

boolean mProjection3D = false;

Key[][] keys;

int matrixOffSetX2D[];
int matrixOffSetY2D[];

int matrixOffSetX3D[];
int matrixOffSetY3D[];
int matrixRotationX[];
int matrixRotationY[];
int matrixRotationZ[];

boolean bMapping = false;

String sMainText = "";

PImage imgLogo;

int iPressI = -1;
int iPressJ = -1;

Serial myPort;  // The serial port
int portNumber = -1;
String keepUniChar = "";

State state;

Robot robot = null;

int timer; // maybe use 'long'

int currentKeyPressedColor = -1;
int currentKeyPressedNumber = -1;
int previousKeyPressedColor = -1;
int previousKeyPressedNumber = -1;



/*
**
 */
void setMatrix(Key[] keys, int offSetX, int offSetY, color fillColor, String prefix) {
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      switch (prefix) {
      case "b":
        keys[j * 4 + i] = new Key(i * 40 - 60, j * 40 - 60, i * 40 - 60, (3-j) * 40 - 60, offSetX, offSetY, fillColor, prefix + (j * 4 + i + 1));
        break;
      case "w":
        keys[j * 4 + i] = new Key(i * 40 - 60, j * 40 - 60, j * 40 - 60, (3-i) * 40 - 60, offSetX, offSetY, fillColor, prefix + (j * 4 + i + 1));
        break;
      case "y":
        keys[j * 4 + i] = new Key(i * 40 - 60, j * 40 - 60, j * 40 - 60, i * 40 - 60, offSetX, offSetY, fillColor, prefix + (j * 4 + i + 1));
        break;
      default:
        keys[j * 4 + i] = new Key(i * 40 - 60, j * 40 - 60, i * 40 - 60, j * 40 - 60, offSetX, offSetY, fillColor, prefix + (j * 4 + i + 1));
        break;
      }
    }
  }
}

void setLayout(int x, int y) {
  setMatrix(keys[WHITE], 0 + x, 160 + y, #F5F5F5, "w");
  matrixOffSetX2D[WHITE] = 0 + x;
  matrixOffSetY2D[WHITE] = 160 + y;

  matrixOffSetX3D[WHITE] = 103 + x;
  matrixOffSetY3D[WHITE] = 257 + y;
  matrixRotationX[WHITE] = -45;
  matrixRotationY[WHITE] = -45;
  matrixRotationZ[WHITE] = 0;

  setMatrix(keys[BLUE], 160 + x, 0 + y, #2196F3, "b");
  matrixOffSetX2D[BLUE] = 160 + x;
  matrixOffSetY2D[BLUE] = 0 + y;

  matrixOffSetX3D[BLUE] = 73 + x;
  matrixOffSetY3D[BLUE] = 73 + y;
  matrixRotationX[BLUE] = -45;
  matrixRotationY[BLUE] = 45;
  matrixRotationZ[BLUE] = 0;

  setMatrix(keys[RED], 160 + x, 160 + y, #F44336, "r");
  matrixOffSetX2D[RED] = 160 + x;
  matrixOffSetY2D[RED] = 160 + y;

  matrixOffSetX3D[RED] = 160 + x;
  matrixOffSetY3D[RED] = 160 + y;
  matrixRotationX[RED] = -45;
  matrixRotationY[RED] = 0;
  matrixRotationZ[RED] = -45;

  setMatrix(keys[GREEN], 160 + x, 320 + y, #4CAF50, "g");
  matrixOffSetX2D[GREEN] = 160 + x;
  matrixOffSetY2D[GREEN] = 320 + y;

  matrixOffSetX3D[GREEN] = 217 + x;
  matrixOffSetY3D[GREEN] = 257 + y;
  matrixRotationX[GREEN] = -45;
  matrixRotationY[GREEN] = 45;
  matrixRotationZ[GREEN] = 0;

  setMatrix(keys[YELLOW], 320 + x, 160 + y, #FFEB3B, "y");
  matrixOffSetX2D[YELLOW] = 320 + x;
  matrixOffSetY2D[YELLOW] = 160 + y;

  matrixOffSetX3D[YELLOW] = 247 + x;
  matrixOffSetY3D[YELLOW] = 73 + y;
  matrixRotationX[YELLOW] = -45;
  matrixRotationY[YELLOW] = -45;
  matrixRotationZ[YELLOW] = 0;
}

void setup() {
  size(492, 750, P3D);
  noStroke();
  surface.setAlwaysOnTop(true);

  keys = new Key[5][16];

  matrixOffSetX2D = new int[5];
  matrixOffSetY2D = new int[5];

  matrixOffSetX3D = new int[5];
  matrixOffSetY3D = new int[5];
  matrixRotationX = new int[5];
  matrixRotationY = new int[5];
  matrixRotationZ = new int[5];

  setLayout(86, 205);

  cp5 = new ControlP5(this);

  /*
  PORT
  */
  
  Group groupPort = cp5.addGroup("Port")
    .setBackgroundColor(128)
    .setBackgroundHeight(44)
    ;
    
  cp5.addScrollableList("SerialPortList")
     .setPosition(4, 4)
     .setSize(256, 128)
     .setBarHeight(24)
     .setItemHeight(24)
     .addItems(Serial.list())
     .moveTo(groupPort)
     .close()
     ;
    
  toggleListening = cp5.addToggle("Listening")
    .setPosition(264, 4)
    .setSize(48, 24)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .moveTo(groupPort)
    ;
  
  /*
  LAYOUT
  */
  
  Group groupLayout = cp5.addGroup("Layout")
    .setBackgroundColor(128)
    .setBackgroundHeight(72)
    ;
    
  cp5.addScrollableList("LayoutFileList")
     .setPosition(4, 4)
     .setSize(256, 128)
     .setBarHeight(24)
     .setItemHeight(24)
     .addItems(getLayoutFileList())
     .moveTo(groupLayout)
     .close()
     ;
     
  mTextfieldLayout = cp5.addTextfield("")
    .setPosition(264, 4)
    .setSize(128, 24)
    .setText("default")
    .moveTo(groupLayout)
    ;
    
  cp5.addButton("Load")
    .setPosition(396, 4)
    .setSize(40, 24)
    .moveTo(groupLayout)
    ;
    
  cp5.addButton("Save")
    .setPosition(440, 4)
    .setSize(40, 24)
    .moveTo(groupLayout)
    ;
  
  cp5.addToggle("Mapping")
    .setPosition(4, 32)
    .setSize(48, 24)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .moveTo(groupLayout)
    ;
    
  cp5.addToggle("Emulate")
    .setPosition(56, 32)
    .setSize(48, 24)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .moveTo(groupLayout)
    ;
    
  state = new State(108, 32, 372, 24, #00305B);
  state.pre(); // use cc.post(); to draw on top of existing controllers.
  
  groupLayout.addCanvas(state);
  
  /*
  VIEWER
  */
  
  Group groupViewer = cp5.addGroup("Viewer")
    .setBackgroundColor(128)
    .setBackgroundHeight(484)
    ;
    
  cp5.addToggle("Viewer3D")
    .setPosition(4, 4)
    .setSize(50, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .moveTo(groupViewer)
    ;

  /*
  CONSOLE
  */
  
  Group groupConsole = cp5.addGroup("Console")
    .setBackgroundHeight(128)
    ;
    
  mainTextarea = cp5.addTextarea("textAreaConsole")
    .setPosition(0, 0)
    .setSize(484, 128)
    .setFont(createFont("arial", 15))
    .setLineHeight(14)
    .setColor(255)
    .setColorBackground(0)
    .moveTo(groupConsole)
    ;

  frameRate(30);
  cp5.addFrameRate().setInterval(10).setPosition(10, 10);

  try {
    robot = new Robot();
  }
  catch (Exception e) {
    //Uh-oh...
    e.printStackTrace();
    exit();
  }

  cp5.addAccordion("accordionMain")
    .setPosition(4, 4)
    .setWidth(484)
    .setMinItemHeight(32)
    .addItem(groupPort)
    .addItem(groupLayout)
    .addItem(groupViewer)
    .addItem(groupConsole)
    .setCollapseMode(Accordion.MULTI)
    ;
}

void draw() {
  background(200);
  
  fill(160);
  rect(4, 120, 484, 490); // layout

  ortho();

  for (int i = 0; i < MATRIX_NUMBER; i++) {
    pushMatrix();
    switch (i) {
    case RED:
      break;
    case WHITE:
      break;
    case GREEN:
      break;
    case BLUE:
      break;
    case YELLOW:
      break;
    }

    if (mProjection3D) {
      translate(matrixOffSetX3D[i], matrixOffSetY3D[i], 100);
      rotateX(radians(matrixRotationX[i]));
      rotateY(radians(matrixRotationY[i]));
      rotateZ(radians(matrixRotationZ[i]));
    } else {
      translate(matrixOffSetX2D[i], matrixOffSetY2D[i], 100);
    }

    for (int j = 0; j < KEYS_NUMBER_PER_MATRIX; j++) {
      keys[i][j].display();
    }
    popMatrix();
  }

  if (mListening) {
    while (myPort.available() > 0) {
      String inBuffer = myPort.readStringUntil('.');
      if (inBuffer != null) {
        println(inBuffer);
        lookForKey(inBuffer);
      }
    }
  }

  if (millis() > timer) {
    timer = millis() + REGULAR_DELAY_KEY_REPEAT;
    //println("timer x 5s");
    if ((currentKeyPressedColor != -1) && (currentKeyPressedNumber != -1)) {
      sMainText += keys[currentKeyPressedColor][currentKeyPressedNumber].getCharacter();
      mainTextarea.setText(sMainText);
      if (mEmulate) {
        robot.keyPress(keys[currentKeyPressedColor][currentKeyPressedNumber].getCodeRobot());
      }
    }
  }
}

void cleanKeysPress() {
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 16; j++) {
      keys[i][j].setPress(false);
    }
  }
}

String[] getLayoutFileList() {
  FilenameFilter layoutFilter = new FilenameFilter() {
    @Override public boolean accept(final File dir, String name) {
      name = name.toLowerCase();
      return name.endsWith(".layout");
    }
  };

  String path = sketchPath() + "/layouts";
  println(path);
  File file = new File(path);
  if (file.isDirectory()) {
    String names[] = file.list(layoutFilter);
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}


/*
** Event
 */
void mousePressed() {
  if (!bMapping)
    return;

  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 16; j++) {
      if (keys[i][j].overRect()) {
        if ((iPressI == i) && (iPressJ ==j)) {
          keys[i][j].togglePress();
          keys[i][j].setCodeASCII(-1);
          iPressI = -1;
          iPressJ = -1;
          state.reset();
        } else {
          cleanKeysPress();
          keys[i][j].togglePress();
          iPressI = i;
          iPressJ = j;
          keys[i][j].setCharacter(keys[i][j].getCode());
          state.setState(keys[i][j].getColorBackground(), "listen " + keys[i][j].getCode());
        }
        return;
      }
    }
  }
}

void keyPressed() {
  if (bMapping) { // if we are in mapping mode
    if (iPressI != -1) { // if one key has been pressed
      println(keyCode);

      if ((keyCode == 77) && (key == ',')) {
        keyCode += 1000;
      }

      if (textFromKeyCode(keyCode) != null) {
        keys[iPressI][iPressJ].setCharacter(textFromKeyCode(keyCode));
        keys[iPressI][iPressJ].setCodeRobot(robotCodeFromKeyCode(keyCode));
        keys[iPressI][iPressJ].setCodeASCII(keyCode);
        keys[iPressI][iPressJ].togglePress();
        iPressI = -1;
        iPressJ = -1;
        state.reset();
      }

      /*
      switch (keyCode) {
       case 8: // backspace
       break;
       case 32: // space
       default:
       if ((key >= 'A' && key <= 'Z') || (key >= 'a' && key <= 'z') || (key == ' '))  {
       keys[iPressI][iPressJ].setCharacter("" + key);
       keys[iPressI][iPressJ].togglePress();
       iPressI = -1;
       iPressJ = -1;
       state.reset();
       }
       break;
       }
       */
    }
  }
}


void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
  } else if (theEvent.isController()) {

    if (theEvent.isFrom(cp5.getController("SerialPortList"))) {
      portNumber = (int) theEvent.getController().getValue();
      println("portNumber: " + portNumber);
    }
  }
}


/*
 * ControlP5 Methods
 */

void Listening(boolean theFlag) {
  if (portNumber == -1) {
    toggleListening.setValue(false);
  } else {
    mListening = theFlag;
    if (mListening) {
      if (myPort == null) {
        // Open the port you are using at the rate you want:
        myPort = new Serial(this, Serial.list()[portNumber], 9600);
      }
    }
  }
}

void Viewer3D(boolean theFlag) {
  mProjection3D = theFlag;
  for (int i = 0; i < MATRIX_NUMBER; i++) {
    for (int j = 0; j < KEYS_NUMBER_PER_MATRIX; j++) {
      keys[i][j].setProjection3D(theFlag);
    }
  }
}

void Emulate(boolean theFlag) {
  mEmulate = theFlag;
}

void Mapping(boolean theFlag) {
  bMapping = theFlag;
  if (!theFlag)
    cleanKeysPress();
}

public void Save() {
  String[] data = new String[80];
  for (int i = 0; i < MATRIX_NUMBER; i++) {
    for (int j = 0; j < KEYS_NUMBER_PER_MATRIX; j++) {
      data[i * 16 + j] = Integer.toString(keys[i][j].getCodeASCII());
    }
  }
  saveStrings(mTextfieldLayout.getText() + LAYOUT_EXTENSION, data);
}

public void Load() {
  String[] data = loadStrings(mTextfieldLayout.getText() + LAYOUT_EXTENSION);
  for (int i = 0; i < MATRIX_NUMBER; i++) {
    for (int j = 0; j < KEYS_NUMBER_PER_MATRIX; j++) {
      int codeASCII = Integer.parseInt(data[i * 16 + j]);
      if ((codeASCII != -1) && (codeASCII != 0)) {
        keys[i][j].setCodeASCII(codeASCII);
        keys[i][j].setCodeRobot(robotCodeFromKeyCode(codeASCII));
        keys[i][j].setCharacter(textFromKeyCode(codeASCII));
      }
      /* MAYBE REMOVE THIS (it just make clean key when not assigned after loading */
      else {
        keys[i][j].setCharacter("");
      }
    }
  }
}

void lookForKey(String buffer) {
  String[] bufkeys = split(buffer, '+');

  for (String s : bufkeys) {
    if (s.length() == 0)
      continue;

    int n = -1;

    if (keepUniChar.length() > 0) {
      s = keepUniChar + s;
      keepUniChar = "";
    }

    if (s.length() == 1) {
      keepUniChar = s;
      continue;
    }

    try
    {
      n = Integer.parseInt(s.substring(1, 2), 16);
    }
    catch (NumberFormatException nfe) 
    {
      System.out.println("NumberFormatException: " + nfe.getMessage());
      n = -1;
    }

    if (n != -1)
    {
      switch (s.charAt(0)) {
      case 'r':
        if (keys[RED][n].togglePress()) {
          sMainText += keys[RED][n].getCharacter();
          if (mEmulate) {
            robot.keyPress(keys[RED][n].getCodeRobot());
          }

          currentKeyPressedColor = RED;
          currentKeyPressedNumber = n;
          timer = millis() + FIRST_DELAY_KEY_REPEAT;
        } else {
          if (mEmulate) {
            robot.keyRelease(keys[RED][n].getCodeRobot());
          }
          currentKeyPressedColor = -1;
          currentKeyPressedNumber = -1;
        }
        break;
      case 'g':
        if (keys[GREEN][n].togglePress()) {
          sMainText += keys[GREEN][n].getCharacter();
          if (mEmulate) {
            robot.keyPress(keys[GREEN][n].getCodeRobot());
          }

          currentKeyPressedColor = GREEN;
          currentKeyPressedNumber = n;
          timer = millis() + FIRST_DELAY_KEY_REPEAT;
        } else {
          if (mEmulate) {
            robot.keyRelease(keys[GREEN][n].getCodeRobot());
          }
          currentKeyPressedColor = -1;
          currentKeyPressedNumber = -1;
        }
        break;
      case 'u': // instead of 'b'
        if (keys[BLUE][n].togglePress()) {
          sMainText += keys[BLUE][n].getCharacter();
          if (mEmulate) {
            robot.keyPress(keys[BLUE][n].getCodeRobot());
          }

          currentKeyPressedColor = BLUE;
          currentKeyPressedNumber = n;
          timer = millis() + FIRST_DELAY_KEY_REPEAT;
        } else {
          if (mEmulate) {
            robot.keyRelease(keys[BLUE][n].getCodeRobot());
          }
          currentKeyPressedColor = -1;
          currentKeyPressedNumber = -1;
        }
        break;
      case 'y':
        if (keys[YELLOW][n].togglePress()) {
          sMainText += keys[YELLOW][n].getCharacter();
          if (mEmulate) {
            robot.keyPress(keys[YELLOW][n].getCodeRobot());
          }

          currentKeyPressedColor = YELLOW;
          currentKeyPressedNumber = n;
          timer = millis() + FIRST_DELAY_KEY_REPEAT;
        } else {
          if (mEmulate) {
            robot.keyRelease(keys[YELLOW][n].getCodeRobot());
          }
          currentKeyPressedColor = -1;
          currentKeyPressedNumber = -1;
        }
        break;
      case 'w':
        if (keys[WHITE][n].togglePress()) {
          sMainText += keys[WHITE][n].getCharacter();
          if (mEmulate) {
            robot.keyPress(keys[WHITE][n].getCodeRobot());
          }

          currentKeyPressedColor = WHITE;
          currentKeyPressedNumber = n;
          timer = millis() + FIRST_DELAY_KEY_REPEAT;
        } else {
          if (mEmulate) {
            robot.keyRelease(keys[WHITE][n].getCodeRobot());
          }
          currentKeyPressedColor = -1;
          currentKeyPressedNumber = -1;
        }
        break;
      default:
        println("weird");
        break;
      }
    }
  }
  mainTextarea.setText(sMainText);
}
