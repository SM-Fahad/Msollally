import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger_barta/logger_barta.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/student/ai_chat/model/student_ai_chat_message_model.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/service/fursa_service.dart';
import 'package:msollaally/feature/student/create_task/model/student_create_task_list_model.dart';
import 'package:msollaally/feature/student/create_task/service/student_task_service.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class StudentAIChatController extends GetxController {
  // ── Observables ──────────────────────────────────────────────────────────
  var userName = 'User'.obs;
  RxBool showFirst = true.obs;
  RxBool isLoading = false.obs;
  RxBool isConnected = false.obs;
  RxList<StudentAiChatMessageModel> messages =
      <StudentAiChatMessageModel>[].obs;
  Rx<File?> selectedAudio = Rx<File?>(null);
  RxList<File> selectedFiles = <File>[].obs;
  RxString threadId = ''.obs;

  TextEditingController studentAiChatTextFieldButtonController =
      TextEditingController();

  // ── Socket ────────────────────────────────────────────────────────────────
  socket_io.Socket? _socket;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadUserName();
    _initSocket();
  }

  @override
  void onClose() {
    _disconnectSocket();
    studentAiChatTextFieldButtonController.dispose();
    super.onClose();
  }

  // ── User Name ─────────────────────────────────────────────────────────────
  Future<void> _loadUserName() async {
    if (Get.isRegistered<StudentProfileController>()) {
      final profileCtrl = Get.find<StudentProfileController>();
      if (profileCtrl.displayName.value.isNotEmpty) {
        userName.value = profileCtrl.displayName.value.split(' ').first;
        return;
      }
    }
    try {
      final savedName = await SharedPreferenceHelper().getSavedUserName();
      if (savedName != null && savedName.isNotEmpty) {
        userName.value = savedName.split(' ').first;
      }
    } catch (_) {}
  }

  // ── Socket: Init ──────────────────────────────────────────────────────────
  Future<void> _initSocket() async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();

      _socket = socket_io.io(
        Urls.aiChatSocketUrl, // https://api.nodmac.com/ai-chat
        socket_io.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': 'Bearer $token'})
            .disableAutoConnect()
            .build(),
      );

      _registerSocketListeners();
      _socket!.connect();
    } catch (e) {
      BartaLog.error('Socket init error', error: e);
    }
  }

  void _registerSocketListeners() {
    // ── Native connect (TCP handshake + namespace join done) ─────────────
    _socket!.onConnect((_) {
      BartaLog.socketOn(event: 'connect', data: 'Socket connected (native)');
      isConnected.value = true;
    });

    // ── Native connect_error (network / CORS / TLS failures) ─────────────
    _socket!.onConnectError((data) {
      BartaLog.socketOn(event: 'connect_error', data: data);
      isConnected.value = false;
      isLoading.value = false;
    });

    // ── App-level connection_success (auth OK from server) ────────────────
    _socket!.on('connection_success', (data) {
      BartaLog.socketOn(event: 'connection_success', data: data);
      isConnected.value = true;
    });

    // ── AI started processing ─────────────────────────────────────────────
    _socket!.on('aiChatStatus', (data) {
      BartaLog.socketOn(event: 'aiChatStatus', data: data);
      // isLoading stays true — UI already shows "AI is thinking…"
    });

    // ── Final AI answer ───────────────────────────────────────────────────
    _socket!.on('aiChatResponse', (data) {
      BartaLog.socketOn(event: 'aiChatResponse', data: data);
      isLoading.value = false;

      try {
        final responseData = data['data'];
        final String answer = responseData['response']?.toString() ??
            'I couldn\'t understand that.';
        final String newThreadId =
            responseData['thread_id']?.toString() ?? '';

        if (newThreadId.isNotEmpty) threadId.value = newThreadId;

        messages.add(
          StudentAiChatMessageModel(
            message: answer,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _tryCompleteCampusTask();
      } catch (e) {
        BartaLog.error('aiChatResponse parse error', error: e);
      }
    });

    // ── Server-side AI/subscription error ────────────────────────────────
    _socket!.on('aiChatError', (data) {
      BartaLog.socketOn(event: 'aiChatError', data: data);
      isLoading.value = false;

      final String code = data['code']?.toString() ?? '';
      final int? statusCode = data['statusCode'] is int
          ? data['statusCode'] as int
          : int.tryParse(data['statusCode']?.toString() ?? '');
      final String msg =
          data['message']?.toString() ?? 'An error occurred.';

      final bool isForbidden = code == 'SUBSCRIPTION_REQUIRED' ||
          code == 'FEATURE_NOT_INCLUDED' ||
          statusCode == 403 ||
          (data['error']?.toString().toLowerCase() == 'forbidden');

      if (isForbidden) {
        _showPremiumDialog(msg);
      } else {
        Get.snackbar('AI Error', msg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
    });

    // ── Auth / handshake error from server ────────────────────────────────
    _socket!.on('connection_error', (data) {
      BartaLog.socketOn(event: 'connection_error', data: data);
      isConnected.value = false;
      isLoading.value = false;
      final String msg =
          data['message']?.toString() ?? 'Connection failed.';
      Get.snackbar('Connection Error', msg,
          snackPosition: SnackPosition.BOTTOM);
    });

    // ── Disconnect ────────────────────────────────────────────────────────
    _socket!.onDisconnect((reason) {
      BartaLog.socketOn(event: 'disconnect', data: reason);
      isConnected.value = false;
    });

    // ── Catch-all: log any event not explicitly handled ────────────────────
    _socket!.onAny((event, data) {
      BartaLog.debug('[Socket ANY] event="$event" data=$data',
          tag: 'SocketAny');
    });
  }

  void _disconnectSocket() {
    _socket?.disconnect();
    _socket?.dispose();
  }

  // ── Premium Dialog ────────────────────────────────────────────────────────
  void _showPremiumDialog([String? reason]) {
    Get.dialog(
      _PremiumUpgradeDialog(reason: reason),
      barrierDismissible: false,
    );
  }

  // ── Chat Actions ──────────────────────────────────────────────────────────
  void clickToTextFieldToChangeMsg() {
    showFirst.value = false;
  }

  void resetChat() {
    messages.clear();
    threadId.value = '';
    showFirst.value = true;
  }

  Future<void> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );
      if (result != null) {
        selectedFiles.addAll(result.paths.map((path) => File(path!)));
        Get.snackbar('Files Added', '${result.files.length} files selected');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not pick files');
    }
  }

  Future<void> pickAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'flac', 'm4a', 'mp3', 'mp4', 'mpeg', 'mpga', 'oga', 'ogg', 'wav', 'webm',
        ],
      );
      if (result != null) {
        selectedAudio.value = File(result.files.single.path!);
        if (studentAiChatTextFieldButtonController.text.isEmpty) {
          studentAiChatTextFieldButtonController.text = 'Audio message';
        }
        await sendMessage();
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not pick audio file');
    }
  }

  Future<void> sendMessage() async {
    final text = studentAiChatTextFieldButtonController.text.trim();
    if (text.isEmpty &&
        selectedAudio.value == null &&
        selectedFiles.isEmpty) {
      return;
    }

    // Add user message bubble immediately
    messages.add(
      StudentAiChatMessageModel(
        message: text.isEmpty
            ? (selectedAudio.value != null ? '🎤 Audio' : '📁 Files')
            : text,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    studentAiChatTextFieldButtonController.clear();
    clickToTextFieldToChangeMsg();
    isLoading.value = true;

    // Reconnect if socket dropped between sends
    if (_socket == null || !_socket!.connected) {
      BartaLog.debug('Socket not connected — reconnecting…', tag: 'Socket');
      _socket?.connect();
      // Give the handshake a moment before emitting
      await Future.delayed(const Duration(milliseconds: 800));
    }

    String promptToSend = text;
    final lower = text.toLowerCase();
    if (lower.contains('task') ||
        lower.contains('todo') ||
        lower.contains('to-do') ||
        (lower.contains('today') && lower.contains('what'))) {
      final taskCtx = await _buildTasksContext();
      if (taskCtx.isNotEmpty) {
        promptToSend = "$text\n\n[Context for AI Assistant: $taskCtx]";
      }
    }

    // Emit via socket
    final payload = {'message': promptToSend};
    BartaLog.socketEmit(event: 'aiChat', data: payload);
    _socket?.emit('aiChat', payload);

    // Clear attachments (file/audio not yet supported over socket)
    selectedAudio.value = null;
    selectedFiles.clear();
  }

  Future<String> _buildTasksContext() async {
    try {
      final raw = await StudentTaskService.getAllTasks();
      if (raw.isEmpty) {
        return "The student currently has no personal tasks recorded in the app.";
      }
      final items = raw.map(StudentCreateTaskListModel.fromJson).toList();
      final buf = StringBuffer("Student's current tasks list:\n");
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final status = item.isTapCheckBox.value ? 'Completed' : 'Pending';
        buf.writeln(
          "- Task ${i + 1}: \"${item.title}\" | Scheduled/Due: ${item.date} | Status: $status${item.note.isNotEmpty ? ' | Note: ${item.note}' : ''}",
        );
      }
      return buf.toString();
    } catch (e) {
      debugPrint('Error building tasks context: $e');
      return "";
    }
  }

  // ── Campus task helper ────────────────────────────────────────────────────
  void _tryCompleteCampusTask() {
    try {
      if (Get.isRegistered<StudentCampusController>()) {
        final campusCtrl = Get.find<StudentCampusController>();
        final userMsgCount = messages.where((m) => m.isUser).length;
        if (userMsgCount == 3) {
          final compId = campusCtrl.competitionsList.isNotEmpty
              ? campusCtrl.competitionsList.first.id
              : 2;
          Get.put(FursaService());
          Get.find<FursaService>()
              .recordLearningProgress(
                competitionId: compId,
                activityType: 'QNA_CHAT',
                timeSpent: 180,
              )
              .then((success) {
            if (success) {
              campusCtrl.completeTask('chat_task', null);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error completing chat task: $e');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Upgrade Dialog
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumUpgradeDialog extends StatelessWidget {
  final String? reason;
  const _PremiumUpgradeDialog({this.reason});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
              blurRadius: 40,
              spreadRadius: -5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // ── Decorative glow circles ───────────────────────────
              Positioned(
                top: -60,
                right: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7C3AED).withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFEC4899).withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Crown icon
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '👑',
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Upgrade to Premium',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Sub-message
                    Text(
                      reason?.isNotEmpty == true
                          ? reason!
                          : 'AI Chat is a premium feature. Unlock unlimited AI conversations with a premium plan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Feature pills
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _FeaturePill(icon: '🤖', label: 'Unlimited AI Chat'),
                        _FeaturePill(icon: '⚡', label: 'Faster Responses'),
                        _FeaturePill(icon: '📚', label: 'All Features'),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Upgrade CTA
                    GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoute.studentupgrade);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withValues(alpha: 0.45),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '✨  Upgrade Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dismiss
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Maybe later',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.45),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
