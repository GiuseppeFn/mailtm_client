import 'package:mailtm_client/mailtm_client.dart';

void main() async {
  MailTm client = await MailTm.init(canSave: false);
  await client.createAccount();
}
