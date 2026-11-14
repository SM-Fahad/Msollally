// ignore_for_file: unused_element

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/core/services/websocket/social_socket_service.dart';
import 'package:msollaally/feature/student/campus/campus_home/service/campus_service.dart';

class CommentController extends GetxController {
  final int postId;
  CommentController({required this.postId});

  final _campusService = CampusService();

  final comments = <dynamic>[].obs;
  final isLoading = true.obs;
  final isSubmitting = false.obs;

  final replyToCommentId = RxnInt();
  final replyToUsername = ''.obs;
  final editingCommentId = RxnInt();
  
  final imagePath = RxnString();
  final NetworkCaller _networkCaller = NetworkCaller();
  
  int? currentUserId;

  final expandedReplies = <int>{}.obs;

  final textController = TextEditingController();
  final focusNode = FocusNode();

  StreamSubscription? _socketSub;

  @override
  void onInit() {
    super.onInit();
    debugPrint('💬 [CommentController] onInit postId=$postId');
    _loadCurrentUser();
    fetchComments();
    _listenSocket();
  }

  Future<void> _loadCurrentUser() async {
    final uidStr = await SharedPreferenceHelper().getUserId();
    if (uidStr != null) {
      currentUserId = int.tryParse(uidStr);
    }
  }

  // ───────────────────────────── Socket ────────────────────────────────────

  void _listenSocket() {
    if (!Get.isRegistered<SocialSocketService>()) {
      debugPrint('⚠️ [CommentController] SocialSocketService not registered');
      return;
    }
    debugPrint('🔌 [CommentController] Listening to socket for postId=$postId');

    _socketSub = Get.find<SocialSocketService>().onPostCommented.stream.listen(
      (data) {
        try {
          debugPrint('📨 [CommentController] socket post:commented → $data');

          final incomingPostId = data['post']?['id'] ?? data['postId'];
          if (incomingPostId != postId) {
            debugPrint(
              '🔕 [CommentController] Ignored – belongs to post $incomingPostId',
            );
            return;
          }

          final parentId = data['parentId'];

          if (parentId != null) {
            debugPrint(
              '↩️ [CommentController] Reply received, parentId=$parentId',
            );
            final listCopy = List<dynamic>.from(comments);
            final inserted = _appendReplyInList(
              listCopy,
              parentId as int,
              data,
            );
            if (inserted) {
              comments.assignAll(listCopy);
              expandedReplies.add(parentId);
            } else {
              debugPrint('❗ [CommentController] Parent not found – refreshing');
              fetchComments();
            }
          } else {
            debugPrint('💬 [CommentController] New root comment received');
            comments.add(data);
          }
        } catch (e, st) {
          debugPrint(' [CommentController] socket handler error: $e\n$st');
        }
      },
      onError: (e) {
        debugPrint(' [CommentController] socket stream error: $e');
      },
    );
  }

  bool _appendReplyInList(List<dynamic> list, int parentId, dynamic reply) {
    for (var i = 0; i < list.length; i++) {
      if (list[i]['id'] == parentId) {
        final replies = List<dynamic>.from(list[i]['replies'] ?? []);
        replies.add(reply);
        list[i] = Map<String, dynamic>.from(list[i] as Map)
          ..['replies'] = replies;
        return true;
      }
    }
    return false;
  }

  // ───────────────────────────── API ───────────────────────────────────────

