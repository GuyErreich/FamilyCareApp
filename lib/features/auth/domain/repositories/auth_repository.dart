import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/features/auth/domain/entities/app_user.dart';

/// Contract for authentication and user profile operations.
abstract interface class AuthRepository {
  Stream<AppUser?> watchAuthState();

  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Result<AppUser>> signInWithGoogle();

  Future<Result<void>> signOut();

  Future<Result<AppUser>> getCurrentUser();

  Future<Result<AppUser>> updateUser(AppUser user);
}
