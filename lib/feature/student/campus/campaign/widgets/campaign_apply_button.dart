import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import '../../../../../core/utils/device/device_utility.dart';

class CampaignApplyButton extends StatelessWidget {
  final String destinationUrl;
  final String ctaLabel;

  const CampaignApplyButton({
    super.key,
    required this.destinationUrl,
    required this.ctaLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.height,
      child: ElevatedButton(
        onPressed: () {
          if (destinationUrl.isNotEmpty) {
            try {
              AppDeviceUtility.launchUrl(destinationUrl);
            } catch (e) {
              Get.snackbar(
                'Error',
                'Could not open link: $e',
                backgroundColor: Colors.red,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          } else {
            Get.snackbar(
              'Information',
              'No URL is provided for this campaign.',
              backgroundColor: Colors.grey.shade800,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButtonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.radius),
          ),
          elevation: 0,
        ),
        child: Text(
          ctaLabel,
          style: getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
