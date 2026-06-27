import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_member.freezed.dart';

/// A person who can be assigned companion shifts.
@freezed
class FamilyMember with _$FamilyMember {
  const factory FamilyMember({
    required String id,
    required String familyId,
    String? userId,
    required String name,
    String? phone,
    required String colorHex,
    String? avatarUrl,
    @Default('member') String role,
    required DateTime createdAt,
  }) = _FamilyMember;
}
