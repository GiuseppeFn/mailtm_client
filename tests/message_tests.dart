import 'dart:async';

import 'package:mailtm_client/mailtm_client.dart';

void main() async {
  TMAccount account = await MailTm.register();
  print('Send a message to the following address: $account');
  late StreamSubscription<Message> subscription;
  subscription = account.messages.listen((event) async {
    print('Listened to message with id: $event');
    if (event.hasAttachments) {
      print('Message has following attachments:');
      event.attachments.forEach((attachment) => print('- $attachment'));
    }
    print('Test completed, everything went fine.');
    await subscription.cancel();
  });
}
