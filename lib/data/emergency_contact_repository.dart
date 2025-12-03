import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_contact.dart';

class EmergencyContactRepository {
  EmergencyContactRepository._();
  static final EmergencyContactRepository instance = EmergencyContactRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';
  static const String _contactsSubCollection = 'emergencyContacts';

  CollectionReference<Map<String, dynamic>> _contactsRef(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_contactsSubCollection);
  }

  Stream<List<EmergencyContact>> watchContacts(String userId) {
    return _contactsRef(userId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EmergencyContact.fromMap(
                doc.id,
                doc.data(),
              ))
          .toList();
    });
  }

  Future<void> addContact({
    required String userId,
    required String name,
    required String phone,
    required String relation,
  }) async {
    final payload = {
      'name': name.trim(),
      'phone': phone.trim(),
      'relation': relation.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _contactsRef(userId).add(payload);
    await _refreshContactsArray(userId);
  }

  Future<void> updateContact({
    required String userId,
    required String contactId,
    required String name,
    required String phone,
    required String relation,
  }) async {
    await _contactsRef(userId).doc(contactId).update({
      'name': name.trim(),
      'phone': phone.trim(),
      'relation': relation.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _refreshContactsArray(userId);
  }

  Future<void> deleteContact({
    required String userId,
    required String contactId,
  }) async {
    await _contactsRef(userId).doc(contactId).delete();
    await _refreshContactsArray(userId);
  }

  Future<void> _refreshContactsArray(String userId) async {
    final snapshot = await _contactsRef(userId).orderBy('createdAt', descending: false).get();
    final contacts = snapshot.docs.map((doc) {
      final data = doc.data();
      final createdAt = data['createdAt'];
      String? createdAtIso;
      if (createdAt is Timestamp) {
        createdAtIso = createdAt.toDate().toIso8601String();
      } else if (createdAt is DateTime) {
        createdAtIso = createdAt.toIso8601String();
      } else if (createdAt is String) {
        createdAtIso = createdAt;
      }
      return {
        'id': doc.id,
        'name': data['name'],
        'phone': data['phone'],
        'relation': data['relation'],
        'createdAt': createdAtIso,
      };
    }).toList();

    await _firestore.collection(_usersCollection).doc(userId).update({
      'emergencyContacts': contacts,
      'emergencyContactsCount': contacts.length,
    });
  }
}

