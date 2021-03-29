
import 'dart:io';
import 'package:aes_crypt/aes_crypt.dart';

class FileEncrypt {
  final String password;

  FileEncrypt({ this.password });
  
  String encryptFile(String path) {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.on);
    crypt.setPassword(password);
    String encFilepath;
    try {
      encFilepath = crypt.encryptFileSync(path);
      print('The encryption has been completed successfully.');
      print('Encrypted file: $encFilepath');
    } catch (e) {
      print("$e");
    }
    return encFilepath;
  }

  String decryptFile(String path) {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.on);
    crypt.setPassword(password);
    String decFilepath;
    try {
      decFilepath = crypt.decryptFileSync(path);
      print('The decryption has been completed successfully.');
      print('Decrypted file 1: $decFilepath');
      print('File content: ' + File(decFilepath).path);
    } catch (e) {
      print("$e");
    }
    return decFilepath;
  }
}