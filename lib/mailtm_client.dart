///This package is a simple but complete mail.tm api wrapper
///you can use this to save and manage your accounts, as well read all your temporary emails.
library mailtm;

export 'src/mailtm.dart' hide randomString, getToken, auths, Auth;
export 'src/models/account.dart' hide accountFromJson, accountFromApi;
export 'src/models/message.dart' hide messageFromJson;
export 'src/models/attachment.dart' hide attachmentFromJson;
export 'src/models/message_source.dart' hide messageSourceFromJson;
export 'src/models/domain.dart';
