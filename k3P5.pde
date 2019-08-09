/*
** Import
 */

import controlP5.*;
import processing.serial.*;
import java.time.LocalTime;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.Arrays;
import java.util.List;


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

Textlabel textlabelPhrase;
Textfield textfieldPhrase;
Textfield textfieldRetranscribe;

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

DateTimeFormatter dtfTiming;
DateTimeFormatter dtfYearMonth;

Pref preference = new Pref();

List<String> phrases;
int phraseIndex;
long timer;
Slider sliderTimer;
int timerValue = 1200;
boolean sessionPhrase = false;

boolean isAzerty = false;
boolean isCube = false;
int Session = 1;

float firstCharacterTiming = -1f;
float beforePreviousCharacterTiming = 0f;
float previousCharacterTiming = 0f;

int keystrokeCount = 0;

String fullAA;
String fullAB;
int countNbAlignment;

String fullInputStream = "";
Textlabel textlabelWPM;
Textlabel textlabelErrorRate;


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
  cp5.getGroup("Phrase").bringToFront();
  cp5.getGroup("Viewer").bringToFront();
  cp5.getGroup("Console").bringToFront();
}

void setup() {
  size(492, 764, P3D);
  surface.setAlwaysOnTop(true);
  surface.setResizable(true);

  dtfTiming = DateTimeFormatter.ofPattern("HH:mm:ss.SSS");
  dtfYearMonth = DateTimeFormatter.ofPattern("YYYYMM");

  smooth();
  PFont font = createFont("Arial", 20, true);
  textFont(font);

  windowHeight = new int[6]; // number of accordion group (Port, Layout, Viewer, Console)
  groupOpen = new boolean[6];

  /*
  ControlP5
   */

  cp5 = new ControlP5(this);

  /*
  CONSOLE
   */

  Group groupConsole = cp5.addGroup("Console")
    .setBackgroundHeight(120)
    .setId(5)
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
    .setId(4)
    ;

  viewer = new Viewer(cp5, "ViewerController").setPosition(0, 0).moveTo(groupViewer).setMatrices();
  viewer.setCallback(new ToViewerCallback());


  /*
  PHRASE
   */

  Group groupPhrase = cp5.addGroup("Phrase")
    .setBackgroundColor(160)
    .setBackgroundHeight(210)
    .setId(3)
    ;

  cp5.addButton("Start")
    .setPosition(4, 4)
    .setSize(40, 20)
    .moveTo(groupPhrase)
    ;

  cp5.addToggle("CubeBoard")
    .setBroadcast(false)
    .setPosition(4, 28)
    .setSize(44, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .moveTo(groupPhrase)
    .setBroadcast(true)
    ;

  cp5.addToggle("AzertyQwerty")
    .setBroadcast(false)
    .setPosition(52, 28)
    .setSize(62, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .moveTo(groupPhrase)
    .setBroadcast(true)
    ;

  cp5.addSlider("Session")
    .setPosition(118, 28)
    .setWidth(160)
    .setRange(1, 6) // values can range from big to small as well
    .setValue(1)
    .setNumberOfTickMarks(6)
    .setSliderMode(Slider.FLEXIBLE)
    .moveTo(groupPhrase)
    ;

  cp5.addButton("Pause")
    .setPosition(396, 4)
    .setSize(40, 20)
    .moveTo(groupPhrase)
    ;

  cp5.addButton("Resume")
    .setPosition(440, 4)
    .setSize(40, 20)
    .moveTo(groupPhrase)
    ;

  sliderTimer = cp5.addSlider("Timer")
    .setPosition(4, 64)
    .setSize(476, 16)
    .setRange(0, 1200)
    .setValue(1200)
    .moveTo(groupPhrase)
    ;

  PFont pfontPhrase = createFont("Monospaced", 18, true);
  ControlFont cfont = new ControlFont(pfontPhrase);

  textfieldPhrase = cp5.addTextfield("fieldPhrase")
    .setFont(cfont)
    .setPosition(4, 84)
    .setSize(476, 32)
    .setText("abcdefghijklmnopqrstuvwxyz")
    .moveTo(groupPhrase)
    ;
  textfieldPhrase.getCaptionLabel().setVisible(false);

  textfieldRetranscribe = cp5.addTextfield("fieldRetranscribe")
    .setText("")
    .setFont(cfont)
    .setPosition(4, 120)
    .setSize(476, 32)
    .moveTo(groupPhrase)
    .setText("_")
    ;
  textfieldRetranscribe.getCaptionLabel().setVisible(false);

  textlabelWPM = cp5.addTextlabel("WPM")
    .setText("- wpm")
    .setFont(cfont)
    .setPosition(320, 156)
    .setWidth(40)
    .setHeight(20)
    .moveTo(groupPhrase)
    ;
    
  textlabelErrorRate = cp5.addTextlabel("ErrorRate")
    .setText("- %")
    .setFont(cfont)
    .setPosition(320, 180)
    .setWidth(40)
    .setHeight(20)
    .moveTo(groupPhrase)
    ;

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
    .setBroadcast(false)
    .setPosition(4, 28)
    .setSize(48, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .moveTo(groupLayout)
    .setBroadcast(true)
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

  cp5.addButton("Refresh")
    .setPosition(264, 4)
    .setSize(40, 20)
    .moveTo(groupPort)
    ;

  toggleListening = cp5.addToggle("Listening")
    .setBroadcast(false)
    .setPosition(308, 4)
    .setSize(48, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .moveTo(groupPort)
    .setBroadcast(true)
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
    .addItem(groupPhrase)
    .addItem(groupViewer)
    .addItem(groupConsole)
    .setCollapseMode(Accordion.MULTI)

    .setColorBackground(color(48))

    .setColorActive(color(128))
    .setColorForeground(color(128))

    .setColorLabel(color(232))
    .setColorValue(color(232))
    ;

  textfieldPhrase.setColorBackground(color(160))
    .setColorActive(color(255, 0, 0))
    .setColorForeground(color(160))
    .setColorValue(color(255));

  windowHeight[0] = groupUser.getBackgroundHeight();
  windowHeight[1] = groupPort.getBackgroundHeight();
  windowHeight[2] = groupLayout.getBackgroundHeight();
  windowHeight[3] = groupPhrase.getBackgroundHeight();
  windowHeight[4] = groupViewer.getBackgroundHeight();
  windowHeight[5] = groupConsole.getBackgroundHeight();

  cp5.getProperties().addSet("k3Set");
  cp5.getProperties().move(cp5.getController("UserDirectoryName"), "default", "k3Set");
  cp5.getProperties().move(cp5.getController("LayoutFileName"), "default", "k3Set");  
  cp5.getProperties().move(cp5.getController("Projection3d"), "default", "k3Set");
  cp5.getProperties().move(cp5.getController("Emulate"), "default", "k3Set");
  cp5.getProperties().move(cp5.getController("AzertyQwerty"), "default", "k3Set");
  cp5.getProperties().move(cp5.getController("CubeBoard"), "default", "k3Set");
  cp5.loadProperties(("k3Set"));

  preference.loading();

  for (int i = 0; i < groupOpen.length; i++) {
    groupOpen[i] = preference.getBoolean("GROUP"+i);
    if (groupOpen[i])
      accordion.open(i);
  }

  reSizeWindow();

  printArray(getUserDirectoryList());

  loadPhrases();
  timer = millis();

  float MSA = MeanSizeAlignments("quickly", "qucehkly", LeveinshteinMatrix("quickly", "qucehkly"), "quickly".length(), "qucehkly".length(), "", "");
  println("MSA= " + MSA);
  println("errorRate");
  println(LeveinshteinDistance("quickly", "qucehkly") * 100.0f / Math.max("quickly".length(), "qucehkly".length()));
  println(LeveinshteinDistance("quickly", "qucehkly") * 100.0f / MSA);

  //println(Math.max("quickly".length(), "qucehkly".length()));
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
        //println(inBuffer);
        lookForKey(inBuffer);
      }
    }
  }

  if (sessionPhrase) {
    if (millis() >= timer) {
      timer += 1000;
      timerValue -= 1;
      sliderTimer.setValue(timerValue);
      if (sliderTimer.getValue() == 0) {
        addLog("FINISH (time due) SESSION " + Session);
        sessionPhrase = false;
      }
    }
  }
}

public void loadPhrases() {
  phrases = Arrays.asList(loadStrings("dataset/phrases2.txt"));
  print(phrases.size());
  addLog("LOAD PHRASES");
  Collections.shuffle(phrases);
  phraseIndex = -1;
}

public void newPhrase() {
  if (phraseIndex >= phrases.size()-1) {
    phraseIndex = -1;
  }
  phraseIndex += 1;
  addLog("PHRASE\t" + phrases.get(phraseIndex));
  textfieldPhrase.setText(phrases.get(phraseIndex));
}

void reSizeWindow() {
  int currentHeight = 0;
  for (int i = 0; i < windowHeight.length; i++) {
    if (groupOpen[i]) {
      currentHeight += windowHeight[i];
    }
  }
  surface.setSize(492, currentHeight + 10 * windowHeight.length + 8); // + barHeight * 5 + barMargin * 5 + windowMargin * 2
}

void appendLogToFile(String text) {
  if (textfieldUser.getText().length() > 0) {
    String path = sketchPath() + "/users/" + textfieldUser.getText() + "/" + dtfYearMonth.format(LocalDateTime.now()) + ".txt";
    appendTextToFile(path, text);
  }
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

    if (isCube) {
      addk3CharToLog(viewer.lookForKey(s));
    } else {
      viewer.lookForKey(s);
    }
  }
}

