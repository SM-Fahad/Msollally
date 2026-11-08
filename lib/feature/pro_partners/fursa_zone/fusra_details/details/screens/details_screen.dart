import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';

import '../controller/fusra_details_controller.dart';
import '../widgets/details_banner_section.dart';
import '../widgets/details_brochure_section.dart';
import '../widgets/details_header_section.dart';
import '../widgets/details_state_card.dart';
import '../widgets/details_video_section.dart';

class DetailsScreen extends GetView<FusraDetailsController> {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isDetailsLoading.value) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoading.line(height: 24, width: 180),
              const SizedBox(height: 8),
              ShimmerLoading.line(height: 14, width: 240),
              const SizedBox(height: 18),
              ShimmerLoading.card(height: 160, borderRadius: 16),
              const SizedBox(height: 24),
              ShimmerLoading.line(height: 18, width: 150),
              const SizedBox(height: 12),
              ShimmerLoading.card(height: 140, borderRadius: 16),
              const SizedBox(height: 24),
              ShimmerLoading.line(height: 18, width: 150),
              const SizedBox(height: 12),
              ShimmerLoading.card(height: 80, borderRadius: 12),
            ],
          ),
        );
      }

      if (controller.detailsError.value.isNotEmpty) {
        return StateCard(
          icon: Icons.error_outline,
          text: controller.detailsError.value,
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailsHeaderSection(controller: controller),
            const SizedBox(height: 18),
            DetailsBannerSection(controller: controller),
            const SizedBox(height: 24),
            Text(
              'Product Training Video',
              style: getTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            DetailsVideoSection(controller: controller),
            const SizedBox(height: 24),
            Text(
              'Digital Brochure',
              style: getTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            DetailsBrochureSection(controller: controller),
          ],
        ),
      );
    });
  }
}
