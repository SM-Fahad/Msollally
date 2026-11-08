import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/feedback/model/feedback_model.dart';
import 'package:msollaally/feature/feedback/service/feedback_service.dart';
import 'package:msollaally/core/utils/logging/logger.dart';
import 'package:msollaally/core/const/appcolors.dart';

class FeedbackController extends GetxController {
  final FeedbackService _service = FeedbackService();
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  var feedbacks = <FeedbackModel>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;
  
  int page = 1;
  int limit = 10;
  
  var selectedCategory = 'all'.obs;
  var selectedStatus = 'all'.obs;

  final ScrollController scrollController = ScrollController();

  final List<String> categories = ['all', 'support', 'suggestion', 'bug', 'other'];
  final List<String> statuses = ['all', 'pending', 'in_progress', 'resolved', 'rejected'];
  final List<String> createCategories = ['support', 'suggestion', 'bug', 'other'];

  var pickedFilePath = RxnString();
  var pickedFileName = RxnString();
  var uploadedAttachmentUrl = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchFeedbacks();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      loadMoreFeedbacks();
    }
  }

  Future<void> fetchFeedbacks({bool refresh = false}) async {
    if (refresh) {
      page = 1;
      hasMore.value = true;
      feedbacks.clear();
    }
    
    if (!hasMore.value) return;

    if (page == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final List<FeedbackModel>? result = await _service.getFeedbacks(
        page: page,
        limit: limit,
        category: selectedCategory.value,
        status: selectedStatus.value,
      );

      if (result != null) {
        if (result.length < limit) {
          hasMore.value = false;
        }
        feedbacks.addAll(result);
        page++;

        if (refresh) {
          final withReply = result
              .where(
                (f) =>
                    f.adminReply != null && f.adminReply!.trim().isNotEmpty,
              )
              .toList();
          if (withReply.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Get.context != null) {
                Get.snackbar(
                  'Admin Response Received',
                  'You have ${withReply.length} feedback item(s) with official responses from Admin Portal.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: AppColors.primaryButtonColor,
                  colorText: Colors.white,
                  icon: const Icon(
                    Icons.mark_chat_read_rounded,
                    color: Colors.white,
                  ),
                  duration: const Duration(seconds: 4),
                  margin: const EdgeInsets.all(12),
                  borderRadius: 12,
                );
              }
            });
          }
        }
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      AppLoggerHelper.error('Error fetching feedbacks: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void loadMoreFeedbacks() {
    if (!isLoading.value && !isLoadingMore.value && hasMore.value) {
      fetchFeedbacks();
    }
  }

  void updateCategoryFilter(String category) {
    selectedCategory.value = category;
    fetchFeedbacks(refresh: true);
  }

  void updateStatusFilter(String status) {
    selectedStatus.value = status;
    fetchFeedbacks(refresh: true);
  }

  Future<void> pickAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result != null) {
      pickedFilePath.value = result.files.single.path;
      pickedFileName.value = result.files.single.name;
      uploadedAttachmentUrl.value = null; // Reset previous upload url
    }
  }

  void clearAttachment() {
    pickedFilePath.value = null;
    pickedFileName.value = null;
    uploadedAttachmentUrl.value = null;
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

  Future<String?> _uploadAttachment(String path) async {
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

  Future<void> createFeedback({
    required String title,
    required String description,
    required String category,
    String? attachmentUrl,
  }) async {
    EasyLoading.show(status: 'Submitting...');
    
    String? finalAttachmentUrl = attachmentUrl ?? uploadedAttachmentUrl.value;
    
    if ((finalAttachmentUrl == null || finalAttachmentUrl.isEmpty) && 
        pickedFilePath.value != null && 
        pickedFilePath.value!.isNotEmpty) {
      finalAttachmentUrl = await _uploadAttachment(pickedFilePath.value!);
      uploadedAttachmentUrl.value = finalAttachmentUrl;
    }

    final success = await _service.createFeedback(
      title: title,
      description: description,
      category: category,
      attachmentUrl: finalAttachmentUrl,
    );

    EasyLoading.dismiss();
    if (success) {
      clearAttachment();
      fetchFeedbacks(refresh: true);
      
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text(
                'Feedback Sent',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'Your feedback has been successfully submitted to the Admin Portal. You will receive an alert once an official response has been provided by the administrators.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back(); // Dismiss dialog
                Get.back(); // Return to feedback screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButtonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      EasyLoading.showError('Failed to submit feedback to Admin Portal');
    }
  }

  Future<void> updateFeedback({
    required int id,
    String? title,
    String? description,
    String? category,
    String? attachmentUrl,
  }) async {
    EasyLoading.show(status: 'Updating...');

    String? finalAttachmentUrl = attachmentUrl ?? uploadedAttachmentUrl.value;
    
    if ((finalAttachmentUrl == null || finalAttachmentUrl.isEmpty) && 
        pickedFilePath.value != null && 
        pickedFilePath.value!.isNotEmpty) {
      finalAttachmentUrl = await _uploadAttachment(pickedFilePath.value!);
      uploadedAttachmentUrl.value = finalAttachmentUrl;
    }

    final success = await _service.updateFeedback(
      id: id,
      title: title,
      description: description,
      category: category,
      attachmentUrl: finalAttachmentUrl,
    );

    if (success) {
      EasyLoading.showSuccess('Feedback updated successfully');
      clearAttachment();
      fetchFeedbacks(refresh: true);
      Get.back();
    } else {
      EasyLoading.showError('Failed to update feedback');
    }
  }

  Future<void> deleteFeedback(int id) async {
    EasyLoading.show(status: 'Deleting...');
    final success = await _service.deleteFeedback(id);

    if (success) {
      EasyLoading.showSuccess('Feedback deleted successfully');
      feedbacks.removeWhere((f) => f.id == id);
    } else {
      EasyLoading.showError('Failed to delete feedback');
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}

