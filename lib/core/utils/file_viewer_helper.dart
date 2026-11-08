import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';
import 'package:msollaally/core/utils/device/device_utility.dart';
import 'package:msollaally/feature/student/academics/qBank/screen/qbank_pdf_viewer.dart';

/// Centralized utility to view files based on extension type.
void openCourseFile(
  BuildContext context, {
  required String url,
  required String name,
  required String type,
}) {
  final normalizedType = type.toLowerCase();
  
  if (normalizedType == 'pdf') {
    // Open inside the app using syncfusion_flutter_pdfviewer
    Get.to(() => QbankPdfViewer(url: url, title: name));
  } else if (normalizedType == 'img' ||
      normalizedType == 'png' ||
      normalizedType == 'jpg' ||
      normalizedType == 'jpeg') {
    // Open inside the app using FullscreenImageView with zoom capabilities
    Get.to(() => FullscreenImageView(imageUrl: url, isNetworkImage: true));
  } else {
    // docx, doc, ppt, pptx, xlsx, etc. open via default system app / browser
    AppDeviceUtility.launchUrl(url);
  }
}
