import 'package:logger_barta/logger_barta.dart';

class AppLoggerHelper {
  AppLoggerHelper._();

  static void debug(String message) {
    BartaLog.debug(message);
  }

  static void info(String message) {
    BartaLog.success(message);
  }

  static void warning(String message) {
    BartaLog.debug(message, tag: 'WARNING');
  }

  static void error(String message, [dynamic error]) {
    BartaLog.error(message, error: error, stackTrace: StackTrace.current);
  }
}
