class Pref {
  
  StringDict dict = new StringDict();
  String fileName = "pref.txt";
  
  void setString(String pKey, String pValue) {
    dict.set(pKey, pValue);
    saving();
  }
  
  String getString(String pKey) {
    return dict.get(pKey);
  }
  
  void setBoolean(String pKey, boolean pValue) {
    dict.set(pKey, str(pValue));
    saving();
  }
  
  boolean getBoolean(String pKey) {
    return boolean(dict.get(pKey));
  }
  
  void loading() {
    String lines[] = loadStrings(fileName);

    if (lines == null)
      return;
      
    for (int i = 1 ; i < lines.length; i++) {
      String[] singlePref = split(lines[i], "=");
      if(singlePref.length == 2) {
        dict.set(singlePref[0], singlePref[1]);
      }
    }
  }
  
  void saving() {
    String[] preferencesFileContent = {"Pref:"};
    for (String k : dict.keys()) {
      String appendString = k + "=" + dict.get(k);
      preferencesFileContent = append(preferencesFileContent, appendString);
    }
    saveStrings(fileName, preferencesFileContent);
  }
}
