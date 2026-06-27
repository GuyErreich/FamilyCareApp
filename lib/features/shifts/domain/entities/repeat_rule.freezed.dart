// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repeat_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RepeatRule {
  String get frequency => throw _privateConstructorUsedError;
  int? get interval => throw _privateConstructorUsedError;
  DateTime? get until => throw _privateConstructorUsedError;

  /// Create a copy of RepeatRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RepeatRuleCopyWith<RepeatRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RepeatRuleCopyWith<$Res> {
  factory $RepeatRuleCopyWith(
    RepeatRule value,
    $Res Function(RepeatRule) then,
  ) = _$RepeatRuleCopyWithImpl<$Res, RepeatRule>;
  @useResult
  $Res call({String frequency, int? interval, DateTime? until});
}

/// @nodoc
class _$RepeatRuleCopyWithImpl<$Res, $Val extends RepeatRule>
    implements $RepeatRuleCopyWith<$Res> {
  _$RepeatRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RepeatRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frequency = null,
    Object? interval = freezed,
    Object? until = freezed,
  }) {
    return _then(
      _value.copyWith(
            frequency: null == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as String,
            interval: freezed == interval
                ? _value.interval
                : interval // ignore: cast_nullable_to_non_nullable
                      as int?,
            until: freezed == until
                ? _value.until
                : until // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RepeatRuleImplCopyWith<$Res>
    implements $RepeatRuleCopyWith<$Res> {
  factory _$$RepeatRuleImplCopyWith(
    _$RepeatRuleImpl value,
    $Res Function(_$RepeatRuleImpl) then,
  ) = __$$RepeatRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String frequency, int? interval, DateTime? until});
}

/// @nodoc
class __$$RepeatRuleImplCopyWithImpl<$Res>
    extends _$RepeatRuleCopyWithImpl<$Res, _$RepeatRuleImpl>
    implements _$$RepeatRuleImplCopyWith<$Res> {
  __$$RepeatRuleImplCopyWithImpl(
    _$RepeatRuleImpl _value,
    $Res Function(_$RepeatRuleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RepeatRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frequency = null,
    Object? interval = freezed,
    Object? until = freezed,
  }) {
    return _then(
      _$RepeatRuleImpl(
        frequency: null == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as String,
        interval: freezed == interval
            ? _value.interval
            : interval // ignore: cast_nullable_to_non_nullable
                  as int?,
        until: freezed == until
            ? _value.until
            : until // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$RepeatRuleImpl implements _RepeatRule {
  const _$RepeatRuleImpl({required this.frequency, this.interval, this.until});

  @override
  final String frequency;
  @override
  final int? interval;
  @override
  final DateTime? until;

  @override
  String toString() {
    return 'RepeatRule(frequency: $frequency, interval: $interval, until: $until)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RepeatRuleImpl &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.until, until) || other.until == until));
  }

  @override
  int get hashCode => Object.hash(runtimeType, frequency, interval, until);

  /// Create a copy of RepeatRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RepeatRuleImplCopyWith<_$RepeatRuleImpl> get copyWith =>
      __$$RepeatRuleImplCopyWithImpl<_$RepeatRuleImpl>(this, _$identity);
}

abstract class _RepeatRule implements RepeatRule {
  const factory _RepeatRule({
    required final String frequency,
    final int? interval,
    final DateTime? until,
  }) = _$RepeatRuleImpl;

  @override
  String get frequency;
  @override
  int? get interval;
  @override
  DateTime? get until;

  /// Create a copy of RepeatRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RepeatRuleImplCopyWith<_$RepeatRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
