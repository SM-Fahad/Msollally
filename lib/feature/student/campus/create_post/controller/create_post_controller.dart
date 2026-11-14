import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

class PostController extends GetxController {
  final _networkCaller = NetworkCaller();
  final _prefs = SharedPreferenceHelper();

  var selectedPrivacy = "Public".obs;
  final isAnnouncement = false.obs;

  final textController = TextEditingController();
  final isSubmitting = false.obs;

  final pickedFilePath = RxnString();
  final pickedFilePaths = <String>[].obs;
  final uploadedMediaUrl = RxnString();
  final uploadedMediaUrls = <String>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickMedia() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(imageQuality: 80);
      if (files.isNotEmpty) {
        for (final file in files) {
          if (!pickedFilePaths.contains(file.path)) {
            pickedFilePaths.add(file.path);
          }
        }
        pickedFilePath.value = pickedFilePaths.first;
        uploadedMediaUrl.value = null;
        uploadedMediaUrls.clear();
        return;
      }
    } catch (_) {}

    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) {
      if (!pickedFilePaths.contains(file.path)) {
        pickedFilePaths.add(file.path);
      }
      pickedFilePath.value = pickedFilePaths.first;
      uploadedMediaUrl.value = null;
      uploadedMediaUrls.clear();
    }
  }

  void removeMediaAt(int index) {
    if (index >= 0 && index < pickedFilePaths.length) {
      pickedFilePaths.removeAt(index);
      pickedFilePath.value = pickedFilePaths.isNotEmpty
          ? pickedFilePaths.first
          : null;
      uploadedMediaUrl.value = null;
      uploadedMediaUrls.clear();
    }
  }

  void clearMedia() {
    pickedFilePath.value = null;
    pickedFilePaths.clear();
    uploadedMediaUrl.value = null;
    uploadedMediaUrls.clear();
  }

  String? _extractUploadedFileUrl(dynamic rawBody) {
    if (rawBody is Map) {
      final url = rawBody['url'] ?? rawBody['secure_url'] ?? rawBody['fileUrl'];
      if (url != null) return url.toString();

      final data = rawBody['data'];
      if (data is Map) {
        return (data['url'] ?? data['secure_url'] ?? data['fileUrl'])
            ?.toString();
      }
      if (data is List && data.isNotEmpty && data.first is Map) {
        return (data.first['url'] ??
                data.first['secure_url'] ??
                data.first['fileUrl'])
            ?.toString();
      }
    } else if (rawBody is List && rawBody.isNotEmpty && rawBody.first is Map) {
      return (rawBody.first['url'] ??
              rawBody.first['secure_url'] ??
              rawBody.first['fileUrl'])
          ?.toString();
    }
    return null;
  }

  Future<String?> _uploadMedia(String path) async {
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) return null;
    final response = await _networkCaller.uploadFileRequest(
      Urls.uploadCloudinaryFile,
      File(path),
      token: 'Bearer $token',
      fieldName: 'files',
    );
    if (!response.isSuccess) return null;
    return _extractUploadedFileUrl(response.responseData);
  }

  Future<void> createPost({
    required String postableType,
    required int postableId,
  }) async {
    if (textController.text.trim().isEmpty &&
        pickedFilePath.value == null &&
        pickedFilePaths.isEmpty) {
      EasyLoading.showError('Please write something or upload a media');
      return;
    }

    try {
      isSubmitting.value = true;
      EasyLoading.show(status: 'Creating post...');

      final pathsToUpload = pickedFilePaths.isNotEmpty
          ? List<String>.from(pickedFilePaths)
          : (pickedFilePath.value != null && pickedFilePath.value!.isNotEmpty
                ? [pickedFilePath.value!]
                : <String>[]);

      final List<String> mediaUrls = List<String>.from(uploadedMediaUrls);
      if (mediaUrls.isEmpty && pathsToUpload.isNotEmpty) {
        for (final path in pathsToUpload) {
          final url = await _uploadMedia(path);
          if (url != null && url.isNotEmpty) {
            mediaUrls.add(url);
          }
        }
        uploadedMediaUrls.assignAll(mediaUrls);
        if (mediaUrls.isNotEmpty) {
          uploadedMediaUrl.value = mediaUrls.first;
        }
      }

      final token = await _prefs.getAccessToken();
      int resolvedPostableId = postableId;
      if (resolvedPostableId <= 0) {
        final uidStr = await _prefs.getUserId();
        resolvedPostableId = int.tryParse(uidStr ?? '') ?? 1;
      }

      final payload = <String, dynamic>{
        "content": textController.text.trim(),
        "postableType": postableType,
        "postableId": resolvedPostableId,
        if (isAnnouncement.value) "isAnnouncement": true,
      };

      if (mediaUrls.isNotEmpty) {
        payload["mediaUrl"] = mediaUrls.first;
        payload["mediaUrls"] = mediaUrls;
      } else if (uploadedMediaUrl.value != null &&
          uploadedMediaUrl.value!.isNotEmpty) {
        payload["mediaUrl"] = uploadedMediaUrl.value;
        payload["mediaUrls"] = [uploadedMediaUrl.value];
      }

      final response = await _networkCaller.postJsonRequest(
        Urls.posts,
        body: payload,
        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
      );

      EasyLoading.dismiss();
      if (response.isSuccess) {
        EasyLoading.showSuccess('Post created successfully!');
        Get.back(result: true);
      } else {
        EasyLoading.showError(response.errorMessage);
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('An error occurred');
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
