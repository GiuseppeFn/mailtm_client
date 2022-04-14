import 'package:mailtm_client/mailtm_client.dart';
import 'package:test/test.dart';

void main() async {
  tearDown(() async => await Future.delayed(Duration(seconds: 1)));
  late TMAccount account;

  test('Domains', () async => expect(Domain.domains, completion(isNotNull)));

  group('MailTm tests -', () {
    test('Register', () async => account = await MailTm.register());
    test('Login', () async => account = await MailTm.login(id: account.id));
  });

  group('Account class -', () {
    test('Update', () => expect(account.update(), completes));
    test('Delete', () => expect(account.delete(), completion(true)));
  });
}
