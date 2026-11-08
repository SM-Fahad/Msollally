import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/health_wellness/model/emergency_support_model.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/health_wellness/screen/health_pdf_viewer.dart';
import 'package:msollaally/feature/student/health_wellness/screen/health_video_viewer.dart';

class EmergencySupportDetailScreen extends StatelessWidget {
  final EmergencySupportModel item;

  const EmergencySupportDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: item.imageUrl != null && item.imageUrl!.isNotEmpty ? 250.height : 100.height,
            pinned: true,
            backgroundColor: AppColors.primaryButtonColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Support Details",
                style: getTextStyle(
                  color: Colors.white,
                  fontSize: 16.fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: AppColors.primaryButtonColor),
                        ),
                        // Overlay gradient for readability
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha((255*0.7).toInt()),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(color: AppColors.primaryButtonColor),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.width),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: appTextStyleHeading1(
                            fontSize: 22.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 12.width),
                        padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 6.height),
                        decoration: BoxDecoration(
                          color: AppColors.primaryButtonColor.withAlpha((255 * 0.1).toInt()),
                          borderRadius: BorderRadius.circular(20.radius),
                          border: Border.all(color: AppColors.primaryButtonColor.withAlpha((255 * 0.2).toInt())),
                        ),
                        child: Text(
                          item.type.toUpperCase(),
                          style: getTextStyle(
                            fontSize: 12.fontSize,
                            color: AppColors.primaryButtonColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.height),
                  Text(
                    "Description",
                    style: getTextStyle(
                      fontSize: 16.fontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.height),
                  Text(
                    item.description,
                    style: getTextStyle(
                      fontSize: 15.fontSize,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32.height),
                  if ((item.pdfUrl != null && item.pdfUrl!.isNotEmpty) ||
                      (item.videoUrl != null && item.videoUrl!.isNotEmpty)) ...[
                    Text(
                      "Resources",
                      style: getTextStyle(
                        fontSize: 16.fontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16.height),
                    Row(
                      children: [
                        if (item.pdfUrl != null && item.pdfUrl!.isNotEmpty)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Get.to(
                                () => HealthPdfViewer(
                                  url: item.pdfUrl!,
                                  title: item.title,
                                ),
                              ),
                              icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                              label: Text("View PDF", style: getTextStyle(color: Colors.white, fontSize: 14.fontSize, fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444), // Red for PDF
                                padding: EdgeInsets.symmetric(vertical: 14.height),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.radius)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        if (item.pdfUrl != null && item.videoUrl != null && item.pdfUrl!.isNotEmpty && item.videoUrl!.isNotEmpty)
                          SizedBox(width: 12.width),
                        if (item.videoUrl != null && item.videoUrl!.isNotEmpty)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Get.to(
                                () => HealthVideoViewer(
                                  url: item.videoUrl!,
                                  title: item.title,
                                ),
                              ),
                              icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 20),
                              label: Text("Watch Video", style: getTextStyle(color: Colors.white, fontSize: 14.fontSize, fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6), // Blue for Video
                                padding: EdgeInsets.symmetric(vertical: 14.height),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.radius)),
                                elevation: 0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
