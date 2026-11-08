import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/widgets/post_action_button.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/feature/pro_partners/campaign/campaign_overview/controller/campaign_social_feed_mapper.dart';
import 'package:msollaally/feature/pro_partners/campaign/campaign_overview/widgets/comment_media_preview_widget.dart';
import 'package:msollaally/feature/pro_partners/campaign/campaign_overview/widgets/expandable_text_widget.dart';
import 'package:msollaally/feature/pro_partners/campaign/campaign_overview/widgets/likes_bottom_sheet_widget.dart';
import 'package:msollaally/feature/pro_partners/campaign/campaign_overview/widgets/profile_avatar_widget.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/student_event_social_feed_controller.dart';

class StudentEventSocialPostCardWidget extends StatelessWidget {
  final String tag;

  const StudentEventSocialPostCardWidget({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentEventSocialFeedController>(tag: tag);

    return Obx(() {
      final event = Map<String, dynamic>.from(controller.event);
      final creator = CampaignSocialFeedMapper.asMap(event['creator']);
      final authorName = CampaignSocialFeedMapper.pickName(creator);
      final authorImage = CampaignSocialFeedMapper.pickAuthorImage(creator);
      final media = _value(event['coverImageUrl']).isNotEmpty
          ? _value(event['coverImageUrl'])
          : _value(event['mediaUrl']);
      final likesCount = event['likeCount'] ?? 0;
      final commentCount = event['commentCount'] ?? 0;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.lavenderE6EAF0),
          boxShadow: const [
            BoxShadow(
              color: AppColors.blackAlpha120F172A,
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(event, authorName, authorImage),
            SizedBox(height: 12.h),
            Text(
              _value(event['title']).isNotEmpty
                  ? _value(event['title'])
                  : 'Event',
              style: TextStyle(
                fontSize: 21.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.black0F172A,
              ),
            ),
            SizedBox(height: 12.h),
            _buildEventDetails(event),
            if (_value(event['description']).isNotEmpty) ...[
              SizedBox(height: 8.h),
              ExpandableTextWidget(
                text: _value(event['description']),
                isExpanded: controller.isDescriptionExpanded.value,
                onToggle: controller.toggleDescriptionExpanded,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.darkSlateGray334155,
                  height: 1.42,
                ),
              ),
            ],
            if (media.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      () => FullscreenImageView(
                        imageUrl: media,
                        isNetworkImage: true,
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: Image.network(
                      media,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),

            SizedBox(height: 16.h),
            if (_value(event['onlineLink']).isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final link = _value(event['onlineLink']);
                    final uri = Uri.tryParse(
                      link.startsWith('http') ? link : 'https://$link',
                    );
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.inAppWebView);
                    }
                  },
                  icon: Icon(Icons.link, color: Colors.white, size: 20.sp),
                  label: Text(
                    'Visit Event',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ],
            _buildRsvpActions(controller, event),

            SizedBox(height: 12.h),
            Divider(color: AppColors.sliderColorInboarding, height: 1.h),
            SizedBox(height: 10.h),
            Row(
              children: [
                GestureDetector(
                  onTap: controller.likes.isEmpty
                      ? null
                      : () => Get.bottomSheet(
                          LikesBottomSheetWidget(likes: controller.likes),
                          isScrollControlled: true,
                        ),
                  child: Text(
                    '$likesCount Likes',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.darkSlateGray475569,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '$commentCount Comments',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.darkSlateGray475569,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Divider(color: AppColors.sliderColorInboarding, height: 1.h),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Opacity(
                  opacity: controller.isLikeLoading.value ? 0.6 : 1,
                  child: IgnorePointer(
                    ignoring: controller.isLikeLoading.value,
                    child: PostActionButton(
                      iconPath: IconsPath.reactIcon,
                      label: event['isLikedByMe'] == true ? 'Liked' : 'Like',
                      isActive: event['isLikedByMe'] == true,
                      activeColor: AppColors.royalBlue2563EB,
                      inactiveColor: AppColors.secondaryTextColor,
                      onTap: controller.toggleLike,
                    ),
                  ),
                ),
                PostActionButton(
                  iconPath: IconsPath.commentIcon,
                  label: 'Comment',
                  inactiveColor: AppColors.secondaryTextColor,
                  onTap: controller.focusCommentComposer,
                ),
                PostActionButton(
                  iconPath: IconsPath.shareIcon,
                  label: 'Share',
                  inactiveColor: AppColors.secondaryTextColor,
                  onTap: controller.shareEvent,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _comments(controller),
          ],
        ),
      );
    });
  }

  Widget _buildRsvpActions(
    StudentEventSocialFeedController controller,
    Map<String, dynamic> event,
  ) {
    return Row(
      children: [
        Icon(
          Icons.people_outline,
          color: AppColors.darkSlateGray475569,
          size: 18.sp,
        ),
        SizedBox(width: 6.w),
        Text(
          '${controller.rsvpsCount.value} going',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.darkSlateGray475569,
          ),
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.isRegistered.value
                ? AppColors.secondaryTextColor
                : AppColors.primaryButtonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            minimumSize: const Size(0, 36),
            elevation: 0,
          ),
          onPressed: () {
            if (controller.isRegistered.value) {
              _showCancelDialog(controller);
            } else {
              _showRegisterDialog(controller);
            }
          },
          child: Text(
            controller.isRegistered.value ? 'Cancel RSVP' : 'Register Now',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _showRegisterDialog(StudentEventSocialFeedController controller) {
    final TextEditingController msgController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Register for Event',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Would you like to include a message? (Optional)',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.darkSlateGray475569,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: msgController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Looking forward to learning...',
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.secondaryTextColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: AppColors.lavenderE2E8F0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: AppColors.lavenderE2E8F0),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.secondaryTextColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButtonColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              Get.back();
              controller.toggleRegister(message: msgController.text.trim());
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(StudentEventSocialFeedController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Cancel Registration',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to cancel your RSVP for this event?',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.darkSlateGray475569,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'No',
              style: TextStyle(color: AppColors.secondaryTextColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.uiDangerColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              Get.back();
              controller.toggleRegister();
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(
    Map<String, dynamic> event,
    String authorName,
    String authorImage,
  ) {
    final raw = event['createdAt']?.toString();
    final dt = raw == null ? null : DateTime.tryParse(raw)?.toLocal();
    final time = dt == null
        ? 'Just now'
        : DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    final coHosts = ((event['coHosts'] as List?) ?? const [])
        .map((e) => CampaignSocialFeedMapper.asMap(e))
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileAvatarWidget(
          imageUrl: authorImage,
          name: authorName,
          radius: 21,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authorName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTextColor,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.secondaryTextColor,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Event Host',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.darkGray94A3B8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (coHosts.isNotEmpty) _coHostStack(coHosts),
      ],
    );
  }

  Widget _buildEventDetails(Map<String, dynamic> event) {
    final startStr = event['startDate']?.toString();
    final endStr = event['endDate']?.toString();
    String dateRange = '';
    if (startStr != null && startStr.isNotEmpty) {
      final startDt = DateTime.tryParse(startStr)?.toLocal();
      if (startDt != null) {
        final startFmt = DateFormat('MMM dd, yyyy • hh:mm a').format(startDt);
        dateRange = startFmt;
        if (endStr != null && endStr.isNotEmpty) {
          final endDt = DateTime.tryParse(endStr)?.toLocal();
          if (endDt != null) {
            final endFmt = DateFormat('MMM dd, yyyy • hh:mm a').format(endDt);
            dateRange = '$startFmt  -  $endFmt';
          }
        }
      }
    }

    final location = event['location']?.toString() ?? '';
    String eventType = event['eventType']?.toString() ?? '';
    if (eventType.isNotEmpty) {
      eventType = eventType[0].toUpperCase() + eventType.substring(1);
    }

    final tags =
        (event['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [];
    final targetMajor = event['targetMajor']?.toString() ?? '';
    final targetYear = event['targetYear']?.toString() ?? '';
    final maxAttendees = event['maxAttendees']?.toString() ?? '';

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dateRange.isNotEmpty)
            _detailRow(Icons.calendar_today_outlined, dateRange),
          if (location.isNotEmpty || eventType.isNotEmpty)
            _detailRow(
              Icons.location_on_outlined,
              [
                if (location.isNotEmpty) location,
                if (eventType.isNotEmpty) '($eventType)',
              ].join(' '),
            ),
          if (targetMajor.isNotEmpty || targetYear.isNotEmpty)
            _detailRow(
              Icons.school_outlined,
              [
                if (targetMajor.isNotEmpty) targetMajor,
                if (targetYear.isNotEmpty) 'Year $targetYear',
              ].join(' • '),
            ),
          if (maxAttendees.isNotEmpty && maxAttendees != '0')
            _detailRow(Icons.groups_outlined, 'Max Attendees: $maxAttendees'),
          if (tags.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: tags
                    .map(
                      (t) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tagBackgroundColor,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.tagBorderColor),
                        ),
                        child: Text(
                          '#$t',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.primaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.secondaryTextColor),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.darkSlateGray475569,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coHostStack(List<Map<String, dynamic>> coHosts) {
    final firstThree = coHosts.take(3).toList();
    final extra = coHosts.length - firstThree.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Co-hosts',
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.darkGray94A3B8,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        SizedBox(
          height: 26.h,
          child: Row(
            children: [
              ...firstThree.asMap().entries.map((entry) {
                final user = CampaignSocialFeedMapper.asMap(
                  entry.value['user'],
                );
                final name = CampaignSocialFeedMapper.pickName(user);
                final image = CampaignSocialFeedMapper.pickAuthorImage(user);
                return Align(
                  widthFactor: entry.key == 0 ? 1 : 0.72,
                  child: ProfileAvatarWidget(
                    imageUrl: image,
                    name: name,
                    radius: 12,
                  ),
                );
              }),
              if (extra > 0)
                Container(
                  width: 24.w,
                  height: 24.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.lavenderE2E8F0,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    '+$extra',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkSlateGray334155,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _comments(StudentEventSocialFeedController controller) {
    final replyingTo = controller.replyingToName();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.comments.isNotEmpty)
          ...controller.comments.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _EventCommentItemWidget(tag: tag, comment: item),
            ),
          )
        else
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
        if ((controller.pickedCommentFilePath.value?.isNotEmpty ?? false))
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: CommentMediaPreviewWidget(
              mediaUrl: controller.pickedCommentFilePath.value!,
              isLocal: true,
              onRemove: controller.clearCommentMedia,
            ),
          ),
        if (replyingTo.isNotEmpty)
          Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.whiteSmokeF1F5F9,
              borderRadius: BorderRadius.circular(10.r),
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
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.panelBackgroundColor,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.lavenderE2E8F0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ProfileAvatarWidget(
                imageUrl: controller.myProfileImageUrl,
                name: controller.myDisplayName,
                radius: 15,
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: controller.pickCommentMedia,
                child: Icon(
                  Icons.attach_file_rounded,
                  size: 20.sp,
                  color: AppColors.slateGray64748B,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: controller.commentController,
                  focusNode: controller.commentFocus,
                  decoration: InputDecoration(
                    hintText: controller.activeReplyCommentId.value != null
                        ? 'Write a reply'
                        : 'Write a comment',
                    hintStyle: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.darkGray94A3B8,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => controller.submitCommentOrReply(),
                ),
              ),
              GestureDetector(
                onTap: controller.isCommentPosting.value
                    ? null
                    : controller.submitCommentOrReply,
                child: controller.isCommentPosting.value
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.send_rounded,
                        size: 19.sp,
                        color: AppColors.royalBlue2563EB,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _value(dynamic input) => input?.toString().trim() ?? '';
}

class _EventCommentItemWidget extends StatelessWidget {
  final String tag;
  final dynamic comment;
  final int depth;

  const _EventCommentItemWidget({
    required this.tag,
    required this.comment,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentEventSocialFeedController>(tag: tag);
    final map = CampaignSocialFeedMapper.asMap(comment);
    final name = CampaignSocialFeedMapper.pickName(map);
    final image = CampaignSocialFeedMapper.pickAuthorImage(map);
    final replies = (map['replies'] as List?) ?? const [];
    final id = CampaignSocialFeedMapper.toInt(map['id']);
    final mediaUrl = map['mediaUrl']?.toString().trim() ?? '';

    return Padding(
      padding: EdgeInsets.only(left: (depth * 20).w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileAvatarWidget(imageUrl: image, name: name, radius: 14),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: depth == 0
                        ? AppColors.panelBackgroundColor
                        : AppColors.whiteSmokeF1F5F9,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.lavenderE2E8F0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(map['content']?.toString() ?? ''),
                      if (mediaUrl.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        CommentMediaPreviewWidget(mediaUrl: mediaUrl),
                      ],
                      SizedBox(height: 6.h),
                      GestureDetector(
                        onTap: () => controller.startReply(id),
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.royalBlue2563EB,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (replies.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Column(
                children: replies
                    .map(
                      (reply) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: _EventCommentItemWidget(
                          tag: tag,
                          comment: reply,
                          depth: depth + 1,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
