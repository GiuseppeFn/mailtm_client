import 'dart:html' as html;

final html.Window window = html.window;

class Platform {
  static bool get isWeb => true;
  static bool get isWindows => false;
  static bool get isMacOS => false;
  static bool get isLinux => false;

  static Map<String, String> get environment => {};
}

class File {
  final String localStoragePath;

  String get absolutePath => localStoragePath;

  File(this.localStoragePath);

  Future<bool> get exists => Future.value(
        html.window.localStorage.containsKey(localStoragePath),
      );

  Future<String> readAsString() => Future.value(
        html.window.localStorage[localStoragePath],
      );

  void writeAsString(String data, {bool flush: false}) =>
      html.window.localStorage[localStoragePath] = data;

  Future<File> create({bool recursive: false}) async => this;

  File createSync({bool recursive: false}) => this;

  Future<File> createTemp(String id) async => File(id);

  Future<bool> delete() async {
    try {
      html.window.localStorage.remove(localStoragePath);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class Process {
  static Future<void> run(String cmd, List<String> args) async {
    return;
  }
}
