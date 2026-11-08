import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

class StudentCampusCampaignService {
  Future<Map<String, dynamic>> fetchCampaigns({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'order': 'DESC',
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final url = Uri.parse('${Urls.baseUrl}/campaigns/published').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final meta = decoded['meta'] as Map<String, dynamic>?;
        final totalPages = meta?['totalPages'] as int? ?? 1;
        
        final List<dynamic> dataList = decoded['data'] ?? [];
        final mappedList = dataList.map((json) {
          final clicks =
              int.tryParse(json['clickCount']?.toString() ?? '0') ?? 0;
          final impressions =
              int.tryParse(json['impressions']?.toString() ?? '0') ?? 0;
          final ctrVal = impressions > 0 ? (clicks / impressions * 100) : 0.0;

          final author = json['author'] as Map<String, dynamic>?;
          String authorName = 'Career Partners';
          if (author != null) {
            final proPartnerName = author['proPartnerName']?.toString();
            final username = author['username']?.toString();
            if (proPartnerName != null &&
                proPartnerName != 'N/A' &&
                proPartnerName.isNotEmpty) {
              authorName = proPartnerName;
            } else if (username != null && username.isNotEmpty) {
              authorName = username;
            }
          }

          String tag = 'Active';
          final status = json['status']?.toString().toLowerCase();
          if (status != null && status.isNotEmpty) {
            tag = status[0].toUpperCase() + status.substring(1);
          }

          return {
            'id': (json['id'] ?? '').toString(),
            'title': (json['campaignTitle'] ?? 'Untitled Campaign').toString(),
            'tag': tag,
            'clicks': '$clicks Clicks',
            'spent': 'AED ${json['spentBudget'] ?? '0'}',
            'ctr': '${ctrVal.toStringAsFixed(1)}%',
            'description': (json['description'] ?? '').toString(),
            'imageOrVideoLink': (json['imageOrVideoLink'] ?? '').toString(),
            'caption': (json['caption'] ?? '').toString(),
            'destinationUrl': (json['destinationUrl'] ?? '').toString(),
            'callToAction': (json['callToAction'] ?? 'apply').toString(),
            'isSponsored': (json['isSponsored'] ?? false).toString(),
            'totalBudget': (json['totalBudget'] ?? '0').toString(),
            'startDate': (json['startDate'] ?? '').toString(),
            'endDate': (json['endDate'] ?? '').toString(),
            'university': (json['university'] is List)
                ? (json['university'] as List).join(', ')
                : (json['university'] ?? '').toString(),
            'major': (json['major'] is List)
                ? (json['major'] as List).join(', ')
                : (json['major'] ?? '').toString(),
            'yearOfStudy': (json['yearOfStudy'] ?? '').toString(),
            'gender': (json['gender'] is List)
                ? (json['gender'] as List).join(', ')
                : (json['gender'] ?? '').toString(),
            'authorName': authorName,
            'authorAvatar': (author?['profile']?['profilePicture'] ??
                    author?['profilePicture'] ??
                    author?['avatar'] ??
                    author?['logo'] ??
                    '')
                .toString(),
          };
        }).toList();
        
        return {
          'data': mappedList,
          'totalPages': totalPages,
        };
      } else {
        throw Exception('Failed to fetch campaigns: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('fetchCampaigns error: $e');
      return {
        'data': <Map<String, String>>[],
        'totalPages': 1,
      };
    }
  }

  Future<Map<String, dynamic>> fetchCampaignDetails(String campaignId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse(Urls.getCampaign(campaignId));

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final json = decoded['data'] ?? {};

        final clicks = int.tryParse(json['clickCount']?.toString() ?? '0') ?? 0;
        final impressions =
            int.tryParse(json['impressions']?.toString() ?? '0') ?? 0;
        final ctrVal = impressions > 0 ? (clicks / impressions * 100) : 0.0;

        final author = json['author'] as Map<String, dynamic>?;
        String authorName = 'Career Partners';
        if (author != null) {
          final proPartnerName = author['proPartnerName']?.toString();
          final username = author['username']?.toString();
          if (proPartnerName != null &&
              proPartnerName != 'N/A' &&
              proPartnerName.isNotEmpty) {
            authorName = proPartnerName;
          } else if (username != null && username.isNotEmpty) {
            authorName = username;
          }
        }

        String tag = 'Active';
        final status = json['status']?.toString().toLowerCase();
        if (status != null && status.isNotEmpty) {
          tag = status[0].toUpperCase() + status.substring(1);
        }

        return {
          'id': (json['id'] ?? '').toString(),
          'title': (json['campaignTitle'] ?? 'Untitled Campaign').toString(),
          'tag': tag,
          'clicks': '$clicks Clicks',
          'spent': 'AED ${json['spentBudget'] ?? '0'}',
          'ctr': '${ctrVal.toStringAsFixed(1)}%',
          'description': (json['description'] ?? '').toString(),
          'imageOrVideoLink': (json['imageOrVideoLink'] ?? '').toString(),
          'caption': (json['caption'] ?? '').toString(),
          'destinationUrl': (json['destinationUrl'] ?? '').toString(),
          'callToAction': (json['callToAction'] ?? 'apply').toString(),
          'isSponsored': (json['isSponsored'] ?? false).toString(),
          'totalBudget': (json['totalBudget'] ?? '0').toString(),
          'startDate': (json['startDate'] ?? '').toString(),
          'endDate': (json['endDate'] ?? '').toString(),
          'university': (json['university'] is List)
              ? (json['university'] as List).join(', ')
              : (json['university'] ?? '').toString(),
          'major': (json['major'] is List)
              ? (json['major'] as List).join(', ')
              : (json['major'] ?? '').toString(),
          'yearOfStudy': (json['yearOfStudy'] ?? '').toString(),
          'authorName': authorName,
          'totalParticipants': (json['totalParticipants'] ?? '0').toString(),
          'qualifiedParticipants': (json['qualifiedParticipants'] ?? '0')
              .toString(),
          'daysRemaining': (json['daysRemaining'] ?? '0').toString(),
          'likeCount': (json['likeCount'] ?? '0').toString(),
          'commentCount': (json['commentCount'] ?? '0').toString(),
          'isLikedByMe': (json['isLikedByMe'] ?? false).toString(),
          'likes': json['likes'] ?? [],
          'comments': json['comments'] ?? [],
        };
      } else {
        throw Exception(
          'Failed to fetch campaign details: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('fetchCampaignDetails error: $e');
      rethrow;
    }
  }

  Future<bool> likeCampaign(String campaignId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse('${Urls.baseUrl}/campaigns/$campaignId/like');

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('likeCampaign error: $e');
      return false;
    }
  }

  Future<bool> unlikeCampaign(String campaignId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse('${Urls.baseUrl}/campaigns/$campaignId/unlike');

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('unlikeCampaign error: $e');
      return false;
    }
  }

  Future<bool> commentCampaign(String campaignId, String content) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse('${Urls.baseUrl}/campaigns/$campaignId/comment');

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'content': content}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('commentCampaign error: $e');
      return false;
    }
  }

  Future<bool> trackCampaignView(String campaignId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final idVal = int.tryParse(campaignId) ?? 0;
      if (idVal == 0) return false;
      final url = Uri.parse(Urls.countCampaignViews(idVal));

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('trackCampaignView error: $e');
      return false;
    }
  }

  Future<bool> trackCampaignImpression(String campaignId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final idVal = int.tryParse(campaignId) ?? 0;
      if (idVal == 0) return false;
      final url = Uri.parse(Urls.countCampaignImpressions(idVal));

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('trackCampaignImpression error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCampaignNotices(
    String campaignId,
  ) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse(Urls.getNotice(campaignId));

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final list = decoded['data'] as List<dynamic>? ?? [];
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      debugPrint('fetchCampaignNotices error: $e');
      return [];
    }
  }
}
