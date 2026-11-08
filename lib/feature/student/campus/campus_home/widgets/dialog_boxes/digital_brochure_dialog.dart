import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'controller/dialogbox_controller.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DigitalBrochureDialog extends StatefulWidget {
  final String? brochureUrl;
  const DigitalBrochureDialog({super.key, this.brochureUrl});

  @override
  State<DigitalBrochureDialog> createState() => _DigitalBrochureDialogState();
}

class _DigitalBrochureDialogState extends State<DigitalBrochureDialog> {
  late PdfViewerController _pdfViewerController;
  int _pageCount = 1;
  int _currentPage = 1;
  bool _isPdfLoaded = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    Get.find<DialogboxController>().startBrochureTimer();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    if (Get.isRegistered<DialogboxController>()) {
      Get.find<DialogboxController>().cancelBrochureTimer();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DialogboxController>();
    final url = widget.brochureUrl ?? controller.partnerInfoFileLink.value;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.only(
          top: 16,
          right: 12,
          bottom: 12,
          left: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, controller),
            const SizedBox(height: 16),
            _buildReadingProgress(controller),
            const SizedBox(height: 16),
            Expanded(child: _buildMainContent(url)),
            const SizedBox(height: 16),
            _buildTimerFooter(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DialogboxController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Digital Brochure",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Read the complete brochure to earn ${controller.brochurePoints.value} points and learn about loan products",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.grey),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildReadingProgress(DialogboxController controller) {
    double progress = _pageCount > 1 ? (_currentPage / _pageCount) : 0.0;
    if (_isPdfLoaded && _pageCount == 1) progress = 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reading Progress",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            color: AppColors.black0D0D1D,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Read for at least ${controller.formatTime(controller.minimumBrochureReadTime.value)} and scroll to 80% to earn points",
          style: const TextStyle(
            color: Colors.deepOrange,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(String url) {
    if (url.isEmpty) {
      return const Center(child: Text('No brochure available.'));
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.todaysQuickPicContainerBGColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SfPdfViewer.network(
          url,
          controller: _pdfViewerController,
          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
            setState(() {
              _isPdfLoaded = true;
              _pageCount = details.document.pages.count;
            });
          },
          onPageChanged: (PdfPageChangedDetails details) {
            setState(() {
              _currentPage = details.newPageNumber;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTimerFooter(DialogboxController controller) {
    return Obx(() {
      final String timeStr = controller.formatTime(controller.brochureSecondsLeft.value);
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.ghostWhiteFAF5FF,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.circle, color: Colors.orange, size: 8),
            const SizedBox(width: 8),
            const Icon(Icons.timer_outlined, size: 18, color: Colors.black54),
            const SizedBox(width: 4),
            Text(
              'Keep reading... $timeStr remaining',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
      );
    });
  }
}