void startCounting() {
  firstCharacterTiming = millis();
  println("startCounting");
  textfieldPhrase.setColorValue(color(160, 238, 255));
  keystrokeCount = 1;
  fullInputStream = "";
}

void addk3CharToLog(String s) {
  if (s.substring(0, 4).equals("true")) { // equivalent of if (isPress)
    keystrokeCount += 1;
    if (firstCharacterTiming == -1f) {
      startCounting();
    }
    beforePreviousCharacterTiming = previousCharacterTiming;
    previousCharacterTiming = millis();

    fullInputStream += s;
  }
  addLog(isAzerty + "\t" + Session + "\t" + isCube + "\t" + s);
}

void addkbCharToLog(char c, boolean isPress) {
  if (isPress) {
    keystrokeCount += 1;
    if (firstCharacterTiming == -1f) {
      startCounting();
    }
    beforePreviousCharacterTiming = previousCharacterTiming;
    previousCharacterTiming = millis();

    fullInputStream += c;
  }
  if (!isCube)
    addLog(isAzerty + "\t" + Session + "\t" + isCube + "\t" + isPress + "\t" + c);
}

void addkbCharToLog(int keycode, boolean isPress) {
  if (!isCube)
    addLog(isAzerty + "\t" + Session + "\t" + isCube + "\t" + isPress + "\t" + keycode);
}

