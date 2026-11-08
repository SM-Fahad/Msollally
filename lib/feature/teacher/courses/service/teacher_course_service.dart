import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:msollaally/core/models/response_data.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/teacher/courses/model/teacher_course_model.dart';

class TeacherCourseService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<List<TeacherCourseModel>> getMyCourses() async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.myCourses,
      token: 'Bearer $token',
    );

    if (!response.isSuccess) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to load courses.',
      );
    }

    final list = _extractList(response.responseData);
    return list.map(TeacherCourseModel.fromJson).toList();
  }

  Future<TeacherCourseModel> createCourse({
    required String title,
    required String description,
    required String courseCode,
    required File coverImageFile,
    required DateTime startDate,
    required DateTime endDate,
    required bool isPublic,
  }) async {
    final token = await _requireToken();

    final coverImageUrl = await uploadCoverImage(
      coverImageFile: coverImageFile,
      token: token,
    );

    final response = await _networkCaller.postJsonRequest(
      Urls.courseList,
      token: 'Bearer $token',
      body: {
        'title': title,
        'description': description,
        'courseCode': courseCode,
        'coverImage': coverImageUrl,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isPublic': isPublic,
      },
    );

    final data = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to create course.',
    );

    return TeacherCourseModel.fromJson(data);
  }

  Future<TeacherCourseModel> updateCourse({
    required int courseId,
    required String title,
    required String description,
    required String courseCode,
    required String currentCoverImage,
    File? coverImageFile,
    required DateTime startDate,
    required DateTime endDate,
    required String status,
    required bool isPublic,
  }) async {
    final token = await _requireToken();
    var coverImageUrl = currentCoverImage;
    if (coverImageFile != null) {
      coverImageUrl = await uploadCoverImage(
        coverImageFile: coverImageFile,
        token: token,
      );
    }

    final response = await _networkCaller.putJsonRequest(
      Urls.courseById(courseId),
      token: 'Bearer $token',
      body: {
        'title': title,
        'description': description,
        'courseCode': courseCode,
        'coverImage': coverImageUrl,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status,
        'isPublic': isPublic,
      },
    );

    final data = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to update course.',
    );

    return TeacherCourseModel.fromJson(data);
  }

  Future<void> deleteCourse(int courseId) async {
    final token = await _requireToken();
    final response = await _networkCaller.deleteRequest(
      Urls.courseById(courseId),
      token: 'Bearer $token',
    );

    if (!response.isSuccess) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to delete course.',
      );
    }
  }

  Future<TeacherCourseModel> publishCourse(int courseId) async {
    final token = await _requireToken();
    final response = await _networkCaller.postJsonRequest(
      Urls.publishCourse(courseId),
      token: 'Bearer $token',
      body: const <String, dynamic>{},
    );

    final data = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to publish course.',
    );

    return TeacherCourseModel.fromJson(data);
  }

  Future<TeacherCourseModel> cloneCourse({
    required int courseId,
    required String title,
    required String courseCode,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.postJsonRequest(
      Urls.cloneCourse(courseId),
      token: 'Bearer $token',
      body: {'title': title, 'courseCode': courseCode},
    );

    final data = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to clone course.',
    );

    return TeacherCourseModel.fromJson(data);
  }

  Future<String> uploadCoverImage({
    required File coverImageFile,
    required String token,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(Urls.uploadCloudinaryFile),
    );

    request.headers.addAll({'accept': '*/*', 'Authorization': 'Bearer $token'});

    request.files.add(
      await http.MultipartFile.fromPath('files', coverImageFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to upload cover image.');
    }

    final uploadedUrl = _extractUploadedFileUrl(response.body);
    if (uploadedUrl == null || uploadedUrl.isEmpty) {
      throw Exception('Cover image upload succeeded but URL was missing.');
    }

    return uploadedUrl;
  }

  Future<String> _requireToken() async {
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }
    return token;
  }

  Map<String, dynamic> _extractMapResponse(
    ResponseData response, {
    required String fallbackMessage,
  }) {
    if (!response.isSuccess) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : fallbackMessage,
      );
    }

    final payload = response.responseData;
    if (payload is Map<String, dynamic>) {
      final nestedData = payload['data'];
      if (nestedData is Map<String, dynamic>) {
        return nestedData;
      }
      if (nestedData is Map) {
        return Map<String, dynamic>.from(nestedData);
      }
      return payload;
    }
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }

    throw Exception(fallbackMessage);
  }

  List<Map<String, dynamic>> _extractList(dynamic payload) {
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (payload is Map<String, dynamic>) {
      final nestedData = payload['data'];
      if (nestedData is List) {
        return nestedData
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return const <Map<String, dynamic>>[];
  }

  String? _extractUploadedFileUrl(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);

      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map<String, dynamic>) {
          final url = first['url'] ?? first['secure_url'] ?? first['fileUrl'];
          return url?.toString();
        }
      }

      if (decoded is Map<String, dynamic>) {
        final topLevelUrl =
            decoded['url'] ?? decoded['secure_url'] ?? decoded['fileUrl'];
        if (topLevelUrl != null) {
          return topLevelUrl.toString();
        }

        final data = decoded['data'];
        if (data is List && data.isNotEmpty) {
          final first = data.first;
          if (first is Map<String, dynamic>) {
            final dataUrl =
                first['url'] ?? first['secure_url'] ?? first['fileUrl'];
            return dataUrl?.toString();
          }
        }

        if (data is Map<String, dynamic>) {
          final dataUrl = data['url'] ?? data['secure_url'] ?? data['fileUrl'];
          return dataUrl?.toString();
        }
      }
    } catch (_) {}

    return null;
  }
}
