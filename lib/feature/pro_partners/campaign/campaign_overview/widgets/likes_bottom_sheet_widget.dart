import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controller/campaign_social_feed_mapper.dart';
import 'profile_avatar_widget.dart';

class LikesBottomSheetWidget extends StatelessWidget {
  final List<dynamic> likes;

  const LikesBottomSheetWidget({super.key, required this.likes});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.25,
        maxChildSize: 0.85,
        initialChildSize: 0.55,
        builder: (_, scroll) {
          return Column(
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.tagBorderColor,
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'People who liked',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black0F172A,
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: ListView.separated(
                  controller: scroll,
                  itemCount: likes.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: AppColors.sliderColorInboarding, height: 14.h),
                  itemBuilder: (_, i) {
                    final map = CampaignSocialFeedMapper.asMap(likes[i]);
                    final name = CampaignSocialFeedMapper.pickName(map);
                    final image = CampaignSocialFeedMapper.pickAuthorImage(map);

                    return Row(
                      children: [
                        ProfileAvatarWidget(
                          imageUrl: image,
                          name: name,
                          radius: 18,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.black0F172A,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
