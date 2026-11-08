import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

import '../model/campaign_stats_model.dart';

class CampaignStatsService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<CampaignStatsModel> fetchStats(int campaignId) async {
    final token = await _prefs.getAccessToken();
    final response = await _networkCaller.getRequest(
      Urls.getCampaignStats('$campaignId'),
      token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage);
    }

    final body = response.responseData;
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid campaign stats response');
    }

    return CampaignStatsModel.fromJson(data);
  }
}
