import 'requests.dart';

class Domain {
  final String id, domain;
  final DateTime createdAt, updatedAt;
  final bool isActive, isPrivate;

  const Domain({
    required this.id,
    required this.domain,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.isPrivate,
  });

  factory Domain.fromJson(Map<String, dynamic> json) => Domain(
        id: json['id'],
        domain: json['domain'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        isActive: json['isActive'],
        isPrivate: json['isPrivate'],
      );

  static Future<Domain> fromId(String id) async {
    final response = await Requests.getRequest('domains/$id');
    return Domain.fromJson(response);
  }
}
