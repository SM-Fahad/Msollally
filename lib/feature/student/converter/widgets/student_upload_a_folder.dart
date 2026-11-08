import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:msollaally/feature/student/converter/controller/student_file_converter_controller.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';

class StudentUploadAFile extends StatelessWidget {
  final StudentFileConverteController? fileController;
  const StudentUploadAFile({super.key, this.fileController});

  @override
  Widget build(BuildContext context) {
    final StudentFileConverteController controller = fileController ??
        (Get.isRegistered<StudentFileConverteController>()
            ? Get.find<StudentFileConverteController>()
            : Get.put(StudentFileConverteController()));

    return Obx(() {
      final hasFile = controller.file.value != null;
      final isUploading = controller.isUploading.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.width, vertical: 40.height),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.radius),
          color: hasFile 
              ? AppColors.primaryButtonColor.withOpacity(0.05) 
              : AppColors.fileConverterUploadFileBGColor,
          border: DashedBorder.fromBorderSide(
            side: BorderSide(
              color: hasFile 
                  ? AppColors.primaryButtonColor.withOpacity(0.5) 
                  : AppColors.fileConverterUploadFileBorderColor,
              width: hasFile ? 1.5 : 1.0,
            ),
            dashLength: 6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: isUploading ? null : controller.pickFile,
              borderRadius: BorderRadius.circular(12.radius),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 24.width, vertical: 12.height),
                decoration: BoxDecoration(
                  color: AppColors.primaryButtonColor,
                  borderRadius: BorderRadius.circular(12.radius),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryButtonColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isUploading 
                        ? SizedBox(
                            width: 20.width, 
                            height: 20.height, 
                            child: const CircularProgressIndicator(
                              strokeWidth: 2, 
                              color: Colors.white,
                            )
                          )
                        : SvgPicture.asset(
                            IconsPath.uploadFileIcon,
                            height: 20.height,
                            width: 20.width,
                            // ignore: deprecated_member_use
                            color: Colors.white,
                          ),
                    SizedBox(width: 12.width),
                    Text(
                      isUploading ? "Uploading..." : (hasFile ? "Change File" : "Select File"),
                      style: appTextStyleHeading1(
                        color: Colors.white,
                        fontSize: 14.fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.height),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: hasFile
                  ? Column(
                      key: const ValueKey('has_file'),
                      children: [
                        Text(
                          controller.uploadedFileName.value.isNotEmpty
                              ? controller.uploadedFileName.value
                              : controller.file.value!.path.split('/').last,
                          style: appTextStyleHeading1(
                            color: AppColors.appBarTitleColor,
                            fontSize: 16.fontSize,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (controller.uploadedFileSize.value.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 6.height),
                            child: Text(
                              controller.uploadedFileSize.value,
                              style: appTextStyleHeading2(
                                color: AppColors.dimGray52525B,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    )
                  : Column(
                      key: const ValueKey('no_file'),
                      children: [
                        Text(
                          "Supported file types",
                          style: appTextStyleHeading2(
                            color: AppColors.dimGray52525B,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.height),
                        Text(
                          "PDF, DOCX, XLSX, TXT",
                          style: appTextStyleHeading2(
                            color: AppColors.appBarTitleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      );
    });
  }
}
