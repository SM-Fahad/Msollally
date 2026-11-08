import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/teacher/schedule_classes/model/class_schedule_model.dart';

class ClassScheduleService {
  final NetworkCaller _caller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<String?> _bearerToken() async {
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) return null;
    return 'Bearer $token';
  }

  /// Fetches all class schedule entries for the current user.
  Future<List<ClassScheduleModel>> getSchedules() async {
    final token = await _bearerToken();
    final result = await _caller.getRequest(Urls.classSchedule, token: token);

    if (!result.isSuccess) {
      throw Exception(result.errorMessage.isNotEmpty
          ? result.errorMessage
          : 'Failed to load class schedules');
    }

    final data = result.responseData;
    final List<dynamic> items =
        (data is Map && data['data'] is List) ? data['data'] as List : [];

    return items
        .whereType<Map<String, dynamic>>()
        .map(ClassScheduleModel.fromJson)
        .toList();
  }

  /// Creates a new class schedule entry.
  Future<ClassScheduleModel> createSchedule({
    required String title,
    required String description,
    required String date,       // "yyyy-MM-dd"
    required String startTime,  // "HH:mm:ss"
    required String endTime,    // "HH:mm:ss"
  }) async {
    final token = await _bearerToken();
    final result = await _caller.postJsonRequest(
      Urls.classSchedule,
      token: token,
      body: {
        'title': title,
        'description': description,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
      },
    );

    if (!result.isSuccess) {
      throw Exception(result.errorMessage.isNotEmpty
          ? result.errorMessage
          : 'Failed to create class schedule');
    }

    final data = result.responseData;
    final Map<String, dynamic> item =
        (data is Map && data['data'] is Map<String, dynamic>)
            ? data['data'] as Map<String, dynamic>
            : (data is Map<String, dynamic> ? data : {});

    return ClassScheduleModel.fromJson(item);
  }

  /// Fetches a single class schedule entry by its ID.
  Future<ClassScheduleModel> getScheduleById(int id) async {
    final token = await _bearerToken();
    final result = await _caller.getRequest(
      Urls.classScheduleById(id),
      token: token,
    );

    if (!result.isSuccess) {
      throw Exception(result.errorMessage.isNotEmpty
          ? result.errorMessage
          : 'Failed to load schedule details');
    }

    final data = result.responseData;
    final Map<String, dynamic> item =
        (data is Map && data['data'] is Map<String, dynamic>)
            ? data['data'] as Map<String, dynamic>
            : (data is Map<String, dynamic> ? data : {});

    return ClassScheduleModel.fromJson(item);
  }

  /// Updates an existing class schedule entry via PUT.
  Future<ClassScheduleModel> updateSchedule({
    required int id,
    required String title,
    required String description,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    final token = await _bearerToken();
    final result = await _caller.putJsonRequest(
      Urls.classScheduleById(id),
      token: token,
      body: {
        'title': title,
        'description': description,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
      },
    );

    if (!result.isSuccess) {
      throw Exception(result.errorMessage.isNotEmpty
          ? result.errorMessage
          : 'Failed to update class schedule');
    }

    final data = result.responseData;
    final Map<String, dynamic> item =
        (data is Map && data['data'] is Map<String, dynamic>)
            ? data['data'] as Map<String, dynamic>
            : (data is Map<String, dynamic> ? data : {});

    return ClassScheduleModel.fromJson(item);
  }

  /// Deletes a class schedule entry by its ID.
  Future<void> deleteSchedule(int id) async {
    final token = await _bearerToken();
    final result = await _caller.deleteRequest(
      Urls.classScheduleById(id),
      token: token,
    );

    if (!result.isSuccess) {
      throw Exception(result.errorMessage.isNotEmpty
          ? result.errorMessage
          : 'Failed to delete class schedule');
    }
  }
}
