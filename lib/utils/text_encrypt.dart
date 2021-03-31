import 'package:encrypt/encrypt.dart';

class EncryptText {
  final Key _key;
  IV iv;
  Encrypter encrypter;

  EncryptText(this._key) {
    this.iv = IV.fromLength(16);
    this.encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
  }

  String aesEncrypt(String text) {
    Encrypted encrypted = encrypter.encrypt(text, iv: iv);
    return encrypted.base64;
  }

  String aesDecrypt(String encryptedText) {
    Encrypted encrypted = Encrypted.fromBase64(encryptedText);
    return encrypter.decrypt(encrypted, iv: iv);
  }
}