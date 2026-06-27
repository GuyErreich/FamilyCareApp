// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_member_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FamilyMemberDto _$FamilyMemberDtoFromJson(Map<String, dynamic> json) {
  return _FamilyMemberDto.fromJson(json);
}

/// @nodoc
mixin _$FamilyMemberDto {
  String get familyId => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String get colorHex => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this FamilyMemberDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FamilyMemberDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FamilyMemberDtoCopyWith<FamilyMemberDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FamilyMemberDtoCopyWith<$Res> {
  factory $FamilyMemberDtoCopyWith(
    FamilyMemberDto value,
    $Res Function(FamilyMemberDto) then,
  ) = _$FamilyMemberDtoCopyWithImpl<$Res, FamilyMemberDto>;
  @useResult
  $Res call({
    String familyId,
    String? userId,
    String name,
    String? phone,
    String colorHex,
    String? avatarUrl,
    String role,
    @TimestampConverter() DateTime createdAt,
  });
}

/// @nodoc
class _$FamilyMemberDtoCopyWithImpl<$Res, $Val extends FamilyMemberDto>
    implements $FamilyMemberDtoCopyWith<$Res> {
  _$FamilyMemberDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FamilyMemberDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? familyId = null,
    Object? userId = freezed,
    Object? name = null,
    Object? phone = freezed,
    Object? colorHex = null,
    Object? avatarUrl = freezed,
    Object? role = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            familyId: null == familyId
                ? _value.familyId
                : familyId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            colorHex: null == colorHex
                ? _value.colorHex
                : colorHex // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FamilyMemberDtoImplCopyWith<$Res>
    implements $FamilyMemberDtoCopyWith<$Res> {
  factory _$$FamilyMemberDtoImplCopyWith(
    _$FamilyMemberDtoImpl value,
    $Res Function(_$FamilyMemberDtoImpl) then,
  ) = __$$FamilyMemberDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String familyId,
    String? userId,
    String name,
    String? phone,
    String colorHex,
    String? avatarUrl,
    String role,
    @TimestampConverter() DateTime createdAt,
  });
}

/// @nodoc
class __$$FamilyMemberDtoImplCopyWithImpl<$Res>
    extends _$FamilyMemberDtoCopyWithImpl<$Res, _$FamilyMemberDtoImpl>
    implements _$$FamilyMemberDtoImplCopyWith<$Res> {
  __$$FamilyMemberDtoImplCopyWithImpl(
    _$FamilyMemberDtoImpl _value,
    $Res Function(_$FamilyMemberDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FamilyMemberDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? familyId = null,
    Object? userId = freezed,
    Object? name = null,
    Object? phone = freezed,
    Object? colorHex = null,
    Object? avatarUrl = freezed,
    Object? role = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$FamilyMemberDtoImpl(
        familyId: null == familyId
            ? _value.familyId
            : familyId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        colorHex: null == colorHex
            ? _value.colorHex
            : colorHex // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FamilyMemberDtoImpl implements _FamilyMemberDto {
  const _$FamilyMemberDtoImpl({
    required this.familyId,
    this.userId,
    required this.name,
    this.phone,
    required this.colorHex,
    this.avatarUrl,
    this.role = 'member',
    @TimestampConverter() required this.createdAt,
  });

  factory _$FamilyMemberDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FamilyMemberDtoImplFromJson(json);

  @override
  final String familyId;
  @override
  final String? userId;
  @override
  final String name;
  @override
  final String? phone;
  @override
  final String colorHex;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final String role;
  @override
  @TimestampConverter()
  final DateTime createdAt;

  @override
  String toString() {
    return 'FamilyMemberDto(familyId: $familyId, userId: $userId, name: $name, phone: $phone, colorHex: $colorHex, avatarUrl: $avatarUrl, role: $role, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FamilyMemberDtoImpl &&
            (identical(other.familyId, familyId) ||
                other.familyId == familyId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    familyId,
    userId,
    name,
    phone,
    colorHex,
    avatarUrl,
    role,
    createdAt,
  );

  /// Create a copy of FamilyMemberDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FamilyMemberDtoImplCopyWith<_$FamilyMemberDtoImpl> get copyWith =>
      __$$FamilyMemberDtoImplCopyWithImpl<_$FamilyMemberDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FamilyMemberDtoImplToJson(this);
  }
}

abstract class _FamilyMemberDto implements FamilyMemberDto {
  const factory _FamilyMemberDto({
    required final String familyId,
    final String? userId,
    required final String name,
    final String? phone,
    required final String colorHex,
    final String? avatarUrl,
    final String role,
    @TimestampConverter() required final DateTime createdAt,
  }) = _$FamilyMemberDtoImpl;

  factory _FamilyMemberDto.fromJson(Map<String, dynamic> json) =
      _$FamilyMemberDtoImpl.fromJson;

  @override
  String get familyId;
  @override
  String? get userId;
  @override
  String get name;
  @override
  String? get phone;
  @override
  String get colorHex;
  @override
  String? get avatarUrl;
  @override
  String get role;
  @override
  @TimestampConverter()
  DateTime get createdAt;

  /// Create a copy of FamilyMemberDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FamilyMemberDtoImplCopyWith<_$FamilyMemberDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
