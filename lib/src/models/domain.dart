import '../requests.dart';

/// MailTm domains.
class Domain {
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

  const Domain({
    required this.id,
    required this.domain,
    required this.isActive,
    required this.isPrivate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Domain._fromJson(Map<String, dynamic> json) => Domain(
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

  /// Returns all the domains
  static Future<List<Domain>> get domains async {
    final response = await Requests.get<List>('/domains');
    List<Domain> result = [];
    for (final item in response) {
      result.add(Domain._fromJson(item));
    }
    return result;
  }

  /// Stringifies the domain
  @override
  String toString() => domain;
}
