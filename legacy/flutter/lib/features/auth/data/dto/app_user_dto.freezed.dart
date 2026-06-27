// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppUserDto _$AppUserDtoFromJson(Map<String, dynamic> json) {
  return _AppUserDto.fromJson(json);
}

/// @nodoc
mixin _$AppUserDto {
  String get email => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get familyId => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String get colorHex => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  List<String> get fcmTokens => throw _privateConstructorUsedError;
  bool get googleCalendarConnected => throw _privateConstructorUsedError;
  int get scheduleDaysShowed => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AppUserDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppUserDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppUserDtoCopyWith<AppUserDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppUserDtoCopyWith<$Res> {
  factory $AppUserDtoCopyWith(
    AppUserDto value,
    $Res Function(AppUserDto) then,
  ) = _$AppUserDtoCopyWithImpl<$Res, AppUserDto>;
  @useResult
  $Res call({
    String email,
    String? displayName,
    String? familyId,
    String? phone,
    String colorHex,
    String? avatarUrl,
    List<String> fcmTokens,
    bool googleCalendarConnected,
    int scheduleDaysShowed,
    @TimestampConverter() DateTime createdAt,
  });
}

/// @nodoc
class _$AppUserDtoCopyWithImpl<$Res, $Val extends AppUserDto>
    implements $AppUserDtoCopyWith<$Res> {
  _$AppUserDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppUserDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? displayName = freezed,
    Object? familyId = freezed,
    Object? phone = freezed,
    Object? colorHex = null,
    Object? avatarUrl = freezed,
    Object? fcmTokens = null,
    Object? googleCalendarConnected = null,
    Object? scheduleDaysShowed = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            familyId: freezed == familyId
                ? _value.familyId
                : familyId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            fcmTokens: null == fcmTokens
                ? _value.fcmTokens
                : fcmTokens // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            googleCalendarConnected: null == googleCalendarConnected
                ? _value.googleCalendarConnected
                : googleCalendarConnected // ignore: cast_nullable_to_non_nullable
                      as bool,
            scheduleDaysShowed: null == scheduleDaysShowed
                ? _value.scheduleDaysShowed
                : scheduleDaysShowed // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$AppUserDtoImplCopyWith<$Res>
    implements $AppUserDtoCopyWith<$Res> {
  factory _$$AppUserDtoImplCopyWith(
    _$AppUserDtoImpl value,
    $Res Function(_$AppUserDtoImpl) then,
  ) = __$$AppUserDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String email,
    String? displayName,
    String? familyId,
    String? phone,
    String colorHex,
    String? avatarUrl,
    List<String> fcmTokens,
    bool googleCalendarConnected,
    int scheduleDaysShowed,
    @TimestampConverter() DateTime createdAt,
  });
}

/// @nodoc
class __$$AppUserDtoImplCopyWithImpl<$Res>
    extends _$AppUserDtoCopyWithImpl<$Res, _$AppUserDtoImpl>
    implements _$$AppUserDtoImplCopyWith<$Res> {
  __$$AppUserDtoImplCopyWithImpl(
    _$AppUserDtoImpl _value,
    $Res Function(_$AppUserDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppUserDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? displayName = freezed,
    Object? familyId = freezed,
    Object? phone = freezed,
    Object? colorHex = null,
    Object? avatarUrl = freezed,
    Object? fcmTokens = null,
    Object? googleCalendarConnected = null,
    Object? scheduleDaysShowed = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$AppUserDtoImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        familyId: freezed == familyId
            ? _value.familyId
            : familyId // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        fcmTokens: null == fcmTokens
            ? _value._fcmTokens
            : fcmTokens // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        googleCalendarConnected: null == googleCalendarConnected
            ? _value.googleCalendarConnected
            : googleCalendarConnected // ignore: cast_nullable_to_non_nullable
                  as bool,
        scheduleDaysShowed: null == scheduleDaysShowed
            ? _value.scheduleDaysShowed
            : scheduleDaysShowed // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$AppUserDtoImpl implements _AppUserDto {
  const _$AppUserDtoImpl({
    required this.email,
    this.displayName,
    this.familyId,
    this.phone,
    this.colorHex = '#4A6741',
    this.avatarUrl,
    final List<String> fcmTokens = const <String>[],
    this.googleCalendarConnected = false,
    this.scheduleDaysShowed = 3,
    @TimestampConverter() required this.createdAt,
  }) : _fcmTokens = fcmTokens;

  factory _$AppUserDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppUserDtoImplFromJson(json);

  @override
  final String email;
  @override
  final String? displayName;
  @override
  final String? familyId;
  @override
  final String? phone;
  @override
  @JsonKey()
  final String colorHex;
  @override
  final String? avatarUrl;
  final List<String> _fcmTokens;
  @override
  @JsonKey()
  List<String> get fcmTokens {
    if (_fcmTokens is EqualUnmodifiableListView) return _fcmTokens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fcmTokens);
  }

  @override
  @JsonKey()
  final bool googleCalendarConnected;
  @override
  @JsonKey()
  final int scheduleDaysShowed;
  @override
  @TimestampConverter()
  final DateTime createdAt;

  @override
  String toString() {
    return 'AppUserDto(email: $email, displayName: $displayName, familyId: $familyId, phone: $phone, colorHex: $colorHex, avatarUrl: $avatarUrl, fcmTokens: $fcmTokens, googleCalendarConnected: $googleCalendarConnected, scheduleDaysShowed: $scheduleDaysShowed, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppUserDtoImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.familyId, familyId) ||
                other.familyId == familyId) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            const DeepCollectionEquality().equals(
              other._fcmTokens,
              _fcmTokens,
            ) &&
            (identical(
                  other.googleCalendarConnected,
                  googleCalendarConnected,
                ) ||
                other.googleCalendarConnected == googleCalendarConnected) &&
            (identical(other.scheduleDaysShowed, scheduleDaysShowed) ||
                other.scheduleDaysShowed == scheduleDaysShowed) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    email,
    displayName,
    familyId,
    phone,
    colorHex,
    avatarUrl,
    const DeepCollectionEquality().hash(_fcmTokens),
    googleCalendarConnected,
    scheduleDaysShowed,
    createdAt,
  );

  /// Create a copy of AppUserDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppUserDtoImplCopyWith<_$AppUserDtoImpl> get copyWith =>
      __$$AppUserDtoImplCopyWithImpl<_$AppUserDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppUserDtoImplToJson(this);
  }
}

abstract class _AppUserDto implements AppUserDto {
  const factory _AppUserDto({
    required final String email,
    final String? displayName,
    final String? familyId,
    final String? phone,
    final String colorHex,
    final String? avatarUrl,
    final List<String> fcmTokens,
    final bool googleCalendarConnected,
    final int scheduleDaysShowed,
    @TimestampConverter() required final DateTime createdAt,
  }) = _$AppUserDtoImpl;

  factory _AppUserDto.fromJson(Map<String, dynamic> json) =
      _$AppUserDtoImpl.fromJson;

  @override
  String get email;
  @override
  String? get displayName;
  @override
  String? get familyId;
  @override
  String? get phone;
  @override
  String get colorHex;
  @override
  String? get avatarUrl;
  @override
  List<String> get fcmTokens;
  @override
  bool get googleCalendarConnected;
  @override
  int get scheduleDaysShowed;
  @override
  @TimestampConverter()
  DateTime get createdAt;

  /// Create a copy of AppUserDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppUserDtoImplCopyWith<_$AppUserDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
