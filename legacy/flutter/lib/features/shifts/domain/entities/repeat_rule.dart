import 'package:freezed_annotation/freezed_annotation.dart';

part 'repeat_rule.freezed.dart';

/// Stub for future recurring schedule support.
@freezed
class RepeatRule with _$RepeatRule {
  const factory RepeatRule({
    required String frequency,
    int? interval,
    DateTime? until,
  }) = _RepeatRule;
}
