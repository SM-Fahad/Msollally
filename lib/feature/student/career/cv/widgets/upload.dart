// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:msollaally/feature/student/converter/controller/student_file_converter_controller.dart';

import '../../../../../core/common/styles/global_text_style.dart';
import '../../../../../core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';

class UploadStudent extends StatelessWidget {
  const UploadStudent({super.key});

  @override
  Widget build(BuildContext context) {
    final _controller = Get.put(StudentFileConverteController());
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 96.width, vertical: 51.height),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.radius),
        color: AppColors.fileConverterUploadFileBGColor,
        border: DashedBorder.fromBorderSide(
          side: BorderSide(color: AppColors.fileConverterUploadFileBorderColor),
          dashLength: 3,
        ),
      ),

      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 40.height,
            width: 161.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.radius),
              border: Border.all(
                color: AppColors.fileConverterUploadFileBorderColor,
              ),
            ),
            child: InkWell(
              onTap: () {
                _controller.pickFile();

                debugPrint("=================pressed file====================");
              },
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SvgPicture.asset(
                      IconsPath.uploadFileIcon,
                      height: 24.height,
                      width: 24.width,
                    ),
                    Text("Upload a file", style: appTextStyleHeading1()),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10.height),
          SizedBox(
            child: Column(
              //  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Supported file types:",
                    style: appTextStyleHeading2(),
                  ),
                ),
                Center(
                  child: Text(
                    "Image, Docs, PDF, Audio",
                    style: appTextStyleHeading2(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
