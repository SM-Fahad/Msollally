import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/end_points.dart';
import '../../../../core/services/share_preferrance_helper.dart';

class FriendshipService extends GetxService {
  Future<dynamic> getSuggestions({int page = 1, int limit = 20}) async {
    final suggestions = await _getRequest('${Urls.friendSuggestions}?page=$page&limit=$limit');
    if (suggestions is List && suggestions.isNotEmpty) {
      return suggestions;
    }
    // Fallback: Query all students across all universities
    final studentUsers = await _getRequest('${Urls.searchCoHost}?role=student&page=$page&limit=$limit');
    if (studentUsers is List && studentUsers.isNotEmpty) {
      return studentUsers;
    }
    final allUsers = await _getRequest('${Urls.searchCoHost}?page=$page&limit=$limit');
    if (allUsers is List && allUsers.isNotEmpty) {
      return allUsers;
    }
    return suggestions ?? [];
  }

  Future<dynamic> getPendingRequests() async {
    return _getRequest(Urls.pendingFriendRequests);
  }

  Future<dynamic> getFriendsByUniversity(int universityId) async {
    return _getRequest(Urls.friendsByUniversity(universityId));
  }

  Future<dynamic> getFriends() async {
    return _getRequest(Urls.friends);
  }

  Future<int> getMutualFriends(int otherUserId) async {
    final response = await _getRequest(
      Urls.mutualFriends(otherUserId),
      returnRaw: true,
    );
    if (response != null && response is Map) {
      return response['mutualCount'] ?? response['count'] ?? 0;
    }
    return 0;
  }

  Future<bool> sendRequest(int receiverId) async {
    return _postRequest(Urls.sendFriendRequest, {'recipientId': receiverId});
  }

  Future<bool> acceptRequest(int requesterId) async {
    return _postRequest(Urls.acceptFriendRequest, {'requesterId': requesterId});
  }

  Future<bool> rejectRequest(int requesterId) async {
    return _postRequest(Urls.rejectFriendRequest, {'requesterId': requesterId});
  }

  Future<bool> removeFriend(int friendId) async {
    return _postRequest(Urls.removeFriend, {'requesterId': friendId});
  }

  Future<dynamic> _getRequest(String url, {bool returnRaw = false}) async {
    debugPrint('🌐 [FriendshipService] GET: $url');
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      if (token == null) {
        debugPrint('⚠️ [FriendshipService] No token found');
        return returnRaw ? null : [];
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'accept': '*/*'},
      );

      debugPrint('📡 [FriendshipService] Status: ${response.statusCode}');
      debugPrint('📄 [FriendshipService] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (returnRaw) return decoded;
        if (decoded is List) return decoded;
        if (decoded is Map && decoded['data'] is List) return decoded['data'];

        // Handle common paginated response structure if applicable
        if (decoded is Map && decoded['friends'] is List) {
          return decoded['friends'];
        }
        if (decoded is Map && decoded['requests'] is List) {
          return decoded['requests'];
        }
        if (decoded is Map && decoded['suggestions'] is List) {
          return decoded['suggestions'];
        }
        if (decoded is Map && decoded['users'] is List) {
          return decoded['users'];
        }
        if (decoded is Map && decoded['students'] is List) {
          return decoded['students'];
        }
        if (decoded is Map && decoded['items'] is List) {
          return decoded['items'];
        }

        return [];
      } else {
        debugPrint('❌ [FriendshipService] GET failed: ${response.statusCode}');
        return returnRaw ? null : [];
      }
    } catch (e) {
      debugPrint('❌ [FriendshipService] Error: $e');
      return returnRaw ? null : [];
    }
  }

  Future<bool> _postRequest(String url, Map<String, dynamic> body) async {
    debugPrint('🌐 [FriendshipService] POST: $url');
    debugPrint('📦 [FriendshipService] Body: ${jsonEncode(body)}');
    try {
      EasyLoading.show(status: 'Loading...');
      final token = await SharedPreferenceHelper().getAccessToken();
      if (token == null) {
        debugPrint('⚠️ [FriendshipService] No token found');
        EasyLoading.dismiss();
        return false;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode(body),
      );

      debugPrint('📡 [FriendshipService] Status: ${response.statusCode}');
      debugPrint('📄 [FriendshipService] Body: ${response.body}');

      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final decoded = jsonDecode(response.body);
        final message =
            decoded['message'] ?? decoded['error'] ?? 'Something went wrong';
        EasyLoading.showError(message.toString());
        return false;
      }
    } catch (e) {
      debugPrint('❌ [FriendshipService] Error: $e');
      EasyLoading.dismiss();
      EasyLoading.showError('Error: $e');
      return false;
    }
  }
}
