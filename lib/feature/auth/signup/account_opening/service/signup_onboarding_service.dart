// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/auth/signup/account_opening/model/sign_up_onboading_model.dart';
import 'dart:io';

class Program {
  final int id;
  final String name;
  final List<Department> departments;

  Program({required this.id, required this.name, required this.departments});

  factory Program.fromJson(Map<String, dynamic> json) => Program(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    name: json['name'] ?? '',
    departments:
        (json['departments'] as List<dynamic>?)
            ?.map((d) => Department.fromJson(d as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

class Department {
  final int id;
  final String name;

  Department({required this.id, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    name: json['name'] ?? '',
  );
}

class UniversityDetail {
  final int id;
  final String name;
  final List<Program> programs;

  UniversityDetail({
    required this.id,
    required this.name,
    required this.programs,
  });

  factory UniversityDetail.fromJson(Map<String, dynamic> json) =>
      UniversityDetail(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        name: json['name'] ?? '',
        programs:
            (json['programs'] as List<dynamic>?)
                ?.map((p) => Program.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class SignupOnboardingService {
  final String baseUrl1;

  SignupOnboardingService({this.baseUrl1 = Urls.baseUrl});
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  /// Completes the user profile. If [profileImagePath] is provided, it's uploaded
  /// as a multipart file under the `profilePicture` field. Otherwise, the
  /// `profilePicture` field will be sent as a plain value if non-null.
  Future<http.Response> completeProfile({
    required String fullName,
    required String gender,
    required String dateOfBirth,
    required int universityId,
    required int programId,
    required int departmentId,
    required String program,
    required String faculty,
    required String studentID,
    required int enrollmentYear,
    String? profilePictureUrl,
    String? email,
    required String bio,
    // Teacher-specific optional fields
    bool isTeacher = false,
    String? designation,
    String? subjectTaught,
    // Recruiter-specific optional fields
    bool isRecruiter = false,
    bool isProPartners = false,
    String? companyType,
    String? location,
    String? companyName,
  }) async {
    // Step 1: if a local image path is provided, upload it to the convert endpoint
    String? finalProfilePictureUrl = profilePictureUrl;

    if (profilePictureUrl == null || profilePictureUrl.isEmpty) {
      // nothing prefilled — check if caller provided a local path via the profilePictureUrl parameter (not used here)
    }

    // If caller provided a local file path in `profilePictureUrl` (legacy), treat it as upload path.
    // However controller passes the selected path via profilePictureUrl in our current usage.
    if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
      // If the provided string is a file path on device, upload it. If it already looks like a URL, keep it.
      final looksLikeUrl =
          profilePictureUrl.startsWith('http://') ||
          profilePictureUrl.startsWith('https://');
      if (!looksLikeUrl) {
        final uploadUri = Uri.parse('$baseUrl1/convert/upload');
        final uploadRequest = http.MultipartRequest('POST', uploadUri);

        // Attach auth token if available
        try {
          final token = await _prefs.getAccessToken();
          if (token != null && token.isNotEmpty) {
            uploadRequest.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {}

        final file = File(profilePictureUrl);
        if (await file.exists()) {
          uploadRequest.files.add(
            await http.MultipartFile.fromPath('file', file.path),
          );
          final streamed = await uploadRequest.send();
          final uploadResp = await http.Response.fromStream(streamed);
          try {
            final Map<String, dynamic> decoded =
                json.decode(uploadResp.body) as Map<String, dynamic>;
            finalProfilePictureUrl = decoded['fileUrl']?.toString();
          } catch (_) {
            // ignore parsing errors; finalProfilePictureUrl stays null
          }
        }
      } else {
        finalProfilePictureUrl = profilePictureUrl;
      }
    }

    // Step 2: send JSON profile complete request with profilePicture set to fileUrl (if available)
    final uri = Uri.parse('$baseUrl1/auth/profile/complete');

    late final Map<String, dynamic> body;

    if (isTeacher) {
      // Teacher profile payload      final String designationValue = (designation ?? '').trim().toLowerCase();
      final String subjectValue = (subjectTaught ?? '').trim().toLowerCase();

      body = {
        'email': email ?? '',
        'fullName': fullName,
        'gender': gender,
        'universityId': universityId,
        'faculty': faculty,
        'profilePicture': finalProfilePictureUrl ?? '',
        'bio': bio,
        'designation': designation ?? '',
        'subjectTaught': subjectTaught ?? '',
      };
    } else if (isRecruiter) {
      // Recruiter profile payload
      body = {
        'email': email ?? '',
        'fullName': fullName,
        'gender': gender,
        'profilePicture': finalProfilePictureUrl ?? '',
        'bio': bio,
        'designation': designation ?? '',
        'companyType': companyType ?? '',
        'location': location ?? '',
        'companyName': companyName ?? '',
      };
    } else if (isProPartners) {
      // propartnar profile payload
      body = {
        'email': email ?? '',
        'fullName': fullName,
        'gender': gender,
        'profilePicture': finalProfilePictureUrl ?? '',
        'bio': bio,
        'designation': designation ?? '',
        'companyType': companyType ?? '',
        'location': location ?? '',
        'companyName': companyName ?? '',
      };
    } else {
      // Student/default profile payload
      body = {
        'email': email ?? '',
        'fullName': fullName,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'universityId': universityId,
        'programId': programId,
        'departmentId': departmentId,
        'program': program,
        'faculty': faculty,
        'studentID': studentID,
        'enrollmentYear': enrollmentYear,
        'bio': bio,
        'profilePicture': finalProfilePictureUrl ?? '',
      };
    }

    final headers = <String, String>{'Content-Type': 'application/json'};

    try {
      final token = await _prefs.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}

    final resp = await http.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );
    return resp;
  }

  Future<List<University>> fetchUniversities() async {
    try {
      final uri = Uri.parse('$baseUrl1/universities');
      final resp = await http.get(uri);

      if (resp.statusCode != 200) {
        throw Exception('Failed to load universities: ${resp.statusCode}');
      }

      final List<dynamic> data = json.decode(resp.body) as List<dynamic>;
      return data
          .map((e) => University.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Propagate a clear error message for callers to handle
      throw Exception('Error fetching universities: $e');
    }
  }

  Future<UniversityDetail> fetchUniversityById(int id) async {
    try {
      final uri = Uri.parse('$baseUrl1/universities/$id');
      final resp = await http.get(uri);

      if (resp.statusCode != 200) {
        throw Exception('Failed to load university detail: ${resp.statusCode}');
      }

      final Map<String, dynamic> data =
          json.decode(resp.body) as Map<String, dynamic>;
      return UniversityDetail.fromJson(data);
    } catch (e) {
      throw Exception('Error fetching university detail: $e');
    }
  }
}
