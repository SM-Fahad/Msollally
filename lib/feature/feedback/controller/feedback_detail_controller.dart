import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/feedback/model/feedback_model.dart';
import 'package:msollaally/feature/feedback/service/feedback_service.dart';
import 'package:msollaally/core/utils/logging/logger.dart';

class FeedbackDetailController extends GetxController {
  final FeedbackService _service = FeedbackService();

  final int feedbackId;
  FeedbackDetailController({required this.feedbackId});

  var feedbackDetails = Rxn<FeedbackModel>();
  var isLoading = true.obs;

  var isReplying = false.obs;
  final replyController = TextEditingController();

  Timer? _autoRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    fetchDetails();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!isClosed && !isReplying.value) {
        fetchDetails(silent: true);
      }
    });
  }

  @override
  void onClose() {
    _autoRefreshTimer?.cancel();
    replyController.dispose();
    super.onClose();
  }

  Future<void> fetchDetails({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      final result = await _service.getFeedbackDetails(feedbackId);
      if (result != null) {
        feedbackDetails.value = result;
      } else {
        AppLoggerHelper.error('Failed to load feedback details');
      }
    } catch (e) {
      AppLoggerHelper.error('Error fetching feedback details: $e');
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> postReply() async {
    if (replyController.text.trim().isEmpty) return;
    isReplying.value = true;
    try {
      final success = await _service.postFeedbackReply(
        feedbackId,
        replyController.text.trim(),
      );
      if (success) {
        replyController.clear();
        await fetchDetails(); // Refresh the details
        Get.snackbar(
          'Success',
          'Reply posted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to post reply',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isReplying.value = false;
    }
  }
}
