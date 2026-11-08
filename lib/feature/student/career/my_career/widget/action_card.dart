import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shimmer/shimmer.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/career/cv/controller/cv_controller.dart';
import 'package:msollaally/feature/student/career/cv/service/cv_service.dart';

/// Background-shaded Action Card
Widget buildActionCard({
  required String title,
  required String subtitle,
  required String leftAction,
  required String rightAction,
  required VoidCallback onLeftTap,
  required VoidCallback onRightTap,
}) {
  return _ActionCard(
    title: title,
    subtitle: subtitle,
    leftAction: leftAction,
    rightAction: rightAction,
    onLeftTap: onLeftTap,
    onRightTap: onRightTap,
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.leftAction,
    required this.rightAction,
    required this.onLeftTap,
    required this.onRightTap,
  });

  final String title;
  final String subtitle;
  final String leftAction;
  final String rightAction;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: getTextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: getTextStyle(color: AppColors.secondaryTextColor),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: onLeftTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // white background
                  foregroundColor:
                      AppColors.primaryButtonColor, // text & icon color
                  side: const BorderSide(
                    color: AppColors.primaryButtonColor,
                  ), // primary border
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // rounded corners
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // shrink to fit content
                  children: [
                    // Custom Icon from your IconsPath
                    Image.asset(
                      IconsPath
                          .customizeIcon, // <-- replace with your custom icon path
                      height: 20,
                      width: 20,
                      color: AppColors.primaryButtonColor,
                    ),
                    const SizedBox(width: 8), // space between icon and text
                    Text(
                      leftAction,
                      style: getTextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryButtonColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 40),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: _buildCvDropdown(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCvDropdown(BuildContext context) {
    final cvController = Get.isRegistered<CvController>()
        ? Get.find<CvController>()
        : Get.put(CvController());

    return Obx(() {
      if (cvController.isFetchingCvs.value && cvController.myCvs.isEmpty) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width * 0.45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }

      final cvs = cvController.myCvs;
      if (cvs.isEmpty) {
        return GestureDetector(
          onTap: onRightTap,
          child: _dropdownContainer(
            context: context,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.download, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  rightAction,
                  style: getTextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }

      return _dropdownContainer(
        context: context,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: null,
            hint: Center(
              child: Text(
                rightAction,
                style: getTextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            dropdownColor: Colors.white,
            isExpanded: true,
            isDense: true,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 20,
            ),
            style: getTextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 12,
            ),
            items: cvs.asMap().entries.map((entry) {
              final index = entry.key;
              final cv = entry.value;
              final createdAt = _formatCreatedAt(cv);

              return DropdownMenuItem<int>(
                value: index,
                child: Text(
                  'CV ${index + 1} - $createdAt',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            onChanged: (index) => _downloadSelectedCv(cvs, index),
          ),
        ),
      );
    });
  }

  Widget _dropdownContainer({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      // add horizontal padding and limit max width to avoid overflow
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      // responsive max width to avoid overflow on small screens
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.45,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryButtonColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  Future<void> _downloadSelectedCv(List<dynamic> cvs, int? index) async {
    if (index == null) return;

    final cv = cvs[index];
    final id = cv is Map ? cv['id']?.toString() : null;

    if (id == null || id.isEmpty) {
      onRightTap();
      return;
    }

    EasyLoading.show(status: 'Downloading CV...');
    try {
      final cvService = CvService();
      await cvService.downloadCv(id);
      EasyLoading.dismiss();
    } catch (_) {
      EasyLoading.showError('Failed to download CV.');
    }
  }

  String _formatCreatedAt(dynamic cv) {
    if (cv is! Map) return '';

    final rawCreatedAt = cv['createdAt']?.toString() ?? '';
    if (rawCreatedAt.isEmpty) return '';

    return rawCreatedAt.split('T').first;
  }
}
