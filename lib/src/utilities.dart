part of mailtm;

final _random = Random.secure();

enum MailService { Tm, Gw }
extension IsTm on MailService {
  bool get isTm => this == MailService.Tm;
  bool get isGw => this == MailService.Gw;
}

/// Client's exception class.
/// If you want to see what corresponds to the error codes see [Requests.request]
class MailException implements Exception {
  final String? message;
  final int? code;

  MailException([this.message = 'Unknown error.', this.code = 0]);

  @override
  String toString() =>
      (code ?? 0).toString() + ': ' + (message ?? 'Unknown error.');
}

/// All the usable characters for a random username/password
const String _charset =
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

/// Generate a random string of [length] characters
String randomString(int length) {
  final _codeUnits = List<int>.generate(
    length,
    (index) => _charset.codeUnitAt(_random.nextInt(_charset.length)),
  );
  return String.fromCharCodes(_codeUnits);
}
