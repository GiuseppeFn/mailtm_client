part of mailtm;

/// MailTm domains.
abstract class Domain {
  /// Domain's id
  final String id;

  /// Domain as string (example: @mailtm.com)
  final String domain;

  /// If the domain is active
  final bool isActive;

  /// If the domain is private
  final bool isPrivate;

  /// When the domain was created
  final DateTime createdAt;

  /// When the domain was updated
  final DateTime updatedAt;

  static Requests requests(MailService service) =>
      service.isTm ? tmrequests : gwrequests;

  const Domain._({
    required this.id,
    required this.domain,
    required this.isActive,
    required this.isPrivate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Domain._fromJson(
    Map<String, dynamic> json,
    MailService service,
  ) {
    if (service.isTm) {
      return TmDomain._(json);
    }
    return GwDomain._(json);
  }

  /// Returns the domain as a Map
  Map<String, dynamic> toJson() => {
        'id': id,
        'domain': domain,
        'isActive': isActive,
        'isPrivate': isPrivate,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static Future<List<T>> _getDomains<T extends Domain>(
    int page,
    MailService s, [
    Map? response,
  ]) async {
    response ??= await requests(s).get<Map>('/domains?page=page', {}, false);
    final List<T> result = [];
    for (int i = 0; i < response["hydra:member"].length; i++) {
      result.add(Domain._fromJson(response["hydra:member"][i], s) as T);
    }
    return result;
  }

  /// Returns all the domains
  static Future<List<T>> _domains<T extends Domain>(MailService s) async {
    var response = await requests(s).get<Map>('/domains?page=1', {}, false);
    int iterations = ((response["hydra:totalItems"] / 30) as double).ceil();
    if (iterations == 1) {
      return _getDomains<T>(-1, s, response);
    }

    final List<T> result = [];
    for (int page = 2; page <= iterations; ++page) {
      result.addAll(await _getDomains(page, s));
    }
    return result;
  }

  /// Stringifies the domain
  @override
  String toString() => domain;
}

class TmDomain extends Domain {
  Requests get requests => tmrequests;

  TmDomain._(Map<String, dynamic> json)
      : super._(
          id: json['id'],
          domain: json['domain'],
          isActive: json['isActive'],
          isPrivate: json['isPrivate'],
          createdAt: DateTime.parse(json['createdAt']),
          updatedAt: DateTime.parse(json['updatedAt']),
        );

  static Future<List<TmDomain>> get domains =>
      Domain._domains<TmDomain>(MailService.Tm);
}

class GwDomain extends Domain {
  Requests get requests => gwrequests;

  GwDomain._(Map<String, dynamic> json)
      : super._(
          id: json['id'],
          domain: json['domain'],
          isActive: json['isActive'],
          isPrivate: false,
          createdAt: DateTime.parse(json['createdAt']),
          updatedAt: DateTime.parse(json['updatedAt']),
        );

  static Future<List<GwDomain>> get domains =>
      Domain._domains<GwDomain>(MailService.Gw);
}
