import 'dart:io';
import 'dart:math';

import 'dart:typed_data';
import 'package:image/image.dart' as imglib;

String strBin(String msg) {
  return msg.codeUnits.map((x) => x.toRadixString(2).padLeft(8, '0')).join();
}

String binStr(String msg) {
  String msgStr = "";

  for (int i = 0, msgLen = msg.length; i < msgLen; i += 8) {
    int charCode = int.parse(msg.substring(i, i + 8), radix: 2);
    msgStr += String.fromCharCode(charCode);
  }

  return msgStr;
}

bool isSingleColoured(List mp) {
  int color = mp[0];
  for (int i = 0; i < mp.length; i++) {
    if (i != color) {
      return false;
    }
  }
  return true;
}

List changeCmp(List cmp, String strBit) {
  int initialColor = cmp[0];
  int pos = 0;
  int bit = int.parse(strBit);
  for (int i = 0; i < cmp.length; i++) {
    if (cmp[i] != initialColor) {
      pos = i - 1;
      break;
    }
  }

  if (bit == 1) {
    cmp[pos + 1] = (cmp[pos] == 255) ? 254 : 1;
  } else {
    cmp[pos + 1] = (cmp[pos] == 0) ? 2 : 253;
  }

  return cmp;
}

List matchAdjustment(List pmp, List cmp) {
  bool complementary = (pmp[0] != cmp[0]);
  List newCmp = cmp.toList();

  for (int i = 0; i < 8; i++) {
    if (complementary) {
      if (pmp[i] == 255)
        newCmp[i] = 0;
      else
        newCmp[i] = 255;
    } else
      newCmp[i] = pmp[i];
  }
  return newCmp;
}

List hideMsg(List imgPixels, msg, {k = 1}) {
  // TODO:A Method To Check if we can Hide the Data inside msg or not
  int position = 0;
  int size = msg.length;

  int rows = imgPixels.length;
  int cols = imgPixels[0].length;
  List newCmp;

  List pmp;
  List cmp;

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols - 6; j += 8) {
      for (k = 0; k < 8; k++) {
        cmp = imgPixels[i][j + k];
      }
      if (i > 1) {
        for (k = 0; k < 8; k++) {
          pmp = imgPixels[i - 1][j + k];
        }
        if (isSingleColoured(pmp)) {
          if (!isSingleColoured(cmp) && (position < size)) {
            newCmp = changeCmp(cmp, msg[position]);
            for (int k = 0; k < 8; k++) {
              imgPixels[i][j + k] = newCmp[k];
            }
            position += 1;
          }
        } else {
          if (!isSingleColoured(cmp)) {
            newCmp = matchAdjustment(pmp, cmp);
            for (int k = 0; k < 8; k++) {
              imgPixels[i][j + k] = newCmp[k];
            }
            continue;
          }
        }
      } else {
        if (!isSingleColoured(cmp) && position < size) {
          newCmp = changeCmp(cmp, msg[position]);
          for (int k = 0; k < 8; k++) {
            imgPixels[i][j + k] = newCmp[k];
          }
          position += 1;
        }
      }
    }
  }

  return imgPixels;
}

int getMsgBit(List cmp) {
  if (cmp.contains(1) || cmp.contains(254))
    return 1;
  else if (cmp.contains(2) || cmp.contains(253))
    return 0;
  else
    return null;
}

String retrieveMsg(List imgPixels, {int k = 1}) {
  String returnString = "";
  List pmp;
  List cmp;
  int rows = imgPixels.length;
  int cols = imgPixels[0].length;

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols - 6; j += 8) {
      for (int k = 0; k < 8; k++) cmp = imgPixels[i][j + k];

      if (i > 1) {
        for (int k = 0; k < 8; k++) pmp = imgPixels[i - 1][j + k];
        if (!isSingleColoured(cmp)) {
          if (isSingleColoured(pmp)) {
            String bit = getReturnString(cmp);
            if (bit != null) returnString += bit;
          }
        }
      } else {
        String bit = getReturnString(cmp);
        if (bit != null) returnString += bit;
      }
    }
  }

  return returnString;
}

String getReturnString(List cmp) {
  int bit = getMsgBit(cmp);
  if (bit != null) return "$bit";
  return null;
}

List convertToLongList(List imgPixels) {
  List returnList = [];
  int row = imgPixels.length;
  int col = imgPixels[0].length;

  for (int i = 0; i < row; i++)
    for (int j = 0; j < col; j++) returnList.add(imgPixels[i][j]);

  return returnList;
}

List getQrPixels(imglib.Image img) {
  int width = img.width;
  int height = img.height;
  List data = imglib.encodePng(img) as Uint8List;

  List imgPixels = [];

  print("$width $height ${data.length} ${data.length}");
  for(int i in data) {
    stdout.write("${data[i]} ");
  }
  print("\n end");
  // for (int i = 0; i < height; i++) {
  //   imgPixels.add(data.sublist(i * width, (i + 1) * width));
  // }

  // if ((imgPixels.length * imgPixels[0].length) == data.length)
  //   return imgPixels;

  return [];
}

void main() async {
  print("Getting Image");
  File file = File("qr.png");
  List data = (await file.readAsBytes()).toList();

  imglib.Image image = imglib.PngDecoder().decodeImage(data);
  image = imglib.grayscale(image);
  List imgPixels = getQrPixels(image);
  // String msg = "Hello, world!";
  // String binMsg = strBin(msg);

  // hideMsg(imgPixels, binMsg);

  print("${imgPixels.length}");
}
