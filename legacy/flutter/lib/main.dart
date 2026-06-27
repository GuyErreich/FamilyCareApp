import 'package:family_care_scheduler/app.dart';
import 'package:family_care_scheduler/features/notifications/domain/fcm_service.dart';
import 'package:family_care_scheduler/features/notifications/domain/local_notification_service.dart';
import 'package:family_care_scheduler/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final container = ProviderContainer();
  await container.read(localNotificationServiceProvider).initialize();
  await container.read(fcmServiceProvider).initialize();
  container.dispose();

  runApp(
    const ProviderScope(
      child: FamilyCareApp(),
    ),
  );
}
