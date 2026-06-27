import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/settings/domain/entities/family_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final familySettingsProvider = StreamProvider<FamilySettings?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  final familyId = user?.familyId;
  if (familyId == null) return const Stream.empty();
  return ref.watch(familySettingsRepositoryProvider).watchFamilySettings(familyId);
});
