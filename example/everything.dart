import 'package:mailtm_client/mailtm_client.dart';

void main() async {
  ///Creates a new MailTm instance that can't save addresses.
  ///if canSave is false, the [MailTm] instance will not store accounts on disk
  ///if canSave is true, it will store on a default db file (MailTm.db)
  ///if canSave is true and customDb is not null, it will store on customDb
  ///To make a simple instance, like a static one, simply use MailTm(canSave:false)
  MailTm client = await MailTm.init(canSave: false);

  ///Creates a new account, specify the password parameter to use a personal password
  Account account = await client.createAccount();

  ///If canSave is true, it stores the account on disk
  client.saveAccount(account);

  ///If canSave is true, it loads account at [index] from disk
  ///If you wanna load an account from the api (So retrieve the account from the api),
  ///you must set forceApi to true and specify the id, the address and the password
  await client.loadAccount();

  ///Listen to the stream of messages
  await account.messages.listen(
    (event) => print('''
    ${event.from['name']} sent you a message:
    ${event.text}
    '''),
  );

  ///Returns account with updated data (Like quota, used, etc)
  ///If updateInstance is true it will update the instance with the new data
  await account.update();

  ///List of messages.
  List<Message> messages = await account.getMessages();

  ///Deletes the account from both disk and api.
  ///If canSave is false, it will only delete from api, but in this case, just use
  ///account.delete()
  await client.deleteAccount(account);

  ///Opens the first message on the default browser
  if (messages.length > 0) messages.first.openWeb();
}
