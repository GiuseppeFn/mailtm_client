TMMessageSource messageSourceFromJson(Map<String, dynamic> json) =>
    TMMessageSource._fromJson(json);

class TMMessageSource {
  /// The id of the message.
  final String id;

  /// Message download url
  final String url;

  /// Message data
  final String data;

  TMMessageSource._({
    required this.id,
    required this.url,
    required this.data,
  });

  factory TMMessageSource._fromJson(
    Map<String, dynamic> json,
  ) =>
      TMMessageSource._(
        id: json['id'],
        url: json['downloadUrl'],
        data: json['data'],
      );

  @override
  String toString() => data;
}
