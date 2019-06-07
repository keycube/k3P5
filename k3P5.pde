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

String sMainText = "";

int iPressI = -1;
int iPressJ = -1;

Serial myPort;  // The serial port
int portNumber = -1;
String keepUniChar = "";

State state;

Robot robot = null;

Viewer viewer;

class ToViewerCallback implements ViewerCallback {
  
  void onSelect(Key k) {
    if (k.isPressed()) {
      state.setState(k.getColorBackground(), "listen " + k.getCode());
    } else {
      state.reset();
    }
  }
}

void setup() {
  size(492, 764, P3D);
  surface.setAlwaysOnTop(true);
  
  smooth();
  PFont font = createFont("Arial", 20, true);
  textFont(font);
  
  /*
  ControlP5
  */
  
  cp5 = new ControlP5(this);
  
  /*
  Callback
  */
  
  CallbackListener toFront = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      switch(theEvent.getController().getName()) {
        case "SerialPortList":
          cp5.getGroup("Port").bringToFront();
        break;
        case "LayoutFileList":
          cp5.getGroup("Layout").bringToFront();
        break;
      }
    }
  };
  
  CallbackListener reOrder = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      // Reset the group order
      cp5.getGroup("Port").bringToFront();
      cp5.getGroup("Layout").bringToFront();
      cp5.getGroup("Viewer").bringToFront();
      cp5.getGroup("Console").bringToFront();
    }
  };
  
  /*
  CONSOLE
  */
  
  Group groupConsole = cp5.addGroup("Console")
    .setBackgroundHeight(160)
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
    
  /*
  VIEWER
  */
  
  Group groupViewer = cp5.addGroup("Viewer")
    .setBackgroundColor(160)
    .setBackgroundHeight(484)
    ;
    
  viewer = new Viewer(cp5, "ViewerController").setPosition(0, 0).moveTo(groupViewer).setMatrices();
  viewer.setCallback(new ToViewerCallback());
  
  /*
  LAYOUT
  */
  
  Group groupLayout = cp5.addGroup("Layout")
    .setBackgroundColor(160)
    .setBackgroundHeight(64)
    ;
     
  mTextfieldLayout = cp5.addTextfield("")
    .setPosition(264, 4)
    .setSize(128, 20)
    .setText("default")
    .moveTo(groupLayout)
    ;
    
  cp5.addButton("Load")
    .setPosition(396, 4)
    .setSize(40, 20)
    .moveTo(groupLayout)
    ;
    
  cp5.addButton("Save")
    .setPosition(440, 4)
    .setSize(40, 20)
    .moveTo(groupLayout)
    ;
  
  cp5.addToggle("Mapping")
    .setPosition(4, 28)
    .setSize(48, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .moveTo(groupLayout)
    ;
    
  cp5.addToggle("Emulate")
    .setPosition(56, 28)
    .setSize(48, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .moveTo(groupLayout)
    ;
    
  cp5.addToggle("Projection3d")
    .setPosition(108, 28)
    .setSize(48, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .moveTo(groupLayout)
    ;
    
  state = new State(263, 28, 217, 24, color(48));
  state.pre(); // use cc.post(); to draw on top of existing controllers.
  groupLayout.addCanvas(state);
  
  cp5.addScrollableList("LayoutFileList")
     .setPosition(4, 4)
     .setSize(256, 128)
     .setBarHeight(20)
     .setItemHeight(20)
     .setBackgroundColor(color(48))
     .addItems(getLayoutFileList())     
     .moveTo(groupLayout)
     .onEnter(toFront)
     .onLeave(reOrder)
     .close()
     ;
  
  /*
  PORT
  */
  
  Group groupPort = cp5.addGroup("Port")
    .setBackgroundColor(160)
    .setBackgroundHeight(40)
    ;
    
  cp5.addScrollableList("SerialPortList")
     .setPosition(4, 4)
     .setSize(256, 128)
     .setBarHeight(20)
     .setItemHeight(20)
     .setBackgroundColor(color(48))
     .addItems(Serial.list())
     .moveTo(groupPort)
     .onEnter(toFront)
     .onLeave(reOrder)
     .close()
     ;
    
  toggleListening = cp5.addToggle("Listening")
    .setPosition(264, 4)
    .setSize(48, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .moveTo(groupPort)
    ;
    
  /*
  Main
  */
  
  cp5.addAccordion("accordionMain")
    .setPosition(4, 4)
    .setWidth(484)
    .setMinItemHeight(32)
    
    .addItem(groupPort)
    .addItem(groupLayout)
    .addItem(groupViewer)
    .addItem(groupConsole)
    .setCollapseMode(Accordion.MULTI)
    
    .setColorBackground(color(48))
    
    .setColorActive(color(128)) 
    .setColorForeground(color(128))
    
    .setColorLabel(color(232))
    .setColorValue(color(232))
    
    .open()
    ;

  try {
    robot = new Robot();
  }
  catch (Exception e) {
    e.printStackTrace();
    exit();
  }
}

void draw() {
  background(224);
  noStroke();
  ortho();
  
  if (mListening) {
    while (myPort.available() > 0) {
      String inBuffer = myPort.readStringUntil('.');
      if (inBuffer != null) {
        println(inBuffer);
        lookForKey(inBuffer);
      }
    }
  }

  /*
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
  */
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
    
}

void keyPressed() {
  if (viewer.isMapping()) { // if we are in mapping mode
    Key k = viewer.getKeyPress();
    if (k != null) { // if one key has been pressed/selected
      println(keyCode);
      if ((keyCode == 77) && (key == ',')) {
        keyCode += 1000;
      }
      
      if (textFromKeyCode(keyCode) != null) {
        k.setCharacter(textFromKeyCode(keyCode));
        k.setCodeRobot(robotCodeFromKeyCode(keyCode));
        k.setCodeASCII(keyCode);
        viewer.clean();
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
    if (toggleListening != null) {
      toggleListening.setValue(false);
    }
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

void Projection3d(boolean theFlag) {
  viewer.setProjection3d(theFlag);
}

void Emulate(boolean theFlag) {
  mEmulate = theFlag;
}

void Mapping(boolean theFlag) {
  viewer.setMapping(theFlag);
}

public void Save() {
  viewer.saveLayout("layouts/" + mTextfieldLayout.getText() + LAYOUT_EXTENSION);
}

public void Load() {
  String[] data = loadStrings("layouts/" + mTextfieldLayout.getText() + LAYOUT_EXTENSION);
  viewer.loadLayout(data);
}

void lookForKey(String buffer) {
  String[] bufkeys = split(buffer, '+');

  for (String s : bufkeys) {
    if (s.length() == 0)
      continue;

    if (keepUniChar.length() > 0) {
      s = keepUniChar + s;
      keepUniChar = "";
    }

    if (s.length() == 1) {
      keepUniChar = s;
      continue;
    }
    
    viewer.lookForKey(s);
  }
}
