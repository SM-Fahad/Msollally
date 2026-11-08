import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/post_model.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/paginated_post_response.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/union_model.dart';
import 'package:msollaally/feature/student/campus/campus_union/model/union_management_models.dart';

class CampusService {
  Future<PaginatedPostResponse> fetchPosts({int page = 1, int limit = 10}) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final url = Uri.parse(Urls.posts).replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Raw Posts Response Body: ${response.body}');
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> postsData = responseData['data'];
        final bool hasNextPage = responseData['meta']?['hasNextPage'] ?? false;
        final posts = postsData.map((json) => PostModel.fromJson(json)).toList();
        return PaginatedPostResponse(posts: posts, hasNextPage: hasNextPage);
      } else {
        throw Exception('Failed to fetch posts: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createPost({required String content, String? mediaUrl}) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final response = await http.post(
        Uri.parse(Urls.posts),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'content': content,
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
          'postableType': 'User',
          'postableId': 0,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updatePost({
    required int id,
    required String content,
    String? mediaUrl,
  }) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final response = await http.put(
        Uri.parse(Urls.postById(id)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'content': content,
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
          'postableType': 'User',
          'postableId': 0,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deletePost(int id) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final response = await http.delete(
        Uri.parse(Urls.postById(id)),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> likePost(int id) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final response = await http.post(
        Uri.parse(Urls.likePost(id)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Like failed: ${response.statusCode} - ${response.body}');
      }

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> unlikePost(int id) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final response = await http.post(
        Uri.parse(Urls.unlikePost(id)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        debugPrint('Unlike failed: ${response.statusCode} - ${response.body}');
      }

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> commentPost(int postId, String content, {int? parentId, String? mediaUrl}) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final body = <String, dynamic>{'content': content};
      if (parentId != null) {
        body['parentCommentId'] = parentId;
      }
      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        body['mediaUrl'] = mediaUrl;
      }

      final response = await http.post(
        Uri.parse(Urls.createCommentOrReply(postId)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint(
        '📝 [CampusService] Comment Submit Response: ${response.body}',
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> fetchComments(int postId) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final response = await http.get(
        Uri.parse(Urls.getCommentsForPost(postId)),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) return decoded;
        return decoded['data'] ?? decoded['comments'] ?? [];
      }
      return [];
    } catch (e) {
      debugPrint('fetchComments error: $e');
      return [];
    }
  }

  Future<bool> likeComment(int commentId) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final response = await http.post(
        Uri.parse(Urls.likeComment(commentId)),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('likeComment error: $e');
      return false;
    }
  }

  Future<bool> unlikeComment(int commentId) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final response = await http.delete(
        Uri.parse(Urls.unlikeComment(commentId)),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('unlikeComment error: $e');
      return false;
    }
  }

  Future<UnionResponseModel> fetchUnions({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final url = Uri.parse(Urls.unions).replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (status != null) 'status': status,
        },
      );

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UnionResponseModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch unions: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UnionModel> createUnion(Map<String, dynamic> data) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final response = await http.post(
        Uri.parse(Urls.unions),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UnionModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create union: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UnionModel> fetchUnionById(int id) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final response = await http.get(
        Uri.parse(Urls.unionById(id)),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UnionModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch union: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ─── Join a union ────────────────────────────────────────────────────────
  Future<bool> joinUnion(int unionId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.post(
        Uri.parse(Urls.joinUnion(unionId)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      debugPrint('joinUnion ${response.statusCode}: ${response.body}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      rethrow;
    }
  }

  // ─── Leave a union ───────────────────────────────────────────────────────
  Future<bool> leaveUnion(int unionId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.post(
        Uri.parse(Urls.leaveUnion(unionId)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      debugPrint('leaveUnion ${response.statusCode}: ${response.body}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      rethrow;
    }
  }

  // ─── Update union (President only) ──────────────────────────────────────
  Future<UnionModel> updateUnion(int unionId, Map<String, dynamic> data) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.put(
        Uri.parse(Urls.updateUnion(unionId)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return UnionModel.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update union: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  // ─── Delete union (President only) ──────────────────────────────────────
  Future<bool> deleteUnion(int unionId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.delete(
        Uri.parse(Urls.deleteUnion(unionId)),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      debugPrint('deleteUnion ${response.statusCode}: ${response.body}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      rethrow;
    }
  }

  // ─── Get union members ───────────────────────────────────────────────────
  Future<List<UnionMemberModel>> fetchUnionMembers(int unionId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.get(
        Uri.parse(Urls.unionMembers(unionId)),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final list = _decodeList(decoded, keys: ['data', 'members']);
        return list.map((e) => UnionMemberModel.fromJson(e)).toList();
      }
      throw Exception('Failed to fetch members: ${response.statusCode}');
    } catch (e) {
      debugPrint('fetchUnionMembers error: $e');
      return [];
    }
  }

  // ─── Get union officials ─────────────────────────────────────────────────
  Future<List<UnionMemberModel>> fetchUnionOfficials(int unionId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.get(
        Uri.parse(Urls.unionOfficials(unionId)),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final list = _decodeList(decoded, keys: ['data', 'officials']);
        return list.map((e) => UnionMemberModel.fromJson(e)).toList();
      }
      throw Exception('Failed to fetch officials: ${response.statusCode}');
    } catch (e) {
      debugPrint('fetchUnionOfficials error: $e');
      return [];
    }
  }

  // ─── Get pending join requests (Admin only) ──────────────────────────────
  Future<List<UnionMemberModel>> fetchPendingRequests(int unionId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.get(
        Uri.parse(Urls.unionPendingRequests(unionId)),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      debugPrint(
        'fetchPendingRequests ${response.statusCode}: ${response.body}',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final list = _decodeList(
          decoded,
          keys: ['data', 'pendingRequests', 'requests'],
        );
        return list.map((e) => UnionMemberModel.fromJson(e)).toList();
      }
      throw Exception(
        'Failed to fetch pending requests: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('fetchPendingRequests error: $e');
      return [];
    }
  }

  /// Safely extract a List from a decoded JSON value.
  /// If [decoded] is already a List (plain-array response), returns it directly.
  /// Otherwise tries each key in [keys] on the Map until one is a List.
  List<dynamic> _decodeList(dynamic decoded, {List<String> keys = const []}) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      for (final key in keys) {
        if (decoded[key] is List) return decoded[key] as List;
      }
    }
    return [];
  }

  // ─── Approve member join request (Admin only) ────────────────────────────
  Future<bool> approveUnionMember(int unionId, int memberId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.post(
        Uri.parse(Urls.approveUnionMember(unionId, memberId)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      debugPrint('approveUnionMember ${response.statusCode}: ${response.body}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      rethrow;
    }
  }

  // ─── Reject member join request (Admin only) ─────────────────────────────
  Future<bool> rejectUnionMember(int unionId, int memberId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.post(
        Uri.parse(Urls.rejectUnionMember(unionId, memberId)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      debugPrint('rejectUnionMember ${response.statusCode}: ${response.body}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      rethrow;
    }
  }

  // ─── Update member role (President only) ─────────────────────────────────
  Future<bool> updateMemberRole(int unionId, int memberId, String role) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.put(
        Uri.parse(Urls.updateMemberRole(unionId, memberId)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'role': role}),
      );
      debugPrint('updateMemberRole ${response.statusCode}: ${response.body}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      rethrow;
    }
  }

  // ─── Remove member from union (Admin only) ───────────────────────────────
  Future<bool> removeUnionMember(int unionId, int memberId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.delete(
        Uri.parse(Urls.removeUnionMember(unionId, memberId)),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      debugPrint('removeUnionMember ${response.statusCode}: ${response.body}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      rethrow;
    }
  }

  // ─── Get union statistics ────────────────────────────────────────────────
  Future<UnionStatsModel> fetchUnionStats(int unionId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.get(
        Uri.parse(Urls.unionStats(unionId)),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return UnionStatsModel.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to fetch union stats: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  // ─── Transfer presidency (President only) ───────────────────────────────
  Future<bool> transferPresidency(int unionId, int newPresidentUserId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.post(
        Uri.parse(Urls.transferPresidency(unionId)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'newPresidentUserId': newPresidentUserId}),
      );
      debugPrint('transferPresidency ${response.statusCode}: ${response.body}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      rethrow;
    }
  }

  // ─── Invite a user to join a union ──────────────────────────────────────
  /// Returns null on success, or the server's error message string on failure.
  Future<String?> inviteToUnion(int unionId, int memberId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.post(
        Uri.parse(Urls.inviteMember(unionId, memberId)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      debugPrint('inviteToUnion ${response.statusCode}: ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null; // success
      }
      // Parse the server's error message
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['message']?.toString() ??
            body['error']?.toString() ??
            'Failed to send invitation';
      } catch (_) {
        return 'Failed to send invitation (${response.statusCode})';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  // ─── View received invitations for current user ──────────────────────────
  Future<List<UnionInvitationModel>> fetchMyInvitations() async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.get(
        Uri.parse(Urls.viewInvitations),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final list = decoded['data'] ?? decoded['invitations'] ?? decoded ?? [];
        return (list as List)
            .map((e) => UnionInvitationModel.fromJson(e))
            .toList();
      }
      throw Exception('Failed to fetch invitations: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  // ─── Accept an invitation to join a union ───────────────────────────────
  Future<bool> acceptInvitation(int unionId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.post(
        Uri.parse(Urls.acceptInvite(unionId)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      debugPrint('acceptInvitation ${response.statusCode}: ${response.body}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      rethrow;
    }
  }
}
