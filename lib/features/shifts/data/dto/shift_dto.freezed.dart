// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shift_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ShiftDto _$ShiftDtoFromJson(Map<String, dynamic> json) {
  return _ShiftDto.fromJson(json);
}

/// @nodoc
mixin _$ShiftDto {
  String get familyId => throw _privateConstructorUsedError;
  String get assignedUserId => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get date => throw _privateConstructorUsedError;
  int get startHour => throw _privateConstructorUsedError;
  int get startMinute => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get endTime => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  List<int> get reminderOffsetMinutes => throw _privateConstructorUsedError;
  String? get calendarEventId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  Map<String, dynamic>? get repeatRule => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ShiftDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShiftDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShiftDtoCopyWith<ShiftDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShiftDtoCopyWith<$Res> {
  factory $ShiftDtoCopyWith(ShiftDto value, $Res Function(ShiftDto) then) =
      _$ShiftDtoCopyWithImpl<$Res, ShiftDto>;
  @useResult
  $Res call({
    String familyId,
    String assignedUserId,
    @TimestampConverter() DateTime date,
    int startHour,
    int startMinute,
    int durationMinutes,
    @TimestampConverter() DateTime endTime,
    String? notes,
    List<int> reminderOffsetMinutes,
    String? calendarEventId,
    String status,
    Map<String, dynamic>? repeatRule,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
  });
}

/// @nodoc
class _$ShiftDtoCopyWithImpl<$Res, $Val extends ShiftDto>
    implements $ShiftDtoCopyWith<$Res> {
  _$ShiftDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShiftDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? familyId = null,
    Object? assignedUserId = null,
    Object? date = null,
    Object? startHour = null,
    Object? startMinute = null,
    Object? durationMinutes = null,
    Object? endTime = null,
    Object? notes = freezed,
    Object? reminderOffsetMinutes = null,
    Object? calendarEventId = freezed,
    Object? status = null,
    Object? repeatRule = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            familyId: null == familyId
                ? _value.familyId
                : familyId // ignore: cast_nullable_to_non_nullable
                      as String,
            assignedUserId: null == assignedUserId
                ? _value.assignedUserId
                : assignedUserId // ignore: cast_nullable_to_non_nullable
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
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            reminderOffsetMinutes: null == reminderOffsetMinutes
                ? _value.reminderOffsetMinutes
                : reminderOffsetMinutes // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            calendarEventId: freezed == calendarEventId
                ? _value.calendarEventId
                : calendarEventId // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            repeatRule: freezed == repeatRule
                ? _value.repeatRule
                : repeatRule // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
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
abstract class _$$ShiftDtoImplCopyWith<$Res>
    implements $ShiftDtoCopyWith<$Res> {
  factory _$$ShiftDtoImplCopyWith(
    _$ShiftDtoImpl value,
    $Res Function(_$ShiftDtoImpl) then,
  ) = __$$ShiftDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String familyId,
    String assignedUserId,
    @TimestampConverter() DateTime date,
    int startHour,
    int startMinute,
    int durationMinutes,
    @TimestampConverter() DateTime endTime,
    String? notes,
    List<int> reminderOffsetMinutes,
    String? calendarEventId,
    String status,
    Map<String, dynamic>? repeatRule,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
  });
}

