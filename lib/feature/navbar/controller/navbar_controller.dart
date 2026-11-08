import 'package:get/get.dart';
import '../model/navbar_item.dart';

class NavbarController extends GetxController {
  final UserProfile userProfile;

  NavbarController({required this.userProfile});

  // Observable current index
  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  // Observable navbar items
  late final RxList<NavbarItem> _navbarItems;
  List<NavbarItem> get navbarItems => _navbarItems;

  @override
  void onInit() {
    super.onInit();
    _navbarItems = NavbarConfig.getNavbarItems(userProfile).obs;
  }

  void changeTab(int index) {
    if (index < 0 || index >= navbarItems.length) return;

    _currentIndex.value = index;
  }

  void updateNotificationCount(int itemIndex, String? count) {
    if (itemIndex < 0 || itemIndex >= navbarItems.length) return;

    final currentItem = navbarItems[itemIndex];
    final updatedItem = NavbarItem(
      label: currentItem.label,
      activeIcon: currentItem.activeIcon,
      inactiveIcon: currentItem.inactiveIcon,
      hasNotification: count != null,
      notificationCount: count,
      route: currentItem.route,
    );

    _navbarItems[itemIndex] = updatedItem;
  }

  void clearNotification(int itemIndex) {
    updateNotificationCount(itemIndex, null);
  }
}
