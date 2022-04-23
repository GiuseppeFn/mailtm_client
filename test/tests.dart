import 'package:mailtm_client/mailtm_client.dart';
import 'package:test/test.dart';

void main() async {
  tearDown(() async => await Future.delayed(Duration(seconds: 1)));
  testClient(MailTm(), 'Tm');
  testClient(MailGw(), 'Gw');
}

void testClient(MailClient client, String suffix) {
  late Account account;
  test('Domains', () => expect(client.domains, completes));

  group('Mail$suffix tests -', () {
    test('Register', () async => account = await client.register());
    test('Login', () async => account = await client.login(id: account.id));
    client.loadAccounts(client.saveAccounts);
    if (client is MailTm) {
      test('Get accounts', () async => expect(client.accounts, isNotEmpty));
    } else if (client is MailGw) {
      test('Get accounts', () async => expect(client.accounts, isNotEmpty));
    }
  });

  group('Account class -', () {
    test('Update', () => expect(account.update(), completes));
    test('Delete', () => expect(account.delete(), completion(true)));
  });
}
