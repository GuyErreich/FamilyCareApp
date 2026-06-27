import 'package:family_care_scheduler/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Shared [GoogleSignIn] for Firebase auth and Google Calendar sync.
///
/// Calendar scope is requested just-in-time via [requestGoogleCalendarAccess].
final googleSignInProvider = Provider<GoogleSignIn>(
  (ref) => GoogleSignIn(
    serverClientId: AppConstants.googleWebClientId,
  ),
);
