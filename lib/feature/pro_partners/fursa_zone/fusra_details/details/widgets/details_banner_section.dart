import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';

import '../controller/fusra_details_controller.dart';
import 'details_state_card.dart';

class DetailsBannerSection extends StatelessWidget {
  const DetailsBannerSection({super.key, required this.controller});

  final FusraDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final imageUrl = controller.promoImageLink.value;
    final uri = Uri.tryParse(imageUrl);
    final isPlaceholderHost =
        imageUrl.contains('example.com') ||
        imageUrl.contains('cdn.example.com');
    final isValidRemoteImage =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        !isPlaceholderHost;

    if (!isValidRemoteImage) {
      return const StateCard(
        icon: Icons.image_not_supported_outlined,
        text: 'Promo image not available',
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 16 / 7,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: AppColors.tagBackgroundColor,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          },
          errorBuilder: (_, _, _) => Container(
            color: AppColors.tagBackgroundColor,
            alignment: Alignment.center,
            child: const Text('Unable to load promo image'),
          ),
        ),
      ),
    );
  }
}
