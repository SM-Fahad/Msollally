import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:msollaally/core/models/response_data.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/teacher/courses/course_module/model/course_module_model.dart';

class ClassService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<CourseClass> createClass({
    required int moduleId,
    required String title,
    required String classroom,
    required String topic,
    required String notes,
    required DateTime startTime,
    required DateTime endTime,
    required int orderIndex,
    required List<String> topics,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.postJsonRequest(
      Urls.moduleClasses(moduleId),
      token: 'Bearer $token',
      body: {
        'title': title,
        'classroom': classroom,
        'topic': topic,
        'notes': notes,
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
        'orderIndex': orderIndex,
        'topics': topics,
      },
    );

    final data = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to create class.',
    );
    return CourseClass.fromJson(data);
  }

  Future<CourseClass> updateClass({
    required int classId,
    required String title,
    required String classroom,
    required String topic,
    required String notes,
    required DateTime startTime,
    required DateTime endTime,
    required int orderIndex,
    required List<String> topics,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.putJsonRequest(
      Urls.classById(classId),
      token: 'Bearer $token',
      body: {
        'title': title,
        'classroom': classroom,
        'topic': topic,
        'notes': notes,
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
        'orderIndex': orderIndex,
        'topics': topics,
      },
    );

    final data = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to update class.',
    );
    return CourseClass.fromJson(data);
  }

  Future<CourseClass> getClassDetails(int classId) async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.classById(classId),
      token: 'Bearer $token',
    );

    final data = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to load class details.',
    );
    return CourseClass.fromJson(data);
  }

  Future<ClassFile> addClassFile({
    required int classId,
    required String name,
    required String fileUrl,
    required String type,
    required int size,
    required String mimeType,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.postJsonRequest(
      Urls.classFiles(classId),
      token: 'Bearer $token',
      body: {
        'name': name,
        'fileUrl': fileUrl,
        'type': type,
        'size': size,
        'mimeType': mimeType,
      },
    );

    final data = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to add class file.',
    );
    return ClassFile.fromJson(data);
  }

  Future<void> deleteClass(int classId) async {
    final token = await _requireToken();
    final response = await _networkCaller.deleteRequest(
      Urls.classById(classId),
      token: 'Bearer $token',
    );

    if (!response.isSuccess) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to delete class.',
      );
    }
  }

  Future<String> uploadClassFile(File file, {String? fileName}) async {
    final token = await _requireToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(Urls.uploadCloudinaryFile),
    );

    request.headers.addAll({'accept': '*/*', 'Authorization': 'Bearer $token'});
    request.files.add(
      await http.MultipartFile.fromPath('files', file.path, filename: fileName),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to upload class file.');
    }

    final uploadedUrl = _extractUploadedFileUrl(response.body);
    if (uploadedUrl == null || uploadedUrl.isEmpty) {
      throw Exception('File upload succeeded but URL was missing.');
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
