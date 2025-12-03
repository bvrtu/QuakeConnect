import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relation;
  final DateTime createdAt;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
    required this.createdAt,
  });

  factory EmergencyContact.fromMap(String id, Map<String, dynamic> data) {
    return EmergencyContact(
      id: id,
      name: (data['name'] as String?)?.trim() ?? 'Unknown',
      phone: (data['phone'] as String?)?.trim() ?? '',
      relation: (data['relation'] as String?)?.trim() ?? 'Contact',
      createdAt: _parseDate(data['createdAt']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) {
      // Assume milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is Map<String, dynamic> && value.containsKey('_seconds')) {
      final seconds = value['_seconds'] as int? ?? 0;
      final nanos = value['_nanoseconds'] as int? ?? 0;
      return DateTime.fromMillisecondsSinceEpoch((seconds * 1000) + (nanos / 1000000).round());
    }
    return DateTime.now();
  }

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? relation,
    DateTime? createdAt,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relation: relation ?? this.relation,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}