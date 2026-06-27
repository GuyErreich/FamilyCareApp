// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FamilyDto _$FamilyDtoFromJson(Map<String, dynamic> json) {
  return _FamilyDto.fromJson(json);
}

/// @nodoc
mixin _$FamilyDto {
  String get name => throw _privateConstructorUsedError;
  String get grandpaName => throw _privateConstructorUsedError;
  String get inviteCode => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this FamilyDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FamilyDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FamilyDtoCopyWith<FamilyDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FamilyDtoCopyWith<$Res> {
  factory $FamilyDtoCopyWith(FamilyDto value, $Res Function(FamilyDto) then) =
      _$FamilyDtoCopyWithImpl<$Res, FamilyDto>;
  @useResult
  $Res call({
    String name,
    String grandpaName,
    String inviteCode,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
  });
}

/// @nodoc
class _$FamilyDtoCopyWithImpl<$Res, $Val extends FamilyDto>
    implements $FamilyDtoCopyWith<$Res> {
  _$FamilyDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FamilyDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? grandpaName = null,
    Object? inviteCode = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            grandpaName: null == grandpaName
                ? _value.grandpaName
                : grandpaName // ignore: cast_nullable_to_non_nullable
                      as String,
            inviteCode: null == inviteCode
                ? _value.inviteCode
                : inviteCode // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
abstract class _$$FamilyDtoImplCopyWith<$Res>
    implements $FamilyDtoCopyWith<$Res> {
  factory _$$FamilyDtoImplCopyWith(
    _$FamilyDtoImpl value,
    $Res Function(_$FamilyDtoImpl) then,
  ) = __$$FamilyDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String grandpaName,
    String inviteCode,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
  });
}

/// @nodoc
class __$$FamilyDtoImplCopyWithImpl<$Res>
    extends _$FamilyDtoCopyWithImpl<$Res, _$FamilyDtoImpl>
    implements _$$FamilyDtoImplCopyWith<$Res> {
  __$$FamilyDtoImplCopyWithImpl(
    _$FamilyDtoImpl _value,
    $Res Function(_$FamilyDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FamilyDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? grandpaName = null,
    Object? inviteCode = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$FamilyDtoImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        grandpaName: null == grandpaName
            ? _value.grandpaName
            : grandpaName // ignore: cast_nullable_to_non_nullable
                  as String,
        inviteCode: null == inviteCode
            ? _value.inviteCode
            : inviteCode // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
class _$FamilyDtoImpl implements _FamilyDto {
  const _$FamilyDtoImpl({
    required this.name,
    required this.grandpaName,
    required this.inviteCode,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
  });

  factory _$FamilyDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FamilyDtoImplFromJson(json);

  @override
  final String name;
  @override
  final String grandpaName;
  @override
  final String inviteCode;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'FamilyDto(name: $name, grandpaName: $grandpaName, inviteCode: $inviteCode, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FamilyDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.grandpaName, grandpaName) ||
                other.grandpaName == grandpaName) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    grandpaName,
    inviteCode,
    createdAt,
    updatedAt,
  );

  /// Create a copy of FamilyDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FamilyDtoImplCopyWith<_$FamilyDtoImpl> get copyWith =>
      __$$FamilyDtoImplCopyWithImpl<_$FamilyDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FamilyDtoImplToJson(this);
  }
}

abstract class _FamilyDto implements FamilyDto {
  const factory _FamilyDto({
    required final String name,
    required final String grandpaName,
    required final String inviteCode,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
  }) = _$FamilyDtoImpl;

  factory _FamilyDto.fromJson(Map<String, dynamic> json) =
      _$FamilyDtoImpl.fromJson;

  @override
  String get name;
  @override
  String get grandpaName;
  @override
  String get inviteCode;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of FamilyDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FamilyDtoImplCopyWith<_$FamilyDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
