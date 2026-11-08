import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../controller/fusra_details_controller.dart';
import 'details_state_card.dart';

class DetailsBrochureSection extends StatelessWidget {
  const DetailsBrochureSection({super.key, required this.controller});

  final FusraDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final pdfUrl = controller.partnerInfoFileLink.value;
    if (pdfUrl.isEmpty) {
      return const StateCard(
        icon: Icons.picture_as_pdf_outlined,
        text: 'Brochure PDF not available',
      );
    }

    return Container(
      height: 420,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sliderColorInboarding),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: AppColors.panelBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Digital Brochure',
                    style: getTextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.to(
                    () => Scaffold(
                      appBar: AppBar(title: const Text('Digital Brochure')),
                      body: SfPdfViewer.network(pdfUrl),
                    ),
                  ),
                  icon: const Icon(Icons.fullscreen),
                ),
              ],
            ),
          ),
          Expanded(
            child: SfPdfViewer.network(
              pdfUrl,
              canShowPaginationDialog: false,
              onDocumentLoadFailed: (_) {
                Get.snackbar('Error', 'Unable to load brochure PDF');
              },
            ),
          ),
        ],
      ),
    );
  }
}
