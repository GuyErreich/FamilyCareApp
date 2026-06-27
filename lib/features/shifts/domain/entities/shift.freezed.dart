// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shift.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Shift {
  String get id => throw _privateConstructorUsedError;
  String get familyId => throw _privateConstructorUsedError;
  String get assignedUserId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  TimeOfDay get startTime => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  List<Duration> get reminderOffsets => throw _privateConstructorUsedError;
  String? get calendarEventId => throw _privateConstructorUsedError;
  ShiftStatus get status => throw _privateConstructorUsedError;
  RepeatRule? get repeatRule => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShiftCopyWith<Shift> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShiftCopyWith<$Res> {
  factory $ShiftCopyWith(Shift value, $Res Function(Shift) then) =
      _$ShiftCopyWithImpl<$Res, Shift>;
  @useResult
  $Res call({
    String id,
    String familyId,
    String assignedUserId,
    DateTime date,
    TimeOfDay startTime,
    int durationMinutes,
    DateTime endTime,
    String? notes,
    List<Duration> reminderOffsets,
    String? calendarEventId,
    ShiftStatus status,
    RepeatRule? repeatRule,
    DateTime createdAt,
    DateTime updatedAt,
  });

  $RepeatRuleCopyWith<$Res>? get repeatRule;
}

