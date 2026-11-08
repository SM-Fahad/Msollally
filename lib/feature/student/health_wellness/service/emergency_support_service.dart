import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/feature/student/health_wellness/model/emergency_support_model.dart';
import 'package:msollaally/core/utils/logging/logger.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

class EmergencySupportService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<List<EmergencySupportModel>?> getEmergencySupport({
    required int page,
    required int limit,
    required String supportType,
    String? type,
  }) async {
    final token = await _prefs.getAccessToken();
    String url = '${Urls.emergencySupport}?page=$page&limit=$limit&supportType=$supportType';
    if (type != null && type.isNotEmpty && type != 'all') {
      url += '&type=$type';
    }

    try {
      final response = await _networkCaller.getRequest(
        url,
        token: token != null ? 'Bearer $token' : null,
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.responseData['data'];
        return data.map((json) => EmergencySupportModel.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      AppLoggerHelper.error('Error fetching emergency support: $e');
      return null;
    }
  }
}
