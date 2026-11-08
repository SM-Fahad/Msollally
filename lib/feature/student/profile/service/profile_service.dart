// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/end_points.dart';
import '../../../../core/services/share_preferrance_helper.dart';

class ProfileService extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var responseMessage = ''.obs;
  var isSuccess = false.obs;

  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? faculty,
    String? profilePicture,
    String? coverPhoto,
    String? bio,
    String? studentID,
    String? program,
    String? phoneNumber,
    String? gender,
    String? dateOfBirth,
    int? departmentId,
    int? enrollmentYear,
    int? universityId,
    int? programId,
    String? designation,
    String? companyType,
    String? employeeCountRange,
    String? location,
    String? companyName,
    String? cellPhoneNumber,
    String? subjectTaught,
  }) async {
    try {
      isLoading.value = true;

      // Get token from SharedPreferences
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        responseMessage.value =
            'Authentication token not found. Please login again.';
        isSuccess.value = false;
        EasyLoading.showError(responseMessage.value);
        return false;
      }

      final Uri url = Uri.parse(Urls.profileUpdate);

      final Map<String, dynamic> body = {};
      if (fullName != null) body['fullName'] = fullName;
      if (email != null) body['email'] = email;
      if (faculty != null) body['faculty'] = faculty;
      if (profilePicture != null) body['profilePicture'] = profilePicture;
      if (coverPhoto != null) body['coverPhoto'] = coverPhoto;
      if (bio != null) body['bio'] = bio;
      if (studentID != null) body['studentID'] = studentID;
      if (program != null) body['program'] = program;
      if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
      if (gender != null) body['gender'] = gender;
      if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth;
      if (departmentId != null) body['departmentId'] = departmentId;
      if (enrollmentYear != null) body['enrollmentYear'] = enrollmentYear;
      
      // newly added missing fields
      if (universityId != null) body['universityId'] = universityId;
      if (programId != null) body['programId'] = programId;
      if (designation != null) body['designation'] = designation;
      if (companyType != null) body['companyType'] = companyType;
      if (employeeCountRange != null) body['employeeCountRange'] = employeeCountRange;
      if (location != null) body['location'] = location;
      if (companyName != null) body['companyName'] = companyName;
      if (cellPhoneNumber != null) body['cellPhoneNumber'] = cellPhoneNumber;
      if (subjectTaught != null) body['subjectTaught'] = subjectTaught;

      print('Request URL: $url');
      print('Request Body: $body');
      print('Request Headers: Authorization: Bearer $token');

      final http.Response response = await http.patch(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        responseMessage.value = 'Profile updated successfully';
        isSuccess.value = true;
        return true;
      } else {
        final responseBody = jsonDecode(response.body);
        var message = responseBody['message'] ?? 'Something went wrong';
        if (message is List) {
          message = message.join(', ');
        }
        responseMessage.value = message.toString();
        isSuccess.value = false;
        EasyLoading.showError(message.toString());
        return false;
      }
    } catch (e) {
      print('Error: $e');
      responseMessage.value = 'Failed to update profile: $e';
      isSuccess.value = false;
      EasyLoading.showError('Failed to update profile: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  static Future<void> updateEmail({required String email}) async {}

  /// Fetches the full authenticated user from GET /auth/me.
  /// Shape: { id, username, phoneNumber, role, friends, profile: { fullName, email, faculty, studentID, bio, profilePicture, coverPhoto, ... } }
  Future<Map<String, dynamic>?> fetchMe() async {
    try {
      isLoading.value = true;

      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        responseMessage.value = 'Authentication token not found.';
        return null;
      }

      final Uri url = Uri.parse(Urls.authMe);
      final http.Response response = await http.get(
        url,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      print('fetchMe status: ${response.statusCode}');
      print('fetchMe body  : ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return null;
      } else {
        final body = jsonDecode(response.body);
        final message =
            (body is Map ? body['message'] : null) ?? 'Failed to fetch profile';
        responseMessage.value = message.toString();
        EasyLoading.showError(message.toString());
        return null;
      }
    } catch (e) {
      responseMessage.value = 'Error: $e';
      EasyLoading.showError('Failed to fetch profile: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> uploadProfileFile({required File file}) async {
    String? lastError;
    const candidateFields = ['file', 'files', 'image', 'attachment', 'fileUrl'];

    final token = await SharedPreferenceHelper().getAccessToken();

    for (final fileFieldName in candidateFields) {
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(Urls.uploadCloudinaryFile),
        );

        request.headers.addAll({
          'accept': '*/*',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        });

        request.files.add(
          await http.MultipartFile.fromPath(fileFieldName, file.path),
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final url = _extractUploadedFileUrl(response.body);
          if (url != null && url.isNotEmpty) {
            return url;
          }
          lastError = 'Upload succeeded but file URL not found in response';
        } else {
          lastError = 'Failed to upload file';
        }
      } catch (e) {
        lastError = e.toString();
      }
    }

    EasyLoading.showError(lastError ?? 'Failed to upload file');
    return null;
  }

  String? _extractUploadedFileUrl(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);

      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map<String, dynamic>) {
          final url = first['url'] ?? first['secure_url'] ?? first['fileUrl'];
          return url?.toString();
        }
      }

      if (decoded is Map<String, dynamic>) {
        final url =
            decoded['url'] ?? decoded['secure_url'] ?? decoded['fileUrl'];
        if (url != null) return url.toString();

        final data = decoded['data'];
        if (data is List && data.isNotEmpty) {
          final first = data.first;
          if (first is Map<String, dynamic>) {
            final dataUrl =
                first['url'] ?? first['secure_url'] ?? first['fileUrl'];
            return dataUrl?.toString();
          }
        }
        if (data is Map<String, dynamic>) {
          final dataUrl = data['url'] ?? data['secure_url'] ?? data['fileUrl'];
          return dataUrl?.toString();
        }
      }
    } catch (_) {}

    return null;
  }
}