void addLog(String s) {
  s = dtfTiming.format(LocalTime.now()) + "\t" + s + "\n";
  textAreaConsole.append(s);
  appendLogToFile(s);
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

  handleKeyEvent(keyCode, true);
}

void keyReleased() {
  handleKeyEvent(keyCode, false);
}

void handleKeyEvent(int keycode, boolean isPress) {
  String transcribed = textfieldRetranscribe.getText();

  if (keycode == 8) { // backspace
    if (transcribed.length()-1 > 0 && isPress) {
      textfieldRetranscribe.setText(transcribed.substring(0, transcribed.length()-2) + "_");
    }
    addkbCharToLog('<', isPress);
  } else 
  if (keycode == 10) { // enter
    addkbCharToLog('>', isPress);
    if (isPress) {
      textfieldRetranscribe.submit();
      textfieldRetranscribe.setText("_");
    }
  } else 
  if (keycode == 32) { // space
    if (isPress) 
      textfieldRetranscribe.setText(transcribed.substring(0, transcribed.length()-1) + " _");
    addkbCharToLog('_', isPress);
  } else
    if (keycode == 59) { // (59 = M with AZERTY, 
      if (isAzerty) { // 59 > 77
        if (isPress)
          textfieldRetranscribe.setText(transcribed.substring(0, transcribed.length()-1) + char(77+32) + "_");
        addkbCharToLog(char(77+32), isPress);
      } else {
        addkbCharToLog(keycode, isPress);
      }
    } else
      if (keycode == 77) {
        if (isAzerty) {
          addkbCharToLog(keycode, isPress);
        } else {
          if (isPress)
            textfieldRetranscribe.setText(transcribed.substring(0, transcribed.length()-1) + char(77+32) + "_");
          addkbCharToLog(char(77+32), isPress);
        }
      } else
        if (keycode >= 'A' && keycode <= 'Z') { // between 65 and 90
          int newKeycode = keycode;

          if (isAzerty) { // 81 <> 65, 90 <> 87
            if (newKeycode == 81 || newKeycode == 65) {
              if (newKeycode == 81) {
                newKeycode = 65;
              } else {
                newKeycode = 81;
              }
            }

            if (newKeycode == 90 || newKeycode == 87) {
              if (newKeycode == 90) {
                newKeycode = 87;
              } else {
                newKeycode = 90;
              }
            }
          }
          if (isPress) 
            textfieldRetranscribe.setText(transcribed.substring(0, transcribed.length()-1) + char(newKeycode+32) + "_");
          addkbCharToLog(char(newKeycode+32), isPress);
        } else {
          addkbCharToLog(keycode, isPress);
        }
}

