import 'dart:async';
import 'dart:io';

import 'package:mailtm_client/mailtm_client.dart';

void main() async {
  TmAccount tmaccount = await MailTm().register();
  GwAccount gwaccount = await MailGw().register();

  print('Send a message to the following addresses: $tmaccount');
  print('Send a message to the following addresses: $gwaccount');
  subscribe(tmaccount, 'Tm');
  subscribe(gwaccount, 'Gw');
}

void subscribe(Account account, String prefix) {
  late StreamSubscription<Message> subscription;

  subscription = account.messages.listen((event) async {
    print('$prefix Listened to message with id: $event');
    if (event.hasAttachments) {
      print('$prefix Message has following attachments:');
      event.attachments.forEach((e) async {
        print('- $e');
        File(e.name)
          ..create()
          ..writeAsBytes(await e.download());
      });
    }
    bool see = await event.see();
    if (see) {
      print('$prefix Message has been seen');
    }
    await account.getAllMessages();
    print('$prefix Test completed, everything went fine.');
    await subscription.cancel();
  });
}
