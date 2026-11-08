// ignore_for_file: library_prefixes, depend_on_referenced_packages

import 'dart:async';
import 'package:msollaally/core/const/appcolors.dart';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as GetX;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/response_data.dart';

class NetworkCaller {
  final int timeoutDuration = 15;
  final int uploadTimeoutDuration = 60;

  Future<ResponseData> getRequest(String url, {String? token}) async {
    log('GET Request: $url');
    log('GET Token: $token');
    try {
      final Response response = await get(
        Uri.parse(url),
        headers: {
          'Authorization': token.toString(),
          'Content-type': 'application/json',
        },
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ─────────────────────────── POST (legacy string body) ───────────────────────────
  Future<ResponseData> postRequest(
    String url, {
    Map<String, String>? body,
    String? token,
  }) async {
    log('POST Request: $url');
    log('Request Body: ${jsonEncode(body)}');
    try {
      final Response response = await post(
        Uri.parse(url),
        headers: {
          if (token != null) 'Authorization': token,
          'Content-type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ─────────────────────────── POST JSON (dynamic body — arrays, numbers, nested) ───────────────────────────
  Future<ResponseData> postJsonRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('POST JSON Request: $url');
    log('Request Body: ${jsonEncode(body)}');
    try {
      final Response response = await post(
        Uri.parse(url),
        headers: {
          if (token != null) 'Authorization': token,
          'Content-type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ─────────────────────────── PATCH ───────────────────────────
  Future<ResponseData> patchJsonRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('PATCH Request: $url');
    log('Request Body: ${jsonEncode(body)}');
    try {
      final Response response = await patch(
        Uri.parse(url),
        headers: {
          if (token != null) 'Authorization': token,
          'Content-type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ─────────────────────────── PUT ───────────────────────────
  Future<ResponseData> putJsonRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('PUT Request: $url');
    log('Request Body: ${jsonEncode(body)}');
    try {
      final Response response = await put(
        Uri.parse(url),
        headers: {
          if (token != null) 'Authorization': token,
          'Content-type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ─────────────────────────── DELETE ───────────────────────────
  Future<ResponseData> deleteRequest(String url, {String? token}) async {
    log('DELETE Request: $url');
    try {
      final Response response = await delete(
        Uri.parse(url),
        headers: {
          if (token != null) 'Authorization': token,
          'Content-type': 'application/json',
        },
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ─────────────────────────── MULTIPART POST REQUEST ───────────────────────────
  Future<ResponseData> multipartPostRequest(
    String url, {
    Map<String, String>? fields,
    Map<String, List<File>>? files,
    String? token,
  }) async {
    log('MULTIPART POST Request: $url');
    try {
      final request = MultipartRequest('POST', Uri.parse(url));
      if (token != null) {
        request.headers['Authorization'] = token;
      }
      if (fields != null) {
        request.fields.addAll(fields);
      }
      if (files != null) {
        for (var entry in files.entries) {
          for (var file in entry.value) {
            request.files.add(
              await MultipartFile.fromPath(entry.key, file.path),
            );
          }
        }
      }
      final StreamedResponse streamed = await request.send().timeout(
        Duration(seconds: uploadTimeoutDuration),
      );
      final Response response = await Response.fromStream(streamed);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ─────────────────────────── MULTIPART FILE UPLOAD (Legacy) ───────────────────────────
  Future<ResponseData> uploadFileRequest(
    String url,
    File file, {
    String? token,
    String fieldName = 'file',
  }) async {
    log('UPLOAD Request: $url — file: ${file.path}');
    try {
      final request = MultipartRequest('POST', Uri.parse(url));
      if (token != null) {
        request.headers['Authorization'] = token;
      }
      request.files.add(await MultipartFile.fromPath(fieldName, file.path));
      final StreamedResponse streamed = await request.send().timeout(
        Duration(seconds: uploadTimeoutDuration),
      );
      final Response response = await Response.fromStream(streamed);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  ResponseData _handleResponse(Response response) {
    log('Response Status: ${response.statusCode}');
    log('Response Body: ${response.body}');

    // 204 No Content / any empty body — skip JSON decode
    if (response.body.isEmpty) {
      final isOk = response.statusCode >= 200 && response.statusCode < 300;
      return ResponseData(
        isSuccess: isOk,
        statusCode: response.statusCode,
        responseData: {},
        errorMessage: isOk
            ? ''
            : 'Request failed with status ${response.statusCode}',
      );
    }

    final dynamic decodedResponse = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decodedResponse is Map && decodedResponse['success'] == false) {
        final msg = (decodedResponse['message'] ?? 'Unknown error occurred')
            .toString();

        if (_isSessionInvalidMessage(msg)) {
          _handleSessionExpired(msg);
        }

        return ResponseData(
          isSuccess: false,
          statusCode: response.statusCode,
          responseData: decodedResponse,
          errorMessage: msg,
        );
      }
      return ResponseData(
        isSuccess: true,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        errorMessage: '',
      );
    } else if (response.statusCode == 400) {
      String errorMsg;
      if (decodedResponse is Map) {
        if (decodedResponse['errorSources'] != null) {
          errorMsg = _extractErrorMessages(decodedResponse['errorSources']);
        } else if (decodedResponse['message'] != null) {
          final msg = decodedResponse['message'];
          errorMsg = msg is List
              ? msg.map((e) => e.toString()).join('\n')
              : msg.toString();
        } else {
          errorMsg = 'Validation error. Please check your input.';
        }
      } else {
        errorMsg = 'Validation error. Please check your input.';
      }

      if (_isSessionInvalidMessage(errorMsg)) {
        _handleSessionExpired(errorMsg);
      }

      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        errorMessage: errorMsg,
      );
    } else if (response.statusCode == 401) {
      // Extract message from body
      final msg = decodedResponse is Map
          ? (decodedResponse['message'] ??
                'Session expired. Please login again.')
          : 'Session expired. Please login again.';

      // Global session expiry: clear tokens and redirect to login
      _handleSessionExpired(msg.toString());

      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        errorMessage: msg.toString(),
      );
    } else if (response.statusCode == 500) {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        errorMessage: (decodedResponse is Map)
            ? (decodedResponse['detail'] ??
                  decodedResponse['message'] ??
                  'An unexpected error occurred!')
            : 'An unexpected error occurred!',
      );
    } else {
      final msg = decodedResponse is Map
          ? (decodedResponse['message'] ?? 'An unknown error occurred')
                .toString()
          : 'An unknown error occurred';

      if (_isSessionInvalidMessage(msg)) {
        _handleSessionExpired(msg);
      }

      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        errorMessage: msg,
      );
    }
  }

  bool _isSessionInvalidMessage(String message) {
    final lower = message.toLowerCase();
    return lower.contains('invalid session') ||
        lower.contains('session expired') ||
        lower.contains('session invalid') ||
        lower.contains('please login') ||
        lower.contains('token expired') ||
        lower.contains('token invalid') ||
        lower.contains('jwt expired') ||
        lower.contains('not authenticated');
  }

  String _extractErrorMessages(dynamic errorSources) {
    if (errorSources is List) {
      return errorSources
          .map((error) => error['message'] ?? 'Unknown error')
          .join(', ');
    }
    return 'Validation error';
  }

  ResponseData _handleError(dynamic error) {
    log('Request Error: $error');
    if (error is ClientException) {
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        responseData: '',
        errorMessage: 'Network error occurred. Please check your connection.',
      );
    } else if (error is TimeoutException) {
      return ResponseData(
        isSuccess: false,
        statusCode: 408,
        responseData: '',
        errorMessage: 'Request timeout. Please try again later.',
      );
    } else {
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        responseData: '',
        errorMessage: 'Unexpected error occurred.',
      );
    }
  }

  void _handleSessionExpired(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    EasyLoading.dismiss();
    EasyLoading.instance
      ..backgroundColor =
          AppColors.firebrickC0392B
      ..textColor =
          AppColors.buttonColorOnboarding
      ..indicatorColor = AppColors.buttonColorOnboarding
      ..loadingStyle = EasyLoadingStyle.custom;

    EasyLoading.showToast(
      '⚠️  Session expired. Please login again.',
      duration: const Duration(seconds: 3),
      toastPosition: EasyLoadingToastPosition.top,
      maskType: EasyLoadingMaskType.none,
    );

    await Future.delayed(const Duration(milliseconds: 800));
    GetX.Get.offAllNamed('/auth/login');
  }
}
