import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/utils/rsa_encrypt.dart';
import 'package:trunk/utils/store_file.dart';
import 'package:trunk/utils/text_encrypt.dart';

Future<String> encryptNote(Map<String, dynamic> publicKey, Note note) async {
  Key key = Key.fromSecureRandom(32);
  String encryptedKey = await rsaEncrypt(publicKey['public_key'], key.bytes);
  Map<String, dynamic> noteMap = note.toMap();
  EncryptText encryptor = EncryptText(key);
    String encryptedText = encryptor.encryptText(jsonEncode(noteMap));
  Map<String, dynamic> map = {
    "encrypted_text": encryptedText,
    'key_title': publicKey['title'],
    'encrypted_key': encryptedKey,
  };

  String jsonString = jsonEncode(map);
  String path =
      await storeEncryptedTemporaryFile("${note.title}.nt", jsonString);
  return path;
}
