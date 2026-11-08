import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/campaign/campaign_overview/controller/campaign_social_feed_mapper.dart';
import 'package:msollaally/feature/pro_partners/campaign/create_campaign/controller/create_campaign_profile_controller.dart';
import 'package:share_plus/share_plus.dart';

class EventSocialFeedController extends GetxController {
  final int eventId;

  EventSocialFeedController({required this.eventId});

  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefHelper = SharedPreferenceHelper();

  final RxBool isInitialLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isCommentPosting = false.obs;
  final RxBool isLikeLoading = false.obs;
  final RxBool isDescriptionExpanded = false.obs;

  final RxMap<String, dynamic> event = <String, dynamic>{}.obs;
  final RxList<dynamic> comments = <dynamic>[].obs;
  final RxList<dynamic> likes = <dynamic>[].obs;

  final RxInt activeComposerIndex = (-1).obs;
  final RxnInt activeReplyCommentId = RxnInt();
  final RxnString pickedCommentFilePath = RxnString();

  late final TextEditingController commentController;
  late final FocusNode commentFocus;
  late final ScrollController scrollController;
  late final CreateCampaignProfileController profileController;

  final Map<int, String> _profileImageCache = {};

  String get myDisplayName {
    final profileName = profileController.me.value?.profile?.fullName?.trim();
    if (profileName != null && profileName.isNotEmpty) return profileName;

    final companyName = profileController.me.value?.profile?.companyName
        ?.trim();
    if (companyName != null && companyName.isNotEmpty) return companyName;

    final username = profileController.me.value?.username?.trim();
    if (username != null && username.isNotEmpty) return username;

    return 'Partner';
  }

  String get myProfileImageUrl =>
      profileController.me.value?.profile?.profilePicture?.trim() ?? '';

  @override
  void onInit() {
    super.onInit();
    commentController = TextEditingController();
    commentFocus = FocusNode();
    scrollController = ScrollController();
    profileController = Get.put(CreateCampaignProfileController());
    fetchEvent();
  }

  @override
  void onClose() {
    commentController.dispose();
    commentFocus.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchEvent({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isInitialLoading.value = true;
    }

    try {
      final token = await _requireToken();
      final response = await _networkCaller.getRequest(
        Urls.getEventById('$eventId'),
        token: 'Bearer $token',
      );

      if (!response.isSuccess) throw Exception(response.errorMessage);
      final data = CampaignSocialFeedMapper.parsePublicProfile(
        response.responseData,
      );
      if (data.isEmpty) throw Exception('Event data not found');

      event.assignAll(data);
      likes.assignAll((data['likes'] as List?) ?? const []);
      comments.assignAll(
        CampaignSocialFeedMapper.buildCommentTree(
          (data['comments'] as List?) ?? const [],
        ),
      );

      await _enrichPublicProfilePictures();
      if (!isRefresh) {
        activeComposerIndex.value = -1;
      }
      activeReplyCommentId.value = null;
    } catch (e) {
      _showError(e.toString());
    } finally {
      isInitialLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> refreshFeed() => fetchEvent(isRefresh: true);

  void toggleDescriptionExpanded() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  Future<void> toggleLike() async {
    if (event.isEmpty || isLikeLoading.value) return;

    final wasLiked = event['isLikedByMe'] == true;
    final previousCount = CampaignSocialFeedMapper.toInt(event['likeCount']);
    final previousLikes = List<dynamic>.from(likes);

    isLikeLoading.value = true;
    _applyLikeOptimistic(wasLiked: wasLiked);

    try {
      final token = await _requireToken();
      final url = wasLiked
          ? Urls.eventDisLike('${event['id'] ?? eventId}')
          : Urls.eventLike('${event['id'] ?? eventId}');

      final response = await _networkCaller.postJsonRequest(
        url,
        body: const {},
        token: 'Bearer $token',
      );

      if (!response.isSuccess) throw Exception(response.errorMessage);
    } catch (_) {
      event['isLikedByMe'] = wasLiked;
      event['likeCount'] = previousCount;
      likes.assignAll(previousLikes);
      _showError('Failed to update like. Please try again.');
    } finally {
      isLikeLoading.value = false;
      event.refresh();
    }
  }

  void focusCommentComposer() {
    if (activeComposerIndex.value == 0) {
      activeComposerIndex.value = -1;
      activeReplyCommentId.value = null;
      commentFocus.unfocus();
    } else {
      activeComposerIndex.value = 0;
      activeReplyCommentId.value = null;
      Future.delayed(const Duration(milliseconds: 120), () {
        if (!isClosed && commentFocus.canRequestFocus) {
          commentFocus.requestFocus();
        }
      });
    }
  }

  void startReply(int parentCommentId) {
    if (parentCommentId <= 0) return;
    activeComposerIndex.value = 0;
    activeReplyCommentId.value = parentCommentId;
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!isClosed && commentFocus.canRequestFocus) {
        commentFocus.requestFocus();
      }
    });
  }

