import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/career/my_career/screen/student_career_screen.dart';
import '../model/mock_model.dart';
import '../screen/mock_interview_screen.dart';

class StatisticsBottomBar extends StatelessWidget {
  final MockResult result;

  const StatisticsBottomBar({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.width, 16.height, 20.width, 36.height),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.sectionBorderColor, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.offAll(() => StudentCareerScreen()),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryButtonColor),
                padding: EdgeInsets.symmetric(vertical: 14.height),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.radius),
                ),
              ),
              child: Text(
                "Career Hub",
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryButtonColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.width),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Get.off(
                  () => MockInterviewScreen(
                    topicId: result.topicId,
                    duration: result.duration,
                    categoryTitle: result.categoryTitle,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButtonColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.height),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.radius),
                ),
              ),
              child: Text(
                "Retake Test",
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
