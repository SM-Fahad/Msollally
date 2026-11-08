import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/feature/student/profile/model/student_profile_about_model.dart';
import 'package:msollaally/feature/student/profile/model/student_profile_friends_model.dart';
import 'package:msollaally/feature/student/profile/model/student_profile_post_model.dart';
import 'package:msollaally/feature/student/career/gigs/model/gigs_model.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:msollaally/feature/student/campus/campus_home/service/campus_service.dart';
import '../model/student_profile_comment_model.dart';
import '../service/profile_service.dart';
import '../service/friendship_service.dart';

class StudentProfileController extends GetxController {
  final _profileService = Get.put(ProfileService());
  final _campusService = Get.put(CampusService());
  final _friendshipService = Get.put(FriendshipService());
  final _networkCaller = NetworkCaller();
  final _prefs = SharedPreferenceHelper();
  final _picker = ImagePicker();

  final profileImage = Rx<File?>(null);
  final coverImage = Rx<File?>(null);
  final profileImageUrl = ''.obs;
  final coverImageUrl = ''.obs;

  final displayName = ''.obs;
  final username = ''.obs;
  final phoneNumber = ''.obs;
  final bioText = ''.obs;
  final friendsCount = 0.obs;
  final userId = 0.obs;
  final profileId = 0.obs;

  final isLoadingProfile = true.obs;
  final isLoadingEdit = false.obs;
  final selectedTab = 0.obs;
  final tabs = ["About", "Posts", "Friends", "Gigs"];

  // Friendship sub-tabs
  final friendTabs = ["Friends", "Pending", "Suggestions"];
  final selectedFriendTab = 0.obs;

  final aboutItem = <StudentProfileAboutModel>[].obs;
  final comments = <StudentCommentModel>[].obs;
  final posts = <StudentProfilePostModel>[].obs;

  final friends = <StudentProfileFriendsModel>[].obs;
  final pendingRequests = <StudentProfileFriendsModel>[].obs;
  final friendSuggestions = <StudentProfileFriendsModel>[].obs;
  final isLoadingFriends = false.obs;

  final gigs = <GigsModel>[].obs;
  final isLoadingGigs = false.obs;

