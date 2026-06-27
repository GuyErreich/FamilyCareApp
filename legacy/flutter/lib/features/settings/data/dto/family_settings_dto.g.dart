// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FamilySettingsDtoImpl _$$FamilySettingsDtoImplFromJson(
  Map<String, dynamic> json,
) => _$FamilySettingsDtoImpl(
  coverageFallbackUserIds:
      (json['coverageFallbackUserIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  updatedAt: const TimestampConverter().fromJson(json['updatedAt'] as Object),
);

Map<String, dynamic> _$$FamilySettingsDtoImplToJson(
  _$FamilySettingsDtoImpl instance,
) => <String, dynamic>{
  'coverageFallbackUserIds': instance.coverageFallbackUserIds,
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};
