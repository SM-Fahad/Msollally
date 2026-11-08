import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../../../core/services/end_points.dart';
import '../../../../../../core/services/share_preferrance_helper.dart';
import '../../courseDetail/model/course_detail_api_model.dart';
import '../../cr/model/cr_course_model.dart';
import '../../module/model/module_api_model.dart';
import '../../notice/model/course_notice_model.dart';
import '../model/academic_course_model.dart';

class AcademicCourseService {
  // ─── GET /courses  (all available courses for Join screen) ───────────────
  static Future<AcademicCourseResponse> getAllCourses() async {
    debugPrint(
      '📚 [AcademicCourseService] Fetching all courses from: ${Urls.courseList}',
    );
    final response = await _authorizedGet(Urls.courseList);
    debugPrint(
      '📡 [AcademicCourseService] Status Code: ${response.statusCode}',
    );
    debugPrint(
      '📄 [AcademicCourseService] Raw Response Body: ${response.body}',
    );

    final decodedData = _decodeResponse(response.body);
    debugPrint('🔍 [AcademicCourseService] Decoded Data: $decodedData');

    if (_isSuccess(response.statusCode)) {
      final result = AcademicCourseResponse.fromJson(decodedData);
      debugPrint(
        '✅ [AcademicCourseService] Parsed courses count: ${result.courses?.length ?? 0}',
      );
      return result;
    }

    debugPrint(
      '❌ [AcademicCourseService] Request failed with status: ${response.statusCode}',
    );
    throw Exception(
      _extractErrorMessage(decodedData, 'Failed to load courses'),
    );
  }

  // ─── GET /courses/myEnrollCourse  (student's enrolled courses) ───────────
  static Future<AcademicCourseResponse> getMyEnrolledCourses() async {
    debugPrint(
      '🎓 [AcademicCourseService] Fetching enrolled courses from: ${Urls.myEnrolledCourses}',
    );
    final response = await _authorizedGet(Urls.myEnrolledCourses);
    debugPrint(
      '📡 [AcademicCourseService] Status Code: ${response.statusCode}',
    );
    debugPrint(
      '📄 [AcademicCourseService] Raw Response Body: ${response.body}',
    );

    final decodedData = _decodeResponse(response.body);
    debugPrint('🔍 [AcademicCourseService] Decoded Data: $decodedData');

    if (_isSuccess(response.statusCode)) {
      final result = AcademicCourseResponse.fromJson(decodedData);
      debugPrint(
        '✅ [AcademicCourseService] Enrolled courses count: ${result.courses?.length ?? 0}',
      );
      return result;
    }

    debugPrint(
      '❌ [AcademicCourseService] Failed to load enrolled courses: ${response.statusCode}',
    );
    throw Exception(
      _extractErrorMessage(decodedData, 'Failed to load enrolled courses'),
    );
  }

