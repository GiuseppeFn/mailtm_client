import 'package:mailtm_client/src/io_handler/implementations.dart';

import 'io_html_stub.dart'
    if (dart.library.io) 'io.dart'
    if (dart.library.js) 'html.dart';

class Storage {
  final FileInterface _file;
  static String get home => Platform().home;
  static bool get isWeb => Platform().isWeb;

  Storage({required String file}) : _file = File(file);

  Future<bool> get exists => _file.exists;

  Future<String> readAsString() => _file.readAsString();

  void writeAsString(String data, {bool flush: false}) =>
      _file.writeAsString(data, flush: flush);

  Future<Storage> create({bool recursive: false}) async {
    await _file.create(recursive: recursive);
    return this;
  }

  Storage createSync({bool recursive: false}) {
    _file.createSync(recursive: recursive);
    return this;
  }

  static Future<Storage> createTemp(String id) async {
    FileInterface temp = await Platform().createTemp(id);
    return Storage(file: temp.path);
  }

  Future<bool> delete() => _file.delete();

  String get absolutePath => _file.absolutePath;
}

void openUrl(String url) async {
  if (Platform().isWeb) {
    window.open(url, '_blank');
    return;
  }
  String cmd;
  if (Platform().isWindows) {
    cmd = 'start';
  } else if (Platform().isMacOS) {
    cmd = 'open';
  } else {
    cmd = 'xdg-open';
  }

  Process().run(cmd, [url]);
}
