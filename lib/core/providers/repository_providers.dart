import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_care_scheduler/core/providers/google_sign_in_provider.dart';
import 'package:family_care_scheduler/features/auth/data/datasources/firestore_data_source.dart';
import 'package:family_care_scheduler/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:family_care_scheduler/features/auth/domain/repositories/auth_repository.dart';
import 'package:family_care_scheduler/features/family/data/repositories/family_repository_impl.dart';
import 'package:family_care_scheduler/features/family/domain/repositories/family_repository.dart';
import 'package:family_care_scheduler/features/shifts/data/repositories/shift_repository_impl.dart';
import 'package:family_care_scheduler/features/shifts/domain/repositories/shift_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firestoreDataSourceProvider = Provider<FirestoreDataSource>(
  (ref) => FirestoreDataSource(ref.watch(firestoreProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreDataSourceProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  ),
);

final familyRepositoryProvider = Provider<FamilyRepository>(
  (ref) => FamilyRepositoryImpl(ref.watch(firestoreDataSourceProvider)),
);

final shiftRepositoryProvider = Provider<ShiftRepository>(
  (ref) => ShiftRepositoryImpl(ref.watch(firestoreDataSourceProvider)),
);
