// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unavailability_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UnavailabilityDto _$UnavailabilityDtoFromJson(Map<String, dynamic> json) {
  return _UnavailabilityDto.fromJson(json);
}

/// @nodoc
mixin _$UnavailabilityDto {
  String get familyId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get date => throw _privateConstructorUsedError;
  int get startHour => throw _privateConstructorUsedError;
  int get startMinute => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get endTime => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UnavailabilityDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UnavailabilityDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UnavailabilityDtoCopyWith<UnavailabilityDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnavailabilityDtoCopyWith<$Res> {
  factory $UnavailabilityDtoCopyWith(
    UnavailabilityDto value,
    $Res Function(UnavailabilityDto) then,
  ) = _$UnavailabilityDtoCopyWithImpl<$Res, UnavailabilityDto>;
  @useResult
  $Res call({
    String familyId,
    String userId,
    @TimestampConverter() DateTime date,
    int startHour,
    int startMinute,
    int durationMinutes,
    @TimestampConverter() DateTime endTime,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
  });
}

/// @nodoc
class _$UnavailabilityDtoCopyWithImpl<$Res, $Val extends UnavailabilityDto>
    implements $UnavailabilityDtoCopyWith<$Res> {
  _$UnavailabilityDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UnavailabilityDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? familyId = null,
    Object? userId = null,
    Object? date = null,
    Object? startHour = null,
    Object? startMinute = null,
    Object? durationMinutes = null,
    Object? endTime = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            familyId: null == familyId
                ? _value.familyId
                : familyId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startHour: null == startHour
                ? _value.startHour
                : startHour // ignore: cast_nullable_to_non_nullable
                      as int,
            startMinute: null == startMinute
                ? _value.startMinute
                : startMinute // ignore: cast_nullable_to_non_nullable
                      as int,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
abstract class _$$UnavailabilityDtoImplCopyWith<$Res>
    implements $UnavailabilityDtoCopyWith<$Res> {
  factory _$$UnavailabilityDtoImplCopyWith(
    _$UnavailabilityDtoImpl value,
    $Res Function(_$UnavailabilityDtoImpl) then,
  ) = __$$UnavailabilityDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String familyId,
    String userId,
    @TimestampConverter() DateTime date,
    int startHour,
    int startMinute,
    int durationMinutes,
    @TimestampConverter() DateTime endTime,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
  });
}

/// @nodoc
class __$$UnavailabilityDtoImplCopyWithImpl<$Res>
    extends _$UnavailabilityDtoCopyWithImpl<$Res, _$UnavailabilityDtoImpl>
    implements _$$UnavailabilityDtoImplCopyWith<$Res> {
  __$$UnavailabilityDtoImplCopyWithImpl(
    _$UnavailabilityDtoImpl _value,
    $Res Function(_$UnavailabilityDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UnavailabilityDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? familyId = null,
    Object? userId = null,
    Object? date = null,
    Object? startHour = null,
    Object? startMinute = null,
    Object? durationMinutes = null,
    Object? endTime = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$UnavailabilityDtoImpl(
        familyId: null == familyId
            ? _value.familyId
            : familyId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startHour: null == startHour
            ? _value.startHour
            : startHour // ignore: cast_nullable_to_non_nullable
                  as int,
        startMinute: null == startMinute
            ? _value.startMinute
            : startMinute // ignore: cast_nullable_to_non_nullable
                  as int,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
class _$UnavailabilityDtoImpl implements _UnavailabilityDto {
  const _$UnavailabilityDtoImpl({
    required this.familyId,
    required this.userId,
    @TimestampConverter() required this.date,
    required this.startHour,
    required this.startMinute,
    required this.durationMinutes,
    @TimestampConverter() required this.endTime,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
  });

  factory _$UnavailabilityDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnavailabilityDtoImplFromJson(json);

  @override
  final String familyId;
  @override
  final String userId;
  @override
  @TimestampConverter()
  final DateTime date;
  @override
  final int startHour;
  @override
  final int startMinute;
  @override
  final int durationMinutes;
  @override
  @TimestampConverter()
  final DateTime endTime;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UnavailabilityDto(familyId: $familyId, userId: $userId, date: $date, startHour: $startHour, startMinute: $startMinute, durationMinutes: $durationMinutes, endTime: $endTime, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnavailabilityDtoImpl &&
            (identical(other.familyId, familyId) ||
                other.familyId == familyId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.startHour, startHour) ||
                other.startHour == startHour) &&
            (identical(other.startMinute, startMinute) ||
                other.startMinute == startMinute) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    familyId,
    userId,
    date,
    startHour,
    startMinute,
    durationMinutes,
    endTime,
    createdAt,
    updatedAt,
  );

  /// Create a copy of UnavailabilityDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnavailabilityDtoImplCopyWith<_$UnavailabilityDtoImpl> get copyWith =>
      __$$UnavailabilityDtoImplCopyWithImpl<_$UnavailabilityDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UnavailabilityDtoImplToJson(this);
  }
}

abstract class _UnavailabilityDto implements UnavailabilityDto {
  const factory _UnavailabilityDto({
    required final String familyId,
    required final String userId,
    @TimestampConverter() required final DateTime date,
    required final int startHour,
    required final int startMinute,
    required final int durationMinutes,
    @TimestampConverter() required final DateTime endTime,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
  }) = _$UnavailabilityDtoImpl;

  factory _UnavailabilityDto.fromJson(Map<String, dynamic> json) =
      _$UnavailabilityDtoImpl.fromJson;

  @override
  String get familyId;
  @override
  String get userId;
  @override
  @TimestampConverter()
  DateTime get date;
  @override
  int get startHour;
  @override
  int get startMinute;
  @override
  int get durationMinutes;
  @override
  @TimestampConverter()
  DateTime get endTime;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of UnavailabilityDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnavailabilityDtoImplCopyWith<_$UnavailabilityDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
