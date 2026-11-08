import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../model/library_model.dart';
import '../service/pdf_storage_service.dart';

//This was made stateful intentionally

class ViewerContent extends StatefulWidget {
  final BookModel book;

  const ViewerContent({super.key, required this.book});

  @override
  State<ViewerContent> createState() => _ViewerContentState();
}

class _ViewerContentState extends State<ViewerContent> {
  late final PdfViewerController _pdfViewerController;
  File? _savedPdfFile;
  bool _isLoadingFile = true;
  bool _isSaving = false;
  bool _isDocumentLoaded = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _checkSavedPdf();
  }

  Future<void> _checkSavedPdf() async {
    try {
      final savedFile = await PdfStorageService.getSavedPdfFile(
        widget.book.id,
        widget.book.pdfUrl,
      );
      if (mounted) {
        setState(() {
          _savedPdfFile = savedFile;
          _isLoadingFile = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking saved PDF: $e');
      if (mounted) {
        setState(() {
          _isLoadingFile = false;
        });
      }
    }
  }

  void _onAnnotationChanged(dynamic annotation) {
    debugPrint('Annotation changed ($annotation) - scheduling save');
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _saveCurrentPdfState();
    });
  }

  Future<void> _saveCurrentPdfState() async {
    if (!mounted || !_isDocumentLoaded) return;
    try {
      setState(() {
        _isSaving = true;
      });

      final bytes = await _pdfViewerController.saveDocument();
      if (bytes.isNotEmpty) {
        final savedFile = await PdfStorageService.saveAnnotatedPdf(
          widget.book.id,
          widget.book.pdfUrl,
          bytes,
        );
        if (mounted && savedFile != null) {
          _savedPdfFile = savedFile;
        }
      }
    } catch (e) {
      debugPrint('Error saving PDF state: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) async {
    _isDocumentLoaded = true;
    final savedPage = await PdfStorageService.getLastPage(widget.book.id);
    if (savedPage > 1 && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _pdfViewerController.jumpToPage(savedPage);
        } catch (e) {
          debugPrint('Error jumping to saved page: $e');
        }
      });
    }
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    PdfStorageService.saveLastPage(widget.book.id, details.newPageNumber);
  }

  void _onLoadFailed(PdfDocumentLoadFailedDetails details) {
    debugPrint('PDF load failed: ${details.description}');
    // If local file failed to load, remove corrupted file and fallback to network
    if (_savedPdfFile != null) {
      PdfStorageService.deleteSavedPdf(widget.book.id, widget.book.pdfUrl);
      if (mounted) {
        setState(() {
          _savedPdfFile = null;
        });
      }
    } else {
      _showError(details.description);
    }
  }

  void _showError(String description) {
    Get.snackbar(
      "Error",
      "Failed to load PDF: $description",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (_isDocumentLoaded) {
      // Trigger synchronous or unawaited save on exit
      _saveCurrentPdfState();
    }
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pdfUrl = widget.book.pdfUrl;

    if (pdfUrl.isEmpty) {
      return Center(
        child: Text(
          "Content not available",
          style: getTextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final isImage =
        pdfUrl.toLowerCase().contains('.jpg') ||
        pdfUrl.toLowerCase().contains('.jpeg') ||
        pdfUrl.toLowerCase().contains('.png') ||
        (widget.book.pdfFile?.fileType == 'image');

    if (isImage) {
      return Center(
        child: InteractiveViewer(
          child: Image.network(
            pdfUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    if (_isLoadingFile) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        _buildPdfViewer(pdfUrl),
        if (_isSaving)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Saving...',
                    style: getTextStyle(fontSize: 11, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPdfViewer(String pdfUrl) {
    // 1. If we have a local saved copy with persisted highlights/annotations, load it
    if (_savedPdfFile != null) {
      return SfPdfViewer.file(
        _savedPdfFile!,
        key: ValueKey('local_${_savedPdfFile!.path}'),
        controller: _pdfViewerController,
        onDocumentLoaded: _onDocumentLoaded,
        onPageChanged: _onPageChanged,
        onDocumentLoadFailed: _onLoadFailed,
        onAnnotationAdded: _onAnnotationChanged,
        onAnnotationRemoved: _onAnnotationChanged,
        onAnnotationDeselected: _onAnnotationChanged,
      );
    }

    // 2. Otherwise load from Network
    if (pdfUrl.startsWith('http')) {
      return SfPdfViewer.network(
        pdfUrl,
        key: ValueKey('net_$pdfUrl'),
        controller: _pdfViewerController,
        onDocumentLoaded: _onDocumentLoaded,
        onPageChanged: _onPageChanged,
        onDocumentLoadFailed: _onLoadFailed,
        onAnnotationAdded: _onAnnotationChanged,
        onAnnotationRemoved: _onAnnotationChanged,
        onAnnotationDeselected: _onAnnotationChanged,
      );
    }

    // 3. Asset fallback
    return SfPdfViewer.asset(
      pdfUrl,
      key: ValueKey('asset_$pdfUrl'),
      controller: _pdfViewerController,
      onDocumentLoaded: _onDocumentLoaded,
      onPageChanged: _onPageChanged,
      onDocumentLoadFailed: _onLoadFailed,
      onAnnotationAdded: _onAnnotationChanged,
      onAnnotationRemoved: _onAnnotationChanged,
      onAnnotationDeselected: _onAnnotationChanged,
    );
  }
}
