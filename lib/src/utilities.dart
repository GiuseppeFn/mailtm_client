import 'dart:async';
import 'dart:io';
import 'dart:math';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

/// Generates a random string of [length] characters.
String generatePassword(length) {
  final Random _rand = Random.secure();

  return String.fromCharCodes(
    List<int>.generate(
      length,
      (_) => _chars.codeUnitAt(_rand.nextInt(_chars.length)),
    ),
  );
}

///Opens [url] using system commands and [Process.run]
Future<void> openUrl(String url) async {
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
String get homeDir =>
    Platform.environment['HOME'] ?? Platform.environment['UserProfile']!;
