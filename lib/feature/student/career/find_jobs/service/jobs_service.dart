import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import '../model/jobs.model.dart';
import '../model/job_application_model.dart';

class JobsService {
  Future<List<JobModel>> fetchJobs({Map<String, String>? filters}) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();

      Uri uri = Uri.parse(Urls.jobs);
      if (filters != null && filters.isNotEmpty) {
        uri = uri.replace(queryParameters: filters);
      }

      debugPrint('[JobsService] Fetching jobs from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('[JobsService] Status Code: ${response.statusCode}');
      debugPrint('[JobsService] Raw Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // API returns { "jobs": [...], "total": N, "page": N, "totalPages": N }
        final List<dynamic> jobsData =
            responseData['jobs'] ?? responseData['data'] ?? [];
        debugPrint('[JobsService] Jobs count: ${jobsData.length}');

        return jobsData.map((json) => JobModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch jobs: ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint('[JobsService] Error fetching jobs: $e');
      debugPrint('[JobsService] StackTrace: $st');
      rethrow;
    }
  }

  Future<JobModel> fetchJobDetails(int jobId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final uri = Uri.parse(Urls.jobById(jobId));

      debugPrint('[JobsService] Fetching job details from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('[JobsService] Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final dynamic jobData =
            responseData['data'] ?? responseData['job'] ?? responseData;
        return JobModel.fromJson(jobData);
      } else {
        throw Exception('Failed to fetch job details: ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint('[JobsService] Error fetching job details: $e');
      debugPrint('[JobsService] StackTrace: $st');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> applyJob({
    required int jobId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final uri = Uri.parse(Urls.applyJob(jobId));
      final headers = {
        'Content-Type': 'application/json',
        'accept': '*/*',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final bodyJson = jsonEncode(body);

      debugPrint('[JobsService] Apply request to: $uri');
      debugPrint('[JobsService] Apply headers: $headers');
      debugPrint('[JobsService] Apply body: $bodyJson');

      final response = await http.post(uri, headers: headers, body: bodyJson);

      debugPrint('[JobsService] Apply Status: ${response.statusCode}');
      debugPrint('[JobsService] Apply Response Body: ${response.body}');

      String message = '';
      try {
        if (response.body.isNotEmpty) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final errorStr = decoded['error']?.toString();
            final msgStr = decoded['message']?.toString();
            if (errorStr != null && errorStr.isNotEmpty && msgStr == 'Database Query Failed') {
              message = errorStr;
            } else {
              message = msgStr ?? errorStr ?? '';
            }
          }
        }
      } catch (e) {
        debugPrint('[JobsService] Failed to decode apply response: $e');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': message.isNotEmpty ? message : 'Successfully applied!',
        };
      } else {
        debugPrint('[JobsService] Apply failed: ${response.body}');
        if (response.body.contains('Database Query Failed') || response.statusCode == 500) {
          debugPrint('[JobsService] Retrying apply with simplified payload to bypass database query failure...');
          final simplifiedBody = <String, dynamic>{
            if (body['coverLetter'] != null && body['coverLetter'].toString().isNotEmpty)
              'coverLetter': body['coverLetter'],
            if (body['resumeUrl'] != null && body['resumeUrl'].toString().isNotEmpty)
              'resumeUrl': body['resumeUrl'],
            if (body['cvId'] != null)
              'cvId': int.tryParse(body['cvId'].toString()) ?? body['cvId'],
          };
          try {
            final retryResponse = await http.post(uri, headers: headers, body: jsonEncode(simplifiedBody));
            debugPrint('[JobsService] Retry status: ${retryResponse.statusCode}');
            if (retryResponse.statusCode == 200 || retryResponse.statusCode == 201) {
              return {
                'success': true,
                'message': 'Successfully applied!',
              };
            }
          } catch (_) {}
        }
        return {
          'success': false,
          'message': message.isNotEmpty ? message : 'Something went wrong',
        };
      }
    } catch (e) {
      debugPrint('[JobsService] Error applying for job: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<String?> uploadFile(dynamic file, {String? fileName}) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final uri = Uri.parse(Urls.uploadCloudinaryFile);

      final candidateFields = ['files', 'file'];
      for (final fieldName in candidateFields) {
        try {
          final request = http.MultipartRequest('POST', uri);
          request.headers.addAll({
            'accept': '*/*',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          });

          final path = file is String ? file : file.path as String;
          request.files.add(
            await http.MultipartFile.fromPath(fieldName, path, filename: fileName),
          );

          final streamed = await request.send();
          final response = await http.Response.fromStream(streamed);

          if (response.statusCode == 200 || response.statusCode == 201) {
            final url = _extractUrl(response.body);
            if (url != null && url.isNotEmpty) {
              return url;
            }
          }
        } catch (_) {}
      }
      return null;
    } catch (e) {
      debugPrint('[JobsService] Upload error: $e');
      return null;
    }
  }

  String? _extractUrl(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map) {
          return (first['url'] ?? first['secure_url'] ?? first['fileUrl'])?.toString();
        }
      }
      if (decoded is Map) {
        final top = decoded['url'] ?? decoded['secure_url'] ?? decoded['fileUrl'];
        if (top != null) return top.toString();
        final data = decoded['data'];
        if (data is List && data.isNotEmpty && data.first is Map) {
          return (data.first['url'] ?? data.first['secure_url'] ?? data.first['fileUrl'])?.toString();
        }
        if (data is Map) {
          return (data['url'] ?? data['secure_url'] ?? data['fileUrl'])?.toString();
        }
        if (decoded['file'] is Map) {
          return (decoded['file']['url'] ?? decoded['file']['secure_url'])?.toString();
        }
      }
    } catch (_) {}
    return null;
  }

  Future<List<JobApplicationModel>> fetchMyApplications() async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final uri = Uri.parse(Urls.myJobApplications);

      debugPrint('[JobsService] Fetching my applications from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'accept': '*/*',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('[JobsService] My applications Status Code: ${response.statusCode}');
      debugPrint('[JobsService] My applications Raw Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        List<dynamic> list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list = decoded['data'] ??
              decoded['applications'] ??
              decoded['items'] ??
              decoded['rows'] ??
              [];
        }
        return list
            .whereType<Map<String, dynamic>>()
            .map((json) => JobApplicationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch my applications: ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint('[JobsService] Error fetching my applications: $e');
      debugPrint('[JobsService] StackTrace: $st');
      return [];
    }
  }

  Future<bool> withdrawApplication(int applicationId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final uri = Uri.parse(Urls.withdrawJobApplication(applicationId));

      debugPrint('[JobsService] Withdrawing application at: $uri');

      final response = await http.delete(
        uri,
        headers: {
          'accept': '*/*',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('[JobsService] Withdraw status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('[JobsService] Error withdrawing application: $e');
      return false;
    }
  }
}
