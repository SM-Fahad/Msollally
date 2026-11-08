import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/feature/student/campus/campus_home/service/campus_service.dart';
import 'package:msollaally/feature/student/profile/model/student_profile_friends_model.dart';
import 'package:msollaally/feature/student/profile/service/friendship_service.dart';

class InviteFriendsController extends GetxController {
  final int unionId;
  InviteFriendsController({required this.unionId});

  final _friendshipService = FriendshipService();
  final _campusService = CampusService();

  final allFriends = <StudentProfileFriendsModel>[].obs;
  final filtered = <StudentProfileFriendsModel>[].obs;
  final selected = <int>{}.obs;
  final isLoading = true.obs;
  final isSending = false.obs;
  final query = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFriends();
  }

  Future<void> loadFriends() async {
    isLoading.value = true;
    final raw = await _friendshipService.getFriends();
    final friends = _mapToModel(raw as List<dynamic>);
    allFriends.assignAll(friends);
    filtered.assignAll(friends);
    isLoading.value = false;
  }

  List<StudentProfileFriendsModel> _mapToModel(List<dynamic> data) {
    return data.whereType<Map<String, dynamic>>().map((item) {
      final user =
          item['requester'] ??
          item['receiver'] ??
          item['friend'] ??
          item['user'] ??
          item;
      return StudentProfileFriendsModel(
        id: user['id'] is int ? user['id'] : int.tryParse('${user['id']}') ?? 0,
        name:
            (user['fullName'] ?? user['name'] ?? user['username'] ?? 'Unknown')
                .toString(),
        imageUrl:
            (user['profilePicture'] ?? user['avatar'] ?? ImagesPath.onboarding1)
                .toString(),
        mutualNumber: item['mutualCount'] ?? 0,
        uvName:
            (user['institution'] ?? user['university'] ?? user['program'] ?? '')
                .toString(),
      );
    }).toList();
  }

  void onSearch(String q) {
    query.value = q.toLowerCase();
    filtered.assignAll(
      allFriends
          .where((f) => f.name.toLowerCase().contains(query.value))
          .toList(),
    );
  }

  void toggleSelect(int id) {
    selected.contains(id) ? selected.remove(id) : selected.add(id);
  }

  void selectAll() {
    if (selected.length == filtered.length) {
      selected.clear();
    } else {
      selected.addAll(filtered.map((f) => f.id));
    }
  }

  Future<void> sendInvites() async {
    if (selected.isEmpty) {
      EasyLoading.showInfo('Select at least one friend');
      return;
    }
    isSending.value = true;
    EasyLoading.show(status: 'Sending invitations...');
    int success = 0;
    final List<String> errors = [];
    final nameById = {for (final f in allFriends) f.id: f.name};
    for (final userId in selected) {
      final errorMsg = await _campusService.inviteToUnion(unionId, userId);
      if (errorMsg == null) {
        success++;
      } else {
        errors.add('${nameById[userId] ?? 'User $userId'}: $errorMsg');
      }
    }
    EasyLoading.dismiss();
    isSending.value = false;
    if (errors.isEmpty) {
      EasyLoading.showSuccess(
        'Invitation${success > 1 ? 's' : ''} sent to $success friend${success > 1 ? 's' : ''}!',
      );
      Get.back();
    } else {
      for (final msg in errors) {
        await EasyLoading.showError(msg, duration: const Duration(seconds: 3));
        await Future.delayed(const Duration(seconds: 3));
      }
      if (success > 0) {
        EasyLoading.showSuccess(
          '$success invitation${success > 1 ? 's' : ''} sent successfully',
        );
      }
    }
  }
}
