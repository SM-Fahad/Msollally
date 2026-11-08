import 'package:msollaally/core/models/response_data.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

class CourseAssessmentService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<List<Map<String, dynamic>>> getAssessments(
    int courseId, {
    String? type,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      _buildAssessmentsUrl(courseId, type: type),
      token: 'Bearer $token',
    );

    return _extractListResponse(
      response,
      // fallbackMessage: 'Failed to load assessments.',
    );
  }

  Future<Map<String, dynamic>> createAssessment({
    required int courseId,
    required String title,
    required String classroom,
    required String type,
    required String notes,
    required int totalMarks,
    required String questionFormat,
    required String dueDate,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.postJsonRequest(
      Urls.courseAssessments(courseId),
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
      fallbackMessage: 'Failed to create assessment.',
    );
  }

  Future<String> _requireToken() async {
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }
    return token;
  }

  String _buildAssessmentsUrl(int courseId, {String? type}) {
    if (type == null || type.isEmpty) {
      return Urls.courseAssessments(courseId);
    }

    return Uri.parse(
      Urls.courseAssessments(courseId),
    ).replace(queryParameters: {'type': type}).toString();
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
          _extractList(payload['assessments']) +
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
}
