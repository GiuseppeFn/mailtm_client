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
