import 'dart:io';
import 'dart:convert';

import 'utilities.dart';

class Message {
  String id, subject, intro, text;
  Map<String, dynamic> from;
  List to, html;
  Map data;

  Message({
    required this.id,
    required this.subject,
    required this.intro,
    required this.text,
    required this.html,
    required this.from,
    required this.to,
    required this.data,
  });

  ///Opens this [Message] in the default web browser using [openUrl]
  ///saving the file the system temporary directory.
  ///And then deletes it after the browser loads the file.
  void openWeb() async {
    Directory tempDir = await Directory.systemTemp.createTemp();
    File temp = await File("${tempDir.path}/temp.html").create();
    String html = this.html[0].replaceAll('\n', '<br>').replaceAll('\r', '');
    temp.writeAsString('''
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Dart MailTm</title>
      </head>
      <body>
        <b>from:</b> $from<br>
        <b>to:</b> $to<br>
        <b>subject:</b> $subject<br><br>
      $html</body>
    </html>
    ''', flush: true);
    await openUrl('file://${temp.absolute.path}');
    Future.delayed(Duration(seconds: 5)).then((_) => temp.delete());
  }

  ///Creates a [Message] from a [Map]
  static Message fromRequests(
    Map<String, dynamic> messageData,
    Map<String, dynamic> message,
  ) =>
      Message(
        id: messageData['id'],
        subject: messageData['subject'],
        intro: messageData['intro'],
        from: Map<String, dynamic>.from(messageData['from']),
        to: messageData['to'],
        text: message['text'],
        html: message['html'],
        data: messageData,
      );

  @override
  String toString() {
    JsonEncoder encoder = JsonEncoder.withIndent('\t');
    String data = encoder.convert(this.data);
    return '''Message(
      id: $id,
      subject: $subject,
      intro: $intro,
      text: $text,
      from: $from,
      to: $to,
      html: $html,
      data: $data
)''';
  }
}
