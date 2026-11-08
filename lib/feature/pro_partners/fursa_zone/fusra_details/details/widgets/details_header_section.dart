import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

import '../controller/fusra_details_controller.dart';

class DetailsHeaderSection extends StatelessWidget {
  const DetailsHeaderSection({super.key, required this.controller});

  final FusraDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.competitionName.value.isEmpty
              ? controller.competitionTitle
              : controller.competitionName.value,
          style: getTextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        if (controller.brandSlogan.value.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            controller.brandSlogan.value,
            style: getTextStyle(fontSize: 14, color: AppColors.secondaryTextColor),
          ),
        ],
        // if (controller.partnerName.value.isNotEmpty) ...[
        //   const SizedBox(height: 6),
        //   Text(
        //     'By ${controller.partnerName.value}',
        //     style: getTextStyle(
        //       fontSize: 13,
        //       fontWeight: FontWeight.w600,
        //       color: AppColors.darkSlateGray374151,
        //     ),
        //   ),
        // ],
      ],
    );
  }
}
