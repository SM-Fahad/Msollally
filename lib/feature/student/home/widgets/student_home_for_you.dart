import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/student/home/controller/student_home_controller.dart';
import 'student_home_expanded_panel.dart';

const _titleColor = Color(0xFF0F172A);

class StudentHomeForYou extends StatelessWidget {
  const StudentHomeForYou({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<StudentHomeController>()
        ? Get.find<StudentHomeController>()
        : Get.put(StudentHomeController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'For You',
          style: getTextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _titleColor,
          ),
        ),
        SizedBox(height: 10.height),
        InkWell(
          onTap: () => showStudentHomeExpandedPanel(context, controller),
          borderRadius: BorderRadius.circular(16.radius),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.width,
              vertical: 13.height,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.radius),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44.width,
                  height: 44.height,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.radius),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.explore_rounded,
                    color: Colors.white,
                    size: 22.fontSize,
                  ),
                ),
                SizedBox(width: 12.width),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Explore Opportunities & Updates',
                        style: getTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.height),
                      Text(
                        'Events, career openings & campus updates',
                        style: getTextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.width),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.width,
                    vertical: 6.height,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryButtonColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.radius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explore',
                        style: getTextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryButtonColor,
                        ),
                      ),
                      SizedBox(width: 3.width),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primaryButtonColor,
                        size: 13.fontSize,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
