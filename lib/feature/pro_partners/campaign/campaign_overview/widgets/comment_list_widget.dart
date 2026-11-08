import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/campaign_social_feed_controller.dart';
import 'comment_media_preview_widget.dart';
import 'comment_item_widget.dart';
import 'profile_avatar_widget.dart';

class CommentListWidget extends StatelessWidget {
  final String tag;

  const CommentListWidget({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CampaignSocialFeedController>(tag: tag);

    return Obx(() {
      final isComposerVisible = controller.activeComposerIndex.value == 0;
      final replyingTo = controller.replyingToName();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isComposerVisible) ...[
            if (controller.comments.isNotEmpty)
              ...controller.comments.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: CommentItemWidget(tag: tag, comment: item, depth: 0),
                ),
              ),
            if (controller.comments.isEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  'No comments yet. Be the first to comment.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ),
            if (replyingTo.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.whiteSmokeF1F5F9,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.lavenderE2E8F0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Replying to $replyingTo',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.darkSlateGray334155,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.cancelReply,
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.royalBlue2563EB,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if ((controller.pickedCommentFilePath.value?.isNotEmpty ?? false))
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: CommentMediaPreviewWidget(
                  mediaUrl: controller.pickedCommentFilePath.value!,
                  isLocal: true,
                  onRemove: controller.clearCommentMedia,
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: controller.focusCommentComposer,
                  child: ProfileAvatarWidget(
                    imageUrl: controller.myProfileImageUrl,
                    name: controller.myDisplayName,
                    radius: 16,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.panelBackgroundColor,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: controller.pickCommentMedia,
                          child: Icon(
                            Icons.attach_file_rounded,
                            color: AppColors.slateGray64748B,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextField(
                            controller: controller.commentController,
                            focusNode: controller.commentFocus,
                            decoration: InputDecoration(
                              hintText:
                                  controller.activeReplyCommentId.value != null
                                  ? 'Write a reply'
                                  : 'Write a comment',
                              hintStyle: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.darkGray94A3B8,
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => controller.submitCommentOrReply(),
                          ),
                        ),
                        Obx(
                          () => GestureDetector(
                            onTap: controller.isCommentPosting.value
                                ? null
                                : controller.submitCommentOrReply,
                            child: controller.isCommentPosting.value
                                ? SizedBox(
                                    width: 18.w,
                                    height: 18.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    Icons.send_rounded,
                                    size: 19.sp,
                                    color: AppColors.royalBlue2563EB,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }
}
