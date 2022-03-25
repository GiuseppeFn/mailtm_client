import 'dart:html' if (dart.library.io) 'html.dart' as html;

import 'implementations.dart';

final html.Window window = html.window;

class Platform extends PlatformInterface {
  bool get isWeb => true;
  bool get isWindows => false;
  bool get isMacOS => false;
  bool get isLinux => false;

  Map<String, String> get environment => {};

  String get home => throw UnimplementedError();

  Future<FileInterface> createTemp(String id) async => File(id);
}

class File extends FileInterface {
  final String localStoragePath;

  String get absolutePath => localStoragePath;

  File(this.localStoragePath) : super(localStoragePath);

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
  Future<ProcessResult> run(String cmd, List<String> args) async {
    return ProcessResult();
  }
}

class ProcessResult {}
