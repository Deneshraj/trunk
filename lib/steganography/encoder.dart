import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:encrypt/encrypt.dart' as crypto;
import 'package:trunk/steganography/request/encode_request.dart';
import 'package:trunk/steganography/response/encode_response.dart';

final int byteSize = 8;
final int byteCnt = 2;
final int dataLength = byteSize * byteCnt;

Uint16List msg2bytes(String msg) {
  return Uint16List.fromList(msg.codeUnits);
}

int getMsgSize(String msg) {
  Uint16List byteMsg = msg2bytes(msg);
  return byteMsg.length * dataLength;
}

String padCryptionKey(String key) {
  if (key.length > 32) {
    throw FlutterError('cryption_key_length_greater_than_32');
  }
  String paddedKey = key;
  int padCnt = 32 - key.length;
  for (int i = 0; i < padCnt; ++i) {
    paddedKey += '.';
  }
  return paddedKey;
}

int getEncoderCapacity(Uint16List img) {
  return img.length;
}

int encodeOnePixel(int pixel, int msg) {
  if (msg != 1 && msg != 0) {
    throw FlutterError('msg_encode_bit_more_than_1_bit');
  }
  int lastBitMask = 254;
  int encoded = (pixel & lastBitMask) | msg;
  return encoded;
}

Uint16List padMsg(int capacity, Uint16List msg) {
  Uint16List padded = Uint16List(capacity);
  for (int i = 0; i < msg.length; ++i) {
    padded[i] = msg[i];
  }
  return padded;
}

Uint16List expandMsg(Uint16List msg) {
  Uint16List expanded = Uint16List(msg.length * dataLength);
  for (int i = 0; i < msg.length; ++i) {
    int msgByte = msg[i];
    for (int j = 0; j < dataLength; ++j) {
      int lastBit = msgByte & 1;
      expanded[i * dataLength + (dataLength - j - 1)] = lastBit;
      msgByte = msgByte >> 1;
    }
  }
  return expanded;
}

EncodeResponse encodeMessageIntoImage(EncodeRequest req) {
  Uint16List img = Uint16List.fromList(req.original.getBytes().toList());
  String msg = req.msg;
  String token = req.token;
  if (req.shouldEncrypt()) {
    crypto.Key key = crypto.Key.fromUtf8(padCryptionKey(token));
    crypto.IV iv = crypto.IV.fromLength(16);
    crypto.Encrypter encrypter = crypto.Encrypter(crypto.AES(key));
    crypto.Encrypted encrypted = encrypter.encrypt(msg, iv: iv);
    msg = encrypted.base64;
  }
  Uint16List encodedImg = img;
  if (getEncoderCapacity(img) < getMsgSize(msg)) {
    throw FlutterError('image_capacity_not_enough');
  }
  Uint16List expandedMsg = expandMsg(msg2bytes(msg));
  Uint16List paddedMsg = padMsg(getEncoderCapacity(img), expandedMsg);
  if (paddedMsg.length != getEncoderCapacity(img)) {
    throw FlutterError('msg_container_size_not_match');
  }
  for (int i = 0; i < getEncoderCapacity(img); ++i) {
    encodedImg[i] = encodeOnePixel(img[i], paddedMsg[i]);
  }
  imglib.Image editableImage = imglib.Image.fromBytes(
      req.original.width, req.original.height, encodedImg.toList());
  Image displayableImage =
      Image.memory(imglib.encodePng(editableImage) as Uint8List, fit: BoxFit.fitWidth);
  Uint8List data = Uint8List.fromList(imglib.encodePng(editableImage));
  EncodeResponse response =
      EncodeResponse(editableImage, displayableImage, data);
  return response;
}

Future<EncodeResponse> encodeMessageIntoImageAsync(EncodeRequest req) async {
    final EncodeResponse res = await compute(encodeMessageIntoImage, req);
    return res;
}