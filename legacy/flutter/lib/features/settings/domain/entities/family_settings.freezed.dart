// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FamilySettings {
  String get familyId => throw _privateConstructorUsedError;
  List<String> get coverageFallbackUserIds =>
      throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of FamilySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FamilySettingsCopyWith<FamilySettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FamilySettingsCopyWith<$Res> {
  factory $FamilySettingsCopyWith(
    FamilySettings value,
    $Res Function(FamilySettings) then,
  ) = _$FamilySettingsCopyWithImpl<$Res, FamilySettings>;
  @useResult
  $Res call({
    String familyId,
    List<String> coverageFallbackUserIds,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$FamilySettingsCopyWithImpl<$Res, $Val extends FamilySettings>
    implements $FamilySettingsCopyWith<$Res> {
  _$FamilySettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FamilySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? familyId = null,
    Object? coverageFallbackUserIds = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            familyId: null == familyId
                ? _value.familyId
                : familyId // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$FamilySettingsImplCopyWith<$Res>
    implements $FamilySettingsCopyWith<$Res> {
  factory _$$FamilySettingsImplCopyWith(
    _$FamilySettingsImpl value,
    $Res Function(_$FamilySettingsImpl) then,
  ) = __$$FamilySettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String familyId,
    List<String> coverageFallbackUserIds,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$FamilySettingsImplCopyWithImpl<$Res>
    extends _$FamilySettingsCopyWithImpl<$Res, _$FamilySettingsImpl>
    implements _$$FamilySettingsImplCopyWith<$Res> {
  __$$FamilySettingsImplCopyWithImpl(
    _$FamilySettingsImpl _value,
    $Res Function(_$FamilySettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FamilySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? familyId = null,
    Object? coverageFallbackUserIds = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$FamilySettingsImpl(
        familyId: null == familyId
            ? _value.familyId
            : familyId // ignore: cast_nullable_to_non_nullable
                  as String,
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

class _$FamilySettingsImpl implements _FamilySettings {
  const _$FamilySettingsImpl({
    required this.familyId,
    final List<String> coverageFallbackUserIds = const <String>[],
    required this.updatedAt,
  }) : _coverageFallbackUserIds = coverageFallbackUserIds;

  @override
  final String familyId;
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
  final DateTime updatedAt;

  @override
  String toString() {
    return 'FamilySettings(familyId: $familyId, coverageFallbackUserIds: $coverageFallbackUserIds, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FamilySettingsImpl &&
            (identical(other.familyId, familyId) ||
                other.familyId == familyId) &&
            const DeepCollectionEquality().equals(
              other._coverageFallbackUserIds,
              _coverageFallbackUserIds,
            ) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    familyId,
    const DeepCollectionEquality().hash(_coverageFallbackUserIds),
    updatedAt,
  );

  /// Create a copy of FamilySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FamilySettingsImplCopyWith<_$FamilySettingsImpl> get copyWith =>
      __$$FamilySettingsImplCopyWithImpl<_$FamilySettingsImpl>(
        this,
        _$identity,
      );
}

abstract class _FamilySettings implements FamilySettings {
  const factory _FamilySettings({
    required final String familyId,
    final List<String> coverageFallbackUserIds,
    required final DateTime updatedAt,
  }) = _$FamilySettingsImpl;

  @override
  String get familyId;
  @override
  List<String> get coverageFallbackUserIds;
  @override
  DateTime get updatedAt;

  /// Create a copy of FamilySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FamilySettingsImplCopyWith<_$FamilySettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
