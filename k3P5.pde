/*
** Import
 */

import controlP5.*;
import processing.serial.*;


/*
** Class
 */

class ToViewerCallback implements ViewerCallback {

  void onSelect(Key k) {
    if (k.isPressed()) {
      state.setState(k.getColorBackground(), "listen " + k.getCode());
    } else {
      state.reset();
    }
  }
}

/*
** Const
 */

final String LAYOUT_EXTENSION = ".layout";

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
String sMainText = "";

Serial myPort;  // The serial port
int portNumber = -1;
String keepUniChar = "";

State state;
Viewer viewer;

int windowHeight[];
boolean groupOpen[];

void setup() {
  size(492, 764, P3D);
  surface.setAlwaysOnTop(true);
  surface.setResizable(true);

  smooth();
  PFont font = createFont("Arial", 20, true);
  textFont(font);

  windowHeight = new int[4]; // number of accordion group (Port, Layout, Viewer, Console)
  groupOpen = new boolean[4];

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
    .setBackgroundHeight(128)
    .setId(3)
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
    .setId(2)
    ;

  viewer = new Viewer(cp5, "ViewerController").setPosition(0, 0).moveTo(groupViewer).setMatrices();
  viewer.setCallback(new ToViewerCallback());

  /*
  LAYOUT
   */

  Group groupLayout = cp5.addGroup("Layout")
    .setBackgroundColor(160)
    .setBackgroundHeight(64)
    .setId(1)
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
    .setId(0)
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

  windowHeight[0] = groupPort.getBackgroundHeight();
  windowHeight[1] = groupLayout.getBackgroundHeight();
  windowHeight[2] = groupViewer.getBackgroundHeight();
  windowHeight[3] = groupConsole.getBackgroundHeight();
  groupOpen[0] = true;
  groupOpen[1] = true;
  groupOpen[2] = true;
  groupOpen[3] = true;

  reSizeWindow();
}

void reSizeWindow() {
  int currentHeight = 0;
  for (int i = 0; i < windowHeight.length; i++) {
    if (groupOpen[i]) {
      currentHeight += windowHeight[i];
    }
  }
  surface.setSize(492, currentHeight + 36 + 4 + 8); // + barHeight * 4 + barMargin * 4 + windowMargin * 2
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
    }
  }
}

/*
** ControlP5 Methods
 */

void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) { // check if the Event was triggered from a ControlGroup
    int id = theEvent.getGroup().getId();
    groupOpen[id] = !groupOpen[id];
    reSizeWindow();
  } else if (theEvent.isController()) {
    if (theEvent.isFrom(cp5.getController("SerialPortList"))) {
      portNumber = (int) theEvent.getController().getValue();
    }
  }
}

// Toggle
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

// Toggle
void Projection3d(boolean theFlag) {
  viewer.setProjection3d(theFlag);
}

// Toggle
void Emulate(boolean theFlag) {
  viewer.setEmulate(theFlag);
}

// Toggle
void Mapping(boolean theFlag) {
  viewer.setMapping(theFlag);
}

// Button
public void Save() {
  viewer.saveLayout("layouts/" + mTextfieldLayout.getText() + LAYOUT_EXTENSION);
}

// Button
public void Load() {
  String[] data = loadStrings("layouts/" + mTextfieldLayout.getText() + LAYOUT_EXTENSION);
  viewer.loadLayout(data);
}
