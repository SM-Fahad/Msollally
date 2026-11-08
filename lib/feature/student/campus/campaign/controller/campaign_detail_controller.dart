import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../service/student_campus_campaign_service.dart';

class CampaignDetailController extends GetxController {
  final String campaignId;
  CampaignDetailController({required this.campaignId});

  final isLoading = false.obs;
  final campaignDetails = Rxn<Map<String, dynamic>>();
  final _campaignService = StudentCampusCampaignService();

  late final TextEditingController commentController;
  late final FocusNode commentFocusNode;
  final isSubmittingComment = false.obs;

  final notices = <Map<String, dynamic>>[].obs;
  final isLoadingNotices = false.obs;

  @override
  void onInit() {
    super.onInit();
    commentController = TextEditingController();
    commentFocusNode = FocusNode();
    fetchCampaignDetails();
    fetchCampaignNotices();
  }

  @override
  void onClose() {
    commentController.dispose();
    commentFocusNode.dispose();
    super.onClose();
  }

  Future<void> fetchCampaignDetails() async {
    if (campaignId.isEmpty) return;
    isLoading.value = true;
    try {
      final details = await _campaignService.fetchCampaignDetails(campaignId);
      campaignDetails.value = details;
    } catch (e) {
      debugPrint('fetchCampaignDetails error inside controller: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCampaignNotices() async {
    if (campaignId.isEmpty) return;
    isLoadingNotices.value = true;
    try {
      final items = await _campaignService.fetchCampaignNotices(campaignId);
      notices.assignAll(items);
    } catch (e) {
      debugPrint('fetchCampaignNotices error inside controller: $e');
    } finally {
      isLoadingNotices.value = false;
    }
  }


  Future<void> toggleLikeCampaign() async {
    final currentDetails = campaignDetails.value;
    if (currentDetails == null) return;

    final isLiked = currentDetails['isLikedByMe'] == 'true';
    final likeCount = int.tryParse(currentDetails['likeCount'] ?? '0') ?? 0;

    // Optimistic Update
    final newIsLiked = !isLiked;
    final newLikeCount = isLiked
        ? (likeCount - 1).clamp(0, 99999)
        : (likeCount + 1);

    final updatedDetails = Map<String, dynamic>.from(currentDetails);
    updatedDetails['isLikedByMe'] = newIsLiked.toString();
    updatedDetails['likeCount'] = newLikeCount.toString();
    campaignDetails.value = updatedDetails;

    // Call API
    final success = newIsLiked
        ? await _campaignService.likeCampaign(campaignId)
        : await _campaignService.unlikeCampaign(campaignId);

    if (!success) {
      // Revert optimistic update
      final revertedDetails = Map<String, dynamic>.from(updatedDetails);
      revertedDetails['isLikedByMe'] = isLiked.toString();
      revertedDetails['likeCount'] = likeCount.toString();
      campaignDetails.value = revertedDetails;
      Get.snackbar(
        'Error',
        'Failed to update like status. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      // Refresh to fetch actual updated data from server
      await fetchCampaignDetails();
    }
  }

  Future<void> submitComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    isSubmittingComment.value = true;
    final success = await _campaignService.commentCampaign(campaignId, text);
    isSubmittingComment.value = false;

    if (success) {
      commentController.clear();
      commentFocusNode.unfocus();
      await fetchCampaignDetails();
    } else {
      Get.snackbar(
        'Error',
        'Failed to add comment. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> addComment(String content) async {
    if (content.trim().isEmpty) return false;

    final success = await _campaignService.commentCampaign(
      campaignId,
      content.trim(),
    );
    if (success) {
      // Fetch latest comments and counts from backend
      await fetchCampaignDetails();
      return true;
    } else {
      Get.snackbar(
        'Error',
        'Failed to add comment. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  void shareCampaign() {
    final details = campaignDetails.value;
    if (details == null) return;
    
    final title = details['title']?.toString().trim();
    final url = details['destinationUrl']?.toString().trim();
    final text = [
      if (title != null && title.isNotEmpty) title,
      if (url != null && url.isNotEmpty) url,
    ].join('\n');
    
    SharePlus.instance.share(
      ShareParams(text: text.isEmpty ? 'Campaign' : text),
    );
  }

  void focusCommentComposer() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!isClosed && commentFocusNode.canRequestFocus) {
        commentFocusNode.requestFocus();
      }
    });
  }
}
