// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/union_model.dart';
import 'package:msollaally/feature/student/campus/campus_home/service/campus_service.dart';
import 'package:msollaally/feature/student/campus/campus_union/model/post_model.dart';
import 'package:msollaally/core/services/websocket/social_socket_service.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/feature/student/profile/service/profile_service.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';

class CampusUnionController extends GetxController {
  final wallTextController = TextEditingController();
  final _campusService = CampusService();
  final _picker = ImagePicker();
  final _profileService = Get.put(ProfileService());

  final union = Rx<UnionModel?>(null);
  final isLoading = false.obs;

  late final SocialSocketService _socialSocketService;
  StreamSubscription? _postLikedSub;
  StreamSubscription? _postUnlikedSub;
  StreamSubscription? _postCommentedSub;

  // Observable list of posts
  var posts = <PostWallModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is UnionModel) {
      union.value = args;
      fetchUnionDetails(args.id);
    } else if (args is int) {
      fetchUnionDetails(args);
    }
    posts.clear();
    _initSocketService();
  }

  void _initSocketService() {
    if (!Get.isRegistered<SocialSocketService>()) {
      Get.put(SocialSocketService());
    }
    _socialSocketService = Get.find<SocialSocketService>();
    _socialSocketService.init();

    _postLikedSub = _socialSocketService.onPostLiked.stream.listen((data) {
      final postId = data['postId'];
      final likeCount = data['likeCount'];
      final likedByUserId = data['likedByUserId'];

      if (postId != null && likeCount != null) {
        final index = posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final originalPost = posts[index];
          bool isLiked = originalPost.isLiked;

          if (Get.isRegistered<StudentProfileController>()) {
            final myId = Get.find<StudentProfileController>().userId.value;
            if (likedByUserId == myId) {
              isLiked = true;
            }
          }

          posts[index] = originalPost.copyWith(
            like: likeCount is int
                ? likeCount
                : int.tryParse('$likeCount') ?? originalPost.like,
            isLiked: isLiked,
          );
        }
      }
    });

    _postUnlikedSub = _socialSocketService.onPostUnliked.stream.listen((data) {
      final postId = data['postId'];
      final likeCount = data['likeCount'];
      final unlikedByUserId = data['unlikedByUserId'];

      if (postId != null && likeCount != null) {
        final index = posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final originalPost = posts[index];
          bool isLiked = originalPost.isLiked;

          if (Get.isRegistered<StudentProfileController>()) {
            final myId = Get.find<StudentProfileController>().userId.value;
            if (unlikedByUserId == myId) {
              isLiked = false;
            }
          }

          posts[index] = originalPost.copyWith(
            like: likeCount is int
                ? likeCount
                : int.tryParse('$likeCount') ?? originalPost.like,
            isLiked: isLiked,
          );
        }
      }
    });

    _postCommentedSub = _socialSocketService.onPostCommented.stream.listen((
      data,
    ) {
      final postId = data['post']?['id'] ?? data['postId'];
      if (postId != null) {
        final index = posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final originalPost = posts[index];
          posts[index] = originalPost.copyWith(
            comment: originalPost.comment + 1,
          );
        }
      }
    });
  }

  Future<void> fetchUnionDetails(int id) async {
    try {
      isLoading.value = true;
      union.value = await _campusService.fetchUnionById(id);
      await fetchUnionPosts(id);
    } catch (e) {
      debugPrint('Error fetching union details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnionPosts(int unionId) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      // Use GET /posts/context?postableType=Union&postableId=... per Feed API spec
      final contextUrl = Uri.parse('https://api.nodmac.com/posts/context')
          .replace(
            queryParameters: {
              'page': '1',
              'limit': '20',
              'postableType': 'Union',
              'postableId': unionId.toString(),
            },
          );

      var response = await http.get(
        contextUrl,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final fallbackUrl = Uri.parse('https://api.nodmac.com/posts').replace(
          queryParameters: {
            'page': '1',
            'limit': '20',
            'postableType': 'Union',
            'postableId': unionId.toString(),
          },
        );
        response = await http.get(
          fallbackUrl,
          headers: {
            'accept': '*/*',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> postsData = decoded is Map<String, dynamic>
            ? (decoded['data'] as List? ?? [])
            : (decoded is List ? decoded : []);

        final filteredPosts = postsData.where((json) {
          if (json is! Map) return false;
          if (json['postableType'] == null) return true;
          return json['postableType'] == 'Union' &&
              json['postableId'] == unionId;
        }).toList();

        final parsedPosts = filteredPosts
            .map((json) => PostWallModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();

        posts.assignAll(parsedPosts);
      } else {
        debugPrint('Failed to fetch posts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
    }
  }

  // ── Join Union ────────────────────────────────────────────────────────────
  Future<void> joinUnion() async {
    final id = union.value?.id;
    if (id == null) return;
    EasyLoading.show(status: 'Joining...');
    try {
      final ok = await _campusService.joinUnion(id);
      if (ok) {
        EasyLoading.showSuccess('Join request sent!');
        fetchUnionDetails(id);
      } else {
        EasyLoading.showError('Failed to join union');
      }
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  // ── Leave Union ───────────────────────────────────────────────────────────
  Future<void> leaveUnion() async {
    final id = union.value?.id;
    if (id == null) return;
    EasyLoading.show(status: 'Leaving...');
    try {
      final ok = await _campusService.leaveUnion(id);
      if (ok) {
        EasyLoading.showSuccess('Left union successfully');
        fetchUnionDetails(id);
      } else {
        EasyLoading.showError('Failed to leave union');
      }
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  // ── Cover Photo ───────────────────────────────────────────────────────────
  Future<void> pickCoverImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1024,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        EasyLoading.show(status: 'Uploading cover...');
        final uploadedUrl = await _profileService.uploadProfileFile(file: file);
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          final unionId = union.value?.id;
          if (unionId != null) {
            final updatedUnion = await _campusService.updateUnion(unionId, {
              'coverImageUrl': uploadedUrl,
            });
            union.value = updatedUnion;
            if (Get.isRegistered<StudentCampusController>()) {
              Get.find<StudentCampusController>().fetchUnions();
            }
            EasyLoading.showSuccess('Cover updated!');
          }
        } else {
          EasyLoading.showError('Upload failed');
        }
      }
    } catch (e) {
      debugPrint('pickCoverImage error: $e');
      EasyLoading.showError('Failed to update cover');
    }
  }

  // ── Invite Member ─────────────────────────────────────────────────────────
  Future<void> inviteMember(int userId) async {
    final id = union.value?.id;
    if (id == null) return;
    EasyLoading.show(status: 'Sending invite...');
    try {
      final errorMsg = await _campusService.inviteToUnion(id, userId);
      if (errorMsg == null) {
        EasyLoading.showSuccess('Invitation sent!');
      } else {
        EasyLoading.showError(errorMsg);
      }
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  // ── Post interactions (local state) ──────────────────────────────────────
  Future<void> toggleLike(PostWallModel post) async {
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index == -1) return;

    final originalPost = posts[index];
    final bool currentlyLiked = originalPost.isLiked;

    posts[index] = originalPost.copyWith(
      like: currentlyLiked
          ? (originalPost.like > 0 ? originalPost.like - 1 : 0)
          : originalPost.like + 1,
      isLiked: !currentlyLiked,
    );

    try {
      final success = currentlyLiked
          ? await _campusService.unlikePost(post.id)
          : await _campusService.likePost(post.id);
      if (!success) {
        posts[index] = originalPost.copyWith(isLiked: !currentlyLiked);
        EasyLoading.showInfo(currentlyLiked ? 'Not unliked' : 'Already liked');
      }
    } catch (e) {
      posts[index] = originalPost;
      EasyLoading.showError('Network error');
    }
  }

  Future<void> deletePost(int id) async {
    try {
      EasyLoading.show(status: 'Deleting...');
      if (await _campusService.deletePost(id)) {
        posts.removeWhere((p) => p.id == id);
        EasyLoading.showSuccess('Deleted');
      }
    } catch (e) {
      EasyLoading.showError('Error deleting post');
    }
  }

  Future<void> updatePost(int id, String content) async {
    try {
      EasyLoading.show(status: 'Updating...');
      if (await _campusService.updatePost(id: id, content: content)) {
        final unionId = union.value?.id;
        if (unionId != null) {
          fetchUnionPosts(unionId);
        }
        EasyLoading.showSuccess('Updated');
      }
    } catch (e) {
      EasyLoading.showError('Error updating post');
    }
  }

  @override
  void onClose() {
    _postLikedSub?.cancel();
    _postUnlikedSub?.cancel();
    _postCommentedSub?.cancel();
    wallTextController.dispose();
    super.onClose();
  }
}