  // ─── POST /courses/{courseId}/enroll ─────────────────────────────────────
  static Future<void> enrollCourse(int courseId) async {
    debugPrint(
      '📝 [AcademicCourseService] Enrolling in course id: $courseId → ${Urls.enrollCourse(courseId)}',
    );
    final token = await SharedPreferenceHelper().getAccessToken();
    debugPrint(
      '🔑 [AcademicCourseService] Token present: ${token != null && token.isNotEmpty}',
    );

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final response = await http.post(
      Uri.parse(Urls.enrollCourse(courseId)),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint(
      '📡 [AcademicCourseService] Enroll Status Code: ${response.statusCode}',
    );
    debugPrint(
      '📄 [AcademicCourseService] Enroll Response Body: ${response.body}',
    );

    if (!_isSuccess(response.statusCode)) {
      final decodedData = _decodeResponse(response.body);
      throw Exception(
        _extractErrorMessage(decodedData, 'Failed to enroll in course'),
      );
    }

    debugPrint(
      '✅ [AcademicCourseService] Successfully enrolled in course $courseId',
    );
  }

  static Future<void> dropCourse(int courseId) async {
    debugPrint(
      '📤 [AcademicCourseService] Dropping course id: $courseId → ${Urls.dropCourse(courseId)}',
    );
    final token = await SharedPreferenceHelper().getAccessToken();
    debugPrint(
      '🔑 [AcademicCourseService] Token present: ${token != null && token.isNotEmpty}',
    );

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final response = await http.post(
      Uri.parse(Urls.dropCourse(courseId)),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint(
      '📡 [AcademicCourseService] Drop Status Code: ${response.statusCode}',
    );
    debugPrint(
      '📄 [AcademicCourseService] Drop Response Body: ${response.body}',
    );

    if (!_isSuccess(response.statusCode)) {
      final decodedData = _decodeResponse(response.body);
      throw Exception(
        _extractErrorMessage(decodedData, 'Failed to drop course'),
      );
    }

    debugPrint(
      '✅ [AcademicCourseService] Successfully dropped course $courseId',
    );
  }

  static Future<List<StudentCourseDashboardItem>> getStudentDashboard() async {
    debugPrint(
      '🗂️ [AcademicCourseService] Fetching student dashboard from: ${Urls.studentDashboard}',
    );
    final response = await _authorizedGet(Urls.studentDashboard);
    debugPrint(
      '📡 [AcademicCourseService] Student dashboard status: ${response.statusCode}',
    );
    debugPrint(
      '📄 [AcademicCourseService] Student dashboard body: ${response.body}',
    );

    final decodedData = _decodeResponse(response.body);
    if (_isSuccess(response.statusCode) && decodedData is List) {
      return decodedData
          .whereType<Map>()
          .map(
            (item) => StudentCourseDashboardItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    throw Exception(
      _extractErrorMessage(decodedData, 'Failed to load dashboard'),
    );
  }

  static Future<CourseDetailApiModel> getCourseById(int courseId) async {
    final url = Urls.courseById(courseId);
    debugPrint('📘 [AcademicCourseService] Fetching course detail from: $url');
    final response = await _authorizedGet(url);
    debugPrint(
      '📡 [AcademicCourseService] Course detail status: ${response.statusCode}',
    );
    debugPrint(
      '📄 [AcademicCourseService] Course detail body: ${response.body}',
    );

    final decodedData = _decodeResponse(response.body);
    if (_isSuccess(response.statusCode) &&
        decodedData is Map<String, dynamic>) {
      return CourseDetailApiModel.fromJson(decodedData);
    }

    throw Exception(
      _extractErrorMessage(decodedData, 'Failed to load course details'),
    );
  }

  static Future<StudentCourseProgressModel> getCourseProgress(
    int courseId,
  ) async {
    final url = Urls.myCourseProgress(courseId);
    debugPrint(
      '📈 [AcademicCourseService] Fetching course progress from: $url',
    );
    final response = await _authorizedGet(url);
    debugPrint(
      '📡 [AcademicCourseService] Course progress status: ${response.statusCode}',
    );
    debugPrint(
      '📄 [AcademicCourseService] Course progress body: ${response.body}',
    );

    final decodedData = _decodeResponse(response.body);
    if (_isSuccess(response.statusCode) &&
        decodedData is Map<String, dynamic>) {
      return StudentCourseProgressModel.fromJson(decodedData);
    }

    throw Exception(
      _extractErrorMessage(decodedData, 'Failed to load course progress'),
    );
  }

  static Future<ModuleApiModel> getModuleById(int moduleId) async {
    final url = Urls.moduleById(moduleId);
    debugPrint('📗 [AcademicCourseService] Fetching module detail from: $url');
    final response = await _authorizedGet(url);
    debugPrint(
      '📡 [AcademicCourseService] Module detail status: ${response.statusCode}',
    );
    debugPrint(
      '📄 [AcademicCourseService] Module detail body: ${response.body}',
    );

    final decodedData = _decodeResponse(response.body);
    if (_isSuccess(response.statusCode) &&
        decodedData is Map<String, dynamic>) {
      return ModuleApiModel.fromJson(decodedData);
    }

    throw Exception(
      _extractErrorMessage(decodedData, 'Failed to load module details'),
    );
  }

  static Future<List<ModuleApiModel>> getCourseModules(int courseId) async {
    final url = Urls.courseModules(courseId);
    debugPrint('📗 [AcademicCourseService] Fetching course modules from: $url');
    final response = await _authorizedGet(url);
    final decodedData = _decodeResponse(response.body);
    if (_isSuccess(response.statusCode)) {
      final list = decodedData is List
          ? decodedData
          : (decodedData is Map && decodedData['data'] is List
              ? decodedData['data']
              : <dynamic>[]);
      return list
          .whereType<Map<String, dynamic>>()
          .map(ModuleApiModel.fromJson)
          .toList();
    }
    return [];
  }

  static Future<List<CourseNoticeModel>> getCourseNotices(int courseId) async {
    final url = Urls.courseNotices(courseId);
    debugPrint('📙 [AcademicCourseService] Fetching course notices from: $url');
    final response = await _authorizedGet(url);
    debugPrint(
      '📡 [AcademicCourseService] Course notices status: ${response.statusCode}',
    );
    debugPrint(
      '📄 [AcademicCourseService] Course notices body: ${response.body}',
    );

    final decodedData = _decodeResponse(response.body);
    if (_isSuccess(response.statusCode) && decodedData is List) {
      return decodedData
          .whereType<Map<String, dynamic>>()
          .map(CourseNoticeModel.fromJson)
          .toList();
    }

    throw Exception(
      _extractErrorMessage(decodedData, 'Failed to load course notices'),
    );
  }

  // ─── GET /courses/my-cr-courses (Student's CR assigned courses) ─────────
  static Future<List<MyCrCourse>> getMyCrCourses() async {
    debugPrint(
      '👑 [AcademicCourseService] Fetching my CR courses from: ${Urls.myCrCourses}',
    );
    try {
      final response = await _authorizedGet(Urls.myCrCourses);
      debugPrint('👑 [AcademicCourseService] Status Code: ${response.statusCode}');
      debugPrint('📄 [AcademicCourseService] CR Body: ${response.body}');

      final decodedData = _decodeResponse(response.body);
      if (_isSuccess(response.statusCode)) {
        final rawData = decodedData is Map<String, dynamic>
            ? (decodedData['data'] ?? decodedData['courses'] ?? [])
            : (decodedData is List ? decodedData : []);

        if (rawData is List) {
          return rawData
              .whereType<Map<String, dynamic>>()
              .map(MyCrCourse.fromJson)
              .toList();
        }
        return [];
      }
    } catch (e) {
      debugPrint('❌ [AcademicCourseService] getMyCrCourses error: $e');
    }
    return [];
  }

  // ─── GET /courses/:courseId/cr (All active CRs for a course) ─────────────
  static Future<List<CourseCrMember>> getCourseCrs(int courseId) async {
    final url = Urls.courseCrs(courseId);
    debugPrint('👥 [AcademicCourseService] Fetching course CRs from: $url');
    try {
      final response = await _authorizedGet(url);
      final decodedData = _decodeResponse(response.body);
      if (_isSuccess(response.statusCode)) {
        final rawData = decodedData is Map<String, dynamic>
            ? (decodedData['data'] ?? [])
            : (decodedData is List ? decodedData : []);

        if (rawData is List) {
          return rawData
              .whereType<Map<String, dynamic>>()
              .map(CourseCrMember.fromJson)
              .toList();
        }
      }
    } catch (e) {
      debugPrint('❌ [AcademicCourseService] getCourseCrs error: $e');
    }
    return [];
  }

  // ─── POST /courses/:courseId/notices (CR Notice Creation) ────────────────
  static Future<bool> createCourseNotice({
    required int courseId,
    required String title,
    required String content,
    bool isImportant = false,
  }) async {
    final url = Urls.courseNotices(courseId);
    debugPrint('📢 [AcademicCourseService] Posting notice to: $url');
    final body = jsonEncode({
      'title': title,
      'notice': content,
      'content': content,
      'isImportant': isImportant,
    });

    final response = await _authorizedPost(url, body);
    debugPrint('📡 [AcademicCourseService] Notice Post Status: ${response.statusCode}');
    debugPrint('📄 [AcademicCourseService] Response: ${response.body}');

    final decodedData = _decodeResponse(response.body);
    if (_isSuccess(response.statusCode)) {
      return true;
    }
    throw Exception(
      _extractErrorMessage(decodedData, 'Failed to publish notice'),
    );
  }

  // ─── Shared helpers ───────────────────────────────────────────────────────
  static Future<http.Response> _authorizedPost(String url, String body) async {
    final token = await SharedPreferenceHelper().getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    return http.post(
      Uri.parse(url),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );
  }
  static Future<http.Response> _authorizedGet(String url) async {
    final token = await SharedPreferenceHelper().getAccessToken();
    debugPrint(
      '🔑 [AcademicCourseService] Token present: ${token != null && token.isNotEmpty}',
    );
    if (token != null && token.isNotEmpty) {
      debugPrint(
        '🔑 [AcademicCourseService] Token (first 20 chars): ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
      );
    }

    if (token == null || token.isEmpty) {
      debugPrint('🚫 [AcademicCourseService] No auth token found!');
      throw Exception('Authentication token not found. Please login again.');
    }

    debugPrint('🌐 [AcademicCourseService] Making GET request to: $url');
    return http.get(
      Uri.parse(url),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  static dynamic _decodeResponse(String body) {
    if (body.isEmpty) {
      debugPrint('⚠️ [AcademicCourseService] Response body is EMPTY');
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(body);
    } catch (e) {
      debugPrint('❌ [AcademicCourseService] JSON decode failed: $e');
      return <String, dynamic>{};
    }
  }

  static bool _isSuccess(int statusCode) {
    return statusCode == 200 || statusCode == 201 || statusCode == 204;
  }

  static String _extractErrorMessage(dynamic decodedData, String fallback) {
    if (decodedData is Map<String, dynamic>) {
      final message = decodedData['message'];
      if (message is String && message.trim().isNotEmpty) return message;
      if (message is List && message.isNotEmpty) return message.join(', ');
    }
    return fallback;
  }
}
