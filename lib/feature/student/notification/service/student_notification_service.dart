import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/services/end_points.dart';
import '../../../../core/services/share_preferrance_helper.dart';
import '../model/student_notification_model.dart';

class StudentNotificationService {
  static const Duration _requestTimeout = Duration(seconds: 30);

  static Future<StudentNotificationListResponse> fetchNotifications({
    required String category,
    int page = 1,
    int limit = 20,
  }) async {
    final sharedPrefHelper = SharedPreferenceHelper();
    final token = await sharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final uri = Uri.parse(Urls.notifications).replace(
      queryParameters: {
        'category': category,
        'page': '$page',
        'limit': '$limit',
      },
    );

    final response = await http
        .get(
          uri,
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(_requestTimeout);

    final Map<String, dynamic> decodedData = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return StudentNotificationListResponse.fromJson(decodedData);
    }

    throw Exception(_extractErrorMessage(decodedData));
  }

  static String _extractErrorMessage(Map<String, dynamic> decodedData) {
    final dynamic message = decodedData['message'] ?? decodedData['error'];

    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    if (message is List && message.isNotEmpty) {
      return message.join(', ');
    }

    return 'Failed to load notifications';
  }

  static Future<int> fetchUnreadCount() async {
    final sharedPrefHelper = SharedPreferenceHelper();
    final token = await sharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final response = await http
        .get(
          Uri.parse(Urls.notificationsUnreadCount),
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(_requestTimeout);

    final Map<String, dynamic> decodedData = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return int.tryParse(decodedData['total']?.toString() ?? '') ?? 0;
    }

    throw Exception(_extractErrorMessage(decodedData));
  }

  static Future<StudentNotificationModel> fetchNotificationById(int id) async {
    final sharedPrefHelper = SharedPreferenceHelper();
    final token = await sharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final response = await http
        .get(
          Uri.parse(Urls.notificationById(id)),
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(_requestTimeout);

    final Map<String, dynamic> decodedData = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return StudentNotificationModel.fromJson(
        _extractNotificationMap(decodedData),
      );
    }

    throw Exception(_extractErrorMessage(decodedData));
  }

  static Map<String, dynamic> _extractNotificationMap(
    Map<String, dynamic> decodedData,
  ) {
    if (_isNotificationMap(decodedData)) {
      return decodedData;
    }

    final notificationNode = decodedData['notification'];
    if (_isNotificationMap(notificationNode)) {
      return Map<String, dynamic>.from(notificationNode as Map);
    }

    final dataNode = decodedData['data'];
    if (_isNotificationMap(dataNode)) {
      return Map<String, dynamic>.from(dataNode as Map);
    }

    if (dataNode is Map) {
      final nestedNotification = dataNode['notification'];
      if (_isNotificationMap(nestedNotification)) {
        return Map<String, dynamic>.from(nestedNotification as Map);
      }
    }

    throw Exception('Invalid notification response');
  }

  static bool _isNotificationMap(dynamic value) {
    if (value is! Map) {
      return false;
    }

    return value.containsKey('title') ||
        value.containsKey('message') ||
        (value.containsKey('id') && value.containsKey('type'));
  }

  static Future<void> deleteNotification(int id) async {
    final sharedPrefHelper = SharedPreferenceHelper();
    final token = await sharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final response = await http
        .delete(
          Uri.parse(Urls.notificationById(id)),
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      return;
    }

    final Map<String, dynamic> decodedData = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    throw Exception(_extractErrorMessage(decodedData));
  }

  static Future<void> archiveNotification(int id) async {
    final sharedPrefHelper = SharedPreferenceHelper();
    final token = await sharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final response = await http
        .put(
          Uri.parse(Urls.archiveNotification(id)),
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      return;
    }

    final Map<String, dynamic> decodedData = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    throw Exception(_extractErrorMessage(decodedData));
  }

  static Future<void> markAsRead(int id) async {
    final sharedPrefHelper = SharedPreferenceHelper();
    final token = await sharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final response = await http
        .put(
          Uri.parse(Urls.markNotificationRead(id)),
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      return;
    }

    final Map<String, dynamic> decodedData = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    throw Exception(_extractErrorMessage(decodedData));
  }

  static Future<void> markAllAsRead() async {
    final sharedPrefHelper = SharedPreferenceHelper();
    final token = await sharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final response = await http
        .put(
          Uri.parse(Urls.markAllNotificationsRead),
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      return;
    }

    final Map<String, dynamic> decodedData = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    throw Exception(_extractErrorMessage(decodedData));
  }
}
