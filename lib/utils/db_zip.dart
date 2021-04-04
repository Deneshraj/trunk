import 'dart:io';

import 'package:path/path.dart';
import 'package:flutter_archive/flutter_archive.dart';

class Zip {
  final String path;
  final Directory dir;

  Zip(this.path, this.dir);

  File _createZipFile(String zipFilePath) {
    final zipFile = File(zipFilePath);

    if (zipFile.existsSync()) {
      zipFile.deleteSync();
    }

    return zipFile;
  }

  Future<File> zip(String fileName) async {
    String filePath = join(path, fileName);
    File zipFile = _createZipFile(filePath);

    try {
      await ZipFile.createFromDirectory(
        sourceDir: dir,
        zipFile: zipFile,
        includeBaseDirectory: false,
        recurseSubDirs: true,
      );
    } catch (e, s) {
      print("$e");
      print("$s");
    }

    return zipFile;
  }

  Future<String> unzip() async {
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    dir.createSync();

    File zipFile = File(path);
    if (await zipFile.exists()) {
      try {
        ZipFile.extractToDirectory(
          zipFile: zipFile,
          destinationDir: dir,
        );
        return dir.path;
      }catch(e, s) {
        print("$e");
        print("$s");
      }
    }
    
    return null;
  }
}
