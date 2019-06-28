/*
** Import
 */

import controlP5.*;
import processing.serial.*;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;


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
Textarea textAreaConsole;
Textfield mTextfieldLayout;
Toggle toggleListening;
Textfield textfieldUser;

/*
** Settings variable
 */

boolean mListening = false;

Serial myPort;  // The serial port
int portNumber = -1;
String keepUniChar = "";

State state;
Viewer viewer;

int windowHeight[];
boolean groupOpen[];

DateTimeFormatter dtf;

Pref preference = new Pref();

/*
  Callback
 */

CallbackListener toFront = new CallbackListener() {
  public void controlEvent(CallbackEvent theEvent) {
    switch(theEvent.getController().getName()) {
    case "UserDirectoryList":
      cp5.getGroup("User").bringToFront();
      break;
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
    bringToFront();
  }
};


void bringToFront() {
  cp5.getGroup("User").bringToFront();
  cp5.getGroup("Port").bringToFront();
  cp5.getGroup("Layout").bringToFront();
  cp5.getGroup("Viewer").bringToFront();
  cp5.getGroup("Console").bringToFront();
}

void setup() {
  size(492, 764, P3D);
  surface.setAlwaysOnTop(true);
  surface.setResizable(true);

  dtf = DateTimeFormatter.ofPattern("HH:mm:ss:SSS");

  smooth();
  PFont font = createFont("Arial", 20, true);
  textFont(font);

  windowHeight = new int[5]; // number of accordion group (Port, Layout, Viewer, Console)
  groupOpen = new boolean[5];

  /*
  ControlP5
   */

  cp5 = new ControlP5(this);

  /*
  CONSOLE
   */

  Group groupConsole = cp5.addGroup("Console")
    .setBackgroundHeight(120)
    .setId(4)
    ;

  textAreaConsole = cp5.addTextarea("textAreaConsole")
    .setPosition(0, 0)
    .setSize(484, 120)
    .setFont(createFont("arial", 15))
    .setLineHeight(14)
    .setColor(255)
    .setColorBackground(0)
    .moveTo(groupConsole)
    .scroll(1)
    ;

  /*
  VIEWER
   */

  Group groupViewer = cp5.addGroup("Viewer")
    .setBackgroundColor(160)
    .setBackgroundHeight(484)
    .setId(3)
    ;

  viewer = new Viewer(cp5, "ViewerController").setPosition(0, 0).moveTo(groupViewer).setMatrices();
  viewer.setCallback(new ToViewerCallback());

  /*
  LAYOUT
   */

  Group groupLayout = cp5.addGroup("Layout")
    .setBackgroundColor(160)
    .setBackgroundHeight(64)
    .setId(2)
    ;

  mTextfieldLayout = cp5.addTextfield("LayoutFileName")
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
    .setBroadcast(false)
    .setPosition(56, 28)
    .setSize(48, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .moveTo(groupLayout)
    .setBroadcast(true)
    ;

  cp5.addToggle("Projection3d")
    .setBroadcast(false)
    .setPosition(108, 28)
    .setSize(48, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .moveTo(groupLayout)
    .setBroadcast(true)
    ;

  state = new State(263, 28, 217, 24, color(48));
  state.post(); // use cc.pre(); to draw beyond existing controllers.
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
    .setId(1)
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
  USER
   */

  Group groupUser = cp5.addGroup("User")
    .setBackgroundColor(160)
    .setBackgroundHeight(32)
    .setId(0)
    ;

  textfieldUser = cp5.addTextfield("UserDirectoryName")
    .setPosition(264, 4)
    .setSize(128, 20)
    .setText("unknown")
    .moveTo(groupUser)
    ;
  textfieldUser.getCaptionLabel().setVisible(false);

  cp5.addScrollableList("UserDirectoryList")
    .setPosition(4, 4)
    .setSize(256, 128)
    .setBarHeight(20)
    .setItemHeight(20)
    .setBackgroundColor(color(48))
    .addItems(getUserDirectoryList())
    .moveTo(groupUser)
    .onEnter(toFront)
    .onLeave(reOrder)
    .close()
    ;

  /*
  Main
   */

  Accordion accordion = cp5.addAccordion("accordionMain")
    .setPosition(4, 4)
    .setWidth(484)
    .setMinItemHeight(32)

    .addItem(groupUser)
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
    ;


  windowHeight[0] = groupUser.getBackgroundHeight();
  windowHeight[1] = groupPort.getBackgroundHeight();
  windowHeight[2] = groupLayout.getBackgroundHeight();
  windowHeight[3] = groupViewer.getBackgroundHeight();
  windowHeight[4] = groupConsole.getBackgroundHeight();

  cp5.getProperties().addSet("k3Set");
  cp5.getProperties().move(cp5.getController("LayoutFileName"), "default", "k3Set");
  cp5.getProperties().move(cp5.getController("UserDirectoryName"), "default", "k3Set");
  cp5.getProperties().move(cp5.getController("Projection3d"), "default", "k3Set");
  cp5.getProperties().move(cp5.getController("Emulate"), "default", "k3Set");
  cp5.loadProperties(("k3Set"));

  preference.loading();

  for (int i = 0; i < groupOpen.length; i++) {
    groupOpen[i] = preference.getBoolean("GROUP"+i);
    if (groupOpen[i])
      accordion.open(i);
  }

  reSizeWindow();

  printArray(getUserDirectoryList());
}

// Draw
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


void reSizeWindow() {
  int currentHeight = 0;
  for (int i = 0; i < windowHeight.length; i++) {
    if (groupOpen[i]) {
      currentHeight += windowHeight[i];
    }
  }
  surface.setSize(492, currentHeight + 45 + 5 + 8); // + barHeight * 4 + barMargin * 4 + windowMargin * 2
}

String[] getUserDirectoryList() {
  FilenameFilter userFilter = new FilenameFilter() {
    @Override public boolean accept(File current, String name) {
      return new File(current, name).isDirectory();
    }
  };

  String path = sketchPath() + "/users";
  File file = new File(path);
  if (file.isDirectory()) {
    String names[] = file.list(userFilter);
    return names;
  } else {
    return null;
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

    addLog(viewer.lookForKey(s));
  }
}

void addLog(String s) {
  textAreaConsole.append(dtf.format(LocalTime.now()) + "\t" + s + "\n");
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
    preference.setBoolean("GROUP"+id, groupOpen[id]);
    reSizeWindow();
  } else if (theEvent.isController()) {
    int index = (int) theEvent.getController().getValue();
    if (theEvent.isFrom(cp5.getController("SerialPortList"))) {
      portNumber = index;
      bringToFront();
    }
    if (theEvent.isFrom(cp5.getController("LayoutFileList"))) {
      mTextfieldLayout.setText(getLayoutFileList()[index].replace(".layout", ""));
      cp5.saveProperties("k3Set", "k3Set");
      bringToFront();
    }
    if (theEvent.isFrom(cp5.getController("UserDirectoryList"))) {
      textfieldUser.setText(getUserDirectoryList()[index]);
      cp5.saveProperties("k3Set", "k3Set");
      bringToFront();
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
  addLog("LISTENING " + theFlag);
}

// Toggle
void Projection3d(boolean theFlag) {
  viewer.setProjection3d(theFlag);
  cp5.saveProperties("k3Set", "k3Set");
  addLog("PROJECTION3D " + theFlag);
}

// Toggle
void Emulate(boolean theFlag) {
  viewer.setEmulate(theFlag);
  cp5.saveProperties("k3Set", "k3Set");
  addLog("EMULATE " + theFlag);
}

// Toggle
void Mapping(boolean theFlag) {
  viewer.setMapping(theFlag);
  addLog("MAPPING " + theFlag);
}

// Button
public void Save() {
  viewer.saveLayout("layouts/" + mTextfieldLayout.getText() + LAYOUT_EXTENSION);
  println("ButtonSave");
  cp5.saveProperties("k3Set", "k3Set");
  addLog("SAVE " + mTextfieldLayout.getText());
}

// Button
public void Load() {
  String[] data = loadStrings("layouts/" + mTextfieldLayout.getText() + LAYOUT_EXTENSION);
  viewer.loadLayout(data);
  cp5.saveProperties("k3Set", "k3Set");
  addLog("LOAD " + mTextfieldLayout.getText());
}
