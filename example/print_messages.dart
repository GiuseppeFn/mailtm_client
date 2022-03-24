import 'package:mailtm_client/mailtm_client.dart';

void main() async {
  MailTm client = await MailTm.init(canSave: false);
  Account acc = await client.createAccount();
  List<Message> messages = await acc.getMessages();
  for (int i = 0; i < messages.length; i++) {
    print('''${i + 1} message:
          ${messages[i].from['name']}:
          ${messages[i].text} 
    ''');
  }
}
