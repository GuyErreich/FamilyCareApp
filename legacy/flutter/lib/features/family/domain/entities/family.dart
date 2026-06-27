import 'package:freezed_annotation/freezed_annotation.dart';

part 'family.freezed.dart';

/// A family group coordinating companion shifts.
@freezed
class Family with _$Family {
  const factory Family({
    required String id,
    required String name,
    required String grandpaName,
    required String inviteCode,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Family;
}
