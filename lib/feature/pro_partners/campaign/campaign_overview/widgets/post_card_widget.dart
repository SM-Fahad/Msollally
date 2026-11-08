import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/core/common/widgets/post_action_button.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/core/utils/device/device_utility.dart';

import '../controller/campaign_social_feed_controller.dart';
import '../controller/campaign_social_feed_mapper.dart';
import 'comment_list_widget.dart';
import 'expandable_text_widget.dart';
import 'likes_bottom_sheet_widget.dart';
import 'profile_avatar_widget.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/wall/wall_video_player.dart';

class PostCardWidget extends StatelessWidget {
  final String tag;

  const PostCardWidget({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CampaignSocialFeedController>(tag: tag);

    return Obx(() {
      final campaign = Map<String, dynamic>.from(controller.campaign);
      final authorName = CampaignSocialFeedMapper.pickName(campaign);
      final authorImage = CampaignSocialFeedMapper.pickAuthorImage(campaign);
      final media = _value(campaign['imageOrVideoLink']);
      final destinationUrl = _value(campaign['destinationUrl']);
      final cta = _value(campaign['callToAction']);
      final isLiked = campaign['isLikedByMe'] == true;
      final likeCount = campaign['likeCount'] ?? 0;
      final commentCount = campaign['commentCount'] ?? 0;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.lavenderE6EAF0),
          boxShadow: const [
            BoxShadow(
              color: AppColors.blackAlpha120F172A,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(campaign, authorName, authorImage),
            SizedBox(height: 10.h),
            _content(campaign, controller),
            if (media.isNotEmpty) ...[SizedBox(height: 12.h), _media(media)],
            // if (cta.isNotEmpty && destinationUrl.isNotEmpty) ...[
            //   SizedBox(height: 12.h),
            //   _cta(cta, destinationUrl),
            // ],
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
                    '$likeCount Likes',
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
                      label: isLiked ? 'Liked' : 'Like',
                      isActive: isLiked,
                      activeColor: AppColors.royalBlue2563EB,
                      inactiveColor: AppColors.secondaryTextColor,
                      onTap: controller.toggleLike,
                    ),
                  ),
                ),
                PostActionButton(
                  iconPath: IconsPath.commentIcon,
                  label: 'Comment',
                  isActive: controller.activeComposerIndex.value == 0,
                  activeColor: AppColors.royalBlue2563EB,
                  inactiveColor: AppColors.secondaryTextColor,
                  onTap: controller.focusCommentComposer,
                ),
                PostActionButton(
                  iconPath: IconsPath.shareIcon,
                  label: 'Share',
                  inactiveColor: AppColors.secondaryTextColor,
                  onTap: controller.shareCampaign,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            CommentListWidget(tag: tag),
          ],
        ),
      );
    });
  }

  Widget _header(
    Map<String, dynamic> campaign,
    String authorName,
    String authorImage,
  ) {
    final raw = campaign['createdAt']?.toString();
    final dt = raw == null ? null : DateTime.tryParse(raw)?.toLocal();
    final time = dt == null
        ? 'Just now'
        : DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    final sponsored =
        (campaign['status']?.toString().toLowerCase() == 'sponsored') ||
        (campaign['isSponsored'] == true);

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
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTextColor,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ),
                  if (sponsored)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.aliceBlueE8F0FF,
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                      child: Text(
                        'Sponsored',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.royalBlue1D4ED8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _content(
    Map<String, dynamic> campaign,
    CampaignSocialFeedController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _value(campaign['campaignTitle']).isNotEmpty
              ? _value(campaign['campaignTitle'])
              : 'Campaign',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.black0F172A,
          ),
        ),
        if (_value(campaign['caption']).isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            _value(campaign['caption']),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.darkSlateGray1F2937,
              height: 1.45,
            ),
          ),
        ],
        if (_value(campaign['description']).isNotEmpty) ...[
          SizedBox(height: 6.h),
          ExpandableTextWidget(
            text: _value(campaign['description']),
            isExpanded: controller.isDescriptionExpanded.value,
            onToggle: controller.toggleDescriptionExpanded,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.darkSlateGray334155,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _media(String media) {
    if (media.isEmpty) return const SizedBox.shrink();

    final isVideo =
        media.toLowerCase().endsWith('.mp4') ||
        media.toLowerCase().endsWith('.mov') ||
        media.toLowerCase().endsWith('.avi') ||
        media.toLowerCase().endsWith('.mkv');

    if (isVideo) {
      return Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: WallVideoPlayer(videoUrl: media),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Center(
        child: GestureDetector(
          onTap: () {
            Get.to(
              () => FullscreenImageView(imageUrl: media, isNetworkImage: true),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              media,
              loadingBuilder: (_, child, loading) {
                if (loading == null) return child;

                return Container(
                  width: double.infinity,
                  height: 200.h,
                  color: AppColors.whiteSmokeF1F5F9,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  String _value(dynamic input) => input?.toString().trim() ?? '';
}
