import 'dart:typed_data';

import "package:pointycastle/export.dart";

Future<String> rsaEncrypt(RSAPublicKey myPublic, Uint8List dataToEncrypt) async {
  final encryptor = OAEPEncoding(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic)); // true=encrypt

  return String.fromCharCodes(_processInBlocks(encryptor, dataToEncrypt));
}

Future<String> rsaDecrypt(RSAPrivateKey myPrivate, Uint8List cipherText) async {
  final decryptor = OAEPEncoding(RSAEngine())
    ..init(false, PrivateKeyParameter<RSAPrivateKey>(myPrivate)); // false=decrypt

  return String.fromCharCodes(_processInBlocks(decryptor, cipherText));
}

Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
  final numBlocks = input.length ~/ engine.inputBlockSize +
      ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

  final output = Uint8List(numBlocks * engine.outputBlockSize);

  var inputOffset = 0;
  var outputOffset = 0;
  while (inputOffset < input.length) {
    final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
        ? engine.inputBlockSize
        : input.length - inputOffset;

    outputOffset += engine.processBlock(
        input, inputOffset, chunkSize, output, outputOffset);

    inputOffset += chunkSize;
  }

  return (output.length == outputOffset)
      ? output
      : output.sublist(0, outputOffset);
}