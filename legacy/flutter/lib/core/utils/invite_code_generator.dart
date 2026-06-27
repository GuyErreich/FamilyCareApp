import 'dart:math';

import 'package:family_care_scheduler/core/constants/app_constants.dart';

/// Generates a random invite code for family joining.
abstract final class InviteCodeGenerator {
  static const _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static final _random = Random.secure();

  static String generate() {
    return List.generate(
      AppConstants.inviteCodeLength,
      (_) => _chars[_random.nextInt(_chars.length)],
    ).join();
  }
}
