import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

import '../model/campaign_notice_model.dart';

class CampaignNoticeService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<List<CampaignNoticeModel>> fetchNotices(int campaignId) async {
    final token = await _prefs.getAccessToken();
    final response = await _networkCaller.getRequest(
      Urls.getNotice('$campaignId'),
      token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage);
    }

    final body = response.responseData;
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map>()
        .map((e) => CampaignNoticeModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<CampaignNoticeModel> createNotice({
    required int campaignId,
    required String title,
    required String notice,
  }) async {
    final token = await _prefs.getAccessToken();
    final response = await _networkCaller.postJsonRequest(
      Urls.postNotice('$campaignId'),
      body: {'title': title, 'notice': notice},
      token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage);
    }

    final body = response.responseData;
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid create notice response');
    }

    return CampaignNoticeModel.fromJson(data);
  }

  Future<CampaignNoticeModel> updateNotice({
    required int noticeId,
    required String title,
    required String notice,
  }) async {
    final token = await _prefs.getAccessToken();
    final response = await _networkCaller.putJsonRequest(
      Urls.updateNotice('$noticeId'),
      body: {'title': title, 'notice': notice},
      token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage);
    }

    final body = response.responseData;
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid update notice response');
    }

    return CampaignNoticeModel.fromJson(data);
  }
}
