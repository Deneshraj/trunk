import 'package:aes_crypt/aes_crypt.dart';

class FileEncrypt {
  final String _password;

  FileEncrypt(this._password );
  
  String encryptFile(String path) {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.on);
    crypt.setPassword(_password);
    try {
      String encFilepath;
      encFilepath = crypt.encryptFileSync(path);
      return encFilepath;
    } catch (e, s) {
      print("$e");
      print("Exception while Encrypting File: $s");
    }
    return null;
  }

  String decryptFile(String path) {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.on);
    crypt.setPassword(_password);
    try {
        String decFilepath;
        decFilepath = crypt.decryptFileSync(path);
        return decFilepath;
    } catch (e) {
      print("$e");
    }
    return null;
  }
}