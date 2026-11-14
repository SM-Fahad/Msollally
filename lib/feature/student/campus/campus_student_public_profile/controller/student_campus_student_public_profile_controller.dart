import 'package:get/get.dart';

import '../model/student_public_profile_about_model.dart';
import '../model/student_public_profile_friends_model.dart';
import 'package:msollaally/feature/student/career/gigs/model/gigs_model.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/post_model.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/student/campus/campus_home/service/campus_service.dart';
import 'package:share_plus/share_plus.dart';

class StudentPublicProfileController extends GetxController {
  //student profile about
  var userId = 0.obs;
  var isLoadingProfile = true.obs;

  var profileName = ''.obs;
  var profileBio = ''.obs;
  var profilePicture = ''.obs;
  var coverPhoto = ''.obs;
  var friendsCount = 0.obs;

  var selectedTab = 0.obs;
  final List<String> tabs = ["About", "Posts", "Friends", "Gigs"];

  final gigs = <GigsModel>[].obs;
  final isLoadingGigs = false.obs;

  final _networkCaller = NetworkCaller();
  final _prefs = SharedPreferenceHelper();
  final _campusService = CampusService();
  final RxList<StudentPublicProfileAboutModel> aboutItems =
      <StudentPublicProfileAboutModel>[].obs;

