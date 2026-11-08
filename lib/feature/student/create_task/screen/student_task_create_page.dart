import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/auth/signup/account_opening/widgets/custom_text_field_nodmac.dart';
import 'package:msollaally/feature/student/create_task/controller/student_create_task_controller.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';

import '../../../../core/common/widgets/custom_button.dart';
import '../../../../core/const/icons_path.dart';
import '../../converter/widgets/student_upload_a_folder.dart';

class StudentCreateTaskPage extends StatelessWidget {
  const StudentCreateTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(StudentCreateTaskController());

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
                title: "Create a Task",
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.width,
                  vertical: 12.height,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.height),

                    CustomTextFieldNodMac(
                      controller: controller.controllerTask,
                      lebelName: "Task",
                      hinText: "Write the task",
                    ),
                    SizedBox(height: 20.height),
                    CustomTextFieldNodMac(
                      textFieldHeight: 105.height,
                      controller: controller.controllernote,
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
                    StudentUploadAFile(),
                    SizedBox(height: 83.height),
                    Obx(
                      () => IgnorePointer(
                        ignoring: controller.isCreating.value,
                        child: Opacity(
                          opacity: controller.isCreating.value ? 0.7 : 1,
                          child: CustomButton(
                            onPressed: controller.createTask,
                            text: controller.createButtonLabel,
                          ),
                        ),
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
