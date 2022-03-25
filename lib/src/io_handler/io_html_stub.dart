import 'package:mailtm_client/src/io_handler/implementations.dart';

final Window window = Window();

class Platform extends PlatformInterface {
  bool get isWeb => throw UnsupportedError('');
  bool get isWindows => throw UnsupportedError('');
  bool get isMacOS => throw UnsupportedError('');
  bool get isLinux => throw UnsupportedError('');
  Map<String, String> get environment => throw UnsupportedError('');
  String get home => throw UnsupportedError('');

  Future<FileInterface> createTemp(String id) async =>
      throw UnsupportedError('');
}

class File extends FileInterface {
  File(String path) : super(path);

  String get absolutePath => throw UnsupportedError('');

  Future<FileInterface> create({bool recursive = false}) =>
      throw UnsupportedError('');

  FileInterface createSync({bool recursive = false}) =>
      throw UnsupportedError('');

  Future<bool> delete() => throw UnsupportedError('');

  Future<bool> get exists => throw UnsupportedError('');

  Future<String> readAsString() => throw UnsupportedError('');

  void writeAsString(String data, {bool flush = false}) => UnsupportedError('');
}

class Window extends WindowInterface {
  void open(String url, String target, [String? options]) =>
      throw UnsupportedError('');
}

class Process extends ProcessInterface {
  void run(String executable, List<String> arguments) =>
      throw UnsupportedError('');
}
