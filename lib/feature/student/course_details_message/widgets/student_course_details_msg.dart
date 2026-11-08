import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

import '../../../../core/const/icons_path.dart';

Widget buildMessage({
  bool? active,
  required bool isMe,
  required String text,
  required String time,
  String? name,
  required String imageUrl,
}) {
  if (isMe) {
    // My message (right side bubble)
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            // margin: EdgeInsets.only(bottom: 12.height),
            padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 12.height),
            constraints: BoxConstraints(maxWidth: 321.width),
            decoration: BoxDecoration(
              color: AppColors.primaryButtonColor,
              borderRadius: BorderRadius.circular(16.radius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: appTextStyleHeading1(
                    fontSize: 14.fontSize,
                    letterSpacing: -.6.fontSize,
                    color: AppColors.buttonColorOnboarding,
                  ),
                ),
                SizedBox(height: 4.height),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      time,
                      style: appTextStyleHeading1(
                        color: AppColors.aliceBlueF4F8FF,
                        fontSize: 12.fontSize,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(width: 5.width),

                    Image.asset(
                      IconsPath.doubleCheckChat,
                      height: 16.height,
                      width: 16.width,

                      color: AppColors.aliceBlueF4F8FF,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 5.height),
          Padding(
            padding: EdgeInsets.only(right: 5.width),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  IconsPath.doubleCheckChat,
                  height: 16.height,
                  width: 16.width,
                  color: AppColors.mediumSeaGreen22C55E,
                ),
                SizedBox(width: 5.width),

                Text(
                  "Sent",
                  style: appTextStyleHeading1(
                    fontSize: 12.fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -.5.fontSize,
                    color: AppColors.darkSlateGray475569,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  } else {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10.height),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 12.radius,
                backgroundImage: imageUrl.isNotEmpty
                    ? AssetImage(imageUrl)
                    : null,
                child: imageUrl.isEmpty ? Text(name![0]) : null,
              ),
              Positioned(
                right: -1.width,
                bottom: -1.height,

                child: active!
                    ? Image.asset(IconsPath.activeIcon, height: 8.height, width: 8.width)
                    : SizedBox(),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.width),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 12.width),
              child: Text(
                name!,
                style: appTextStyleHeading2(letterSpacing: 0.2.fontSize),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 12.height),
              padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 12.height),
              constraints: BoxConstraints(maxWidth: 311.width),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.mediumPurple8757F3),
                color: AppColors.ghostWhiteF8F5FF,
                borderRadius: BorderRadius.circular(16.radius),
              ),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: appTextStyleHeading1(
                      fontSize: 14.fontSize,
                      letterSpacing: -.6.fontSize,
                    ),
                  ),
                  SizedBox(height: 4.height),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          time,
                          style: appTextStyleHeading1(
                            color: AppColors.appBarTitleColor.withValues(alpha: .7),
                            fontSize: 12.fontSize,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(width: 5.width),

                        Image.asset(
                          IconsPath.doubleCheckChat,
                          height: 16.height,
                          width: 16.width,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
