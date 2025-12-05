import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import '../data/notification_repository.dart';
import '../data/settings_repository.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Initialize settings
      await SettingsRepository.instance.loadSettings();
      
      // Initialize notification service
      await NotificationService.instance.initialize();
      
      // Check for updates
      await NotificationRepository.instance.checkUpdatesInBackground();
      
      return Future.value(true);
    } catch (e) {
      debugPrint('Background task error: $e');
      return Future.value(false);
    }
  });
}

class BackgroundService {
  static final BackgroundService instance = BackgroundService._();
  BackgroundService._();

  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    
    // Register periodic task (runs every 15 minutes minimum on Android/iOS)
    // Note: on iOS this uses Background App Refresh which is not guaranteed to run exactly every 15m
    await Workmanager().registerPeriodicTask(
      "quakeconnect_updates",
      "checkUpdates",
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }
}

