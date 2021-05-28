import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/model/notebook.dart';
import 'package:trunk/utils/rsa_encrypt.dart';
import 'package:trunk/utils/store_file.dart';
import 'package:trunk/utils/text_encrypt.dart';

Future<String> encryptNotebook(Map<String, dynamic> publicKey, String notebookFilePath, Notebooks notebook, DatabaseHelper helper) async {
  // Generating Random AES Key and Creating an Encryptor to Encrypt the Text
  Key key = Key.fromSecureRandom(32);
  Key fieldsKey = Key.fromSecureRandom(32);
  String encryptedKey = await rsaEncrypt(publicKey['public_key'], key.bytes);
  String encryptedFieldsKey = await rsaEncrypt(publicKey['public_key'], key.bytes);
  EncryptText encryptor = EncryptText(key);
  EncryptText cipher = EncryptText(fieldsKey);
  
  // Opening the File to read the contents and Encrypting it
  await helper.processNotebookForSharing(notebook, cipher);
  File file = File(notebookFilePath);
  List<int> contents = await file.readAsBytes();
  String encryptedText = encryptor.encryptAsBytes(contents);
  
  // Creating a Map so that we can easily decrypt the Notebook file once received
  Map<String, dynamic> map = {
    "encrypted_text": encryptedText,
    'key_title': publicKey['title'],
    'encrypted_key': encryptedKey,
    'fields_encrypted_key': encryptedFieldsKey
  };
  String jsonString = jsonEncode(map);
  
  String path =
      await storeEncryptedTemporaryFile("${notebook.name}.nb", jsonString);
  return path;
}