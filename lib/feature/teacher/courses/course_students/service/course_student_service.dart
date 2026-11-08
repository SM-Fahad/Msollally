import 'package:msollaally/core/models/response_data.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/teacher/courses/course_students/model/course_group_model.dart';
import 'package:msollaally/feature/teacher/courses/course_students/model/course_student_chat_model.dart';

class CourseStudentService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<List<CourseStudentChatModel>> getCourseStudents(int courseId) async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.courseStudents(courseId),
      token: 'Bearer $token',
    );

    final items = _extractListResponse(
      response,
      fallbackMessage: 'Failed to load students.',
    );

    return items.map(CourseStudentChatModel.fromJson).toList();
  }

  Future<List<CourseGroupModel>> getCourseGroups(int courseId) async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.courseGroups(courseId),
      token: 'Bearer $token',
    );

    final items = _extractListResponse(
      response,
      fallbackMessage: 'Failed to load groups.',
      primaryKeys: const ['groups'],
    );

    return items.map(CourseGroupModel.fromJson).toList();
  }

  Future<CourseGroupModel> getCourseGroupById(int groupId) async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.courseGroupById(groupId),
      token: 'Bearer $token',
    );

    final item = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to load group.',
      primaryKeys: const ['group'],
    );

    return CourseGroupModel.fromJson(item);
  }

  Future<void> createCourseGroup({
    required int courseId,
    required String name,
    required List<int> memberIds,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.postJsonRequest(
      Urls.courseGroups(courseId),
      token: 'Bearer $token',
      body: <String, dynamic>{'name': name, 'memberIds': memberIds},
    );

    _ensureSuccess(response, fallbackMessage: 'Failed to create group.');
  }

  Future<void> updateCourseGroup({
    required int groupId,
    required String name,
    required List<int> memberIds,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.putJsonRequest(
      Urls.courseGroupById(groupId),
      token: 'Bearer $token',
      body: <String, dynamic>{'name': name, 'memberIds': memberIds},
    );

    _ensureSuccess(response, fallbackMessage: 'Failed to update group.');
  }

  Future<void> deleteCourseGroup(int groupId) async {
    final token = await _requireToken();
    final response = await _networkCaller.deleteRequest(
      Urls.courseGroupById(groupId),
      token: 'Bearer $token',
    );

    _ensureSuccess(response, fallbackMessage: 'Failed to delete group.');
  }

  Future<String> _requireToken() async {
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }
    return token;
  }

  List<Map<String, dynamic>> _extractListResponse(
    ResponseData response, {
    required String fallbackMessage,
    List<String> primaryKeys = const [],
  }) {
    _ensureSuccess(response, fallbackMessage: fallbackMessage);

    final payload = response.responseData;
    final list = _extractList(payload);
    if (list.isNotEmpty) {
      return list;
    }

    if (payload is Map<String, dynamic>) {
      for (final key in primaryKeys) {
        final keyedList = _extractList(payload[key]);
        if (keyedList.isNotEmpty) {
          return keyedList;
        }
      }

      return _extractList(payload['data']) +
          _extractList(payload['students']) +
          _extractList(payload['groups']) +
          _extractList(payload['items']);
    }

    throw Exception(fallbackMessage);
  }

  Map<String, dynamic> _extractMapResponse(
    ResponseData response, {
    required String fallbackMessage,
    List<String> primaryKeys = const [],
  }) {
    _ensureSuccess(response, fallbackMessage: fallbackMessage);

    final payload = response.responseData;
    if (payload is Map<String, dynamic>) {
      for (final key in primaryKeys) {
        final nested = _extractMap(payload[key]);
        if (nested.isNotEmpty) {
          return nested;
        }
      }

      final dataMap = _extractMap(payload['data']);
      if (dataMap.isNotEmpty) {
        return dataMap;
      }

      if (payload.isNotEmpty) {
        return payload;
      }
    }

    throw Exception(fallbackMessage);
  }

  void _ensureSuccess(
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

  Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    return const <String, dynamic>{};
  }
}
