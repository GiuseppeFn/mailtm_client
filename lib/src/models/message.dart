import 'attachment.dart';
import 'message_source.dart';
import '../requests.dart';
import '../mailtm.dart';

TMMessage messageFromJson(Map<String, dynamic> json) =>
    TMMessage._fromMap(json);

class TMMessage {
  TMMessage._({
    required this.id,
    required this.accountId,
    required this.msgid,
    required this.intro,
    required this.from,
    required this.to,
    required this.cc,
    required this.bcc,
    required this.subject,
    required this.seen,
    required this.flagged,
    required this.isDeleted,
    required this.verifications,
    required this.retention,
    required this.retentionDate,
    required this.text,
    required this.html,
    required this.hasAttachments,
    required this.attachments,
    required this.size,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  /// The unique identifier of the message (MailTm DB).
  final String id;

  /// The unique identifier of the account.
  final String accountId;

  /// The unique identifier of the message
  /// (Global, both the receiver service and MailTm will know this).
  final String msgid;

  /// The introduction of the message.
  final String intro;

  /// The sender of the message.
  final Map<String, dynamic> from;

  /// The recipients of the message.
  final List<Map<String, dynamic>> to;

  /// The carbon copy recipients of the message.
  final List<String> cc;

  /// The blind carbon copy recipients of the message.
  final List<String> bcc;

  /// The subject of the message.
  final String subject;

  /// Whether the message has been seen.
  final bool seen;

  /// Whether the message has been flagged.
  final bool flagged;

  /// Whether the message has been deleted.
  final bool isDeleted;

  /// The verifications of the message.
  final List<String> verifications;

  /// If the message has arrived
  final bool retention;

  /// The date of the message retention.
  final DateTime retentionDate;

  /// The text of the message.
  final String text;

  /// The HTML of the message.
  final List<String> html;

  /// Whether the message has attachments.
  final bool hasAttachments;

  /// List of the message.
  final List<TMAttachment> attachments;

  /// The size of the message.
  final int size;

  /// The downloadUrl of the message.
  final String url;

  /// The date of the message creation.
  final DateTime createdAt;

  /// When the message was seen
  final DateTime updatedAt;

  factory TMMessage._fromMap(Map<String, dynamic> json) => TMMessage._(
        id: json["id"],
        accountId: json["accountId"].split('/accounts/')[1],
        msgid: json["msgid"],
        intro: json["intro"],
        from: json["from"],
        to: List<Map<String, dynamic>>.from(json["to"]),
        cc: List<String>.from(json["cc"]),
        bcc: List<String>.from(json["bcc"]),
        subject: json["subject"],
        seen: json["seen"],
        flagged: json["flagged"],
        isDeleted: json["isDeleted"],
        verifications: List<String>.from(json["verifications"]),
        retention: json["retention"],
        retentionDate: DateTime.parse(json["retentionDate"]),
        text: json["text"],
        html: List<String>.from(json["html"]),
        hasAttachments: json["hasAttachments"],
        attachments: json["attachments"]
            .map<TMAttachment>((e) => attachmentFromJson(
                  e,
                  json["accountId"].split('/accounts/')[1],
                ))
            .toList(),
        size: json["size"],
        url: json["downloadUrl"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  /// Returns the message as a map.
  Map<String, dynamic> toJson() => {
        "id": id,
        "accountId": accountId,
        "msgid": msgid,
        "intro": intro,
        "from": from,
        "to": to,
        "cc": cc,
        "bcc": bcc,
        "subject": subject,
        "seen": seen,
        "flagged": flagged,
        "isDeleted": isDeleted,
        "verifications": verifications,
        "retention": retention,
        "retentionDate": retentionDate.toIso8601String(),
        "text": text,
        "html": html,
        "hasAttachments": hasAttachments,
        "attachments": attachments,
        "size": size,
        "url": url,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };

  /// Downloads the message as [TMMessageSource]
  Future<TMMessageSource> download() async {
    var r = await Requests.get<Map>('/sources/$id', auths[accountId]!.headers)
        as Map<String, dynamic>;
    return messageSourceFromJson(r);
  }

  /// Deletes the message.
  Future<bool> delete() =>
      Requests.delete('/messages/$id', auths[accountId]!.headers);

  /// Marks the message as seen.
  Future<bool> see() async {
    try {
      var r = await Requests.patch('/messages/$id', auths[accountId]!.headers);
      return r;
    } catch (e) {
      if (e is MailException) {
        if (e.code == 422) {
          return true;
        }
      }
      return false;
    }
  }

  /// Stringifies the message
  @override
  String toString() => id;
}