/*
** ControlP5 Methods
 */

void stopCounting() {
  firstCharacterTiming = -1f;
  textfieldPhrase.setColorValue(color(255));
}

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
    if (theEvent.isFrom(textfieldRetranscribe)) {
      String s = theEvent.getStringValue();
      s = s.substring(0, s.length()-1);
      float timingS = (beforePreviousCharacterTiming - firstCharacterTiming)/1000f;
      String presentedText = textfieldPhrase.getText(); //phrases.get(phraseIndex);
      float LD = LeveinshteinDistance(presentedText, s);
      float WPM = WordsPerMinute(s, timingS);
      float errorRate = LD / MeanSizeAlignments(presentedText, s, LeveinshteinMatrix(presentedText, s), presentedText.length(), s.length(), "", "") * 100f;
      if (sessionPhrase) {
        addLog("DONE" +
          "\t" + presentedText + 
          "\t" + s + 
          "\t" + LD + 
          "\t" + timingS + 
          "\t" + WPM + 
          "\t" + (keystrokeCount-1) + 
          "\t" + KSPC(keystrokeCount-1, s.length()) + // minus 1 to keystrokeCount to remove Enter
          "\t" + errorRate +
          "\t" + fullInputStream          
          );

        newPhrase(); // public float MeanSizeAlignments(String A, String B, int[][] D, int X, int Y, String AA, String AB) {
      }
      textlabelWPM.setText(WPM + " wpm");
      textlabelErrorRate.setText(errorRate + " %");
      stopCounting();
    }
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
    } else {
      myPort = null;
    }
  }
  addLog("LISTENING\t" + theFlag);
}

// Toggle
void CubeBoard(boolean theFlag) {
  isCube = theFlag;
  cp5.saveProperties("k3Set", "k3Set");
  addLog("CubeBoard\t" + isCube);
}

// Toggle
void AzertyQwerty(boolean theFlag) {
  isAzerty = theFlag;
  cp5.saveProperties("k3Set", "k3Set");
  addLog("AzertyQwerty\t" + isAzerty);
}

