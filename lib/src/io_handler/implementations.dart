abstract class PlatformInterface {
  bool get isWeb;
  bool get isWindows;
  bool get isMacOS;
  bool get isLinux;
  Map<String, String> get environment;

  String get home;

  Future<FileInterface> createTemp(String id);
}

abstract class FileInterface {
  final String path;

  String get absolutePath;

  FileInterface(this.path);

  Future<bool> get exists;

  Future<String> readAsString();

  void writeAsString(String data, {bool flush: false});

  Future<FileInterface> create({bool recursive: false});

  FileInterface createSync({bool recursive: false});

  Future<bool> delete();
}

abstract class ProcessInterface {
  void run(String executable, List<String> arguments);
}

abstract class WindowInterface {
  void open(String url, String target, [String? options]);
}

abstract class DirectoryInterface {}
