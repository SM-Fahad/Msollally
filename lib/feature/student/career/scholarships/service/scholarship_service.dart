import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import '../model/scholarship_model.dart';
import '../model/scholarship_application_model.dart';

class ScholarshipService {
  Future<List<ScholarshipModel>> fetchScholarships() async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.get(
        Uri.parse(Urls.scholarships),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> scholarshipsJson = data['data'] ?? [];
        return scholarshipsJson
            .map((json) => ScholarshipModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load scholarships: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> applyScholarship({
    required int scholarshipId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.post(
        Uri.parse(Urls.applyScholarship(scholarshipId)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Successfully applied!',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to apply.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong: $e'};
    }
  }

  Future<List<ScholarshipApplicationModel>> fetchMyApplications() async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.get(
        Uri.parse(Urls.myScholarshipApplications),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> applicationsJson = data['data'] ?? [];
        return applicationsJson
            .map((json) => ScholarshipApplicationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load applications: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateScholarshipApplication({
    required int applicationId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.patch(
        Uri.parse(Urls.updateScholarshipApplication(applicationId)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Successfully updated!',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong: $e'};
    }
  }

  Future<ScholarshipApplicationModel> fetchApplicationById(int id) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.get(
        Uri.parse(Urls.getScholarshipApplicationById(id)),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ScholarshipApplicationModel.fromJson(data['data'] ?? {});
      } else {
        throw Exception(
          'Failed to load application details: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> uploadFile(File file) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final request = http.MultipartRequest('POST', Uri.parse(Urls.uploadFile));
      request.headers.addAll({
        'accept': '*/*',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      request.files.add(await http.MultipartFile.fromPath('files', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          return decoded[0]['url']?.toString();
        } else if (decoded is Map) {
          final data = decoded['data'];
          if (data is List && data.isNotEmpty) {
            return data[0]['url']?.toString();
          } else if (data is Map) {
            return (data['url'] ?? data['secure_url'])?.toString();
          } else if (decoded['url'] != null) {
            return decoded['url']?.toString();
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