// Toggle
void Projection3d(boolean theFlag) {
  viewer.setProjection3d(theFlag);
  cp5.saveProperties("k3Set", "k3Set");
  addLog("PROJECTION3D\t" + theFlag);
}

// Toggle
void Emulate(boolean theFlag) {
  viewer.setEmulate(theFlag);
  cp5.saveProperties("k3Set", "k3Set");
  addLog("EMULATE\t" + theFlag);
}

// Toggle
void Mapping(boolean theFlag) {
  viewer.setMapping(theFlag);
  addLog("MAPPING\t" + theFlag);
}

public void Pause() {
  if (sessionPhrase) {
    sessionPhrase = false;
    textfieldRetranscribe.submit();
    textfieldRetranscribe.setText("_");
    textfieldRetranscribe.setColorValue(color(0));
    addLog("PAUSE\t");
  }
}

public void Resume() {
  if (!sessionPhrase) {
    timer = millis() + 1000;
    sessionPhrase = true;
    textfieldRetranscribe.setColorValue(color(255));
    addLog("RESUME\t");
  }
}

// Button
public void Save() {
  viewer.saveLayout("layouts/" + mTextfieldLayout.getText() + LAYOUT_EXTENSION);
  println("ButtonSave");
  cp5.saveProperties("k3Set", "k3Set");
  addLog("SAVE\t" + mTextfieldLayout.getText());
}

// Button
public void Load() {
  String[] data = loadStrings("layouts/" + mTextfieldLayout.getText() + LAYOUT_EXTENSION);
  viewer.loadLayout(data);
  cp5.saveProperties("k3Set", "k3Set");
  addLog("LOAD\t" + mTextfieldLayout.getText());
}

// Button
public void Start() {
  textfieldRetranscribe.submit();
  textfieldRetranscribe.setText("_");
  firstCharacterTiming = -1f;
  addLog("START SESSION " + Session);
  sliderTimer.setValue(1200);
  timer = millis() + 1000;
  timerValue = 1200;
  sessionPhrase = true;
  newPhrase();
}

// Button
public void Refresh() {
  println("Refresh()");
  cp5.get(ScrollableList.class, "SerialPortList").clear();
  cp5.get(ScrollableList.class, "SerialPortList").addItems(Serial.list());
}

public float MeanSizeAlignments(String A, String B, int[][] D, int X, int Y, String AA, String AB) {
  fullAA = "";
  fullAB = "";
  countNbAlignment = 0;
  Align(A, B, D, X, Y, AA, AB);
  println("fullAA " + fullAA);
  println("fullAB " + fullAB);
  println("countNbAlignment " + countNbAlignment);
  return (float)fullAA.length()/countNbAlignment;
}

public void Align(String A, String B, int[][] D, int X, int Y, String AA, String AB) {
  if (X == 0 && Y == 0) {
    fullAA += AA;
    fullAB += AB;
    countNbAlignment += 1;
    println(AA);
    println(AB);
    return;
  }
  if (X > 0 && Y > 0) {
    if (D[X][Y] == D[X-1][Y-1] && A.charAt(X-1) == B.charAt(Y-1))
      Align(A, B, D, X-1, Y-1, A.charAt(X-1) + AA, B.charAt(Y-1) + AB);
    if (D[X][Y] == D[X-1][Y-1] + 1)
      Align(A, B, D, X-1, Y-1, A.charAt(X-1) + AA, B.charAt(Y-1) + AB);
  }
  if (X > 0 && D[X][Y] == D[X-1][Y] + 1)
    Align(A, B, D, X-1, Y, A.charAt(X-1) + AA, "-" + AB);
  if (Y > 0 && D[X][Y] == D[X][Y-1] + 1)
    Align(A, B, D, X, Y-1, "-" + AA, B.charAt(Y-1) + AB);
  return;
}
