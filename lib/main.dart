import 'package:flutter/material.dart';
import 'package:msollaally/core/services/firebase_messaging_service.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/msollaaly.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserRoleService.initAsync();
  try {
    await FirebaseMessagingService.initialize();
  } catch (error, stackTrace) {
    debugPrint('Firebase setup skipped: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
  runApp(const Msollaaly());
}
