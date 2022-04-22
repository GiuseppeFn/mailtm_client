import '../requests.dart';

/// MailTm domains.
class TMDomain {
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

  const TMDomain({
    required this.id,
    required this.domain,
    required this.isActive,
    required this.isPrivate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TMDomain._fromJson(Map<String, dynamic> json) => TMDomain(
        id: json['id'],
        domain: json['domain'],
        isActive: json['isActive'],
        isPrivate: json['isPrivate'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  /// Returns the domain as a Map
  Map<String, dynamic> toJson() => {
        'id': id,
        'domain': domain,
        'isActive': isActive,
        'isPrivate': isPrivate,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static Future<List<TMDomain>> _getDomains(int page, [Map? response]) async {
    response ??= await Requests.get<Map>('/domains?page=page', {}, false);
    final List<TMDomain> result = [];
    for (int i = 0; i < response["hydra:member"].length; i++) {
      result.add(TMDomain._fromJson(response["hydra:member"][i]));
    }
    return result;
  }

  /// Returns all the domains
  static Future<List<TMDomain>> get domains async {
    var response = await Requests.get<Map>('/domains?page=1', {}, false);
    int iterations = ((response["hydra:totalItems"] / 30) as double).ceil();
    if (iterations == 1) {
      return _getDomains(-1, response);
    }

    final List<TMDomain> result = [];
    for (int page = 2; page <= iterations; ++page) {
      result.addAll(await _getDomains(page));
    }
    return result;
  }

  /// Stringifies the domain
  @override
  String toString() => domain;
}
