import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/health_wellness/controller/health_wellness_controller.dart';
import 'package:msollaally/core/widgets/global_app_bar.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class StudentHealthScreen extends StatefulWidget {
  const StudentHealthScreen({super.key});

  @override
  State<StudentHealthScreen> createState() => _StudentHealthScreenState();
}

class _StudentHealthScreenState extends State<StudentHealthScreen> {
  final HealthWellnessController _controller = Get.put(
    HealthWellnessController(),
  );

  late String supportType;
  late String screenTitle;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    supportType = args?['type'] ?? 'mental_health';
    
    if (supportType == 'physical_health') {
       screenTitle = "Physical Health";
    } else {
       screenTitle = "Mental Health";
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool changed = false;
      if (_controller.selectedSupportType.value != supportType) {
          _controller.selectedSupportType.value = supportType;
          changed = true;
      }
      if (_controller.selectedType.value != 'all') {
          _controller.selectedType.value = 'all';
          changed = true;
      }
      
      if (!changed && _controller.emergencySupportList.isEmpty) {
        _controller.refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ghostWhiteF5F7FB,
      appBar: GlobalAppBar(title: screenTitle),
      body: Column(
        children: [
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (_controller.isLoading.value &&
          _controller.emergencySupportList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.emergencySupportList.isEmpty) {
        return RefreshIndicator(
          onRefresh: _controller.refreshData,
          child: ListView(
            children: [
              SizedBox(height: 100.height),
              Center(
                child: Text(
                  "No records found.",
                  style: getTextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _controller.refreshData,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _controller.scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: 16.width,
            vertical: 8.height,
          ),
          itemCount: _controller.emergencySupportList.length + 1,
          itemBuilder: (context, index) {
            if (index == _controller.emergencySupportList.length) {
              return _controller.isLoadingMore.value
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : const SizedBox.shrink();
            }
            final item = _controller.emergencySupportList[index];
            return Container(
              margin: EdgeInsets.only(bottom: 24.height),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...[
                    Text(
                      item.title,
                      style: appTextStyleHeading1(
                        fontSize: 18.fontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black1F1F1F,
                      ),
                    ),
                    SizedBox(height: 8.height),
                  ],
                  ...[
                    Text(
                      item.description,
                      style: appTextStyleHeading1(
                        fontSize: 14.fontSize,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 12.height),
                  ],
                  if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.radius),
                      child: Image.network(
                        item.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  if (item.videoUrl != null && item.videoUrl!.isNotEmpty) ...[
                    SizedBox(height: 8.height),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.width),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8.radius),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.play_circle_fill,
                            color: Colors.blue.shade600,
                            size: 24.fontSize,
                          ),
                          SizedBox(width: 8.width),
                          Expanded(
                            child: Text(
                              "Watch Video",
                              style: appTextStyleHeading1(
                                fontSize: 14.fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (item.pdfUrl != null && item.pdfUrl!.isNotEmpty) ...[
                    SizedBox(height: 8.height),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.width),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8.radius),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red.shade600,
                            size: 24.fontSize,
                          ),
                          SizedBox(width: 8.width),
                          Expanded(
                            child: Text(
                              "View PDF Document",
                              style: appTextStyleHeading1(
                                fontSize: 14.fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