  // dynamic profile lists
  final posts = <PostModel>[].obs;
  final friends = <StudentPublicProfileFriendsModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is int) {
      userId.value = Get.arguments as int;
      fetchPublicProfile();
      fetchGigs();
    } else {
      isLoadingProfile.value = false;
    }
  }

  Future<void> fetchPublicProfile() async {
    isLoadingProfile.value = true;
    try {
      final token = await _prefs.getAccessToken();
      final result = await _networkCaller.getRequest(
        Urls.profilePublicById(userId.value.toString()),
        token: 'Bearer $token',
      );

      if (result.isSuccess && result.responseData != null) {
        final data = result.responseData; // It's directly the user object
        final profile = data['profile'] ?? {};
        final university = profile['university'] ?? {};

        profileName.value =
            profile['fullName'] ??
            data['fullName'] ??
            data['username'] ??
            'Unknown';
        profileBio.value = profile['bio'] ?? '';
        profilePicture.value =
            profile['profilePicture'] ??
            data['profilePicture'] ??
            data['avatar'] ??
            '';
        coverPhoto.value = profile['coverPhoto'] ?? '';
        friendsCount.value = data['friendsCount'] ?? 0;

        aboutItems.assignAll([
          StudentPublicProfileAboutModel(
            title: "Name",
            titleValue: profileName.value,
          ),
          StudentPublicProfileAboutModel(
            title: "Institution",
            titleValue:
                university['fullName'] ??
                university['name'] ??
                profile['institution'] ??
                data['institution'] ??
                'N/A',
          ),
          StudentPublicProfileAboutModel(
            title: "Faculty",
            titleValue: profile['faculty'] ?? 'N/A',
          ),
          // StudentPublicProfileAboutModel(
          //   title: "Student ID",
          //   titleValue: profile['studentID'] ?? 'N/A',
          // ),
          // StudentPublicProfileAboutModel(
          //   title: "Email",
          //   titleValue: profile['email'] ?? data['email'] ?? 'N/A',
          // ),
          // StudentPublicProfileAboutModel(
          //   title: "Cell",
          //   titleValue: profile['phoneNumber'] ?? data['phoneNumber'] ?? 'N/A',
          // ),
          StudentPublicProfileAboutModel(
            title: "Bio",
            titleValue: profileBio.value,
          ),
        ]);

        if (data['posts'] != null && data['posts'] is List) {
          final postList = (data['posts'] as List)
              .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
              .toList();
          posts.assignAll(postList);
        }

        if (userId.value > 0) {
          final userPostsRes = await _campusService.fetchUserPosts(
            userId.value,
          );
          if (userPostsRes.posts.isNotEmpty) {
            posts.assignAll(userPostsRes.posts);
          }
        }

        final rawFriends = data['friends'] ?? data['friendships'] ?? data['friendsList'];
        if (rawFriends != null && rawFriends is List && rawFriends.isNotEmpty) {
          final friendsList = rawFriends.map((item) {
            final fProfile = item['profile'] ?? (item['friend'] is Map ? item['friend']['profile'] : {}) ?? {};
            final fUniv = fProfile['university'] ?? {};
            final dynamic rawId = item['friendId'] ?? item['id'] ?? (item['friend'] is Map ? item['friend']['id'] : null) ?? item['userId'];
            final int? fId = rawId is int ? rawId : int.tryParse('$rawId');
            return StudentPublicProfileFriendsModel(
              id: fId,
              name: fProfile['fullName'] ?? item['username'] ?? item['name'] ?? (item['friend'] is Map ? item['friend']['username'] : null) ?? 'Unknown',
              imageUrl: fProfile['profilePicture'] ?? (item['friend'] is Map ? item['friend']['profilePicture'] : '') ?? '',
              mutualNumber: item['mutualCount'] ?? item['mutualFriendsCount'] ?? 0,
              uvName: fUniv['name'] ?? fUniv['fullName'] ?? 'N/A',
            );
          }).toList();
          friends.assignAll(friendsList);
        } else if (userId.value > 0) {
          try {
            final mutualRes = await _networkCaller.getRequest(
              Urls.mutualFriends(userId.value),
              token: 'Bearer $token',
            );
            if (mutualRes.isSuccess && mutualRes.responseData != null) {
              final rawList = mutualRes.responseData is List
                  ? mutualRes.responseData as List
                  : (mutualRes.responseData['data'] is List ? mutualRes.responseData['data'] as List : []);
              if (rawList.isNotEmpty) {
                final mutualFriendsList = rawList.map((item) {
                  final fProfile = item['profile'] ?? {};
                  final fUniv = fProfile['university'] ?? {};
                  final dynamic rawId = item['friendId'] ?? item['id'] ?? item['userId'];
                  final int? fId = rawId is int ? rawId : int.tryParse('$rawId');
                  return StudentPublicProfileFriendsModel(
                    id: fId,
                    name: fProfile['fullName'] ?? item['username'] ?? item['name'] ?? 'Unknown',
                    imageUrl: fProfile['profilePicture'] ?? '',
                    mutualNumber: item['mutualCount'] ?? 0,
                    uvName: fUniv['name'] ?? fUniv['fullName'] ?? 'N/A',
                  );
                }).toList();
                friends.assignAll(mutualFriendsList);
              }
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      Get.log("Error fetching public profile: $e");
    } finally {
      isLoadingProfile.value = false;
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
            .where((gig) => gig.author?.id == userId.value)
            .toList();

        gigs.assignAll(allGigs);
      }
    } finally {
      isLoadingGigs.value = false;
    }
  }

  Future<void> toggleLike(PostModel post) async {
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index == -1) return;

    final original = posts[index];
    final bool currentlyLiked = original.isLiked;

    posts[index] = original.copyWith(
      likeCount: currentlyLiked
          ? (original.likeCount > 0 ? original.likeCount - 1 : 0)
          : original.likeCount + 1,
      isLiked: !currentlyLiked,
    );

    try {
      final success = currentlyLiked
          ? await _campusService.unlikePost(post.id)
          : await _campusService.likePost(post.id);
      if (!success) {
        posts[index] = original;
      }
    } catch (_) {
      posts[index] = original;
    }
  }

  void sharePost(PostModel post) {
    final title = post.author.fullName.isNotEmpty
        ? post.author.fullName
        : post.author.username;
    final text = "Check out this post from $title:\n${post.content}";
    Share.share(text);
  }
}
