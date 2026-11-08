import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/teacher/more/session/model/teacher_session_model.dart';
import 'package:msollaally/feature/teacher/more/session/service/teacher_session_service.dart';

class TeacherSessionController extends GetxController {
  final TeacherSessionService _service = TeacherSessionService();

  final sessions = <TeacherSessionModel>[].obs;
  final isLoading = false.obs;
  final deletingSessionIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final result = await _service.fetchSessions();
      sessions.assignAll(result);
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  bool isDeletingSession(int sessionId) =>
      deletingSessionIds.contains(sessionId);

  Future<void> confirmDeleteSession(TeacherSessionModel session) async {
    if (session.isCurrentSession) {
      EasyLoading.showInfo('Current session cannot be removed here.');
      return;
    }

    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove session'),
        content: const Text(
          'This will sign out that device session. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await deleteSession(session.id);
    }
  }

  Future<void> deleteSession(int sessionId) async {
    if (deletingSessionIds.contains(sessionId)) {
      return;
    }

    deletingSessionIds.add(sessionId);
    deletingSessionIds.refresh();

    try {
      await _service.deleteSession(sessionId);
      sessions.removeWhere((session) => session.id == sessionId);
      EasyLoading.showSuccess('Session removed.');
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      deletingSessionIds.remove(sessionId);
      deletingSessionIds.refresh();
    }
  }

  String displayDevice(TeacherSessionModel session) {
    final agent = session.userAgent;
    if (agent.contains('Dart')) {
      return 'Mobile App';
    }

    String os = 'Desktop';
    if (agent.contains('Macintosh') || agent.contains('Mac OS X')) {
      os = 'Mac';
    } else if (agent.contains('Windows')) {
      os = 'Windows';
    } else if (agent.contains('Android')) {
      os = 'Android';
    } else if (agent.contains('iPhone') || agent.contains('iPad')) {
      os = 'iPhone';
    } else if (agent.contains('Linux')) {
      os = 'Linux';
    }

    String browser = 'Browser';
    if (agent.contains('Chrome')) {
      browser = 'Chrome';
    } else if (agent.contains('Safari') && !agent.contains('Chrome')) {
      browser = 'Safari';
    } else if (agent.contains('Firefox')) {
      browser = 'Firefox';
    } else if (agent.contains('Edge')) {
      browser = 'Edge';
    }

    return '$os • $browser';
  }

  IconData displayIcon(TeacherSessionModel session) {
    final agent = session.userAgent;
    if (agent.contains('Dart') ||
        agent.contains('Android') ||
        agent.contains('iPhone') ||
        agent.contains('iPad')) {
      return Icons.phone_iphone_rounded;
    }
    return Icons.laptop_mac_rounded;
  }

  String _extractErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