  Future<void> fetchComments() async {
    debugPrint('🔄 [CommentController] fetchComments postId=$postId');
    isLoading.value = true;
    try {
      final fetched = await _campusService.fetchComments(postId);

      debugPrint(
        '📦 [CommentController] RAW DATA START (${fetched.length} items)',
      );
      for (var i = 0; i < fetched.length; i++) {
        final item = fetched[i];
        debugPrint(
          '  [$i] ID: ${item['id']} | Content: ${item['content']} | parentComment: ${item['parentComment']} | parentId: ${item['parentId']}',
        );
      }
      debugPrint('📦 [CommentController] RAW DATA END');

      final nested = _nestComments(fetched);
      comments.assignAll(nested);

      debugPrint(
        '✅ [CommentController] Loaded ${comments.length} root comments',
      );
    } catch (e) {
      debugPrint('❌ [CommentController] fetchComments error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<dynamic> _nestComments(List<dynamic> fetchedList) {
    debugPrint(
      '🌳 [CommentController] Backend returned ${fetchedList.length} root items',
    );

    final List<dynamic> roots = List<dynamic>.from(fetchedList);

    roots.sort((a, b) {
      final da =
          DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.now();
      final db =
          DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.now();
      return db.compareTo(da);
    });

    return roots;
  }

  bool _findAndAppend(List<dynamic> list, String parentId, dynamic child) {
    for (var i = 0; i < list.length; i++) {
      if (list[i]['id'].toString() == parentId) {
        final replies = List<dynamic>.from(list[i]['replies'] ?? []);
        replies.add(child);
        list[i] = Map<String, dynamic>.from(list[i])..['replies'] = replies;
        return true;
      }
      if (list[i]['replies'] != null) {
        if (_findAndAppend(list[i]['replies'], parentId, child)) return true;
      }
    }
    return false;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imagePath.value = picked.path;
    }
  }

  void removeImage() {
    imagePath.value = null;
  }

  String? _extractUploadedFileUrl(dynamic rawBody) {
    if (rawBody == null) return null;
    if (rawBody is String) return rawBody;
    if (rawBody is Map) {
      return (rawBody['data'] ??
              rawBody['url'] ??
              rawBody['secure_url'] ??
              rawBody['fileUrl'])
          ?.toString();
    }
    return null;
  }

  Future<void> submitComment() async {
    final text = textController.text.trim();
    if (text.isEmpty && imagePath.value == null) return;

    // Handle comment edit mode (PUT /comments/:commentID)
    if (editingCommentId.value != null) {
      final commentId = editingCommentId.value!;
      isSubmitting.value = true;
      try {
        String? mediaUrl;
        if (imagePath.value != null) {
          final token = await SharedPreferenceHelper().getAccessToken();
          final response = await _networkCaller.uploadFileRequest(
            Urls.uploadCloudinaryFile,
            File(imagePath.value!),
            token: token,
          );
          if (response.isSuccess) {
            mediaUrl = _extractUploadedFileUrl(response.responseData);
          }
        }
        final ok = await _campusService.updateComment(
          commentId,
          content: text,
          mediaUrl: mediaUrl,
        );
        if (ok) {
          textController.clear();
          removeImage();
          editingCommentId.value = null;
          await fetchComments();
        } else {
          Get.snackbar('Error', 'Failed to update comment');
        }
      } catch (e) {
        debugPrint(' [CommentController] updateComment error: $e');
      } finally {
        isSubmitting.value = false;
      }
      return;
    }

    final parentId = replyToCommentId.value;
    
    isSubmitting.value = true;
    
    String? mediaUrl;
    if (imagePath.value != null) {
       try {
         final token = await SharedPreferenceHelper().getAccessToken();
         final response = await _networkCaller.uploadFileRequest(
            Urls.uploadCloudinaryFile,
            File(imagePath.value!),
            token: token,
         );
         if (response.isSuccess) {
            mediaUrl = _extractUploadedFileUrl(response.responseData);
         }
       } catch (e) {
         debugPrint(' [CommentController] Image upload failed: $e');
         Get.snackbar('Error', 'Failed to upload image');
         isSubmitting.value = false;
         return; // Abort submit if image failed to upload
       }
    }

    final optimisticComment = {
      'id': -1,
      'content': text,
      'mediaUrl': mediaUrl,
      'author': {'username': 'You', 'id': currentUserId},
      'parentId': parentId,
      'isOptimistic': true,
      'replies': [],
      'likeCount': 0,
      'isLiked': false,
    };

    if (parentId != null) {
      final listCopy = List<dynamic>.from(comments);
      _appendReplyInList(listCopy, parentId, optimisticComment);
      comments.assignAll(listCopy);
      expandedReplies.add(parentId);
    } else {
      comments.add(optimisticComment);
    }

    try {
      final success = await _campusService.commentPost(
        postId,
        text,
        parentId: parentId,
        mediaUrl: mediaUrl,
      );

      if (success) {
        debugPrint(' [CommentController] API Submit Success');
        textController.clear();
        removeImage();
        replyToCommentId.value = null;
        replyToUsername.value = '';
        await fetchComments();
      } else {
        debugPrint(' [CommentController] API Submit Failed');
        await fetchComments();
      }
    } catch (e) {
      debugPrint(' [CommentController] submitComment Exception: $e');
      await fetchComments();
    } finally {
      isSubmitting.value = false;
    }
  }

  void startEditComment(int commentId, String currentContent) {
    replyToCommentId.value = null;
    replyToUsername.value = '';
    editingCommentId.value = commentId;
    textController.text = currentContent;
    focusNode.requestFocus();
  }

  void cancelEditComment() {
    editingCommentId.value = null;
    textController.clear();
  }

  Future<void> deleteComment(int commentId) async {
    try {
      final ok = await _campusService.deleteComment(commentId);
      if (ok) {
        if (editingCommentId.value == commentId) {
          cancelEditComment();
        }
        await fetchComments();
      } else {
        Get.snackbar('Error', 'Failed to delete comment');
      }
    } catch (e) {
      debugPrint(' [CommentController] deleteComment error: $e');
    }
  }

  void setReplyTo(int commentId, String username) {
    debugPrint(
      '↩️ [CommentController] setReplyTo commentId=$commentId user=$username',
    );
    editingCommentId.value = null;
    replyToCommentId.value = commentId;
    replyToUsername.value = username;
    focusNode.requestFocus();
  }

  void clearReply() {
    replyToCommentId.value = null;
    replyToUsername.value = '';
  }

  void toggleReplies(int commentId) {
    if (expandedReplies.contains(commentId)) {
      expandedReplies.remove(commentId);
    } else {
      expandedReplies.add(commentId);
    }
  }

  Future<void> toggleLikeComment(int commentId, bool isCurrentlyLiked) async {
    debugPrint(
      '❤️ [CommentController] toggleLike commentId=$commentId liked=$isCurrentlyLiked',
    );
    // Optimistic update
    final listCopy = List<dynamic>.from(comments);
    _mutate(listCopy, commentId, (c) {
      c['isLiked'] = !isCurrentlyLiked;
      c['likeCount'] =
          ((c['likeCount'] ?? 0) as int) + (isCurrentlyLiked ? -1 : 1);
    });
    comments.assignAll(listCopy);

    try {
      final success = isCurrentlyLiked
          ? await _campusService.unlikeComment(commentId)
          : await _campusService.likeComment(commentId);

      debugPrint(' [CommentController] toggleLike api result=$success');
      if (!success) await fetchComments();
    } catch (e) {
      debugPrint(' [CommentController] toggleLikeComment error: $e');
      await fetchComments();
    }
  }

  void _mutate(
    List<dynamic> list,
    int commentId,
    void Function(Map<String, dynamic> c) mutate,
  ) {
    for (var i = 0; i < list.length; i++) {
      if (list[i]['id'] == commentId) {
        final copy = Map<String, dynamic>.from(list[i] as Map);
        mutate(copy);
        list[i] = copy;
        return;
      }
      if ((list[i]['replies'] as List?)?.isNotEmpty == true) {
        _mutate(list[i]['replies'] as List<dynamic>, commentId, mutate);
      }
    }
  }

  @override
  void onClose() {
    debugPrint('💬 [CommentController] onClose postId=$postId');
    textController.dispose();
    focusNode.dispose();
    _socketSub?.cancel();
    super.onClose();
  }
}
