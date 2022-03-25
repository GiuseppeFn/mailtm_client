import 'io.dart' if (dart.library.io) 'html.dart';
import '../utilities.dart';

class IO {
  static void openUrl(String url) async {
    if (Platform.isWeb) {
      window.open(url, '_blank');
      return;
    }
    String cmd;
    if (Platform.isWindows) {
      cmd = 'start';
    } else if (Platform.isMacOS) {
      cmd = 'open';
    } else {
      cmd = 'xdg-open';
    }

    await Process.run(cmd, [url]);
  }

  ///Gets home dir using env vars.
  static String get homeDir =>
      Platform.environment['HOME'] ?? Platform.environment['UserProfile']!;
}

class Storage {
  final File _file;
  static bool get isWeb => Platform.isWeb;

  Storage({required String filePath}) : _file = File(filePath);

  Future<bool> get exists => _file.exists;

  Future<String> readAsString() => _file.readAsString();

  void writeAsString(String data, {bool flush: false}) =>
      _file.writeAsString(data);

  Future<Storage> create({bool recursive: false}) async {
    await _file.create(recursive: recursive);
    return this;
  }

  Storage createSync({bool recursive: false}) {
    _file.createSync(recursive: recursive);
    return this;
  }

  Storage._(this._file);

  static Future<Storage> createTemp() async {
    String id = generatePassword(16);
    File file = await File.createTemp('$id.html');
    return Storage._(file);
  }

  Future<bool> delete() => _file.delete();

  String get absolutePath => _file.absolutePath;
}
