import 'dart:async';
import 'dart:io';

import 'package:image/image.dart';
import 'package:path/path.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:path_provider/path_provider.dart';

Future<String> storeFileLocally(String fileName, String dirName, String contents) async {
  var dir = await getExternalStorageDirectory();
  var extDir = await new Directory('${dir.path}/$dirName').create(recursive: true);
  var path = join(extDir.path, fileName);
  
  await new Future.delayed(new Duration(seconds: 1));
  bool checkResult =
      await SimplePermissions.checkPermission(Permission.WriteExternalStorage);
  if (!checkResult) {
    var status = await SimplePermissions.requestPermission(
        Permission.WriteExternalStorage);

    if (status == PermissionStatus.authorized) {
      writeFile(path, contents);
      return path;
    } else {
      return null;
    }
  } else {
    writeFile(path, contents);
    return path;
  }
}

Future<String> storeTemporaryFile(String fileName, String contents) async {
  var dir = await getExternalStorageDirectory();
  var path = join(dir.path, fileName);
  
  await new Future.delayed(new Duration(seconds: 1));

  try {
    await writeFile(path, contents);
    return path;
  } catch(e) {
    print("$e");
    return null;
  }
}

Future<String> storeImageLocally(String fileName, Image img) async{
  var dir = await getTemporaryDirectory();
  var path = join(dir.path, fileName);

  await new Future.delayed(new Duration(seconds: 1));

  try {
    File file = File(path);
    await file.create(recursive: true);
    await file.writeAsBytes(img.getBytes().toList());
    return path;
  } catch(e) {
    print("$e");
    return null;
  }    
}

Future<String> storeEncryptedTemporaryFile(String fileName, String contents) async {
  var dir = await getExternalCacheDirectories();
  var filePath = join(dir[0].path, fileName);

  await new Future.delayed(new Duration(seconds: 1));

  try {
    await writeFile(filePath, contents);
    return filePath;
  } catch(e, s) {
    print("$e $s");
    return null;
  }
}

Future<void> writeFile(String path, String contents) async {
  File file = File(path);
  file.writeAsString(contents);
}

void deleteFile(String path) {
  File file = File(path);
  file.delete();
}