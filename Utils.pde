/*
 * Import
 */
import java.io.FilenameFilter;

import java.awt.Robot;
import java.awt.event.KeyEvent;

import java.util.Map;

import java.io.BufferedWriter;
import java.io.FileWriter;

public static float WordsPerMinute(String transcribedText, float timing) {
  return (transcribedText.length()-1)/timing*12f; // 60 * 1/5
}

// Dynamic Programming Approach of Levenshtein Distance from https://www.baeldung.com/java-levenshtein-distance
public static int costOfSubstitution(char a, char b) {
  return a == b ? 0 : 1;
}

public static int LeveinshteinDistance(String x, String y) {
  int[][] dp = new int[x.length() + 1][y.length() + 1];

  for (int i = 0; i <= x.length(); i++) {
    for (int j = 0; j <= y.length(); j++) {
      if (i == 0) {
        dp[i][j] = j;
      } else if (j == 0) {
        dp[i][j] = i;
      } else {
        dp[i][j] = min(dp[i - 1][j - 1] 
          + costOfSubstitution(x.charAt(i - 1), y.charAt(j - 1)), 
          dp[i - 1][j] + 1, 
          dp[i][j - 1] + 1);
      }
    }
  }
  return dp[x.length()][y.length()];
}

/**
 * Appends text to the end of a text file located in the data directory, 
 * creates the file if it does not exist.
 * Can be used for big files with lots of rows, 
 * existing lines will not be rewritten
 */
