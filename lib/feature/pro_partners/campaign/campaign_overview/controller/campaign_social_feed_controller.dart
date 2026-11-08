import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/campaign/create_campaign/controller/create_campaign_profile_controller.dart';
import 'package:share_plus/share_plus.dart';

import 'campaign_social_feed_mapper.dart';

class CampaignSocialFeedController extends GetxController {
  final int campaignId;

  CampaignSocialFeedController({required this.campaignId});

  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefHelper = SharedPreferenceHelper();

  final RxBool isInitialLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isCommentPosting = false.obs;
  final RxBool isLikeLoading = false.obs;

  final RxMap<String, dynamic> campaign = <String, dynamic>{}.obs;
  final RxList<dynamic> comments = <dynamic>[].obs;
  final RxList<dynamic> likes = <dynamic>[].obs;

  final RxInt activeComposerIndex = (-1).obs;
  final RxnInt activeReplyCommentId = RxnInt();
  final RxBool isDescriptionExpanded = false.obs;
  final RxnString pickedCommentFilePath = RxnString();
  final RxnString pickedCommentMediaType = RxnString();

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

  Timer? _autoRefreshTimer;
  final Set<int> _knownCommentIds = <int>{};
  bool _hasInitialCommentsLoaded = false;

  @override
  void onInit() {
    super.onInit();
    commentController = TextEditingController();
    commentFocus = FocusNode();
    scrollController = ScrollController();
    profileController = Get.put(CreateCampaignProfileController());
    fetchCampaign();
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _autoRefreshTimer?.cancel();
    commentController.dispose();
    commentFocus.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _pollFeedUpdates();
    });
  }

  void _recordKnownComments(List<dynamic> list) {
    for (final item in list) {
      final map = CampaignSocialFeedMapper.asMap(item);
      final id = CampaignSocialFeedMapper.toInt(map['id']);
      if (id > 0) _knownCommentIds.add(id);
      final replies = map['replies'];
      if (replies is List) _recordKnownComments(replies);
    }
  }

  Future<void> _pollFeedUpdates() async {
    if (isCommentPosting.value || isRefreshing.value || isInitialLoading.value) {
      return;
    }

    try {
      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final response = await _networkCaller.getRequest(
        Urls.getCampaign('$campaignId'),
        token: 'Bearer $token',
      );

      if (!response.isSuccess) return;

      final data = CampaignSocialFeedMapper.extractCampaignData(
        response.responseData,
      );
      if (data == null || data.isEmpty) return;

      final rawComments = (data['comments'] as List?) ?? const [];
      final newTree = CampaignSocialFeedMapper.buildCommentTree(rawComments);

      final myId = profileController.me.value?.id;
      final newStudentComments = <Map<String, dynamic>>[];

      void inspectNewComments(List<dynamic> list) {
        for (final item in list) {
          final map = CampaignSocialFeedMapper.asMap(item);
          final id = CampaignSocialFeedMapper.toInt(map['id']);
          if (id > 0 && !_knownCommentIds.contains(id)) {
            final authorId = CampaignSocialFeedMapper.toInt(
              map['author']?['id'] ?? map['userId'],
            );
            final authorName = CampaignSocialFeedMapper.pickName(map);
            final isFromMe =
                (myId != null && authorId == myId) || authorName == myDisplayName;
            if (!isFromMe) {
              newStudentComments.add(map);
            }
          }
          final replies = map['replies'];
          if (replies is List) inspectNewComments(replies);
        }
      }

      if (_hasInitialCommentsLoaded) {
        inspectNewComments(newTree);
      }

      _recordKnownComments(newTree);
      _hasInitialCommentsLoaded = true;

      // Update data seamlessly without resetting composer
      campaign.assignAll(data);
      likes.assignAll((data['likes'] as List?) ?? const []);
      comments.assignAll(newTree);
      _enrichPublicProfilePictures();

      if (newStudentComments.isNotEmpty) {
        final campaignName = (data['campaignTitle'] ??
                data['title'] ??
                campaign['campaignTitle'] ??
                campaign['title'] ??
                'Campaign')
            .toString();

        for (final newComment in newStudentComments) {
          final senderName = CampaignSocialFeedMapper.pickName(newComment);
          final content = (newComment['content'] ?? 'New message').toString();
          _showAlertToast(
            campaignTitle: campaignName,
            sender: senderName,
            message: content,
          );
        }
      }
    } catch (_) {
      // Ignore background polling errors
    }
  }

  void _showAlertToast({
    required String campaignTitle,
    required String sender,
    required String message,
  }) {
    Get.snackbar(
      campaignTitle,
      '$sender: $message',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      icon: const Icon(Icons.campaign, color: Color(0xFF22B573)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 8,
    );
  }

  Future<void> fetchCampaign({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isInitialLoading.value = true;
    }

    try {
      final token = await _requireToken();
      final response = await _networkCaller.getRequest(
        Urls.getCampaign('$campaignId'),
        token: 'Bearer $token',
      );

      if (!response.isSuccess) throw Exception(response.errorMessage);

      final data = CampaignSocialFeedMapper.extractCampaignData(
        response.responseData,
      );
      if (data == null || data.isEmpty) {
        throw Exception('Campaign data not found');
      }

      campaign.assignAll(data);
      likes.assignAll((data['likes'] as List?) ?? const []);
      final tree = CampaignSocialFeedMapper.buildCommentTree(
        (data['comments'] as List?) ?? const [],
      );
      comments.assignAll(tree);
      _recordKnownComments(tree);
      _hasInitialCommentsLoaded = true;
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

  Future<void> refreshFeed() => fetchCampaign(isRefresh: true);

  Future<void> toggleLike() async {
    if (campaign.isEmpty || isLikeLoading.value) return;

    final wasLiked = campaign['isLikedByMe'] == true;
    final previousCount = CampaignSocialFeedMapper.toInt(campaign['likeCount']);
    final previousLikes = List<dynamic>.from(likes);

    isLikeLoading.value = true;
    _applyLikeOptimistic(wasLiked: wasLiked);

    try {
      final token = await _requireToken();
      final url = wasLiked
          ? Urls.campaignDisLike('${campaign['id'] ?? campaignId}')
          : Urls.campaignLike('${campaign['id'] ?? campaignId}');

      final response = await _networkCaller.postJsonRequest(
        url,
        body: const {},
        token: 'Bearer $token',
      );

      if (!response.isSuccess) throw Exception(response.errorMessage);
    } catch (_) {
      campaign['isLikedByMe'] = wasLiked;
      campaign['likeCount'] = previousCount;
      likes.assignAll(previousLikes);
      _showError('Failed to update like. Please try again.');
    } finally {
      isLikeLoading.value = false;
      campaign.refresh();
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

  void toggleDescriptionExpanded() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  Future<void> pickCommentMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null || path.isEmpty) return;
    pickedCommentFilePath.value = path;
    pickedCommentMediaType.value = CampaignSocialFeedMapper.detectMediaType(
      path,
      fallbackExt: result.files.first.extension,
    );
    focusCommentComposer();
  }

  void clearCommentMedia() {
    pickedCommentFilePath.value = null;
    pickedCommentMediaType.value = null;
  }

  Future<void> submitCommentOrReply() async {
    if (isCommentPosting.value || campaign.isEmpty) return;

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
        Urls.campaignComment('${campaign['id'] ?? campaignId}'),
        body: {
          'content': text,
          if (uploadedMediaUrl != null && uploadedMediaUrl.isNotEmpty)
            'mediaUrl': uploadedMediaUrl,
          if (parentId != null) 'parentCommentId': parentId,
        },
        token: 'Bearer $token',
      );

      if (!response.isSuccess) throw Exception(response.errorMessage);
      
      // Fetch in the background without triggering the full screen loader
      await fetchCampaign(isRefresh: true);
    } catch (_) {
      _removeOptimisticComment(optimistic['id']);
      campaign['commentCount'] = max(
        0,
        CampaignSocialFeedMapper.toInt(campaign['commentCount']) - 1,
      );
      campaign.refresh();
      _showError('Failed to post comment. Please try again.');
    } finally {
      clearCommentMedia();
      isCommentPosting.value = false;
    }
  }

  void shareCampaign() {
    final title = campaign['campaignTitle']?.toString().trim() ?? 'Campaign';
    final deepLink = "https://www.nodmac.com/post/$campaignId";
    final text = "Check out this campaign: $title\n$deepLink";
    
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

    campaign['commentCount'] =
        CampaignSocialFeedMapper.toInt(campaign['commentCount']) + 1;
    comments.refresh();
    campaign.refresh();
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
    final currentCount = CampaignSocialFeedMapper.toInt(campaign['likeCount']);

    campaign['isLikedByMe'] = nowLiked;
    campaign['likeCount'] = max(0, currentCount + (nowLiked ? 1 : -1));

    if (nowLiked) {
      likes.insert(0, {
        'name': myDisplayName,
        'fullName': myDisplayName,
        'profileImage': myProfileImageUrl,
      });
    } else {
      likes.removeWhere((item) {
        final name = CampaignSocialFeedMapper.pickName(
          CampaignSocialFeedMapper.asMap(item),
        ).toLowerCase();
        return name == myDisplayName.toLowerCase();
      });
    }

    campaign.refresh();
  }

  Future<String> _requireToken() async {
    final token = await _prefHelper.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Access token not found. Please login again.');
    }
    return token;
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

    dynamic raw = response.responseData;
    if (raw is String) return raw;
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
      if (data is Map) {
        return (data['url'] ?? data['secure_url'] ?? data['fileUrl'])
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
    final campaignAuthor = CampaignSocialFeedMapper.asMap(campaign['author']);
    final campaignUserId = CampaignSocialFeedMapper.toInt(campaignAuthor['id']);
    if (campaignUserId > 0) ids.add(campaignUserId);

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
    final campaignAuthor = CampaignSocialFeedMapper.asMap(campaign['author']);
    final campaignUserId = CampaignSocialFeedMapper.toInt(campaignAuthor['id']);
    final campaignImage = _profileImageCache[campaignUserId];
    if ((campaignImage ?? '').isNotEmpty) {
      campaignAuthor['profilePicture'] = campaignImage;
      campaign['author'] = campaignAuthor;
    }

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
    campaign.refresh();
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

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message.replaceFirst('Exception: ', ''),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
