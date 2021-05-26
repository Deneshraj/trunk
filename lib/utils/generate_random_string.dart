import 'dart:math';

String generateRandomString(int length, int type, String excludeList) {
    String randomString = "";
    String required = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
    String splChars = "!@#\$%^&*()_+-=~`";
    String superSplChars = "{}[]:;<>,.?/|\\";
    
    String validStrings = required;
    
    switch(type) {
      case 1:
        validStrings += splChars;
        break;
      case 2:
        validStrings += superSplChars;
        break;
      default:
        break;
    }
    
    Random rng = Random();
    int maxLen = validStrings.length;

    for (int i = 0; i < length; i++) {
      String currentChar = validStrings[rng.nextInt(maxLen)];
      while(excludeList.contains(currentChar)) {
        currentChar = validStrings[rng.nextInt(maxLen)]; 
      }
      randomString += currentChar;
    }

    return randomString;
  }