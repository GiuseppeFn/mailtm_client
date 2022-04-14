MessageSource messageSourceFromJson(Map<String, dynamic> json) =>
    MessageSource._fromJson(json);

class MessageSource {
  /// The id of the message.
  final String id;

  /// Message download url
  final String url;

  /// Message data
  final String data;


  MessageSource._({
    required this.id,
    required this.url,
    required this.data,
  });

  factory MessageSource._fromJson(
    Map<String, dynamic> json,
  ) =>
      MessageSource._(
        id: json['id'],
        url: json['downloadUrl'],
        data: json['data'],
      );

  @override
  String toString() => data;
}
