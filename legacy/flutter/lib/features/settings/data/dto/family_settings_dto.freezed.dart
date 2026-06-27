// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_settings_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FamilySettingsDto _$FamilySettingsDtoFromJson(Map<String, dynamic> json) {
  return _FamilySettingsDto.fromJson(json);
}

/// @nodoc
mixin _$FamilySettingsDto {
  List<String> get coverageFallbackUserIds =>
      throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this FamilySettingsDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FamilySettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FamilySettingsDtoCopyWith<FamilySettingsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FamilySettingsDtoCopyWith<$Res> {
  factory $FamilySettingsDtoCopyWith(
    FamilySettingsDto value,
    $Res Function(FamilySettingsDto) then,
  ) = _$FamilySettingsDtoCopyWithImpl<$Res, FamilySettingsDto>;
  @useResult
  $Res call({
    List<String> coverageFallbackUserIds,
    @TimestampConverter() DateTime updatedAt,
  });
}

/// @nodoc
class _$FamilySettingsDtoCopyWithImpl<$Res, $Val extends FamilySettingsDto>
    implements $FamilySettingsDtoCopyWith<$Res> {
  _$FamilySettingsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FamilySettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coverageFallbackUserIds = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            coverageFallbackUserIds: null == coverageFallbackUserIds
                ? _value.coverageFallbackUserIds
                : coverageFallbackUserIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FamilySettingsDtoImplCopyWith<$Res>
    implements $FamilySettingsDtoCopyWith<$Res> {
  factory _$$FamilySettingsDtoImplCopyWith(
    _$FamilySettingsDtoImpl value,
    $Res Function(_$FamilySettingsDtoImpl) then,
  ) = __$$FamilySettingsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<String> coverageFallbackUserIds,
    @TimestampConverter() DateTime updatedAt,
  });
}

/// @nodoc
class __$$FamilySettingsDtoImplCopyWithImpl<$Res>
    extends _$FamilySettingsDtoCopyWithImpl<$Res, _$FamilySettingsDtoImpl>
    implements _$$FamilySettingsDtoImplCopyWith<$Res> {
  __$$FamilySettingsDtoImplCopyWithImpl(
    _$FamilySettingsDtoImpl _value,
    $Res Function(_$FamilySettingsDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FamilySettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coverageFallbackUserIds = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$FamilySettingsDtoImpl(
        coverageFallbackUserIds: null == coverageFallbackUserIds
            ? _value._coverageFallbackUserIds
            : coverageFallbackUserIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FamilySettingsDtoImpl implements _FamilySettingsDto {
  const _$FamilySettingsDtoImpl({
    final List<String> coverageFallbackUserIds = const <String>[],
    @TimestampConverter() required this.updatedAt,
  }) : _coverageFallbackUserIds = coverageFallbackUserIds;

  factory _$FamilySettingsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FamilySettingsDtoImplFromJson(json);

  final List<String> _coverageFallbackUserIds;
  @override
  @JsonKey()
  List<String> get coverageFallbackUserIds {
    if (_coverageFallbackUserIds is EqualUnmodifiableListView)
      return _coverageFallbackUserIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coverageFallbackUserIds);
  }

  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'FamilySettingsDto(coverageFallbackUserIds: $coverageFallbackUserIds, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FamilySettingsDtoImpl &&
            const DeepCollectionEquality().equals(
              other._coverageFallbackUserIds,
              _coverageFallbackUserIds,
            ) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_coverageFallbackUserIds),
    updatedAt,
  );

  /// Create a copy of FamilySettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FamilySettingsDtoImplCopyWith<_$FamilySettingsDtoImpl> get copyWith =>
      __$$FamilySettingsDtoImplCopyWithImpl<_$FamilySettingsDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FamilySettingsDtoImplToJson(this);
  }
}

abstract class _FamilySettingsDto implements FamilySettingsDto {
  const factory _FamilySettingsDto({
    final List<String> coverageFallbackUserIds,
    @TimestampConverter() required final DateTime updatedAt,
  }) = _$FamilySettingsDtoImpl;

  factory _FamilySettingsDto.fromJson(Map<String, dynamic> json) =
      _$FamilySettingsDtoImpl.fromJson;

  @override
  List<String> get coverageFallbackUserIds;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of FamilySettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FamilySettingsDtoImplCopyWith<_$FamilySettingsDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
