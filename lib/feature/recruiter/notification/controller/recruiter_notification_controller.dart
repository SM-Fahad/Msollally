import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/notification/model/student_notification_model.dart';
import 'package:msollaally/feature/student/notification/service/student_notification_service.dart';

class RecruiterNotificationController extends GetxController {
  final List<_NotificationCategory> _categories = const [
    _NotificationCategory(label: 'All', apiValue: 'all'),
    _NotificationCategory(label: 'Academics', apiValue: 'academics'),
    _NotificationCategory(label: 'Community', apiValue: 'community'),
    _NotificationCategory(label: 'Career', apiValue: 'career'),
    _NotificationCategory(label: 'System', apiValue: 'system'),
  ];

  List<String> get categoryLabels =>
      _categories.map((category) => category.label).toList();

  final RxList<StudentNotificationModel> notifications =
      <StudentNotificationModel>[].obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isMarkingAllRead = false.obs;
  final RxnString errorMessage = RxnString();
  final RxInt unreadCount = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  static const int _pageSize = 20;

  String get selectedCategory => _categories[selectedCategoryIndex.value].apiValue;
  bool get hasMorePages => currentPage.value < totalPages.value;

  @override
  void onInit() {
    super.onInit();
    fetchUnreadCount();
  }

  Future<void> fetchUnreadCount() async {
    try {
      unreadCount.value = await StudentNotificationService.fetchUnreadCount();
    } catch (_) {
      // Keep the last known count when the badge request fails.
    }
  }

  void selectCategory(int index) {
    if (index == selectedCategoryIndex.value) {
      return;
    }
    selectedCategoryIndex.value = index;
    fetchNotifications();
  }

  void updateNotificationInList(StudentNotificationModel updated) {
    final index = notifications.indexWhere((item) => item.id == updated.id);
    if (index == -1) {
      return;
    }

    final previous = notifications[index];
    notifications[index] = updated;

    if (!previous.isRead && updated.isRead) {
      unreadCount.value = unreadCount.value > 0 ? unreadCount.value - 1 : 0;
    }
  }

  Future<void> fetchNotifications({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingMore.value || !hasMorePages) {
        return;
      }
      isLoadingMore.value = true;
      errorMessage.value = null;
    } else {
      isLoading.value = true;
      errorMessage.value = null;
      currentPage.value = 1;
      totalPages.value = 1;
    }

    try {
      final response = await StudentNotificationService.fetchNotifications(
        category: selectedCategory,
        page: loadMore ? currentPage.value + 1 : 1,
        limit: _pageSize,
      );

      currentPage.value = response.page;
      totalPages.value = response.totalPages;

      if (loadMore) {
        notifications.addAll(response.notifications);
      } else {
        notifications.assignAll(response.notifications);
      }

      await fetchUnreadCount();
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
      if (!loadMore) {
        notifications.clear();
      }
    } finally {
      if (loadMore) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }

  Future<void> loadMoreNotifications() async {
    await fetchNotifications(loadMore: true);
  }

  void _removeNotificationFromList(int id) {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    final removed = notifications.removeAt(index);
    if (!removed.isRead) {
      unreadCount.value = unreadCount.value > 0 ? unreadCount.value - 1 : 0;
    }
  }

  Future<bool> deleteNotification(int id) async {
    try {
      await StudentNotificationService.deleteNotification(id);
      _removeNotificationFromList(id);
      await fetchUnreadCount();
      EasyLoading.showSuccess('Notification deleted');
      return true;
    } catch (error) {
      EasyLoading.showError(error.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> archiveNotification(int id) async {
    try {
      await StudentNotificationService.archiveNotification(id);
      _removeNotificationFromList(id);
      await fetchUnreadCount();
      EasyLoading.showSuccess('Notification archived');
      return true;
    } catch (error) {
      EasyLoading.showError(error.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<void> markAllRead() async {
    if (isMarkingAllRead.value) {
      return;
    }

    try {
      isMarkingAllRead.value = true;

      notifications.assignAll(
        notifications.map((item) => item.copyWith(isRead: true)).toList(),
      );
      unreadCount.value = 0;

      await StudentNotificationService.markAllAsRead();
      await fetchUnreadCount();
      EasyLoading.showSuccess('All notifications marked as read');
    } catch (error) {
      EasyLoading.showError(error.toString().replaceFirst('Exception: ', ''));
      await fetchNotifications();
    } finally {
      isMarkingAllRead.value = false;
    }
  }
}

class _NotificationCategory {
  final String label;
  final String apiValue;

  const _NotificationCategory({required this.label, required this.apiValue});
}
