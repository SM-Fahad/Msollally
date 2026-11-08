import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/auth/signup/account_opening/widgets/custom_text_field_nodmac.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';

import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/const/icons_path.dart';
import '../../../converter/widgets/student_upload_a_folder.dart';
import '../controller/student_edit_task_controller.dart';

class StudentEditTaskPage extends StatelessWidget {
  const StudentEditTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<StudentEditTaskController>()
        ? Get.find<StudentEditTaskController>()
        : Get.put(StudentEditTaskController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar(
                leadingIcon: SvgPicture.asset(IconsPath.uploadFileXIcon),
                onLeadingTap: () {
                  Get.back();
                },
                title: "Edit Task",

                actionWidget: Obx(
                  () => InkWell(
                    onTap: controller.isUpdating.value
                        ? null
                        : () => controller.updateTask(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.width,
                        vertical: 6.height,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.radius),

                        color: AppColors.primaryButtonColor,
                      ),
                      child: Text(
                        controller.isUpdating.value ? "Saving..." : "Save",
                        style: appTextStyleHeading2(
                          fontWeight: FontWeight.w500,
                          color: AppColors.buttonColorOnboarding,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 12.height),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.height),

                    CustomTextFieldNodMac(
                      controller: controller.controllerEditTaskTask,
                      lebelName: "Task",
                      hinText: "Write the task",
                    ),
                    SizedBox(height: 20.height),
                    CustomTextFieldNodMac(
                      textFieldHeight: 105.height,
                      controller: controller.controllerEditTaskNote,
                      lebelName: "Note",
                      hinText: "Add a note",
                    ),
                    SizedBox(height: 20.height),
                    Text(
                      "Date & time",
                      style: appTextStyleHeading2(color: AppColors.black18181B),
                    ),
                    SizedBox(height: 8.height),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.width,
                        vertical: 12.height,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.radius),
                        border: Border.all(
                          color: AppColors.textfieldBorderColor,
                        ),
                      ),
                      child: Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.formattedDateTime,
                              style: appTextStyleHeading2(
                                letterSpacing: 0.2.fontSize,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                controller.pickDateTime(context);
                              },
                              child: SvgPicture.asset(
                                IconsPath.calenderIcon,
                                height: 24.height,
                                width: 24.width,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30.height),
                    StudentUploadAFile(fileController: controller.fileController),
                    SizedBox(height: 83.height),

                    Obx(
                      () => CustomButton(
                        vertical: 8.height,
                        color: AppColors.uiDangerColor,
                        onPressed: () {
                          if (controller.isDeleting.value) {
                            return;
                          }
                          controller.deleteTask();
                        },
                        text: controller.isDeleting.value
                            ? "Deleting..."
                            : "Delete Task",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
