import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'category_selection_sheet.dart';

class MockInterviewCard extends StatelessWidget {
  const MockInterviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(16.radius),
        border: Border.all(color: AppColors.sectionBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.radius),
                decoration: BoxDecoration(
                  color: AppColors.primaryButtonColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.radius),
                ),
                child: const Icon(
                  Icons.quiz_outlined,
                  color: AppColors.primaryButtonColor,
                ),
              ),
              SizedBox(width: 12.width),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mock Interview Prep',
                      style: getTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 2.height),
                    Text(
                      'Sharpen your skills with themed tests',
                      style: getTextStyle(
                        color: AppColors.secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.height),
          ElevatedButton(
            onPressed: () => showCategoryBottomSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButtonColor,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 44.height),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.radius),
              ),
            ),
            child: Text(
              'Start a mock interview',
              style: getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
