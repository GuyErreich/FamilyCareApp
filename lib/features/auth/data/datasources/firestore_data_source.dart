import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_care_scheduler/core/constants/firestore_collections.dart';
import 'package:family_care_scheduler/features/auth/data/dto/app_user_dto.dart';
import 'package:family_care_scheduler/features/auth/domain/entities/app_user.dart';
import 'package:family_care_scheduler/features/family/data/dto/family_dto.dart';
import 'package:family_care_scheduler/features/family/data/dto/family_member_dto.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/shifts/data/dto/shift_dto.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';

/// Low-level Firestore access for app collections.
class FirestoreDataSource {
  FirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  CollectionReference<Map<String, dynamic>> get _families =>
      _firestore.collection(FirestoreCollections.families);

  CollectionReference<Map<String, dynamic>> get _members =>
      _firestore.collection(FirestoreCollections.familyMembers);

  CollectionReference<Map<String, dynamic>> get _shifts =>
      _firestore.collection(FirestoreCollections.shifts);

  Future<void> setUser(String id, AppUserDto dto) =>
      _users.doc(id).set(dto.toJson());

  Future<AppUser?> getUser(String id) async {
    final doc = await _users.doc(id).get();
    if (!doc.exists) return null;
    return AppUserDto.fromJson(doc.data()!).toDomain(id);
  }

  Stream<AppUser?> watchUser(String id) {
    return _users.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUserDto.fromJson(doc.data()!).toDomain(id);
    });
  }

  Future<Family> createFamily(FamilyDto dto) async {
    final ref = await _families.add(dto.toJson());
    return dto.toDomain(ref.id);
  }

  Future<Family?> getFamily(String id) async {
    final doc = await _families.doc(id).get();
    if (!doc.exists) return null;
    return FamilyDto.fromJson(doc.data()!).toDomain(id);
  }

  Future<Family?> getFamilyByInviteCode(String code) async {
    final query = await _families
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return FamilyDto.fromJson(doc.data()).toDomain(doc.id);
  }

  Future<void> updateFamily(Family family) => _families
      .doc(family.id)
      .update(FamilyDtoX.fromDomain(family).toJson());

  Stream<List<FamilyMember>> watchMembers(String familyId) {
    return _members
        .where('familyId', isEqualTo: familyId)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => FamilyMemberDto.fromJson(doc.data()).toDomain(doc.id),
              )
              .toList(),
        );
  }

  Future<FamilyMember> addMember(FamilyMemberDto dto) async {
    final ref = await _members.add(dto.toJson());
    return dto.toDomain(ref.id);
  }

  Future<void> updateMember(String id, FamilyMemberDto dto) =>
      _members.doc(id).update(dto.toJson());

  Future<void> deleteMember(String id) => _members.doc(id).delete();

  Stream<List<Shift>> watchShiftsForRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
  }) {
    return _shifts
        .where('familyId', isEqualTo: familyId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ShiftDto.fromJson(doc.data()).toDomain(doc.id))
              .toList(),
        );
  }

  Future<List<Shift>> getShiftsForDay({
    required String familyId,
    required DateTime date,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    final query = await _shifts
        .where('familyId', isEqualTo: familyId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();
    return query.docs
        .map((doc) => ShiftDto.fromJson(doc.data()).toDomain(doc.id))
        .toList();
  }

  Future<Shift?> getShift(String id) async {
    final doc = await _shifts.doc(id).get();
    if (!doc.exists) return null;
    return ShiftDto.fromJson(doc.data()!).toDomain(id);
  }

  Future<Shift> createShift(ShiftDto dto) async {
    final ref = await _shifts.add(dto.toJson());
    return dto.toDomain(ref.id);
  }

  Future<void> updateShift(String id, ShiftDto dto) =>
      _shifts.doc(id).update(dto.toJson());

  Future<void> deleteShift(String id) => _shifts.doc(id).delete();
}
