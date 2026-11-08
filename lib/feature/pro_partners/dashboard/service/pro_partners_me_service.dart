// lib/service/pro_partners_dashboard_service.dart
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import '../model/pro_partner_me_model.dart';

class ProPartnersDashboardService {
  final NetworkCaller _networkCaller = NetworkCaller();

  Future<ProPartnerMeResponse> fetchMe({required String accessToken}) async {
    final uri = Uri.parse(Urls.authMe);
    final response = await http.get(
      uri,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
      },
    );

    debugPrint("Api: ${Urls.authMe} Response status: ${response.statusCode}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ProPartnerMeResponse.fromJson(jsonDecode(response.body));
    } else {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Failed to fetch profile');
    }
  }

  Future<Map<String, dynamic>?> fetchOverviewStats({required String accessToken}) async {
    final response = await _networkCaller.getRequest(
      Urls.overviewOfProPartner,
      token: 'Bearer $accessToken',
    );

    if (response.isSuccess && response.responseData['data'] != null) {
      return response.responseData['data'] as Map<String, dynamic>;
    }
    
    return null; 
  }
}