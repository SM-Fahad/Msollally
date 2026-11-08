import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../../../../routes/app_route.dart';
import '../controller/student_create_task_controller.dart';

class StudentTaskListItem extends StatelessWidget {
  const StudentTaskListItem({
    super.key,
    required StudentCreateTaskController controller,
  }) : _controller = controller;

  final StudentCreateTaskController _controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isTaskLoading.value) {
        return SizedBox(
          height: 360.height,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (_controller.taskErrorMessage.value.isNotEmpty) {
        return SizedBox(
          height: 360.height,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.width),
              child: Text(
                _controller.taskErrorMessage.value,
                style: appTextStyleHeading2(color: AppColors.tertiaryTextColor),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      if (_controller.taskListItems.isEmpty) {
        return SizedBox(
          height: 360.height,
          child: Center(
            child: Text(
              'No tasks found',
              style: appTextStyleHeading2(color: AppColors.tertiaryTextColor),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _controller.taskListItems.length,
        itemBuilder: (_, index) {
          final items = _controller.taskListItems[index];

          return GestureDetector(
            onTap: () {
              final taskId = items.id;
              final allTaskIds = _controller.taskListItems
                  .map((e) => e.id)
                  .toList();
              debugPrint('Task list ids: $allTaskIds');
              if (taskId == null || taskId <= 0) {
                EasyLoading.showError('Task id is missing');
                debugPrint('Navigation blocked: invalid task id -> $taskId');
                return;
              }
              debugPrint('Navigating to task details with id: $taskId');
              Get.toNamed(AppRoute.studentDetailsTask, arguments: taskId);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 16.height),
              decoration: BoxDecoration(
                color: AppColors.buttonColorOnboarding,
                border: Border.all(
                  width: 0.5.width,
                  color: AppColors.textfieldBorderColor,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Obx(
                          () => Checkbox(
                            activeColor: AppColors.checkBoxActiveColor,
                            checkColor:
                                AppColors.buttonColorGoogleAppleOnboarding,
                            side: const BorderSide(color: AppColors.gray909090),
                            value: _controller
                                .taskListItems[index]
                                .isTapCheckBox
                                .value,
                            onChanged:
                                (items.id == null ||
                                    _controller.isCompletedUpdating(items.id!))
                                ? null
                                : (value) {
                                    _controller.toggleCheckBox(index);
                                  },
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(items.title, style: appTextStyleHeading1()),
                            Text(items.date, style: appTextStyleHeading2()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (items.id == null) {
                        return;
                      }
                      if (_controller.isFavouriteUpdating(items.id!)) {
                        return;
                      }
                      _controller.toggleFavorite(index);
                    },
                    child: Obx(
                      () =>
                          _controller
                              .taskListItems[index]
                              .isTappedFavorite
                              .value
                          ? SvgPicture.asset(
                              IconsPath.starBlueIcon,
                              height: 24.height,
                              width: 24.width,
                            )
                          : SvgPicture.asset(
                              IconsPath.starIcon,
                              height: 24.height,
                              width: 24.width,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
