import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/student/campus/union/create_union/screen/create_union_screen.dart';

class UnionHeader extends StatelessWidget {
  final StudentCampusController controller;

  const UnionHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isUnionSearching.value) {
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
                  controller: controller.unionSearchController,
                  autofocus: true,
                  onChanged: (val) => controller.unionSearchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: "Search unions...",
                    hintStyle: getTextStyle(
                      fontSize: 14.fontSize,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.appBarTitleColor,
                      size: 20,
                    ),
                    suffixIcon: controller.unionSearchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              controller.unionSearchController.clear();
                              controller.unionSearchQuery.value = '';
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
                controller.isUnionSearching.value = false;
                controller.unionSearchQuery.value = '';
                controller.unionSearchController.clear();
              },
            ),
          ],
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "The Student Union",
            style: appTextStyleHeading1(
              fontSize: 20.fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: -.5.fontSize,
              color: AppColors.appBarTitleColor,
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  controller.isUnionSearching.value = true;
                },
                child: const Icon(
                  Icons.search,
                  size: 24,
                  color: AppColors.appBarTitleColor,
                ),
              ),
              SizedBox(width: 24.width),
              InkWell(
                onTap: () {
                  Get.to(const CreateUnionScreen());
                },
                child: Image.asset(
                  "assets/icons/iconButtons.png",
                  height: 28.height,
                  width: 28.width,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

