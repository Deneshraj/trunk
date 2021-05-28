import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:trunk/utils/rsa_encrypt.dart';
import 'package:trunk/utils/store_file.dart';
import 'package:trunk/utils/text_encrypt.dart';

Future<String> encryptNotebook(Map<String, dynamic> publicKey, String notebookFilePath, String notebookFileName) async {
  // Generating Random AES Key and Creating an Encryptor to Encrypt the Text
  Key key = Key.fromSecureRandom(32);
  String encryptedKey = await rsaEncrypt(publicKey['public_key'], key.bytes);
  EncryptText encryptor = EncryptText(key);
  
  // Opening the File to read the contents and Encrypting it
  File file = File(notebookFilePath);
  List<int> contents = await file.readAsBytes();
  String encryptedText = encryptor.encryptAsBytes(contents);
  
  // Creating a Map so that we can easily decrypt the Notebook file once received
  Map<String, dynamic> map = {
    "encrypted_text": encryptedText,
    'key_title': publicKey['title'],
    'encrypted_key': encryptedKey,
  };
  String jsonString = jsonEncode(map);
  
  String path =
      await storeEncryptedTemporaryFile("$notebookFileName.nb", jsonString);
  return path;
}