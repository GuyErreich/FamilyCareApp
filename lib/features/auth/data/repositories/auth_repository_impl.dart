import 'package:family_care_scheduler/core/errors/failures.dart';
import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/utils/invite_code_generator.dart';
import 'package:family_care_scheduler/features/auth/data/datasources/firestore_data_source.dart';
import 'package:family_care_scheduler/features/auth/data/dto/app_user_dto.dart';
import 'package:family_care_scheduler/features/auth/domain/entities/app_user.dart';
import 'package:family_care_scheduler/features/auth/domain/repositories/auth_repository.dart';
import 'package:family_care_scheduler/features/family/data/dto/family_dto.dart';
import 'package:family_care_scheduler/features/family/data/dto/family_member_dto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Auth and user profile repository.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._firebaseAuth,
    required this._firestore,
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final FirestoreDataSource _firestore;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<AppUser?> watchAuthState() {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _firestore.getUser(user.uid);
    });
  }

  @override
  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _loadOrCreateUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      return Error(AuthFailure(e.message ?? 'Sign in failed.'));
    } catch (e) {
      return Error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<AppUser>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(displayName);
      final user = AppUser(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );
      await _firestore.setUser(user.id, AppUserDtoX.fromDomain(user));
      return Success(user);
    } on FirebaseAuthException catch (e) {
      return Error(AuthFailure(e.message ?? 'Registration failed.'));
    } catch (e) {
      return Error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<AppUser>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Error(AuthFailure('Google sign in was cancelled.'));
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return _loadOrCreateUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return Error(AuthFailure(e.message ?? 'Google sign in failed.'));
    } catch (e) {
      return Error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return const Success(null);
    } catch (e) {
      return Error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<AppUser>> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return const Error(AuthFailure('Not signed in.'));
    }
    final user = await _firestore.getUser(firebaseUser.uid);
    if (user == null) {
      return const Error(AuthFailure('User profile not found.'));
    }
    return Success(user);
  }

  @override
  Future<Result<AppUser>> updateUser(AppUser user) async {
    try {
      await _firestore.setUser(user.id, AppUserDtoX.fromDomain(user));
      return Success(user);
    } catch (e) {
      return Error(DataFailure(e.toString()));
    }
  }

  Future<Result<AppUser>> _loadOrCreateUser(User firebaseUser) async {
    final existing = await _firestore.getUser(firebaseUser.uid);
    if (existing != null) return Success(existing);

    final user = AppUser(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      avatarUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
    );
    await _firestore.setUser(user.id, AppUserDtoX.fromDomain(user));
    return Success(user);
  }
}

/// Family repository using Firestore.
export 'package:family_care_scheduler/features/family/data/repositories/family_repository_impl.dart'
    show FamilyRepositoryImpl;
