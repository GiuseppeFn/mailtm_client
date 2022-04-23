///This package is a simple but complete mail.tm api wrapper
///you can use this to save and manage your accounts, as well read all your temporary emails.
library mailtm;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mercure_client/mercure_client.dart';

part 'src/clients.dart';
part 'src/models/account.dart';
part 'src/models/message.dart';
part 'src/models/attachment.dart';
part 'src/models/message_source.dart';
part 'src/models/domain.dart';
part 'src/requests.dart';
part 'src/utilities.dart';
