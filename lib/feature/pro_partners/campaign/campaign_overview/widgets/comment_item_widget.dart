import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/campaign_social_feed_controller.dart';
import '../controller/campaign_social_feed_mapper.dart';
import 'comment_media_preview_widget.dart';
import 'profile_avatar_widget.dart';

class CommentItemWidget extends StatelessWidget {
  final String tag;
  final dynamic comment;
  final int depth;

  const CommentItemWidget({
    super.key,
    required this.tag,
    required this.comment,
    this.depth = 0,
  });

  String _timeLabel(dynamic raw) {
    final value = raw?.toString();
    if (value == null || value.isEmpty) return 'now';
    final dt = DateTime.tryParse(value)?.toLocal();
    if (dt == null) return 'now';
    return DateFormat('dd MMM, hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CampaignSocialFeedController>(tag: tag);
    final map = comment is Map<String, dynamic> ? comment : <String, dynamic>{};
    final name = CampaignSocialFeedMapper.pickName(map);
    final image = CampaignSocialFeedMapper.pickAuthorImage(map);
    final replies = (map['replies'] as List?) ?? const [];
    final id = map['id'];
    final mediaUrl = map['mediaUrl']?.toString().trim() ?? '';

    return Padding(
      padding: EdgeInsets.only(left: (depth * 20).w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (depth > 0)
            Container(
              margin: EdgeInsets.only(left: 16.w),
              width: 1.2.w,
              height: 8.h,
              color: AppColors.lavenderDDE3EC,
            ),
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
                          color: AppColors.black0F172A,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        map['content']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.darkSlateGray334155,
                          height: 1.35,
                        ),
                      ),
                      if (mediaUrl.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        CommentMediaPreviewWidget(mediaUrl: mediaUrl),
                      ],
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Text(
                            _timeLabel(map['createdAt']),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.slateGray64748B,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          if ((map['likeCount'] ?? 0) != 0)
                            Text(
                              '${map['likeCount']} likes',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.slateGray64748B,
                              ),
                            ),
                          if (replies.isNotEmpty) ...[
                            SizedBox(width: 10.w),
                            Text(
                              '${replies.length} replies',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.slateGray64748B,
                              ),
                            ),
                          ],
                          SizedBox(width: 10.w),
                          GestureDetector(
                            onTap: () => controller.startReply(
                              (id is int)
                                  ? id
                                  : int.tryParse(id?.toString() ?? '') ?? 0,
                            ),
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
                        child: CommentItemWidget(
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
