import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Generic PDF viewer for Q-Bank question papers and answer sheets.
/// Uses GetX Rx variables for error/loading state — no StatefulWidget needed.
class QbankPdfViewer extends StatelessWidget {
  final String url;
  final String title;

  // Rx state managed locally via GetX
  final _hasError = false.obs;
  final _errorMessage = ''.obs;
  final _isLoading = true.obs;

  QbankPdfViewer({super.key, required this.url, required this.title});

  void _onDocumentLoaded(PdfDocumentLoadedDetails _) =>
      _isLoading.value = false;

  void _onLoadFailed(PdfDocumentLoadFailedDetails details) {
    _hasError.value = true;
    _isLoading.value = false;
    _errorMessage.value = details.description.isNotEmpty
        ? details.description
        : 'Failed to load the document.';
  }

  void _retry() {
    _hasError.value = false;
    _errorMessage.value = '';
    _isLoading.value = true;
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Cannot Open',
        'Unable to open the URL in a browser.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            tooltip: 'Open in browser',
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openInBrowser,
          ),
        ],
      ),
      body: url.isEmpty
          ? _buildUnavailable()
          : Obx(() {
              if (_hasError.value) return _buildError();
              return Stack(
                children: [
                  SfPdfViewer.network(
                    url,
                    key: ValueKey(url),
                    onDocumentLoaded: _onDocumentLoaded,
                    onDocumentLoadFailed: _onLoadFailed,
                  ),
                  if (_isLoading.value)
                    const Center(child: CircularProgressIndicator()),
                ],
              );
            }),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.picture_as_pdf_outlined,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load PDF',
              style: getTextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage.value,
              textAlign: TextAlign.center,
              style: getTextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: _retry,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.open_in_browser, size: 18),
                    label: const Text('Open in Browser'),
                    onPressed: _openInBrowser,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnavailable() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Document not available',
            style: getTextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
