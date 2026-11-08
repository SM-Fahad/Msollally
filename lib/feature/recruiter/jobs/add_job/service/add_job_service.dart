import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

import '../model/add_job_model.dart';
import '../model/update_job_model.dart';

class AddJobService {
  final SharedPreferenceHelper _sharedPreferenceHelper =
      SharedPreferenceHelper();

  Future<AddJobModel> createJob(AddJobModel job) async {
    try {
      final token = await _sharedPreferenceHelper.getAccessToken();

      final response = await http.post(
        Uri.parse(Urls.jobs),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(job.toJson()),
      );

      debugPrint('Create Job POST response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        AddJobModel createdJob = job;

        if (response.body.isEmpty) {
          throw Exception('Job created but response did not include an id');
        }

        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final dynamic data = decoded['data'];
          if (data is Map<String, dynamic>) {
            createdJob = AddJobModel.fromJson(data);
          }

          final String? extractedId = _extractJobId(decoded);
          if (extractedId != null && extractedId.isNotEmpty) {
            createdJob = AddJobModel(
              id: extractedId,
              title: createdJob.title,
              department: createdJob.department,
              location: createdJob.location,
              jobType: createdJob.jobType,
              salaryType: createdJob.salaryType,
              minimumSalary: createdJob.minimumSalary,
              maximumSalary: createdJob.maximumSalary,
              description: createdJob.description,
              responsibilities: createdJob.responsibilities,
              requirements: createdJob.requirements,
              benefits: createdJob.benefits,
              professionalSkills: createdJob.professionalSkills,
              otherFacilities: createdJob.otherFacilities,
              experienceLevel: createdJob.experienceLevel,
              minimumExperience: createdJob.minimumExperience,
              maximumExperience: createdJob.maximumExperience,
              applicationDeadline: createdJob.applicationDeadline,
              companyName: createdJob.companyName,
              companyLogo: createdJob.companyLogo,
            );
          }
        }

        if (createdJob.id == null || createdJob.id!.trim().isEmpty) {
          throw Exception('Job created but missing job id for publish');
        }

        await _publishJob(createdJob.id!, token: token);

        return createdJob;
      }

      throw Exception(_extractErrorMessage(response.body));
    } catch (e) {
      debugPrint('Error creating job: $e');
      rethrow;
    }
  }

  Future<UpdateJobModel> updateJob(int id, UpdateJobModel job) async {
    try {
      final token = await _sharedPreferenceHelper.getAccessToken();

      final response = await http.put(
        Uri.parse(Urls.updateJobById(id)),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(job.toJson()),
      );

      debugPrint('Update Job PUT response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return job;

        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final dynamic data = decoded['data'];
          if (data is Map<String, dynamic>) {
            return UpdateJobModel.fromJson(data);
          }
          return UpdateJobModel.fromJson(decoded);
        }

        return job;
      }

      throw Exception(_extractErrorMessage(response.body));
    } catch (e) {
      debugPrint('Error updating job: $e');
      rethrow;
    }
  }

  Future<void> _publishJob(String id, {String? token}) async {
    final response = await http.put(
      Uri.parse(Urls.updateJobStatus(id)),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': 'published'}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw Exception(
      'Job created but publish failed: ${_extractErrorMessage(response.body)}',
    );
  }

  String _extractErrorMessage(String body) {
    if (body.isEmpty) {
      return 'Failed to create job';
    }

    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message != null) {
          return message.toString();
        }
      }
    } catch (_) {
      // Fall through to the raw body.
    }

    return body;
  }

  String? _extractJobId(Map<String, dynamic> decoded) {
    final List<dynamic> candidates = [
      decoded['id'],
      decoded['_id'],
      decoded['jobId'],
      decoded['data'] is Map<String, dynamic>
          ? (decoded['data'] as Map<String, dynamic>)['id']
          : null,
      decoded['data'] is Map<String, dynamic>
          ? (decoded['data'] as Map<String, dynamic>)['_id']
          : null,
      decoded['data'] is Map<String, dynamic>
          ? (decoded['data'] as Map<String, dynamic>)['jobId']
          : null,
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  Future<String> uploadImage(File file) async {
    try {
      final token = await _sharedPreferenceHelper.getAccessToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Urls.convertUpload),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      debugPrint('📤 Uploading image to: ${Urls.convertUpload}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('📨 Image upload response: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map<String, dynamic>) {
          final fileUrl = decoded['fileUrl'];
          if (fileUrl != null && fileUrl.toString().isNotEmpty) {
            debugPrint('✅ Image uploaded successfully: $fileUrl');
            return fileUrl.toString();
          }
        }
        throw Exception('File uploaded but no fileUrl in response');
      }

      throw Exception(
        'Failed to upload image: ${_extractErrorMessage(responseBody)}',
      );
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      rethrow;
    }
  }
}