void appendTextToFile(String filename, String text) {
  File f = new File(dataPath(filename));
  if (!f.exists()) {
    createFile(f);
  }
  try {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.print(text);
    out.close();
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}


/**
 * Creates a new file including all subfolders
 */
void createFile(File f) {
  File parentDir = f.getParentFile();
  try {
    parentDir.mkdirs(); 
    f.createNewFile();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}

public static String removeLastChar(String str) {
  return str.substring(0, str.length() - 1);
}

// This function returns all the files in a directory as an array of Strings  
public static String[] listLayoutNames(String dir) {
  FilenameFilter layoutFilter = new FilenameFilter() {
    public boolean accept(File dir, String name) {
      String lowercaseName = name.toLowerCase();
      if (lowercaseName.endsWith(".layout")) {
        return true;
      } else {
        return false;
      }
    }
  };

  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list(layoutFilter);
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

static int robotCodeFromKeyCode(int keyNumber) {
  Map<Integer, Integer> mMap = new HashMap<Integer, Integer>();

  // letters (a-z)
  mMap.put(65, KeyEvent.VK_A);
  mMap.put(66, KeyEvent.VK_B);
  mMap.put(67, KeyEvent.VK_C);
  mMap.put(68, KeyEvent.VK_D);
  mMap.put(69, KeyEvent.VK_E);
  mMap.put(70, KeyEvent.VK_F);
  mMap.put(71, KeyEvent.VK_G);
  mMap.put(72, KeyEvent.VK_H);
  mMap.put(73, KeyEvent.VK_I);
  mMap.put(74, KeyEvent.VK_J);
  mMap.put(75, KeyEvent.VK_K);
  mMap.put(76, KeyEvent.VK_L);
  mMap.put(77, KeyEvent.VK_M); 
  mMap.put(78, KeyEvent.VK_N);
  mMap.put(79, KeyEvent.VK_O);
  mMap.put(80, KeyEvent.VK_P);
  mMap.put(81, KeyEvent.VK_Q);
  mMap.put(82, KeyEvent.VK_R);
  mMap.put(83, KeyEvent.VK_S);
  mMap.put(84, KeyEvent.VK_T);
  mMap.put(85, KeyEvent.VK_U);
  mMap.put(86, KeyEvent.VK_V);
  mMap.put(87, KeyEvent.VK_W);
  mMap.put(88, KeyEvent.VK_X);
  mMap.put(89, KeyEvent.VK_Y);
  mMap.put(90, KeyEvent.VK_Z);

  // numbers (0-9)
  mMap.put(48, KeyEvent.VK_0);
  mMap.put(49, KeyEvent.VK_1);
  mMap.put(50, KeyEvent.VK_2);
  mMap.put(51, KeyEvent.VK_3);
  mMap.put(52, KeyEvent.VK_4);
  mMap.put(53, KeyEvent.VK_5);
  mMap.put(54, KeyEvent.VK_6);
  mMap.put(55, KeyEvent.VK_7);
  mMap.put(56, KeyEvent.VK_8);
  mMap.put(57, KeyEvent.VK_9);

  // directional arrow
  mMap.put(37, KeyEvent.VK_LEFT);
  mMap.put(38, KeyEvent.VK_UP);
  mMap.put(39, KeyEvent.VK_RIGHT);
  mMap.put(40, KeyEvent.VK_DOWN);

  // special keys
  mMap.put(1077, KeyEvent.VK_SEMICOLON); // ",?"
  mMap.put(59, KeyEvent.VK_SEMICOLON); // ",?"

  mMap.put(44, KeyEvent.VK_COMMA); // ";." 
  mMap.put(45, KeyEvent.VK_MINUS); // ")°" 
  mMap.put(46, KeyEvent.VK_PERIOD); // ":/" 
  mMap.put(47, KeyEvent.VK_SLASH); // "=+" 
  mMap.put(61, KeyEvent.VK_EQUALS); // "-_" 
  mMap.put(93, KeyEvent.VK_CLOSE_BRACKET); // "$*" 

  mMap.put(222, KeyEvent.VK_QUOTE); // "ù%" 
  mMap.put(138, KeyEvent.VK_QUOTE); // "ù%"

  mMap.put(91, KeyEvent.VK_OPEN_BRACKET); // "^¨" 
  mMap.put(92, KeyEvent.VK_BACK_SLASH); // "`£"

  mMap.put(192, KeyEvent.VK_BACK_QUOTE); // "<>"
  mMap.put(96, KeyEvent.VK_BACK_QUOTE); // "<>"

  // un-written/printable keys
  mMap.put(8, KeyEvent.VK_BACK_SPACE);
  mMap.put(9, KeyEvent.VK_TAB);
  mMap.put(10, KeyEvent.VK_ENTER);
  mMap.put(16, KeyEvent.VK_SHIFT);
  mMap.put(17, KeyEvent.VK_CONTROL);
  mMap.put(18, KeyEvent.VK_ALT);
  mMap.put(157, KeyEvent.VK_META);
  mMap.put(32, KeyEvent.VK_SPACE);

  mMap.put(12, KeyEvent.VK_CAPS_LOCK);

  //mMap.put(,KeyEvent.VK_);

  return mMap.get(keyNumber);
}


/*
 * Help mapping from macbook pro azerty keyboard 
 */
static String textFromKeyCode(int keyNumber) {
  Map<Integer, String> mMap = new HashMap<Integer, String>();

  // letters (a-z)
  mMap.put(65, "A");
  mMap.put(66, "B");
  mMap.put(67, "C");
  mMap.put(68, "D");
  mMap.put(69, "E");
  mMap.put(70, "F");
  mMap.put(71, "G");
  mMap.put(72, "H");
  mMap.put(73, "I");
  mMap.put(74, "J");
  mMap.put(75, "K");
  mMap.put(76, "L");
  mMap.put(77, "M");
  mMap.put(78, "N");
  mMap.put(79, "O");
  mMap.put(80, "P");
  mMap.put(81, "Q");
  mMap.put(82, "R");
  mMap.put(83, "S");
  mMap.put(84, "T");
  mMap.put(85, "U");
  mMap.put(86, "V");
  mMap.put(87, "W");
  mMap.put(88, "X");
  mMap.put(89, "Y");
  mMap.put(90, "Z");

  // numbers (0-9)
  mMap.put(49, "1 !");
  mMap.put(50, "2 @");
  mMap.put(51, "3 #");
  mMap.put(52, "4 $");
  mMap.put(53, "5 %");
  mMap.put(54, "6 ^");
  mMap.put(55, "7 &");
  mMap.put(56, "8 *");
  mMap.put(57, "9 (");
  mMap.put(48, "0 )");

  // directional arrow
  mMap.put(37, "LFT");
  mMap.put(38, "UP");
  mMap.put(39, "RGHT");
  mMap.put(40, "DWN");

  // special keys
  mMap.put(1077, "; :");
  mMap.put(59, "; :");

  //mMap.put(192, "§ ±");
  mMap.put(192, "` ~");
  mMap.put(96, "` ~");

  mMap.put(44, ", <");
  mMap.put(45, "- _");  
  mMap.put(46, ". >");
  mMap.put(47, "/ ?");
  mMap.put(61, "= +");

  mMap.put(222, "' \"");
  mMap.put(138, "' \""); // 138 is key ". DEL" from numpad because " ' return the same as right arrow (code 39)

  mMap.put(92, "\\ |");
  mMap.put(91, "[ {");
  mMap.put(93, "] }");
  // mMap.put(1192, "` ~");

  // un-written/printable key
  mMap.put(8, "BKSP");
  mMap.put(9, "TAB");
  mMap.put(10, "ENTR");
  mMap.put(16, "SHFT");
  mMap.put(17, "CTRL");
  mMap.put(18, "ALT");
  mMap.put(157, "META");
  mMap.put(32, "SPCE");

  mMap.put(12, "CLCK"); // 12 is key for "Num Lock" from numpad because Caps Lock is not recognized

  //mMap.put(57, "LOCK"); // change it, understand why 1022 is not right, check website https://docs.oracle.com/javase/8/docs/api/constant-values.html#java.awt.event.KeyEvent.KEY_FIRST

  //mMap.put(,"");

  return mMap.get(keyNumber);
}

/*
 * Help mapping from macbook pro azerty keyboard 
 */
/*
static int robotCodeFromKeyCode(int keyNumber) {
 Map<Integer, Integer> mMap = new HashMap<Integer, Integer>();
 
 // letters (a-z)
 mMap.put(65, KeyEvent.VK_Q); // KeyEvent.VK_A);
 mMap.put(66, KeyEvent.VK_B);
 mMap.put(67, KeyEvent.VK_C);
 mMap.put(68, KeyEvent.VK_D);
 mMap.put(69, KeyEvent.VK_E);
 mMap.put(70, KeyEvent.VK_F);
 mMap.put(71, KeyEvent.VK_G);
 mMap.put(72, KeyEvent.VK_H);
 mMap.put(73, KeyEvent.VK_I);
 mMap.put(74, KeyEvent.VK_J);
 mMap.put(75, KeyEvent.VK_K);
 mMap.put(76, KeyEvent.VK_L);
 mMap.put(77, KeyEvent.VK_SEMICOLON); // KeyEvent.VK_M); 
 mMap.put(78, KeyEvent.VK_N);
 mMap.put(79, KeyEvent.VK_O);
 mMap.put(80, KeyEvent.VK_P);
 mMap.put(81, KeyEvent.VK_A); // KeyEvent.VK_Q);
 mMap.put(82, KeyEvent.VK_R);
 mMap.put(83, KeyEvent.VK_S);
 mMap.put(84, KeyEvent.VK_T);
 mMap.put(85, KeyEvent.VK_U);
 mMap.put(86, KeyEvent.VK_V);
 mMap.put(87, KeyEvent.VK_Z); // KeyEvent.VK_W);
 mMap.put(88, KeyEvent.VK_X);
 mMap.put(89, KeyEvent.VK_Y);
 mMap.put(90, KeyEvent.VK_W); // KeyEvent.VK_Z);
 
 // numbers (0-9)
 mMap.put(48, KeyEvent.VK_0);
 mMap.put(49, KeyEvent.VK_1);
 mMap.put(50, KeyEvent.VK_2);
 mMap.put(51, KeyEvent.VK_3);
 mMap.put(52, KeyEvent.VK_4);
 mMap.put(53, KeyEvent.VK_5);
 mMap.put(54, KeyEvent.VK_6);
 mMap.put(55, KeyEvent.VK_7);
 mMap.put(56, KeyEvent.VK_8);
 mMap.put(57, KeyEvent.VK_9);
 
 // directional arrow
 mMap.put(37, KeyEvent.VK_LEFT);
 mMap.put(38, KeyEvent.VK_UP);
 mMap.put(39, KeyEvent.VK_RIGHT);
 mMap.put(40, KeyEvent.VK_DOWN);
 
 // special keys
 mMap.put(192, KeyEvent.VK_QUOTEDBL); // "@#"
 mMap.put(1077, KeyEvent.VK_M); // ",?" -- mac azerty keyboard
 mMap.put(44, KeyEvent.VK_COMMA); // ";." -- mac azerty keyboard
 mMap.put(45, KeyEvent.VK_MINUS); // ")°" -- mac azerty keyboard
 mMap.put(46, KeyEvent.VK_PERIOD); // ":/" -- mac azerty keyboard
 mMap.put(47, KeyEvent.VK_SLASH); // "=+" -- mac azerty keyboard
 mMap.put(61, KeyEvent.VK_EQUALS); // "-_" -- mac azerty keyboard
 mMap.put(93, KeyEvent.VK_CLOSE_BRACKET); // "$*" -- mac azerty keyboard
 mMap.put(222, KeyEvent.VK_QUOTE); // "ù%" -- mac azerty keyboard
 mMap.put(91, KeyEvent.VK_OPEN_BRACKET); // "^¨" -- mac azerty keyboard
 mMap.put(92, KeyEvent.VK_BACK_SLASH); // "`£" -- mac azerty keyboard
 mMap.put(1192, KeyEvent.VK_BACK_QUOTE); // "<>" -- mac azerty keyboard
 
 // un-written/printable keys
 mMap.put(8, KeyEvent.VK_BACK_SPACE);
 mMap.put(9, KeyEvent.VK_TAB);
 mMap.put(10, KeyEvent.VK_ENTER);
 mMap.put(16, KeyEvent.VK_SHIFT);
 mMap.put(17, KeyEvent.VK_CONTROL);
 mMap.put(18, KeyEvent.VK_ALT);
 mMap.put(157, KeyEvent.VK_META);
 mMap.put(32, KeyEvent.VK_SPACE);
 
 //mMap.put(,KeyEvent.VK_);
 
 return mMap.get(keyNumber);
 }
 */

/*
 * Help mapping from macbook pro azerty keyboard 
 */
/*
static String textFromKeyCode(int keyNumber) {
 Map<Integer, String> mMap = new HashMap<Integer, String>();
 
 // letters (a-z)
 mMap.put(65, "A");
 mMap.put(66, "B");
 mMap.put(67, "C");
 mMap.put(68, "D");
 mMap.put(69, "E");
 mMap.put(70, "F");
 mMap.put(71, "G");
 mMap.put(72, "H");
 mMap.put(73, "I");
 mMap.put(74, "J");
 mMap.put(75, "K");
 mMap.put(76, "L");
 mMap.put(77, "M");
 mMap.put(78, "N");
 mMap.put(79, "O");
 mMap.put(80, "P");
 mMap.put(81, "Q");
 mMap.put(82, "R");
 mMap.put(83, "S");
 mMap.put(84, "T");
 mMap.put(85, "U");
 mMap.put(86, "V");
 mMap.put(87, "W");
 mMap.put(88, "X");
 mMap.put(89, "Y");
 mMap.put(90, "Z");
 
 // numbers (0-9)
 mMap.put(48, "0");
 mMap.put(49, "1");
 mMap.put(50, "2");
 mMap.put(51, "3");
 mMap.put(52, "4");
 mMap.put(53, "5");
 mMap.put(54, "6");
 mMap.put(55, "7");
 mMap.put(56, "8");
 mMap.put(57, "9");
 
 // directional arrow
 mMap.put(37, "LEFT");
 mMap.put(38, "UP");
 mMap.put(39, "RIGHT");
 mMap.put(40, "DOWN");
 
 // special keys
 mMap.put(1077, ", ?");
 mMap.put(192, "@ #");
 mMap.put(44, "; .");
 mMap.put(45, ") °");  
 mMap.put(46, ": /");
 mMap.put(47, "= +");
 mMap.put(61, "- _");
 mMap.put(93, "$ *");
 mMap.put(222, "ù %");
 mMap.put(92, "` £");
 mMap.put(91, "^ ¨");
 mMap.put(1192, "< >");
 
 // un-written/printable key
 mMap.put(8, "<-");
 mMap.put(9, "TAB");
 mMap.put(10, "ENTER");
 mMap.put(16, "SHIFT");
 mMap.put(17, "CTRL");
 mMap.put(18, "ALT");
 mMap.put(157, "META");
 mMap.put(32, "SPACE");
 
 //mMap.put(,"");
 
 return mMap.get(keyNumber);
 }
 */