  void cancelReply() => activeReplyCommentId.value = null;

  Future<void> pickCommentMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null || path.isEmpty) return;
    pickedCommentFilePath.value = path;
    focusCommentComposer();
  }

  void clearCommentMedia() {
    pickedCommentFilePath.value = null;
  }

  Future<void> submitCommentOrReply() async {
    if (isCommentPosting.value || event.isEmpty) return;

    final text = commentController.text.trim();
    final localMediaPath = pickedCommentFilePath.value;
    if (text.isEmpty && (localMediaPath == null || localMediaPath.isEmpty)) {
      return;
    }

    final parentId = activeReplyCommentId.value;
    final optimistic = _buildOptimisticComment(
      text: text,
      parentCommentId: parentId,
      mediaUrl: localMediaPath,
    );

    commentController.clear();
    activeReplyCommentId.value = null;
    commentFocus.unfocus();

    _insertOptimisticComment(optimistic, parentCommentId: parentId);

    isCommentPosting.value = true;
    try {
      final token = await _requireToken();
      final uploadedMediaUrl = await _uploadCommentMedia(token: token);
      final response = await _networkCaller.postJsonRequest(
        Urls.eventComment('${event['id'] ?? eventId}'),
        body: {
          'content': text,
          if (uploadedMediaUrl != null && uploadedMediaUrl.isNotEmpty)
            'mediaUrl': uploadedMediaUrl,
          if (parentId != null) 'parentCommentId': parentId,
        },
        token: 'Bearer $token',
      );

      if (!response.isSuccess) throw Exception(response.errorMessage);
      await fetchEvent(isRefresh: true);
    } catch (_) {
      _removeOptimisticComment(optimistic['id']);
      event['commentCount'] = max(
        0,
        CampaignSocialFeedMapper.toInt(event['commentCount']) - 1,
      );
      event.refresh();
      _showError('Failed to post comment. Please try again.');
    } finally {
      clearCommentMedia();
      isCommentPosting.value = false;
    }
  }

  void shareEvent() {
    final title = event['title']?.toString().trim() ?? 'Event';
    final deepLink = "https://www.nodmac.com/post/$eventId";
    final text = "Check out this event: $title\n$deepLink";
    
    Share.share(text);
  }

  String replyingToName() {
    final id = activeReplyCommentId.value;
    if (id == null) return '';
    final item = _findCommentById(comments, id);
    if (item == null) return '';
    return CampaignSocialFeedMapper.pickName(
      CampaignSocialFeedMapper.asMap(item),
    );
  }

  dynamic _findCommentById(List<dynamic> nodes, int id) {
    for (final node in nodes) {
      final map = CampaignSocialFeedMapper.asMap(node);
      if (CampaignSocialFeedMapper.toInt(map['id']) == id) return map;
      final replies = (map['replies'] as List?) ?? const [];
      final found = _findCommentById(List<dynamic>.from(replies), id);
      if (found != null) return found;
    }
    return null;
  }

  dynamic _buildOptimisticComment({
    required String text,
    int? parentCommentId,
    String? mediaUrl,
  }) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch,
      'content': text,
      'mediaUrl': mediaUrl,
      'createdAt': DateTime.now().toIso8601String(),
      'likeCount': 0,
      'author': {
        'id': profileController.me.value?.id,
        'fullName': myDisplayName,
        'profilePicture': myProfileImageUrl,
      },
      'parentCommentId': parentCommentId,
      'replies': <dynamic>[],
    };
  }

  void _insertOptimisticComment(dynamic optimistic, {int? parentCommentId}) {
    if (parentCommentId == null) {
      comments.insert(0, optimistic);
    } else {
      CampaignSocialFeedMapper.appendReplyRecursively(
        comments,
        parentCommentId,
        optimistic,
      );
    }

    event['commentCount'] =
        CampaignSocialFeedMapper.toInt(event['commentCount']) + 1;
    comments.refresh();
    event.refresh();
  }

  void _removeOptimisticComment(dynamic optimisticId) {
    comments.removeWhere(
      (e) => CampaignSocialFeedMapper.asMap(e)['id'] == optimisticId,
    );
    for (var i = 0; i < comments.length; i++) {
      final node = CampaignSocialFeedMapper.asMap(comments[i]);
      node['replies'] = CampaignSocialFeedMapper.removeReplyById(
        List<dynamic>.from((node['replies'] as List?) ?? const []),
        optimisticId,
      );
      comments[i] = node;
    }
    comments.refresh();
  }

  void _applyLikeOptimistic({required bool wasLiked}) {
    final nowLiked = !wasLiked;
    final currentCount = CampaignSocialFeedMapper.toInt(event['likeCount']);

    event['isLikedByMe'] = nowLiked;
    event['likeCount'] = max(0, currentCount + (nowLiked ? 1 : -1));

    if (nowLiked) {
      likes.insert(0, {
        'fullName': myDisplayName,
        'profilePicture': myProfileImageUrl,
        'userId': profileController.me.value?.id,
      });
    } else {
      likes.removeWhere((item) {
        final name = CampaignSocialFeedMapper.pickName(
          CampaignSocialFeedMapper.asMap(item),
        ).toLowerCase();
        return name == myDisplayName.toLowerCase();
      });
    }

    event.refresh();
  }

  Future<String?> _uploadCommentMedia({required String token}) async {
    final path = pickedCommentFilePath.value;
    if (path == null || path.isEmpty) return null;
    final response = await _networkCaller.uploadFileRequest(
      Urls.uploadCloudinaryFile,
      File(path),
      token: 'Bearer $token',
      fieldName: 'files',
    );
    if (!response.isSuccess) {
      _showError('Media upload failed');
      return null;
    }

    final raw = response.responseData;
    if (raw is List && raw.isNotEmpty && raw.first is Map) {
      final first = raw.first as Map;
      return (first['url'] ?? first['secure_url'] ?? first['fileUrl'])
          ?.toString();
    }
    if (raw is Map) {
      final top = raw['url'] ?? raw['secure_url'] ?? raw['fileUrl'];
      if (top != null) return top.toString();
      final data = raw['data'];
      if (data is List && data.isNotEmpty && data.first is Map) {
        final first = data.first as Map;
        return (first['url'] ?? first['secure_url'] ?? first['fileUrl'])
            ?.toString();
      }
    }
    return null;
  }

  Future<void> _enrichPublicProfilePictures() async {
    final ids = _collectUserIds();
    if (ids.isEmpty) return;
    final token = await _requireToken();

    await Future.wait(
      ids.map((id) async {
        if (_profileImageCache[id]?.isNotEmpty == true) return;
        final response = await _networkCaller.getRequest(
          Urls.profilePublicById('$id'),
          token: 'Bearer $token',
        );
        if (!response.isSuccess) return;
        final userMap = CampaignSocialFeedMapper.parsePublicProfile(
          response.responseData,
        );
        final url = CampaignSocialFeedMapper.extractPublicProfilePicture(
          userMap,
        );
        if (url.isNotEmpty) _profileImageCache[id] = url;
      }),
    );

    _applyProfilePictures();
  }

  Set<int> _collectUserIds() {
    final ids = <int>{};
    final creator = CampaignSocialFeedMapper.asMap(event['creator']);
    final creatorId = CampaignSocialFeedMapper.toInt(creator['id']);
    if (creatorId > 0) ids.add(creatorId);

    final coHosts = (event['coHosts'] as List?) ?? const [];
    for (final coHost in coHosts) {
      final map = CampaignSocialFeedMapper.asMap(coHost);
      final user = CampaignSocialFeedMapper.asMap(map['user']);
      final userId = CampaignSocialFeedMapper.toInt(user['id']);
      if (userId > 0) ids.add(userId);
    }

    for (final like in likes) {
      final map = CampaignSocialFeedMapper.asMap(like);
      final userId = CampaignSocialFeedMapper.toInt(map['userId']);
      if (userId > 0) ids.add(userId);
    }
    _collectCommentUserIds(comments, ids);
    return ids;
  }

  void _collectCommentUserIds(List<dynamic> nodes, Set<int> ids) {
    for (final item in nodes) {
      final map = CampaignSocialFeedMapper.asMap(item);
      final author = CampaignSocialFeedMapper.asMap(map['author']);
      final userId = CampaignSocialFeedMapper.toInt(author['id']);
      if (userId > 0) ids.add(userId);
      final replies = (map['replies'] as List?) ?? const [];
      _collectCommentUserIds(List<dynamic>.from(replies), ids);
    }
  }

  void _applyProfilePictures() {
    final creator = CampaignSocialFeedMapper.asMap(event['creator']);
    final creatorId = CampaignSocialFeedMapper.toInt(creator['id']);
    final creatorImage = _profileImageCache[creatorId];
    if ((creatorImage ?? '').isNotEmpty) {
      creator['profilePicture'] = creatorImage;
      event['creator'] = creator;
    }

    final coHosts = (event['coHosts'] as List?) ?? const [];
    final nextCoHosts = coHosts.map((coHost) {
      final map = CampaignSocialFeedMapper.asMap(coHost);
      final user = CampaignSocialFeedMapper.asMap(map['user']);
      final userId = CampaignSocialFeedMapper.toInt(user['id']);
      final image = _profileImageCache[userId];
      if ((image ?? '').isNotEmpty) {
        user['profilePicture'] = image;
        map['user'] = user;
      }
      return map;
    }).toList();
    event['coHosts'] = nextCoHosts;

    for (var i = 0; i < likes.length; i++) {
      final map = CampaignSocialFeedMapper.asMap(likes[i]);
      final userId = CampaignSocialFeedMapper.toInt(map['userId']);
      final image = _profileImageCache[userId];
      if ((image ?? '').isNotEmpty) {
        map['profilePicture'] = image;
        likes[i] = map;
      }
    }

    comments.assignAll(_applyCommentAvatars(comments));
    event.refresh();
    likes.refresh();
    comments.refresh();
  }

  List<dynamic> _applyCommentAvatars(List<dynamic> nodes) {
    return nodes.map((item) {
      final map = CampaignSocialFeedMapper.asMap(item);
      final author = CampaignSocialFeedMapper.asMap(map['author']);
      final userId = CampaignSocialFeedMapper.toInt(author['id']);
      final image = _profileImageCache[userId];
      if ((image ?? '').isNotEmpty) {
        author['profilePicture'] = image;
        map['author'] = author;
      }
      final replies = (map['replies'] as List?) ?? const [];
      map['replies'] = _applyCommentAvatars(List<dynamic>.from(replies));
      return map;
    }).toList();
  }

  Future<String> _requireToken() async {
    final token = await _prefHelper.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Access token not found. Please login again.');
    }
    return token;
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message.replaceFirst('Exception: ', ''),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
