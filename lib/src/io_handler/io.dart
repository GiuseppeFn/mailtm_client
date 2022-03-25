import 'dart:io' as io;

final Window window = Window();

class Platform {
  static bool get isWeb => false;
  static bool get isWindows => io.Platform.isWindows;
  static bool get isMacOS => io.Platform.isMacOS;
  static bool get isLinux => io.Platform.isLinux;
  static Map<String, String> get environment => io.Platform.environment;
}

class File {
  io.File file;

  String get absolutePath => file.absolute.path;

  File(String path) : file = io.File(path);

  Future<bool> get exists => file.exists();

  Future<String> readAsString() => file.readAsString();

  void writeAsString(String data, {bool flush: false}) async =>
      await file.writeAsString(data, flush: flush);

  Future<File> create({bool recursive: false}) async {
    await file.create(recursive: recursive);
    return this;
  }

  File createSync({bool recursive: false}) {
    file.createSync(recursive: recursive);
    return this;
  }

  static Future<File> createTemp(String id) async {
    io.Directory tempDir = await io.Directory.systemTemp.createTemp();
    File temp = await File("${tempDir.path}/$id.html").create();
    return temp;
  }

  Future<bool> delete() async {
    try {
      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

class Window {
  void open(String url, String name, [String? options]) {
    return;
  }
}

class Process {
  static Future<io.ProcessResult> run(String cmd, List<String> args) async {
    return io.Process.run(cmd, args);
  }
}