  final comentController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _initAboutItems();
    loadProfile();
    fetchFriendsData();
    fetchGigs();
  }

  /// Pull-to-refresh: re-fetches profile, friends, and gigs concurrently.
  Future<void> refreshAll() async {
    await Future.wait([loadProfile(), fetchFriendsData(), fetchGigs()]);
  }

  void _initAboutItems() {
    aboutItem.assignAll([
      StudentProfileAboutModel(
        title: 'Name',
        titleValue: '',
        ontap: () => editName(displayName.value),
      ),
      StudentProfileAboutModel(
        title: 'Institution',
        titleValue: '',
        ontap: () => editInstitution(_getAboutValue('Institution')),
      ),
      StudentProfileAboutModel(
        title: 'Faculty',
        titleValue: '',
        ontap: () => editFaculty(_getAboutValue('Faculty')),
      ),
      StudentProfileAboutModel(
        title: 'Student ID',
        titleValue: '',
        ontap: () => editStudentId(_getAboutValue('Student ID')),
      ),
      StudentProfileAboutModel(
        title: 'Email',
        titleValue: '',
        ontap: () => editEmail(_getAboutValue('Email')),
      ),
      StudentProfileAboutModel(
        title: 'Cell',
        titleValue: '',
        ontap: () => editCell(phoneNumber.value),
      ),
      StudentProfileAboutModel(
        title: 'Bio',
        titleValue: '',
        ontap: () => editBio(bioText.value),
      ),
    ]);
  }

  String _getAboutValue(String title) =>
      aboutItem.firstWhereOrNull((e) => e.title == title)?.titleValue ?? '';

  Future<void> pickImage(bool isProfile) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 512.height,
        maxWidth: 512.width,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final uploadedUrl = await _profileService.uploadProfileFile(file: file);
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          if (isProfile) {
            profileImage.value = file;
            profileImageUrl.value = uploadedUrl;
            await _profileService.updateProfile(profilePicture: uploadedUrl);
          } else {
            coverImage.value = file;
            coverImageUrl.value = uploadedUrl;
            await _profileService.updateProfile(coverPhoto: uploadedUrl);
          }
        }
      }
    } catch (e) {
      EasyLoading.showError('Failed to pick image');
    }
  }

  Future<void> loadProfile() async {
    isLoadingProfile.value = true;
    try {
      final data = await _profileService.fetchMe();
      if (data == null) return;

      userId.value = data['id'] is int
          ? data['id']
          : int.tryParse('${data['id']}') ?? 0;
      final profileData = data['profile'] as Map<String, dynamic>? ?? {};
      profileId.value = profileData['id'] is int
          ? profileData['id']
          : int.tryParse('${profileData['id']}') ?? 0;

      username.value = data['username']?.toString() ?? '';
      phoneNumber.value = data['phoneNumber']?.toString() ?? '';
      friendsCount.value = (data['friends'] as List?)?.length ?? 0;

      displayName.value =
          (profileData['fullName']?.toString().isNotEmpty == true)
          ? profileData['fullName']
          : username.value;
      bioText.value = profileData['bio']?.toString() ?? '';
      profileImageUrl.value = profileData['profilePicture']?.toString() ?? '';
      coverImageUrl.value = profileData['coverPhoto']?.toString() ?? '';

      final rawPosts = profileData['posts'] ?? data['posts'];
      if (rawPosts is List) {
        posts.assignAll(
          rawPosts.whereType<Map<String, dynamic>>().map((json) {
            final isLikedByMe = json['isLikedByMe'] ?? false;

            final postWithAuthor = Map<String, dynamic>.from(json);
            if (postWithAuthor['author'] == null &&
                postWithAuthor['user'] == null) {
              postWithAuthor['author'] = {
                'fullName': displayName.value,
                'username': username.value,
                'profilePicture': profileImageUrl.value,
              };
            }
            final p = StudentProfilePostModel.fromJson(postWithAuthor);
            return p.copyWith(isLiked: isLikedByMe);
          }).toList(),
        );
        posts.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
      }

      final friendsList = data['friends'];
      if (friendsList is List) _setFriendsFromApi(friendsList);

      _updateAboutItem('Name', displayName.value);
      _updateAboutItem('Institution', profileData['program']);
      _updateAboutItem('Faculty', profileData['faculty']);
      _updateAboutItem('Student ID', profileData['studentID']);
      _updateAboutItem('Email', profileData['email']);
      _updateAboutItem('Cell', phoneNumber.value);
      _updateAboutItem('Bio', bioText.value);
    } finally {
      isLoadingProfile.value = false;
    }
  }

  void _updateAboutItem(String title, dynamic value) {
    if (value == null) return;
    final index = aboutItem.indexWhere((e) => e.title == title);
    if (index != -1) {
      aboutItem[index] = aboutItem[index].copyWith(
        titleValue: value.toString(),
      );
    }
  }

  Future<void> toggleLike(StudentProfilePostModel post) async {
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index == -1) return;

    final original = posts[index];
    posts[index] = original.copyWith(
      likeCount: original.isLiked
          ? (original.likeCount > 0 ? original.likeCount - 1 : 0)
          : original.likeCount + 1,
      isLiked: !original.isLiked,
    );

    try {
      final success = original.isLiked
          ? await _campusService.unlikePost(post.id)
          : await _campusService.likePost(post.id);
      if (!success) {
        posts[index] = original;
        EasyLoading.showInfo(
          original.isLiked ? 'Not unliked' : 'Already liked',
        );
      }
    } catch (e) {
      posts[index] = original;
      EasyLoading.showError('Network error');
    }
  }

  Future<void> fetchFriendsData() async {
    isLoadingFriends.value = true;
    final fList = await _friendshipService.getFriends();
    final pList = await _friendshipService.getPendingRequests();
    final sList = await _friendshipService.getSuggestions();

    friends.assignAll(_mapToFriendsModel(fList));
    pendingRequests.assignAll(_mapToFriendsModel(pList));
    friendSuggestions.assignAll(_mapToFriendsModel(sList));

    friendsCount.value = friends.length;
    isLoadingFriends.value = false;
  }

  List<StudentProfileFriendsModel> _mapToFriendsModel(List<dynamic> data) {
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
        mutualNumber: item['mutualCount'] ?? item['mutuals'] ?? 0,
        uvName:
            (user['institution'] ??
                    user['university'] ??
                    user['program'] ??
                    'N/A')
                .toString(),
      );
    }).toList();
  }

  Future<void> acceptFriendRequest(int requesterId) async {
    final success = await _friendshipService.acceptRequest(requesterId);
    if (success) {
      fetchFriendsData();
    }
  }

  Future<void> rejectFriendRequest(int requesterId) async {
    final success = await _friendshipService.rejectRequest(requesterId);
    if (success) {
      fetchFriendsData();
    }
  }

  Future<void> sendFriendRequest(int receiverId) async {
    final success = await _friendshipService.sendRequest(receiverId);
    if (success) {
      fetchFriendsData();
    }
  }

  Future<void> removeFriend(int friendId) async {
    final success = await _friendshipService.removeFriend(friendId);
    if (success) {
      fetchFriendsData();
    }
  }

  Future<void> fetchGigs() async {
    isLoadingGigs.value = true;
    try {
      final token = await _prefs.getAccessToken();
      final result = await _networkCaller.getRequest(
        Urls.getAllGigs,
        token: 'Bearer $token',
      );
      if (result.isSuccess) {
        final List<dynamic> data =
            result.responseData['data'] as List<dynamic>? ?? [];
        final allGigs = data
            .map((e) => GigsModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Filter gigs for the current user if possible,
        // or just show all if it's a general profile view.
        // For 'My Profile', we filter by current user ID.
        if (userId.value != 0) {
          gigs.assignAll(
            allGigs.where((g) => g.author?.id == userId.value).toList(),
          );
        } else {
          gigs.assignAll(allGigs);
        }
      }
    } catch (e) {
      // Error handled by UI
    } finally {
      isLoadingGigs.value = false;
    }
  }

  void _setFriendsFromApi(List<dynamic> data) {
    // Initial fetch from me endpoint, can be overridden by fetchFriendsData
    friends.assignAll(_mapToFriendsModel(data));
  }

  void editName(String val) async =>
      _handleEdit(AppRoute.studentProfileEditNameViewPage, {
        "firstName": val.split(" ").first,
        "lastName": val.split(" ").length > 1
            ? val.split(" ").sublist(1).join(" ")
            : "",
      }, "Name");
  void editEmail(String val) async => _handleEdit(
    AppRoute.studentProfileEditEmailViewPage,
    {"email": val},
    "Email",
  );
  void editInstitution(String val) async => _handleEdit(
    AppRoute.studentProfileEditInstitutionViewPage,
    {"institution": val},
    "Institution",
  );
  void editStudentId(String val) async => _handleEdit(
    AppRoute.studentProfileEditStudentIdViewPage,
    {"studentId": val},
    "Student ID",
  );
  void editBio(String val) async =>
      _handleEdit(AppRoute.studentProfileEditBioViewPage, {"bio": val}, "Bio");
  void editFaculty(String val) async => _handleEdit(
    AppRoute.studentProfileEditFacultyViewPage,
    {"faculty": val},
    "Faculty",
  );
  void editCell(String val) async => _handleEdit(
    AppRoute.studentProfileEditCellViewPage,
    {"cell": val},
    "Cell",
  );

  void _handleEdit(
    String route,
    Map<String, dynamic> args,
    String title,
  ) async {
    final result = await Get.toNamed(route, arguments: args);
    if (result != null) loadProfile();
  }

  void sendComment(String text) {
    if (text.trim().isEmpty) return;
    comments.add(
      StudentCommentModel(
        imageUrl: "",
        name: "Jenny Wilson",
        comment: text.trim(),
        time: 1,
        isLiked: true,
      ),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void onClose() {
    comentController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
