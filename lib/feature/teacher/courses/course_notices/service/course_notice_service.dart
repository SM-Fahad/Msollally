import 'package:msollaally/core/models/response_data.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/teacher/courses/course_notices/model/course_notice_model.dart';

class CourseNoticeService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<List<CourseNotice>> getCourseNotices(int courseId) async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.courseNotices(courseId),
      token: 'Bearer $token',
    );

    final items = _extractListResponse(response);
    return items.map(CourseNotice.fromJson).toList();
  }

  Future<CourseNotice> createCourseNotice({
    required int courseId,
    required String title,
    required String notice,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.postJsonRequest(
      Urls.courseNotices(courseId),
      token: 'Bearer $token',
      body: {'title': title, 'notice': notice},
    );

    final data = _extractMapResponse(response);
    return CourseNotice.fromJson(data);
  }

  Future<CourseNotice> getCourseNoticeDetails(int noticeId) async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.courseNoticeById(noticeId),
      token: 'Bearer $token',
    );

    final data = _extractMapResponse(response);
    return CourseNotice.fromJson(data);
  }

  Future<CourseNotice> updateCourseNotice({
    required int noticeId,
    required String title,
    required String notice,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.putJsonRequest(
      Urls.courseNoticeById(noticeId),
      token: 'Bearer $token',
      body: {'title': title, 'notice': notice},
    );

    final data = _extractMapResponse(response);
    return CourseNotice.fromJson(data);
  }

  Future<void> deleteCourseNotice(int noticeId) async {
    final token = await _requireToken();
    final response = await _networkCaller.deleteRequest(
      Urls.courseNoticeById(noticeId),
      token: 'Bearer $token',
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage);
    }
  }

  Future<String> _requireToken() async {
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }
    return token;
  }

  Map<String, dynamic> _extractMapResponse(ResponseData response) {
    if (!response.isSuccess) {
      throw Exception(response.errorMessage);
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

    throw Exception(response.errorMessage);
  }

  List<Map<String, dynamic>> _extractListResponse(ResponseData response) {
    if (!response.isSuccess) {
      throw Exception(response.errorMessage);
    }

    final payload = response.responseData;
    final list = _extractList(payload);
    if (list.isNotEmpty) {
      return list;
    }

    if (payload is Map<String, dynamic>) {
      return _extractList(payload['data']) +
          _extractList(payload['notices']) +
          _extractList(payload['items']);
    }

    throw Exception(response.errorMessage);
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
