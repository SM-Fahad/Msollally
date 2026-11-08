import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'package:msollaally/feature/student/profile/service/profile_service.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/leaderboard_model.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/student_campus_friends_for_you_model.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/student_campus_fursa_zone_model.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/union_model.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/student_campus_wall_model.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/post_model.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/bonus_data_model.dart';
import 'package:msollaally/feature/student/campus/campus_home/service/campus_service.dart';
import 'package:msollaally/feature/student/campus/campus_home/service/fursa_service.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/dialog_boxes/controller/dialogbox_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/dialog_boxes/early_completion_dialog.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/quiz_question_model.dart';
import 'package:msollaally/core/services/websocket/social_socket_service.dart';
import 'package:msollaally/feature/student/profile/service/friendship_service.dart';
import 'package:msollaally/core/utils/feed_video_manager.dart';

class StudentCampusController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final postTextEditingController = TextEditingController();
  final selectedTab = 0.obs;
  final tabs = [
    "Wall",
    "Union",
    "Students",
    "Campaign",
    "Events",
    "Campus Inbox",
  ].obs;

  final selectStudentUnionTab = 0.obs;
  final studentUnionTabs = ["For you", "Your union", "Status"];
  final unionForYouList = <UnionModel>[].obs;
  final yourUnionList = <UnionModel>[].obs;
  final pendingUnionList = <UnionModel>[].obs;
  final isLoadingUnions = false.obs;
  final isUnionSearching = false.obs;
  final unionSearchQuery = ''.obs;
  final unionSearchController = TextEditingController();

  final selectStudentFriendsTab = 0.obs;
  final studentFriendsTab = ["For you", "Your Campus", "Requests"];
  final friendsForYouList = <StudentCampusFriendsForYouModel>[].obs;
  final yourCampusList = <StudentCampusFriendsForYouModel>[].obs;
  final requestsList = <StudentCampusFriendsForYouModel>[].obs;
  final requestedUserIds = <int>{}.obs;
  final isLoadingFriends = false.obs;
  final isLoadingMoreFriends = false.obs;
  final friendsPage = 1.obs;
  final hasMoreFriends = true.obs;

  // Student directory filters & search
  final isStudentSearching = false.obs;
  final studentSearchQuery = ''.obs;
  final studentSearchController = TextEditingController();
  final selectedUniversityFilter = 'All'.obs;
  final selectedProgramFilter = 'All'.obs;
  final selectedYearFilter = 'All'.obs;

  final statusList = <StudentCampusStatusModel>[].obs;
  final postsList = <PostModel>[].obs;
  var isLoadingPosts = false.obs;
  var isLoadingMorePosts = false.obs;
  var currentPage = 1.obs;
  var hasMorePosts = true.obs;
  var isBackgroundUploadingPost = false.obs;
  
  final isCreatingPost = false.obs;
  final selectedImagePath = ''.obs;

  final bonusData = <BonusDataModel>[].obs;
  final loginCheckedInToday = false.obs;

  // Track if learning phase qualification has been reached
  final showFinalComp = false.obs;

  final _campusService = CampusService();
  final _fursaService = FursaService();
  final _profileService = ProfileService();
  final _friendshipService = FriendshipService();
  final _picker = ImagePicker();

  late final SocialSocketService _socialSocketService;
  StreamSubscription? _postLikedSub;
  StreamSubscription? _postCommentedSub;
  StreamSubscription? _notificationSub;

  final isWeekly = true.obs;
  final selectLeaderboardTab = 0.obs;
  final thisWeekLeaderboardList = <StudentCampusLeaderboardModel>[].obs;
  final allTimeLeaderboardList = <StudentCampusLeaderboardModel>[].obs;

  List<StudentCampusLeaderboardModel> get currentList =>
      isWeekly.value ? thisWeekLeaderboardList : allTimeLeaderboardList;

  void showWeekly() => isWeekly.value = true;
  void showAllTime() => isWeekly.value = false;

  late TabController tabController;
  final myTabs = const <Tab>[
    Tab(text: 'Fursa zone'),
    Tab(text: 'Winners'),
    Tab(text: 'Leaderboard'),
  ];

  final fursaTasks = <FursaTask>[].obs;
  final competitionsList = <CompetitionModel>[].obs;
  final isLoadingFursaZone = true.obs;
  final fursaZoneBannerImage = ''.obs;
  final fursaZoneSponsorImage = ''.obs;

  final thisWeekWinnersList = <WinnerModel>[].obs;
  final lastWeekWinnersList = <WinnerModel>[].obs;
  final topSchoolsList = <TopSchoolModel>[].obs;
  final userRank = 6.obs;
  final pointsToQualify = 1000.obs;

  final quizCurrentQuestion = 0.obs;
  final quizSelectedAnswer = Rx<String?>(null);
  final quizAnsweredCount = 0.obs;
  final quizTimeRemaining = 0.obs;
  Timer? _quizTimer;
  final quizAnswers = <int, String>{}.obs;
  final quizQuestions = <QuizQuestionModel>[].obs;
  final isLoadingQuizQuestions = false.obs;
  final quizActiveType = 'QUALIFICATION'.obs;

  final taskCompleted = RxMap<String, bool>({});
  final bonusItemEarned = RxMap<String, bool>({});
  final loginStreakDays = 3.obs;
  final checkedInToday = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Listen for tab changes to load data lazily and pause active videos
    ever(selectedTab, (index) {
      FeedVideoManager.pauseAll();
      loadDataForTab(index);
    });

    if (Get.isRegistered<StudentProfileController>()) {
      ever(Get.find<StudentProfileController>().userId, (_) {
        if (selectedTab.value == 0) fetchPosts();
        if (selectedTab.value == 1) fetchUnions();
      });
    }

    tabController = TabController(vsync: this, length: myTabs.length);
    tabController.addListener(() => update());

    // Load initial tab data
    loadDataForTab(selectedTab.value);

    _initSocketService();
  }

  void loadDataForTab(int tabIndex, {bool forceRefresh = false}) {
    switch (tabIndex) {
      case 0: // Wall
        if (postsList.isEmpty || forceRefresh) fetchPosts();
        break;
      case 1: // Union
        if (unionForYouList.isEmpty || forceRefresh) fetchUnions();
        break;
      case 2: // Students
        if (friendsForYouList.isEmpty || forceRefresh) fetchFriendsData();
        break;
      case 3: // Campaign
        break;
      case 4: // Events
        break;
    }
  }

  void _initSocketService() {
    if (!Get.isRegistered<SocialSocketService>()) {
      Get.put(SocialSocketService());
    }
    _socialSocketService = Get.find<SocialSocketService>();
    _socialSocketService.init(); // Async init but we don't need to await here

    _postLikedSub = _socialSocketService.onPostLiked.stream.listen((data) {
      final postId = data['postId'];
      final likeCount = data['likeCount'];
      final likedByUserId = data['likedByUserId'];

      if (postId != null && likeCount != null) {
        final index = postsList.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final originalPost = postsList[index];
          bool isLiked = originalPost.isLiked;
          if (Get.isRegistered<StudentProfileController>()) {
            final myId = Get.find<StudentProfileController>().userId.value;
            if (likedByUserId == myId) {
              isLiked = true; // or leave it to toggleLike to manage local state
            }
          }

          postsList[index] = originalPost.copyWith(
            likeCount: likeCount,
            isLiked:
                isLiked, // Best to maintain local isLiked state unless we need strict server sync
          );
        }
      }
    });

    _postCommentedSub = _socialSocketService.onPostCommented.stream.listen((
      data,
    ) {
      final postId = data['post']?['id'] ?? data['postId'];
      if (postId != null) {
        final index = postsList.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final originalPost = postsList[index];
          postsList[index] = originalPost.copyWith(
            commentCount: originalPost.commentCount + 1,
          );
        }
      }
    });

    _notificationSub = _socialSocketService.onNotification.stream.listen((
      data,
    ) {
      if (data['type'] == 'POST_LIKED') {
        EasyLoading.showToast('Someone liked your post!');
      }
    });
  }

  Future<void> fetchFriendsData({bool refresh = false}) async {
    if (refresh) {
      friendsPage.value = 1;
      hasMoreFriends.value = true;
    }
    isLoadingFriends.value = true;
    try {
      final sList = await _friendshipService.getSuggestions(
        page: friendsPage.value,
        limit: 20,
      );
      final mapped = _mapToFriendsModel(sList);
      if (friendsPage.value == 1) {
        friendsForYouList.assignAll(mapped);
      } else {
        friendsForYouList.addAll(mapped);
      }
      if (mapped.length < 20) {
        hasMoreFriends.value = false;
      }

      if (Get.isRegistered<StudentProfileController>()) {
        final profileData = await _profileService.fetchMe();
        int universityId = 1; // Fallback
        if (profileData != null && profileData['profile'] != null) {
          universityId = profileData['profile']['universityId'] ?? 1;
        }

        final yourCampus = await _friendshipService.getFriendsByUniversity(
          universityId,
        );
        yourCampusList.assignAll(_mapToFriendsModel(yourCampus));
      }

      final pList = await _friendshipService.getPendingRequests();
      requestsList.assignAll(_mapToFriendsModel(pList));
    } catch (e) {
      debugPrint('Error fetching friends data: $e');
    } finally {
      isLoadingFriends.value = false;
    }
  }

  Future<void> fetchMoreFriends() async {
    if (isLoadingMoreFriends.value || !hasMoreFriends.value) return;
    isLoadingMoreFriends.value = true;
    friendsPage.value++;
    try {
      final sList = await _friendshipService.getSuggestions(
        page: friendsPage.value,
        limit: 20,
      );
      final mapped = _mapToFriendsModel(sList);
      if (mapped.isNotEmpty) {
        friendsForYouList.addAll(mapped);
      }
      if (mapped.length < 20) {
        hasMoreFriends.value = false;
      }
    } catch (e) {
      debugPrint('Error loading more friends: $e');
    } finally {
      isLoadingMoreFriends.value = false;
    }
  }

  List<StudentCampusFriendsForYouModel> _mapToFriendsModel(
    List<dynamic>? data,
  ) {
    if (data == null) return [];
    return data.whereType<Map<String, dynamic>>().map((item) {
      final user =
          item['requester'] ??
          item['receiver'] ??
          item['friend'] ??
          item['user'] ??
          item;
      final profile = user['profile'] ?? {};
      final universityObj = profile['university'] ?? user['university'] ?? {};

      final universityName =
          universityObj['name'] ??
          universityObj['fullName'] ??
          profile['institution'] ??
          user['institution'] ??
          profile['program'] ??
          user['program'] ??
          'N/A';

      final rawPic =
          profile['profilePicture'] ?? user['profilePicture'] ?? user['avatar'];
      final String picUrl = (rawPic != null && rawPic.toString().isNotEmpty)
          ? rawPic.toString()
          : ImagesPath.onboarding1;

      final program = (profile['program'] ?? profile['major'] ?? user['program'] ?? '').toString();
      final yearOfStudy = (profile['yearOfStudy'] ?? profile['year'] ?? user['yearOfStudy'] ?? '').toString();

      return StudentCampusFriendsForYouModel(
        id: user['id'] is int ? user['id'] : int.tryParse('${user['id']}') ?? 0,
        name:
            (profile['fullName'] ??
                    user['fullName'] ??
                    user['name'] ??
                    user['username'] ??
                    'Unknown')
                .toString(),
        imageUrl: picUrl,
        mutualNumber: item['mutualCount'] ?? item['mutuals'] ?? 0,
        uvName: universityName.toString(),
        program: program,
        yearOfStudy: yearOfStudy,
      );
    }).toList();
  }

  List<UnionModel> getFilteredUnions(List<UnionModel> list) {
    if (!isUnionSearching.value || unionSearchQuery.value.trim().isEmpty) {
      return list;
    }
    final q = unionSearchQuery.value.trim().toLowerCase();
    return list.where((u) {
      final name = u.name.toLowerCase();
      final desc = (u.description ?? '').toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();
  }

  List<StudentCampusFriendsForYouModel> getFilteredFriends(
      List<StudentCampusFriendsForYouModel> originalList) {
    return originalList.where((friend) {
      // 1. Search Query
      if (studentSearchQuery.value.trim().isNotEmpty) {
        final q = studentSearchQuery.value.trim().toLowerCase();
        final match = friend.name.toLowerCase().contains(q) ||
            friend.uvName.toLowerCase().contains(q) ||
            friend.program.toLowerCase().contains(q);
        if (!match) return false;
      }
      // 2. University Filter
      if (selectedUniversityFilter.value != 'All' &&
          selectedUniversityFilter.value.isNotEmpty) {
        if (!friend.uvName
            .toLowerCase()
            .contains(selectedUniversityFilter.value.toLowerCase())) {
          return false;
        }
      }
      // 3. Program Filter
      if (selectedProgramFilter.value != 'All' &&
          selectedProgramFilter.value.isNotEmpty) {
        if (!friend.program
            .toLowerCase()
            .contains(selectedProgramFilter.value.toLowerCase())) {
          return false;
        }
      }
      // 4. Year Filter
      if (selectedYearFilter.value != 'All' &&
          selectedYearFilter.value.isNotEmpty) {
        if (!friend.yearOfStudy
            .toLowerCase()
            .contains(selectedYearFilter.value.toLowerCase())) {
          return false;
        }
      }
      return true;
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
      requestedUserIds.add(receiverId);
      // We don't need to re-fetch the entire list just to show 'Added',
      // but if the backend removes it from suggestions we can leave it.
      // fetchFriendsData();
    }
  }

  void ignoreFriendSuggestion(int userId) {
    // Optimistically remove from all potential lists
    friendsForYouList.removeWhere((item) => item.id == userId);
    yourCampusList.removeWhere((item) => item.id == userId);
  }

  Future<void> fetchPosts() async {
    try {
      currentPage.value = 1;
      hasMorePosts.value = true;
      isLoadingPosts.value = true;
      
      final paginatedResponse = await _campusService.fetchPosts(page: currentPage.value);
      final posts = paginatedResponse.posts;
      hasMorePosts.value = paginatedResponse.hasNextPage;
      
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (Get.isRegistered<StudentProfileController>()) {
        final profileCtrl = Get.find<StudentProfileController>();
        final myId = profileCtrl.userId.value;
        final myPic = profileCtrl.profileImageUrl.value;
        final myName = profileCtrl.displayName.value;

        for (var i = 0; i < posts.length; i++) {
          final isMyPost = posts[i].author.id == myId;
          final isLikedByMe = posts[i].isLiked;

          final author = posts[i].author;
          posts[i] = posts[i].copyWith(
            author: author.copyWith(
              username: isMyPost && myName.isNotEmpty
                  ? myName
                  : author.username,
              fullName: isMyPost && myName.isNotEmpty
                  ? myName
                  : author.fullName,
            ),
            isLiked: isLikedByMe,
          );
        }
      }
      postsList.assignAll(posts);
    } catch (e) {
      debugPrint('Error fetching posts: $e');
    } finally {
      isLoadingPosts.value = false;
    }
  }

  Future<void> fetchMorePosts() async {
    if (isLoadingMorePosts.value || !hasMorePosts.value) return;
    try {
      isLoadingMorePosts.value = true;
      currentPage.value++;
      
      final paginatedResponse = await _campusService.fetchPosts(page: currentPage.value);
      final posts = paginatedResponse.posts;
      hasMorePosts.value = paginatedResponse.hasNextPage;
      
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (Get.isRegistered<StudentProfileController>()) {
        final profileCtrl = Get.find<StudentProfileController>();
        final myId = profileCtrl.userId.value;
        final myPic = profileCtrl.profileImageUrl.value;
        final myName = profileCtrl.displayName.value;

        for (var i = 0; i < posts.length; i++) {
          final isMyPost = posts[i].author.id == myId;
          final isLikedByMe = posts[i].isLiked;

          final author = posts[i].author;
          posts[i] = posts[i].copyWith(
            author: author.copyWith(
              username: isMyPost && myName.isNotEmpty
                  ? myName
                  : author.username,
              fullName: isMyPost && myName.isNotEmpty
                  ? myName
                  : author.fullName,
            ),
            isLiked: isLikedByMe,
          );
        }
      }
      postsList.addAll(posts);
    } catch (e) {
      debugPrint('Error fetching more posts: $e');
      currentPage.value--; // Revert page on error
    } finally {
      isLoadingMorePosts.value = false;
    }
  }

  Future<void> fetchUnions() async {
    try {
      isLoadingUnions.value = true;
      final response = await _campusService.fetchUnions();
      unionForYouList.assignAll(
        response.forYou.isEmpty ? response.unions : response.forYou,
      );
      yourUnionList.assignAll(response.yourUnions);

      // Fetch pending unions for the "Status" tab
      final pendingResponse = await _campusService.fetchUnions(
        status: 'pending_approval',
      );
      pendingUnionList.assignAll(pendingResponse.unions);
    } catch (e) {
      debugPrint('Error fetching unions: $e');
    } finally {
      isLoadingUnions.value = false;
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) selectedImagePath.value = image.path;
  }

  void removeSelectedImage() => selectedImagePath.value = '';

  Future<void> createPost() async {
    final text = postTextEditingController.text.trim();
    final imagePath = selectedImagePath.value;
    
    if (text.isEmpty && imagePath.isEmpty) {
      EasyLoading.showError('Please enter some text or select an image');
      return;
    }

    // Immediately clear UI
    postTextEditingController.clear();
    selectedImagePath.value = '';
    isBackgroundUploadingPost.value = true;

    try {
      String? mediaUrl;
      if (imagePath.isNotEmpty) {
        mediaUrl = await _profileService.uploadProfileFile(
          file: File(imagePath),
        );
      }

      final success = await _campusService.createPost(
        content: text,
        mediaUrl: mediaUrl,
      );

      if (success) {
        fetchPosts(); // Refresh the feed silently
        if (Get.isRegistered<StudentProfileController>()) {
          Get.find<StudentProfileController>().loadProfile();
        }
      } else {
        EasyLoading.showError('Failed to create post');
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      EasyLoading.showError('An error occurred while creating post');
    } finally {
      isBackgroundUploadingPost.value = false;
    }
  }

  /// Pull-to-refresh: re-fetches all campus data lazily based on selected tab.
  Future<void> refreshAll() async {
    switch (selectedTab.value) {
      case 0:
        await fetchPosts();
        break;
      case 1:
        await fetchUnions();
        break;
      case 2:
        await fetchFriendsData();
        break;
      case 3:
      case 4:
        await Future.delayed(const Duration(milliseconds: 500));
        break;
    }
  }

  @override
  void onClose() {
    _postLikedSub?.cancel();
    _postCommentedSub?.cancel();
    _notificationSub?.cancel();
    FeedVideoManager.pauseAll();
    tabController.dispose();
    super.onClose();
  }

  Future<void> loadFursaZoneData() async {
    try {
      isLoadingFursaZone.value = true;
      final competitions = await _fursaService.fetchCompetitions();
      if (competitions.isNotEmpty) {
        competitionsList.assignAll(competitions);
        final firstComp = competitions.first;
        if (firstComp.promoImageLink != null && firstComp.promoImageLink!.isNotEmpty) {
          fursaZoneBannerImage.value = firstComp.promoImageLink!;
        }
        if (firstComp.logo != null && firstComp.logo!.isNotEmpty) {
          fursaZoneSponsorImage.value = firstComp.logo!;
        }
        
        _fursaService.performBonusCheckIn(firstComp.id).then((_) {
          _fursaService.fetchBonusStatus(firstComp.id).then((status) {
            if (status != null) {
              final bonusesList = (status['bonuses'] as List?)
                      ?.map((e) => BonusDataModel.fromJson(e))
                      .toList() ??
                  [];
              bonusData.assignAll(bonusesList);
              
              for (var bonus in bonusesList) {
                if (bonus.type == 'SOCIAL_SHARE' && bonus.claimed) {
                  setBonusItemEarned('share_social_media', true);
                } else if (bonus.type == 'LOGIN_STREAK' && bonus.claimed) {
                  setBonusItemEarned('daily_login_streak', true);
                } else if (bonus.type == 'EARLY_COMPLETION' && bonus.claimed) {
                  setBonusItemEarned('early_completion_bonus', true);
                }
              }

              final loginStreak = status['loginStreak'];
              if (loginStreak != null) {
                loginStreakDays.value = loginStreak['currentStreak'] ?? 0;
                loginCheckedInToday.value = loginStreak['checkedInToday'] ?? false;
              }
            }
          }).catchError((e) {
            debugPrint('Error fetching bonus status: $e');
          });
        }).catchError((e) {
          debugPrint('Error performing background check-in: $e');
        });

        // Sync learning progress
        try {
          if (firstComp.isRegistered && firstComp.registrationId != null) {
            final regId = firstComp.registrationId!;
            
            final progress = await _fursaService.fetchLearningProgress(regId);
            
            // Also sync the registration progress to DialogboxController so it gets dynamic timers
            if (Get.isRegistered<DialogboxController>()) {
              Get.find<DialogboxController>().syncRegistrationProgress(firstComp, progress);
            }

            if (progress != null) {
              taskCompleted['video_task'] = progress['hasWatchedVideo'] ?? false;
              taskCompleted['brochure_task'] = progress['hasReadBrochure'] ?? false;
              taskCompleted['chat_task'] = progress['hasCompletedQnA'] ?? false;
              
              // Phase completion states
              taskCompleted['learning_phase_completed'] = progress['hasCompletedLearning'] ?? false;
              taskCompleted['qualification_phase_completed'] = progress['hasCompletedQualification'] ?? false;
              taskCompleted['final_phase_completed'] = progress['hasCompletedFinal'] ?? false;
              
              taskCompleted.refresh();
            }
          } else {
             // Reset dialogbox controller data if not registered
             if (Get.isRegistered<DialogboxController>()) {
                Get.find<DialogboxController>().syncRegistrationProgress(firstComp, null);
             }
          }
        } catch (e) {
          debugPrint('Error syncing learning progress: $e');
        }
      }
      
      fursaTasks.clear();
      thisWeekWinnersList.clear();
      lastWeekWinnersList.clear();
      topSchoolsList.clear();
      thisWeekLeaderboardList.clear();
      allTimeLeaderboardList.clear();
    } catch (e) {
      debugPrint('Error loading fursa data: $e');
      fursaTasks.clear();
      thisWeekWinnersList.clear();
      lastWeekWinnersList.clear();
      topSchoolsList.clear();
      thisWeekLeaderboardList.clear();
      allTimeLeaderboardList.clear();
    } finally {
      isLoadingFursaZone.value = false;
    }
  }

  // Static fursa, winners, and schools mock generators removed

  void startQuizTimer(int seconds) {
    if (_quizTimer != null) return;
    quizTimeRemaining.value = seconds;
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (quizTimeRemaining.value > 0) {
        quizTimeRemaining.value--;
      } else {
        _quizTimer?.cancel();
        _quizTimer = null;
      }
    });
  }

  void incrementQuizAnsweredCount() => quizAnsweredCount.value++;

  void resetQuizState() {
    _quizTimer?.cancel();
    _quizTimer = null;
    quizCurrentQuestion.value = 0;
    quizSelectedAnswer.value = null;
    quizAnsweredCount.value = 0;
    quizTimeRemaining.value = 0;
    quizAnswers.clear();
  }

  void updateQuizQuestion(int index) {
    quizCurrentQuestion.value = index;
    quizSelectedAnswer.value = quizAnswers[index];
  }

  void updateQuizAnswer(String answer) {
    quizSelectedAnswer.value = answer;
    quizAnswers[quizCurrentQuestion.value] = answer;
  }

  Future<void> loadQuizQuestions({
    required int competitionId,
    required String quizType,
    int weekNumber = 1,
  }) async {
    try {
      quizActiveType.value = quizType;
      isLoadingQuizQuestions.value = true;
      resetQuizState();
      quizQuestions.clear();
      final questions = await _fursaService.fetchQuizQuestions(
        competitionId: competitionId,
        quizType: quizType,
        weekNumber: weekNumber,
      );
      quizQuestions.assignAll(questions);
    } catch (e) {
      debugPrint('Error loading quiz questions: $e');
    } finally {
      isLoadingQuizQuestions.value = false;
    }
  }

  void completeTask(String key, VoidCallback? onTaskCompleted) {
    taskCompleted[key] = true;

    // Track task completion if it's a campaign/fursa task
    final int? campaignId = int.tryParse(key);
    if (campaignId != null) {
      _fursaService.trackTaskAction(campaignId, 'view');
      _fursaService.trackTaskAction(campaignId, 'impression');
    }

    onTaskCompleted?.call();
  }

  Future<void> fetchLeaderboardData() async {
    // Intentionally empty.
  }

  // Static leaderboard mock generators removed

  void resetTask(String key) => taskCompleted[key] = false;
  void toggleBonusItemEarned(String key) => claimBonusPoints(key);
  void setBonusItemEarned(String key, bool earned) =>
      bonusItemEarned[key] = earned;

  Future<void> claimBonusPoints(String key) async {
    if (competitionsList.isEmpty) return;
    final compId = competitionsList.first.id;

    if (key == 'share_social_media') {
      final link = "https://nodmac.com/competition/$compId";
      
      try {
        final result = await Share.share(
          'Join this amazing competition on Nodmac! $link',
        );
        
        if (result.status == ShareResultStatus.success) {
          final metadata = result.raw.isNotEmpty ? result.raw : 'social_share';
          
          EasyLoading.show(status: 'Claiming bonus...');
          final success = await _fursaService.claimBonusPoints(
            competitionId: compId,
            bonusType: 'SOCIAL_SHARE',
            metadata: metadata,
          );
          
          EasyLoading.dismiss();
          if (success) {
            setBonusItemEarned(key, true);
            EasyLoading.showSuccess('Bonus points claimed!');
          } else {
            EasyLoading.showError('Failed to claim bonus points.');
          }
        }
      } catch (e) {
        debugPrint('Share error: $e');
        EasyLoading.showError('Failed to share.');
      }
    } else if (key == 'daily_login_streak') {
      if (loginStreakDays.value < 3) {
        EasyLoading.showToast('You need a 3-day login streak to claim this bonus.');
        return;
      }
      
      EasyLoading.show(status: 'Claiming bonus...');
      final success = await _fursaService.claimBonusPoints(
        competitionId: compId,
        bonusType: 'LOGIN_STREAK',
        metadata: 'login_streak',
      );
      EasyLoading.dismiss();
      if (success) {
        setBonusItemEarned(key, true);
        EasyLoading.showSuccess('Login streak bonus claimed!');
      } else {
        EasyLoading.showError('Failed to claim login streak bonus.');
      }
    } else if (key == 'early_completion_bonus') {
      Get.dialog(
        EarlyCompletionDialog(
          compId: compId,
          itemKey: key,
        ),
      );
    }
  }

  Future<void> claimEarlyCompletionBonus(dynamic compId, String key) async {
    Get.back(); // Close the dialog
    EasyLoading.show(status: 'Claiming bonus...');
    final success = await _fursaService.claimBonusPoints(
      competitionId: compId,
      bonusType: 'EARLY_COMPLETION',
      metadata: 'early_completion',
    );
    EasyLoading.dismiss();
    if (success) {
      setBonusItemEarned(key, true);
      EasyLoading.showSuccess('Early completion bonus claimed!');
    } else {
      EasyLoading.showError('Failed to claim early completion bonus.');
    }
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> deletePost(int id) async {
    try {
      EasyLoading.show(status: 'Deleting...');
      if (await _campusService.deletePost(id)) {
        postsList.removeWhere((p) => p.id == id);
        if (Get.isRegistered<StudentProfileController>()) {
          Get.find<StudentProfileController>().loadProfile();
        }
        EasyLoading.showSuccess('Deleted');
      }
    } catch (e) {
      EasyLoading.showError('Error');
    }
  }

  Future<void> updatePost(int id, String content, {String? mediaUrl, String? newImagePath}) async {
    try {
      EasyLoading.show(status: 'Updating...');
      String? finalMediaUrl = mediaUrl;
      
      if (newImagePath != null && newImagePath.isNotEmpty) {
        final uploadedUrl = await _profileService.uploadProfileFile(
          file: File(newImagePath),
        );
        if (uploadedUrl != null) {
          finalMediaUrl = uploadedUrl;
        } else {
          EasyLoading.showError('Failed to upload image');
          return;
        }
      }

      if (await _campusService.updatePost(id: id, content: content, mediaUrl: finalMediaUrl)) {
        fetchPosts();
        if (Get.isRegistered<StudentProfileController>()) {
          Get.find<StudentProfileController>().loadProfile();
        }
        EasyLoading.showSuccess('Updated');
      }
    } catch (e) {
      EasyLoading.showError('Error');
    }
  }

  Future<void> toggleLike(PostModel post) async {
    final index = postsList.indexWhere((p) => p.id == post.id);
    if (index == -1) return;

    final originalPost = postsList[index];
    final bool currentlyLiked = originalPost.isLiked;

    postsList[index] = originalPost.copyWith(
      likeCount: currentlyLiked
          ? (originalPost.likeCount > 0 ? originalPost.likeCount - 1 : 0)
          : originalPost.likeCount + 1,
      isLiked: !currentlyLiked,
    );

    try {
      final success = currentlyLiked
          ? await _campusService.unlikePost(post.id)
          : await _campusService.likePost(post.id);
      if (!success) {
        postsList[index] = originalPost.copyWith(isLiked: !currentlyLiked);
        EasyLoading.showInfo(currentlyLiked ? 'Not unliked' : 'Already liked');
      }
    } catch (e) {
      postsList[index] = originalPost;
      EasyLoading.showError('Network error');
    }
  }

  void sharePost(PostModel post) {
    final title = post.author.fullName;
    final deepLink = "https://nodmac.com/post/${post.id}";
    final text = "Check out this post from $title:\n$deepLink";
    
    Share.share(text);
  }
}
