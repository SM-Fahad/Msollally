import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'union_list_item.dart';

class UnionListView extends StatelessWidget {
  const UnionListView({super.key, required this.controller});

  final StudentCampusController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingUnions.value) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 16.height),
          child: ShimmerLoading.list(
            itemCount: 3,
            height: 72.height,
            borderRadius: 12.radius,
          ),
        );
      }

      final rawList = controller.selectStudentUnionTab.value == 0
          ? controller.unionForYouList
          : controller.selectStudentUnionTab.value == 1
          ? controller.yourUnionList
          : controller.pendingUnionList;

      final currentList = controller.getFilteredUnions(rawList);

      if (currentList.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: 20.height),
          child: Center(
            child: Text(
              "No unions found",
              style: appTextStyleHeading2(color: Colors.grey),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: currentList.length,
        itemBuilder: (_, index) {
          final item = currentList[index];
          return UnionListItem(
            item: item,
            showStatus: controller.selectStudentUnionTab.value != 0,
          );
        },
      );
    });
  }
}
