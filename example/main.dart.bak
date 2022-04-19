import 'dart:async';

import 'package:mailtm_client/mailtm_client.dart';

void main() async {
  TMAccount account = await MailTm.register();
  print('Send a message to the following account: $account');
  late StreamSubscription subscription;
  subscription = account.messages.listen((e) async {
    print('Listened to message with id: $e');
    if (e.hasAttachments) {
      print('Message has following attachments:');
      e.attachments.forEach((a) => print('- ${a.name}'));
    }
    await subscription.cancel();
  });
}