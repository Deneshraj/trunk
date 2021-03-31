import 'package:encrypt/encrypt.dart';

class EncryptedFileParams {
  final Key _key;
  final String path;

  EncryptedFileParams(this._key, {
    this.path,
  });

  Key get key {
    return _key;
  }
}
