part of mailtm;

abstract class Attachment {
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
  final String _token;

  final MailService _service;

  const Attachment._({
    required this.id,
    required this.name,
    required this.type,
    required this.disposition,
    required this.encoding,
    required this.related,
    required this.size,
    required this.url,
    required String token,
    required MailService service,
  })  : _token = token,
        _service = service;

  factory Attachment._fromJson(
    Map<String, dynamic> json,
    String token,
    MailService service,
  ) {
    if (service.isTm) {
      return TmAttachment._fromJson(json, token);
    }
    return GwAttachment._fromJson(json, token);
  }

  /// Downloads the attachment
  Future<Uint8List> download() {
    if (_service.isTm) {
      return tmrequests.download(url, {'Authorization': 'Bearer $_token'});
    }
    return gwrequests.download(url, {'Authorization': 'Bearer $_token'});
  }

  @override
  String toString() => name;
}

class TmAttachment extends Attachment {
  TmAttachment._fromJson(
    Map<String, dynamic> json,
    String token,
  ) : super._(
          id: json['id'],
          name: json['filename'],
          type: json['contentType'],
          disposition: json['disposition'],
          encoding: json['transferEncoding'],
          related: json['related'],
          size: json['size'],
          url: json['downloadUrl'],
          token: token,
          service: MailService.Tm,
        );
}

class GwAttachment extends Attachment {
  GwAttachment._fromJson(
    Map<String, dynamic> json,
    String token,
  ) : super._(
          id: json['id'],
          name: json['filename'],
          type: json['contentType'],
          disposition: json['disposition'],
          encoding: json['transferEncoding'],
          related: json['related'],
          size: json['size'],
          url: json['downloadUrl'],
          token: token,
          service: MailService.Gw,
        );
}
