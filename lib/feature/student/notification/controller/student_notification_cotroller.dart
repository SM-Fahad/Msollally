import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msollaally/feature/student/notification/model/student_notification_model.dart';
import 'package:msollaally/feature/student/notification/service/student_notification_service.dart';

class NotificationController extends GetxController {
  final List<_NotificationCategory> _categories = const [
    _NotificationCategory(label: 'All', apiValue: 'all'),
    _NotificationCategory(label: 'Academics', apiValue: 'academics'),
    _NotificationCategory(label: 'Community', apiValue: 'community'),
    _NotificationCategory(label: 'Career', apiValue: 'career'),
    _NotificationCategory(label: 'System', apiValue: 'system'),
  ];

  List<String> get notificationItem =>
      _categories.map((category) => category.label).toList();

  final RxInt selectIndex = 0.obs;
  final RxList<StudentNotificationModel> notificationAll =
      <StudentNotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxnString errorMessage = RxnString();
  final RxInt unreadCount = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool isMarkingAllRead = false.obs;

  static const int _pageSize = 20;

  String get selectedCategory => _categories[selectIndex.value].apiValue;
  bool get hasMorePages => currentPage.value < totalPages.value;

  void selectNotification(int index) {
    if (index == selectIndex.value) {
      return;
    }
    selectIndex.value = index;
    fetchNotifications();
  }

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
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

      unreadCount.value = response.unreadCount;
      currentPage.value = response.page;
      totalPages.value = response.totalPages;

      if (loadMore) {
        notificationAll.addAll(response.notifications);
      } else {
        notificationAll.assignAll(response.notifications);
      }
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
      if (!loadMore) {
        notificationAll.clear();
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

  void updateNotificationInList(StudentNotificationModel updated) {
    final index = notificationAll.indexWhere((n) => n.id == updated.id);
    if (index != -1) {
      notificationAll[index] = updated;

      // Recalculate unread count from the local list
      unreadCount.value = notificationAll.where((n) => !n.isRead).length;
    }
  }

  Future<void> markAllRead() async {
    if (isMarkingAllRead.value) {
      return;
    }

    try {
      isMarkingAllRead.value = true;

      // Optimistically update the local list and unread count instantly
      final updatedList = notificationAll.map((item) {
        return item.copyWith(isRead: true);
      }).toList();
      notificationAll.assignAll(updatedList);
      unreadCount.value = 0;

      await StudentNotificationService.markAllAsRead();
      EasyLoading.showSuccess('All notifications marked as read');
    } catch (error) {
      EasyLoading.showError(error.toString().replaceFirst('Exception: ', ''));
      // Optional: Could revert the list here by re-fetching if it failed
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
