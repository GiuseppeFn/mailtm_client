import 'dart:io' as io;

import 'package:path/path.dart';

import 'implementations.dart';

final Window window = Window();

class Platform extends PlatformInterface {
  bool get isWeb => false;
  bool get isWindows => io.Platform.isWindows;
  bool get isMacOS => io.Platform.isMacOS;
  bool get isLinux => io.Platform.isLinux;
  Map<String, String> get environment => io.Platform.environment;

  String get home =>
      io.Platform.environment['HOME'] ??
      io.Platform.environment['UserProfile']!;

  Future<FileInterface> createTemp(String id) async {
    final tempDir = await io.Directory.systemTemp.createTemp(id);
    return File(join(tempDir.path, id));
  }
}

class File extends FileInterface {
  io.File _file;

  String get absolutePath => _file.absolute.path;

  File(String path)
      : _file = io.File(path),
        super(path);

  Future<bool> get exists => _file.exists();

  Future<String> readAsString() => _file.readAsString();

  void writeAsString(String data, {bool flush: false}) async =>
      await _file.writeAsString(data, flush: flush);

  Future<File> create({bool recursive: false}) async {
    await _file.create(recursive: recursive);
    return this;
  }

  File createSync({bool recursive: false}) {
    _file.createSync(recursive: recursive);
    return this;
  }

  static Future<File> createTemp(String id) async {
    io.Directory tempDir = await io.Directory.systemTemp.createTemp();
    File temp = await File("${tempDir.path}/$id.html").create();
    return temp;
  }

  Future<bool> delete() async {
    try {
      await _file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

class Window extends WindowInterface {
  void open(String url, String name, [String? options]) {
    return;
  }
}

class Process extends ProcessInterface {
  void run(String cmd, List<String> args) async {
    await io.Process.run(cmd, args);
  }
}
