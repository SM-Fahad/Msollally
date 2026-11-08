import 'package:msollaally/core/models/response_data.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/teacher/more/session/model/teacher_session_model.dart';

class TeacherSessionService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<List<TeacherSessionModel>> fetchSessions() async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.sessions,
      token: 'Bearer $token',
    );

    final data = _extractListResponse(
      response,
      fallbackMessage: 'Failed to load sessions.',
    );

    return data.map((item) => TeacherSessionModel.fromJson(item)).toList();
  }

  Future<void> deleteSession(int sessionId) async {
    final token = await _requireToken();
    final response = await _networkCaller.deleteRequest(
      Urls.sessionById(sessionId),
      token: 'Bearer $token',
    );

    if (!response.isSuccess) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to delete session.',
      );
    }
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
    if (payload is List) {
      return payload.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }

    if (payload is Map<String, dynamic>) {
      final nestedData = payload['data'];
      if (nestedData is List) {
        return nestedData
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList();
      }
    }

    throw Exception(fallbackMessage);
  }
}
