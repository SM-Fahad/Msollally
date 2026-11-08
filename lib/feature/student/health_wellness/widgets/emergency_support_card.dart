import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/health_wellness/model/emergency_support_model.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/health_wellness/screen/emergency_support_detail_screen.dart';

class EmergencySupportCard extends StatelessWidget {
  final EmergencySupportModel item;

  const EmergencySupportCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => EmergencySupportDetailScreen(item: item)),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.height),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.radius),
          border: Border.all(color: AppColors.lavenderE6EBF2),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.04).toInt()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11.radius),
          child: item.imageUrl != null && item.imageUrl!.isNotEmpty
              ? Image.network(
                  item.imageUrl!,
                  height: 140.h,
                  cacheHeight: 350,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallbackCard(),
                )
              : _buildFallbackCard(),
        ),
      ),
    );
  }

  Widget _buildFallbackCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.width),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryButtonColor,
            AppColors.primaryButtonColor.withAlpha((255 * 0.8).toInt()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.width,
              vertical: 4.height,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((255 * 0.2).toInt()),
              borderRadius: BorderRadius.circular(20.radius),
            ),
            child: Text(
              item.type.toUpperCase(),
              style: getTextStyle(
                color: Colors.white,
                fontSize: 10.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 12.height),
          Text(
            item.title,
            style: getTextStyle(
              fontSize: 18.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.height),
          Text(
            "Tap to view details",
            style: getTextStyle(fontSize: 12.fontSize, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
