import 'package:get/get.dart';
import 'package:msollaally/feature/student/notification/model/student_notification_model.dart';
import 'package:msollaally/feature/student/notification/service/student_notification_service.dart';
import 'package:msollaally/feature/teacher/notification/controller/teacher_notification_controller.dart';

class TeacherNotificationDetailController extends GetxController {
  final Rxn<StudentNotificationModel> notification = Rxn<StudentNotificationModel>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  int? _notificationId;

  Future<void> prepareDetails(dynamic args) async {
    final id = _resolveNotificationId(args);
    if (id == null || id == 0) {
      errorMessage.value = 'Notification not found';
      return;
    }

    _notificationId = id;

    final seeded = _resolveSeededNotification(args);
    if (seeded != null) {
      notification.value = seeded;
    }

    await markAsReadIfNeeded();
    await fetchNotificationDetails();
  }

  Future<void> markAsReadIfNeeded() async {
    final id = _notificationId;
    if (id == null || id == 0) {
      return;
    }

    final current = notification.value;
    if (current != null && current.isRead) {
      return;
    }

    final optimistic = (current ?? StudentNotificationModel(
      id: id,
      type: '',
      category: 'all',
      priority: 'normal',
      title: '',
      message: '',
      isRead: false,
      isArchived: false,
    )).copyWith(isRead: true, readAt: DateTime.now());

    notification.value = optimistic;
    _syncListNotification(optimistic);

    try {
      await StudentNotificationService.markAsRead(id);
    } catch (_) {
      if (current != null && !current.isRead) {
        notification.value = current;
        _syncListNotification(current);
      }
    }
  }

  Future<void> fetchNotificationDetails() async {
    final id = _notificationId;
    if (id == null || id == 0 || isLoading.value) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response =
          await StudentNotificationService.fetchNotificationById(id);
      final previous = notification.value;
      notification.value = previous != null
          ? _mergeWithSeeded(previous, response)
          : response;
      _syncListNotification(notification.value!);
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
      if (notification.value == null) {
        errorMessage.value ??= 'Failed to load notification';
      }
    } finally {
      isLoading.value = false;
    }
  }

  StudentNotificationModel _mergeWithSeeded(
    StudentNotificationModel seeded,
    StudentNotificationModel fetched,
  ) {
    return fetched.copyWith(
      title: fetched.title.isNotEmpty ? fetched.title : seeded.title,
      message: fetched.message.isNotEmpty ? fetched.message : seeded.message,
      type: fetched.type.isNotEmpty ? fetched.type : seeded.type,
      category: fetched.category != 'all' ? fetched.category : seeded.category,
      imageUrl: fetched.imageUrl ?? seeded.imageUrl,
      actionUrl: fetched.actionUrl ?? seeded.actionUrl,
      data: fetched.data ?? seeded.data,
      createdAt: fetched.createdAt ?? seeded.createdAt,
      actor: fetched.actor ?? seeded.actor,
      isRead: seeded.isRead || fetched.isRead,
      readAt: seeded.readAt ?? fetched.readAt,
    );
  }

  void _syncListNotification(StudentNotificationModel updated) {
    if (!Get.isRegistered<TeacherNotificationController>()) {
      return;
    }

    Get.find<TeacherNotificationController>().updateNotificationInList(updated);
  }

  int? _resolveNotificationId(dynamic args) {
    if (args is int) {
      return args;
    }
    if (args is String) {
      return int.tryParse(args);
    }
    if (args is Map) {
      final dynamic id = args['id'] ?? args['notificationId'];
      if (id is int) {
        return id;
      }
      return int.tryParse(id?.toString() ?? '');
    }
    if (args is StudentNotificationModel) {
      return args.id;
    }
    return null;
  }

  StudentNotificationModel? _resolveSeededNotification(dynamic args) {
    if (args is StudentNotificationModel) {
      return args;
    }
    if (args is Map && args['notification'] is StudentNotificationModel) {
      return args['notification'] as StudentNotificationModel;
    }
    return null;
  }
}
