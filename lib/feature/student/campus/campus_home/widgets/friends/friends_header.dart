import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';

class FriendsHeader extends StatelessWidget {
  final StudentCampusController controller;

  const FriendsHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.width),
      child: Obx(() {
        if (controller.isStudentSearching.value) {
          return Row(
            children: [
              Expanded(
                child: Container(
                  height: 44.height,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10.radius),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: controller.studentSearchController,
                    autofocus: true,
                    onChanged: (val) => controller.studentSearchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: "Search students by name, program...",
                      hintStyle: getTextStyle(
                        fontSize: 13.fontSize,
                        color: Colors.grey.shade500,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.appBarTitleColor,
                        size: 20,
                      ),
                      suffixIcon: controller.studentSearchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                controller.studentSearchController.clear();
                                controller.studentSearchQuery.value = '';
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.height),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.width),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  controller.isStudentSearching.value = false;
                  controller.studentSearchQuery.value = '';
                  controller.studentSearchController.clear();
                },
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Student",
              style: appTextStyleHeading1(
                fontSize: 20.fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: -.5.fontSize,
                color: AppColors.appBarTitleColor,
              ),
            ),
            InkWell(
              onTap: () {
                controller.isStudentSearching.value = true;
              },
              child: const Icon(
                Icons.search,
                size: 24,
                color: AppColors.appBarTitleColor,
              ),
            ),
          ],
        );
      }),
    );
  }
}