/// @nodoc
class __$$ShiftDtoImplCopyWithImpl<$Res>
    extends _$ShiftDtoCopyWithImpl<$Res, _$ShiftDtoImpl>
    implements _$$ShiftDtoImplCopyWith<$Res> {
  __$$ShiftDtoImplCopyWithImpl(
    _$ShiftDtoImpl _value,
    $Res Function(_$ShiftDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShiftDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? familyId = null,
    Object? assignedUserId = null,
    Object? date = null,
    Object? startHour = null,
    Object? startMinute = null,
    Object? durationMinutes = null,
    Object? endTime = null,
    Object? notes = freezed,
    Object? reminderOffsetMinutes = null,
    Object? calendarEventId = freezed,
    Object? status = null,
    Object? repeatRule = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ShiftDtoImpl(
        familyId: null == familyId
            ? _value.familyId
            : familyId // ignore: cast_nullable_to_non_nullable
                  as String,
        assignedUserId: null == assignedUserId
            ? _value.assignedUserId
            : assignedUserId // ignore: cast_nullable_to_non_nullable
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
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        reminderOffsetMinutes: null == reminderOffsetMinutes
            ? _value._reminderOffsetMinutes
            : reminderOffsetMinutes // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        calendarEventId: freezed == calendarEventId
            ? _value.calendarEventId
            : calendarEventId // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        repeatRule: freezed == repeatRule
            ? _value._repeatRule
            : repeatRule // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
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
class _$ShiftDtoImpl implements _ShiftDto {
  const _$ShiftDtoImpl({
    required this.familyId,
    required this.assignedUserId,
    @TimestampConverter() required this.date,
    required this.startHour,
    required this.startMinute,
    required this.durationMinutes,
    @TimestampConverter() required this.endTime,
    this.notes,
    final List<int> reminderOffsetMinutes = const <int>[],
    this.calendarEventId,
    this.status = 'scheduled',
    final Map<String, dynamic>? repeatRule,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
  }) : _reminderOffsetMinutes = reminderOffsetMinutes,
       _repeatRule = repeatRule;

  factory _$ShiftDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShiftDtoImplFromJson(json);

  @override
  final String familyId;
  @override
  final String assignedUserId;
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
  final String? notes;
  final List<int> _reminderOffsetMinutes;
  @override
  @JsonKey()
  List<int> get reminderOffsetMinutes {
    if (_reminderOffsetMinutes is EqualUnmodifiableListView)
      return _reminderOffsetMinutes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reminderOffsetMinutes);
  }

  @override
  final String? calendarEventId;
  @override
  @JsonKey()
  final String status;
  final Map<String, dynamic>? _repeatRule;
  @override
  Map<String, dynamic>? get repeatRule {
    final value = _repeatRule;
    if (value == null) return null;
    if (_repeatRule is EqualUnmodifiableMapView) return _repeatRule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ShiftDto(familyId: $familyId, assignedUserId: $assignedUserId, date: $date, startHour: $startHour, startMinute: $startMinute, durationMinutes: $durationMinutes, endTime: $endTime, notes: $notes, reminderOffsetMinutes: $reminderOffsetMinutes, calendarEventId: $calendarEventId, status: $status, repeatRule: $repeatRule, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShiftDtoImpl &&
            (identical(other.familyId, familyId) ||
                other.familyId == familyId) &&
            (identical(other.assignedUserId, assignedUserId) ||
                other.assignedUserId == assignedUserId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.startHour, startHour) ||
                other.startHour == startHour) &&
            (identical(other.startMinute, startMinute) ||
                other.startMinute == startMinute) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(
              other._reminderOffsetMinutes,
              _reminderOffsetMinutes,
            ) &&
            (identical(other.calendarEventId, calendarEventId) ||
                other.calendarEventId == calendarEventId) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._repeatRule,
              _repeatRule,
            ) &&
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
    assignedUserId,
    date,
    startHour,
    startMinute,
    durationMinutes,
    endTime,
    notes,
    const DeepCollectionEquality().hash(_reminderOffsetMinutes),
    calendarEventId,
    status,
    const DeepCollectionEquality().hash(_repeatRule),
    createdAt,
    updatedAt,
  );

  /// Create a copy of ShiftDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShiftDtoImplCopyWith<_$ShiftDtoImpl> get copyWith =>
      __$$ShiftDtoImplCopyWithImpl<_$ShiftDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShiftDtoImplToJson(this);
  }
}

abstract class _ShiftDto implements ShiftDto {
  const factory _ShiftDto({
    required final String familyId,
    required final String assignedUserId,
    @TimestampConverter() required final DateTime date,
    required final int startHour,
    required final int startMinute,
    required final int durationMinutes,
    @TimestampConverter() required final DateTime endTime,
    final String? notes,
    final List<int> reminderOffsetMinutes,
    final String? calendarEventId,
    final String status,
    final Map<String, dynamic>? repeatRule,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
  }) = _$ShiftDtoImpl;

  factory _ShiftDto.fromJson(Map<String, dynamic> json) =
      _$ShiftDtoImpl.fromJson;

  @override
  String get familyId;
  @override
  String get assignedUserId;
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
  String? get notes;
  @override
  List<int> get reminderOffsetMinutes;
  @override
  String? get calendarEventId;
  @override
  String get status;
  @override
  Map<String, dynamic>? get repeatRule;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of ShiftDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShiftDtoImplCopyWith<_$ShiftDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
