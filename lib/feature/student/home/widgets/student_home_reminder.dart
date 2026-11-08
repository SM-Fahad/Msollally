import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/routes/app_route.dart';

const _titleColor = Color(0xFF0F172A);

class StudentHomeReminderBanner extends StatelessWidget {
  const StudentHomeReminderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Reminder',
          style: getTextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _titleColor,
          ),
        ),
        SizedBox(height: 8.height),
        InkWell(
          onTap: () => Get.toNamed(AppRoute.fursaZoneScreen),
          borderRadius: BorderRadius.circular(3.radius),
          child: Container(
            height: 60.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.radius),
              image: const DecorationImage(
                image: AssetImage('assets/images/watches.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0xAA111827),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Center(
              child: Text(
                'Fursa Zone',
                style: getTextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: AppColors.royalBlue6366F1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
