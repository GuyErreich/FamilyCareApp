import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/features/auth/domain/entities/app_user.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(
    messaging: FirebaseMessaging.instance,
    ref: ref,
  );
});

/// Registers FCM tokens and handles foreground messages.
class FcmService {
  FcmService({
    required this._messaging,
    required this._ref,
  });

  final FirebaseMessaging _messaging;
  final Ref _ref;

  Future<void> initialize() async {
    await _messaging.requestPermission();
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveToken(token);
    }
    _messaging.onTokenRefresh.listen(_saveToken);
    FirebaseMessaging.onMessage.listen((message) {
      // Foreground messages are surfaced by the OS on mobile when configured.
    });
  }

  Future<void> _saveToken(String token) async {
    final user = _ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    if (user.fcmTokens.contains(token)) return;

    final updated = user.copyWith(
      fcmTokens: [...user.fcmTokens, token],
    );
    await _ref.read(authRepositoryProvider).updateUser(updated);
  }

  Future<void> clearToken() async {
    final user = _ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    final token = await _messaging.getToken();
    if (token == null) return;

    final updated = user.copyWith(
      fcmTokens: user.fcmTokens.where((t) => t != token).toList(),
    );
    await _ref.read(authRepositoryProvider).updateUser(updated);
    await _messaging.deleteToken();
  }
}
