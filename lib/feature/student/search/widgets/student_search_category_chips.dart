import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/student_search_controller.dart';

class StudentSearchCategoryChips extends StatelessWidget {
  const StudentSearchCategoryChips({super.key, required this.controller});

  final StudentSearchController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.width),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == category;

            return Padding(
              padding: EdgeInsets.only(right: 8.width),
              child: ChoiceChip(
                label: Text(
                  category,
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.black0F172A,
                  ),
                ),
                selected: isSelected,
                onSelected: (val) {
                  if (val) {
                    controller.selectedCategory.value = category;
                  }
                },
                selectedColor: AppColors.primaryButtonColor,
                backgroundColor: AppColors.panelBackgroundColor,
                disabledColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.radius),
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryButtonColor
                      : AppColors.textfieldBorderColor,
                  width: 1.width,
                ),
                showCheckmark: false,
                padding: EdgeInsets.symmetric(
                  horizontal: 12.width,
                  vertical: 4.height,
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
