import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/widgets/global_app_bar.dart';
import 'package:msollaally/feature/feedback/controller/feedback_detail_controller.dart';
import 'package:msollaally/feature/feedback/widgets/feedback_detail_widgets.dart';

class FeedbackDetailScreen extends StatelessWidget {
  final int feedbackId;
  const FeedbackDetailScreen({super.key, required this.feedbackId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedbackDetailController(feedbackId: feedbackId), tag: feedbackId.toString());

    return Scaffold(
      backgroundColor: AppColors.ghostWhiteF5F7FB,
      appBar: GlobalAppBar(
        title: 'Feedback Details',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: AppColors.darkSlateGray1F2937),
            onPressed: () => controller.fetchDetails(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final feedback = controller.feedbackDetails.value;
        if (feedback == null) {
          return Center(
            child: Text(
              "Feedback not found.",
              style: appTextStyleHeading1(fontSize: 16.fontSize, color: Colors.grey.shade500),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchDetails(),
          color: AppColors.primaryButtonColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.width),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeedbackMainDetailsCard(feedback: feedback),
                if (feedback.attachmentUrl != null && feedback.attachmentUrl!.isNotEmpty) ...[
                  SizedBox(height: 16.height),
                  FeedbackAttachmentCard(url: feedback.attachmentUrl!),
                ],
                if (feedback.adminReply != null && feedback.adminReply!.isNotEmpty) ...[
                  SizedBox(height: 16.height),
                  FeedbackAdminReplyCard(feedback: feedback),
                ],
                if (feedback.replies != null && feedback.replies!.isNotEmpty) ...[
                  SizedBox(height: 16.height),
                  FeedbackRepliesList(replies: feedback.replies!),
                ],
                SizedBox(height: 24.height),
                _buildReplyForm(controller),
                SizedBox(height: 24.height),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildReplyForm(FeedbackDetailController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.width),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.radius),
        border: Border.all(color: AppColors.lavenderE6EBF2.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add a Reply",
            style: appTextStyleHeading1(
              fontSize: 16.fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.black1F1F1F,
            ),
          ),
          SizedBox(height: 12.height),
          TextField(
            controller: controller.replyController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Enter your message here...",
              hintStyle: appTextStyleHeading1(fontSize: 14.fontSize, color: Colors.grey.shade400),
              filled: true,
              fillColor: AppColors.ghostWhiteF5F7FB,
              contentPadding: EdgeInsets.all(16.width),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.radius),
                borderSide: BorderSide(color: AppColors.lavenderE6EBF2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.radius),
                borderSide: BorderSide(color: AppColors.lavenderE6EBF2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.radius),
                borderSide: BorderSide(color: Colors.blue.shade300),
              ),
            ),
          ),
          SizedBox(height: 16.height),
          Align(
            alignment: Alignment.centerRight,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.isReplying.value ? null : controller.postReply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 24.width, vertical: 12.height),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.radius),
                    ),
                  ),
                  child: controller.isReplying.value
                      ? SizedBox(
                          height: 20.height,
                          width: 20.height,
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          "Submit Reply",
                          style: appTextStyleHeading1(
                            fontSize: 14.fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                )),
          ),
        ],
      ),
    );
  }
}
