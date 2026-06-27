// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FamilyDtoImpl _$$FamilyDtoImplFromJson(
  Map<String, dynamic> json,
) => _$FamilyDtoImpl(
  name: json['name'] as String,
  grandpaName: json['grandpaName'] as String,
  inviteCode: json['inviteCode'] as String,
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt'] as Object),
);

Map<String, dynamic> _$$FamilyDtoImplToJson(_$FamilyDtoImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'grandpaName': instance.grandpaName,
      'inviteCode': instance.inviteCode,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
