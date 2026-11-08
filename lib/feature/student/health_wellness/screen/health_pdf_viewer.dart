import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthPdfViewer extends StatelessWidget {
  final String url;
  final String title;

  final _hasError = false.obs;
  final _errorMessage = ''.obs;
  final _isLoading = true.obs;

  HealthPdfViewer({super.key, required this.url, required this.title});

  void _onDocumentLoaded(PdfDocumentLoadedDetails _) => _isLoading.value = false;

  void _onLoadFailed(PdfDocumentLoadFailedDetails details) {
    _hasError.value = true;
    _isLoading.value = false;
    _errorMessage.value = details.description.isNotEmpty ? details.description : 'Failed to load the document.';
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openInBrowser,
          ),
        ],
      ),
      body: Obx(() {
        if (_hasError.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(_errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _retry, child: const Text('Retry')),
              ],
            ),
          );
        }
        return Stack(
          children: [
            SfPdfViewer.network(
              url,
              key: ValueKey(url),
              onDocumentLoaded: _onDocumentLoaded,
              onDocumentLoadFailed: _onLoadFailed,
            ),
            if (_isLoading.value) const Center(child: CircularProgressIndicator()),
          ],
        );
      }),
    );
  }
}
