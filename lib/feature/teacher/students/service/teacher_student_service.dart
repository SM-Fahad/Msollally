import 'package:msollaally/core/models/response_data.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/teacher/students/model/teacher_student_enrollment_model.dart';

class TeacherStudentService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<List<TeacherStudentEnrollmentModel>> getMyStudents() async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.facultyMyStudents,
      token: 'Bearer $token',
    );

    final items = _extractListResponse(
      response,
      fallbackMessage: 'Failed to load students.',
    );

    return items.map(TeacherStudentEnrollmentModel.fromJson).toList();
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
  }) {
    if (!response.isSuccess) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : fallbackMessage,
      );
    }

    final payload = response.responseData;
    final topLevelList = _extractList(payload);
    if (topLevelList.isNotEmpty) {
      return topLevelList;
    }

    if (payload is Map<String, dynamic>) {
      final dataList = _extractList(payload['data']);
      if (dataList.isNotEmpty) {
        return dataList;
      }
      final studentList = _extractList(payload['students']);
      if (studentList.isNotEmpty) {
        return studentList;
      }
      final itemList = _extractList(payload['items']);
      if (itemList.isNotEmpty) {
        return itemList;
      }
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
