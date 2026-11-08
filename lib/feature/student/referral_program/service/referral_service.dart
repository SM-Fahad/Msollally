import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

class ReferralService {
  static Future<Map<String, dynamic>> getUserAuthMe() async {
    final pref = SharedPreferenceHelper();
    final token = await pref.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse(Urls.authMe),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load user info');
  }

  static Future<Map<String, dynamic>> getUserStats() async {
    final pref = SharedPreferenceHelper();
    final token = await pref.getAccessToken();
    
    final response = await http.get(
      Uri.parse(Urls.referStats),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load user stats');
  }

  static Future<Map<String, dynamic>> getReferRole() async {
    final pref = SharedPreferenceHelper();
    final token = await pref.getAccessToken();
    
    final response = await http.get(
      Uri.parse(Urls.referRole),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load referral role');
  }

  static Future<Map<String, dynamic>> applyForLevel(String level) async {
    final pref = SharedPreferenceHelper();
    final token = await pref.getAccessToken();
    
    final response = await http.post(
      Uri.parse(Urls.referApplyLevel),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'requestedLevel': level}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }
    
    if (data['message'] != null) {
       final msg = data['message'];
       if (msg is List) {
         throw Exception(msg.join('\n'));
       } else {
         throw Exception(msg.toString());
       }
    }
    throw Exception(data['error'] ?? 'Failed to apply for level');
  }

  static Future<Map<String, dynamic>> requestPayout({
    required double amount,
    required String provider,
    required String phoneNumber,
    required String accountName,
  }) async {
    final pref = SharedPreferenceHelper();
    final token = await pref.getAccessToken();
    
    final response = await http.post(
      Uri.parse(Urls.referralPayoutRequest),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': amount,
        'provider': provider,
        'phoneNumber': phoneNumber,
        'accountName': accountName,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }
    
    if (data['message'] != null) {
      final msg = data['message'];
      if (msg is List) {
        throw Exception(msg.join('\n'));
      } else {
        throw Exception(msg.toString());
      }
    }
    throw Exception(data['error'] ?? 'Failed to submit payout request');
  }
}
