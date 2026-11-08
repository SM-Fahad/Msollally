import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../../notification/widgets/custom_app_bar.dart';
import '../controller/student_file_converter_controller.dart';
import '../widgets/student_file_converter_item.dart';
import '../widgets/student_file_converter_show_result.dart';

class StudentFileConverterResultPage extends StatelessWidget {
  const StudentFileConverterResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<StudentFileConverteController>()
        ? Get.find<StudentFileConverteController>()
        : Get.put(StudentFileConverteController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              leadingIcon: SvgPicture.asset(IconsPath.arrowLeftIcon),
              onLeadingTap: Get.back,
              title: "Universal File Converter",
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.width, 16.height, 20.width, 24.height),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StudentFileConverterItem(),
                    SizedBox(height: 24.height),
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Convert to",
                            style: appTextStyleHeading2(
                              fontSize: 14.fontSize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2.fontSize,
                              color: AppColors.appBarTitleColor,
                            ),
                          ),
                          SizedBox(height: 12.height),
                          Wrap(
                            spacing: 12.width,
                            runSpacing: 12.height,
                            children: StudentFileConverteController.formatOptions.entries.map((entry) {
                              final isSelected = controller.selectedFormat.value == entry.key;
                              return GestureDetector(
                                onTap: controller.isBusy ? null : () => controller.setSelectedFormat(entry.key),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 12.height),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primaryButtonColor : AppColors.fileConverterUploadFileBGColor,
                                    borderRadius: BorderRadius.circular(12.radius),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryButtonColor : AppColors.fileConverterUploadFileBorderColor,
                                    ),
                                    boxShadow: isSelected ? [
                                      BoxShadow(
                                        color: AppColors.primaryButtonColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ] : [],
                                  ),
                                  child: Text(
                                    entry.value,
                                    style: appTextStyleHeading2(
                                      fontSize: 14.fontSize,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isSelected ? AppColors.buttonColorOnboarding : AppColors.appBarTitleColor,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.height),
                    Obx(
                      () => IgnorePointer(
                        ignoring: controller.isBusy,
                        child: Opacity(
                          opacity: controller.isBusy ? 0.7 : 1,
                          child: CustomButton(
                            text: controller.convertButtonLabel,
                            color: controller.isBusy
                                ? AppColors.fileConverterUploadFileBorderColor
                                : AppColors.primaryButtonColor,
                            onPressed: controller.reconvertUploadedFile,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.height),
                    Text(
                      "Result",
                      style: appTextStyleHeading1(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2.fontSize,
                      ),
                    ),
                    SizedBox(height: 12.height),
                    const StudentFileConverterShowResult(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