/// @nodoc
class _$ShiftCopyWithImpl<$Res, $Val extends Shift>
    implements $ShiftCopyWith<$Res> {
  _$ShiftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? familyId = null,
    Object? assignedUserId = null,
    Object? date = null,
    Object? startTime = null,
    Object? durationMinutes = null,
    Object? endTime = null,
    Object? notes = freezed,
    Object? reminderOffsets = null,
    Object? calendarEventId = freezed,
    Object? status = null,
    Object? repeatRule = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
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
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as TimeOfDay,
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
            reminderOffsets: null == reminderOffsets
                ? _value.reminderOffsets
                : reminderOffsets // ignore: cast_nullable_to_non_nullable
                      as List<Duration>,
            calendarEventId: freezed == calendarEventId
                ? _value.calendarEventId
                : calendarEventId // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ShiftStatus,
            repeatRule: freezed == repeatRule
                ? _value.repeatRule
                : repeatRule // ignore: cast_nullable_to_non_nullable
                      as RepeatRule?,
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

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RepeatRuleCopyWith<$Res>? get repeatRule {
    if (_value.repeatRule == null) {
      return null;
    }

    return $RepeatRuleCopyWith<$Res>(_value.repeatRule!, (value) {
      return _then(_value.copyWith(repeatRule: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ShiftImplCopyWith<$Res> implements $ShiftCopyWith<$Res> {
  factory _$$ShiftImplCopyWith(
    _$ShiftImpl value,
    $Res Function(_$ShiftImpl) then,
  ) = __$$ShiftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String familyId,
    String assignedUserId,
    DateTime date,
    TimeOfDay startTime,
    int durationMinutes,
    DateTime endTime,
    String? notes,
    List<Duration> reminderOffsets,
    String? calendarEventId,
    ShiftStatus status,
    RepeatRule? repeatRule,
    DateTime createdAt,
    DateTime updatedAt,
  });

  @override
  $RepeatRuleCopyWith<$Res>? get repeatRule;
}

/// @nodoc
class __$$ShiftImplCopyWithImpl<$Res>
    extends _$ShiftCopyWithImpl<$Res, _$ShiftImpl>
    implements _$$ShiftImplCopyWith<$Res> {
  __$$ShiftImplCopyWithImpl(
    _$ShiftImpl _value,
    $Res Function(_$ShiftImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? familyId = null,
    Object? assignedUserId = null,
    Object? date = null,
    Object? startTime = null,
    Object? durationMinutes = null,
    Object? endTime = null,
    Object? notes = freezed,
    Object? reminderOffsets = null,
    Object? calendarEventId = freezed,
    Object? status = null,
    Object? repeatRule = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ShiftImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
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
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as TimeOfDay,
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
        reminderOffsets: null == reminderOffsets
            ? _value._reminderOffsets
            : reminderOffsets // ignore: cast_nullable_to_non_nullable
                  as List<Duration>,
        calendarEventId: freezed == calendarEventId
            ? _value.calendarEventId
            : calendarEventId // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ShiftStatus,
        repeatRule: freezed == repeatRule
            ? _value.repeatRule
            : repeatRule // ignore: cast_nullable_to_non_nullable
                  as RepeatRule?,
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

class _$ShiftImpl extends _Shift {
  const _$ShiftImpl({
    required this.id,
    required this.familyId,
    required this.assignedUserId,
    required this.date,
    required this.startTime,
    required this.durationMinutes,
    required this.endTime,
    this.notes,
    final List<Duration> reminderOffsets = const <Duration>[],
    this.calendarEventId,
    this.status = ShiftStatus.scheduled,
    this.repeatRule,
    required this.createdAt,
    required this.updatedAt,
  }) : _reminderOffsets = reminderOffsets,
       super._();

  @override
  final String id;
  @override
  final String familyId;
  @override
  final String assignedUserId;
  @override
  final DateTime date;
  @override
  final TimeOfDay startTime;
  @override
  final int durationMinutes;
  @override
  final DateTime endTime;
  @override
  final String? notes;
  final List<Duration> _reminderOffsets;
  @override
  @JsonKey()
  List<Duration> get reminderOffsets {
    if (_reminderOffsets is EqualUnmodifiableListView) return _reminderOffsets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reminderOffsets);
  }

  @override
  final String? calendarEventId;
  @override
  @JsonKey()
  final ShiftStatus status;
  @override
  final RepeatRule? repeatRule;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Shift(id: $id, familyId: $familyId, assignedUserId: $assignedUserId, date: $date, startTime: $startTime, durationMinutes: $durationMinutes, endTime: $endTime, notes: $notes, reminderOffsets: $reminderOffsets, calendarEventId: $calendarEventId, status: $status, repeatRule: $repeatRule, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShiftImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.familyId, familyId) ||
                other.familyId == familyId) &&
            (identical(other.assignedUserId, assignedUserId) ||
                other.assignedUserId == assignedUserId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(
              other._reminderOffsets,
              _reminderOffsets,
            ) &&
            (identical(other.calendarEventId, calendarEventId) ||
                other.calendarEventId == calendarEventId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.repeatRule, repeatRule) ||
                other.repeatRule == repeatRule) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    familyId,
    assignedUserId,
    date,
    startTime,
    durationMinutes,
    endTime,
    notes,
    const DeepCollectionEquality().hash(_reminderOffsets),
    calendarEventId,
    status,
    repeatRule,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShiftImplCopyWith<_$ShiftImpl> get copyWith =>
      __$$ShiftImplCopyWithImpl<_$ShiftImpl>(this, _$identity);
}

abstract class _Shift extends Shift {
  const factory _Shift({
    required final String id,
    required final String familyId,
    required final String assignedUserId,
    required final DateTime date,
    required final TimeOfDay startTime,
    required final int durationMinutes,
    required final DateTime endTime,
    final String? notes,
    final List<Duration> reminderOffsets,
    final String? calendarEventId,
    final ShiftStatus status,
    final RepeatRule? repeatRule,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ShiftImpl;
  const _Shift._() : super._();

  @override
  String get id;
  @override
  String get familyId;
  @override
  String get assignedUserId;
  @override
  DateTime get date;
  @override
  TimeOfDay get startTime;
  @override
  int get durationMinutes;
  @override
  DateTime get endTime;
  @override
  String? get notes;
  @override
  List<Duration> get reminderOffsets;
  @override
  String? get calendarEventId;
  @override
  ShiftStatus get status;
  @override
  RepeatRule? get repeatRule;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShiftImplCopyWith<_$ShiftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
