// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_member_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FamilyMemberDtoImpl _$$FamilyMemberDtoImplFromJson(
  Map<String, dynamic> json,
) => _$FamilyMemberDtoImpl(
  familyId: json['familyId'] as String,
  userId: json['userId'] as String?,
  name: json['name'] as String,
  phone: json['phone'] as String?,
  colorHex: json['colorHex'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  role: json['role'] as String? ?? 'member',
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
);

Map<String, dynamic> _$$FamilyMemberDtoImplToJson(
  _$FamilyMemberDtoImpl instance,
) => <String, dynamic>{
  'familyId': instance.familyId,
  'userId': instance.userId,
  'name': instance.name,
  'phone': instance.phone,
  'colorHex': instance.colorHex,
  'avatarUrl': instance.avatarUrl,
  'role': instance.role,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};
