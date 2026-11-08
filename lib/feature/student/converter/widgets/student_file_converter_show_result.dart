import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/student_file_converter_controller.dart';

class StudentFileConverterShowResult extends StatefulWidget {
  const StudentFileConverterShowResult({super.key});

  @override
  State<StudentFileConverterShowResult> createState() => _StudentFileConverterShowResultState();
}

class _StudentFileConverterShowResultState extends State<StudentFileConverterShowResult> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<StudentFileConverteController>()
        ? Get.find<StudentFileConverteController>()
        : Get.put(StudentFileConverteController());

    return Obx(() {
      final isConverting = controller.isConverting.value;
      final previewText = controller.convertedFileName.value.isEmpty
          ? 'No converted file yet.'
          : controller.convertedTextPreview.value.isNotEmpty
              ? controller.convertedTextPreview.value
              : 'Converted file ready: ${controller.convertedFileName.value}';

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: isConverting
            ? _buildConvertingVisualizer()
            : _buildResultContent(controller, previewText),
      );
    });
  }

  Widget _buildConvertingVisualizer() {
    return Container(
      key: const ValueKey('converting'),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 32.height),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.radius),
        color: AppColors.fileConverterUploadFileBGColor,
        border: Border.all(
          color: AppColors.fileConverterUploadFileBorderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.primaryButtonColor.withOpacity(0.5),
            highlightColor: AppColors.primaryButtonColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 28.fontSize),
                SizedBox(width: 12.width),
                Text(
                  "Visualizing format...",
                  style: appTextStyleHeading1(
                    fontSize: 18.fontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.height),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                5,
                (index) => Container(
                  margin: EdgeInsets.only(bottom: 16.height),
                  height: 14.height,
                  width: index == 4 ? 180.width : double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.radius),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent(StudentFileConverteController controller, String previewText) {
    return Container(
      key: const ValueKey('result'),
      padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 16.height),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.radius),
        border: Border.all(
          color: AppColors.fileConverterUploadFileBorderColor,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 16.height),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.radius),
              border: Border.all(
                color: AppColors.fileConverterUploadFileBorderColor.withOpacity(0.5),
              ),
              color: AppColors.fileConverterUploadFileBGColor,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 320.height),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: previewText.length > 600,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: SelectableText(
                    previewText,
                    style: appTextStyleHeading2(
                      letterSpacing: 0.3.fontSize,
                      color: AppColors.appBarTitleColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.height),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.width, vertical: 8.height),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1.5.width,
                  color: AppColors.fileConverterUploadFileBorderColor.withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (controller.selectedFormat.value == 'txt' && controller.convertedFileName.value.isNotEmpty)
                  InkWell(
                    onTap: controller.copyConvertedText,
                    borderRadius: BorderRadius.circular(8.radius),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.width,
                        vertical: 10.height,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.radius),
                        border: Border.all(
                          color: AppColors.fileConverterUploadFileBorderColor,
                        ),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 16.fontSize, color: AppColors.appBarTitleColor),
                          SizedBox(width: 8.width),
                          Text(
                            "Copy Text",
                            style: appTextStyleHeading2(
                              fontWeight: FontWeight.w600,
                              color: AppColors.appBarTitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (controller.selectedFormat.value == 'txt' && controller.convertedFileName.value.isNotEmpty)
                  SizedBox(width: 16.width),
                AnimatedOpacity(
                  opacity: controller.convertedFileName.value.isEmpty ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: InkWell(
                    onTap: controller.convertedFileName.value.isEmpty
                        ? null
                        : controller.saveConvertedFileToDownloads,
                    borderRadius: BorderRadius.circular(8.radius),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.width,
                        vertical: 10.height,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.radius),
                        color: AppColors.primaryButtonColor,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryButtonColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.download_rounded, size: 18.fontSize, color: AppColors.buttonColorOnboarding),
                          SizedBox(width: 8.width),
                          Text(
                            "Download",
                            style: appTextStyleHeading1(
                              fontSize: 14.fontSize,
                              color: AppColors.buttonColorOnboarding,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (controller.downloadedFileLocation.value.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.height),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text: controller.downloadedFileLocation.value,
                      ),
                    );
                    Get.snackbar(
                      'Copied',
                      'File path copied to clipboard',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 8.height),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.radius),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 14.fontSize),
                        SizedBox(width: 8.width),
                        Flexible(
                          child: Text(
                            'Saved at: ${controller.downloadedFileLocation.value}',
                            style: appTextStyleHeading2(
                              fontSize: 12.fontSize,
                              color: Colors.green.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
