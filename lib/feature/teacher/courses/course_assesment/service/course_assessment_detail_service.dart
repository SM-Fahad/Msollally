import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:msollaally/core/models/response_data.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/teacher/courses/course_module/model/course_module_model.dart';

class CourseAssessmentDetailService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<Map<String, dynamic>> getAssessmentDetails(int assessmentId) async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.assessmentById(assessmentId),
      token: 'Bearer $token',
    );

    return _extractMapResponse(
      response,
      // fallbackMessage: 'Failed to load assessment details.',
    );
  }

  Future<List<Map<String, dynamic>>> getAssessmentSubmissions(
    int assessmentId,
  ) async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.assessmentSubmissions(assessmentId),
      token: 'Bearer $token',
    );

    return _extractListResponse(
      response,
      // fallbackMessage: 'Failed to load assessment submissions.',
    );
  }

  Future<Map<String, dynamic>> updateAssessment({
    required int assessmentId,
    required String title,
    required String classroom,
    required String type,
    required String notes,
    required int totalMarks,
    required String questionFormat,
    required String dueDate,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.putJsonRequest(
      Urls.assessmentById(assessmentId),
      token: 'Bearer $token',
      body: {
        'title': title,
        'classroom': classroom,
        'type': type,
        'notes': notes,
        'totalMarks': totalMarks,
        'questionFormat': questionFormat,
        'dueDate': dueDate,
      },
    );

    return _extractMapResponse(
      response,
      fallbackMessage: 'Failed to update assessment.',
    );
  }

  Future<void> deleteAssessment(int assessmentId) async {
    final token = await _requireToken();
    final response = await _networkCaller.deleteRequest(
      Urls.assessmentById(assessmentId),
      token: 'Bearer $token',
    );

    if (!response.isSuccess) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to delete assessment.',
      );
    }
  }

  Future<String> uploadAssessmentFile(File file, {String? fileName}) async {
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
      throw Exception('Failed to upload assessment file.');
    }

    final uploadedUrl = _extractUploadedFileUrl(response.body);
    if (uploadedUrl == null || uploadedUrl.isEmpty) {
      throw Exception('File upload succeeded but URL was missing.');
    }

    return uploadedUrl;
  }

  Future<ClassFile> addAssessmentFile({
    required int assessmentId,
    required String name,
    required String fileUrl,
    required String type,
    required int size,
    required String mimeType,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.postJsonRequest(
      Urls.assessmentFiles(assessmentId),
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
      fallbackMessage: 'Failed to add assessment file.',
    );
    return ClassFile.fromJson(data);
  }

  Future<Map<String, dynamic>> gradeSubmission({
    required int submissionId,
    required int marks,
    required String feedback,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.postJsonRequest(
      Urls.gradeCourseSubmission(submissionId),
      token: 'Bearer $token',
      body: {'marks': marks, 'feedback': feedback},
    );

    return _extractMapResponse(
      response,
      fallbackMessage: 'Failed to grade submission.',
    );
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
    String? fallbackMessage,
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

  List<Map<String, dynamic>> _extractListResponse(
    ResponseData response, {
    String? fallbackMessage,
  }) {
    if (!response.isSuccess) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : fallbackMessage,
      );
    }

    final payload = response.responseData;
    final list = _extractList(payload);
    if (list.isNotEmpty) {
      return list;
    }

    if (payload is Map<String, dynamic>) {
      return _extractList(payload['data']) +
          _extractList(payload['submissions']) +
          _extractList(payload['items']);
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
