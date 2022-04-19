import 'dart:typed_data';

import '../mailtm.dart';
import '../requests.dart';

Attachment attachmentFromJson(Map<String, dynamic> json, String accountId) =>
    Attachment._fromJson(json, accountId);

class Attachment {
  /// The attachment id.
  final String id;

  /// The attachment name.
  final String name;

  /// The attachment contentType.
  final String type;

  /// The attachment disposition.
  final String disposition;

  /// The attachment transferEncoding.
  final String encoding;

  final bool related;

  /// The attachment size.
  final int size;

  /// The attachment downloadUrl.
  final String url;

  /// The attachment's account id.
  final String _accountId;

  const Attachment._({
    required this.id,
    required this.name,
    required this.type,
    required this.disposition,
    required this.encoding,
    required this.related,
    required this.size,
    required this.url,
    required accountId,
  }) : _accountId = accountId;

  factory Attachment._fromJson(Map<String, dynamic> json, String accountId) =>
      Attachment._(
        id: json['id'],
        name: json['filename'],
        type: json['contentType'],
        disposition: json['disposition'],
        encoding: json['transferEncoding'],
        related: json['related'],
        size: json['size'],
        url: json['downloadUrl'],
        accountId: accountId,
      );

  /// Downloads the attachment
  Future<Uint8List> download() =>
      Requests.download(url, auths[_accountId]!.headers);

  /// Download the attachment from the server.
  static Future<String> fromUrl(String url) => Requests.get<String>(url);

  @override
  String toString() => name;
}
