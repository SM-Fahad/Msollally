import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/student_search_controller.dart';

class StudentSearchHeader extends StatelessWidget {
  const StudentSearchHeader({super.key, required this.controller});

  final StudentSearchController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 12.height),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 22.fontSize),
            color: AppColors.black0F172A,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 12.width),
          Expanded(
            child: Container(
              height: 46.height,
              decoration: BoxDecoration(
                color: AppColors.panelBackgroundColor,
                borderRadius: BorderRadius.circular(24.radius),
                border: Border.all(
                  color: AppColors.textfieldBorderColor,
                  width: 1.width,
                ),
              ),
              child: TextField(
                controller: controller.textController,
                autofocus: true,
                textAlignVertical: TextAlignVertical.center,
                style: getTextStyle(
                  fontSize: 14,
                  color: AppColors.black0F172A,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search courses, tasks, chats, tools...',
                  hintStyle: getTextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryTextColor,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 22.fontSize,
                    color: AppColors.secondaryTextColor,
                  ),
                  suffixIcon: Obx(() {
                    final text = controller.searchQuery.value;
                    if (text.isEmpty) return const SizedBox();
                    return IconButton(
                      icon: Icon(
                        Icons.cancel_rounded,
                        size: 20.fontSize,
                        color: AppColors.secondaryTextColor,
                      ),
                      onPressed: () {
                        controller.textController.clear();
                      },
                    );
                  }),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 11.height),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
