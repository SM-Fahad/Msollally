import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/library_controller.dart';
import '../model/library_model.dart';
import '../service/pdf_storage_service.dart';
import '../widgets/viewer_content.dart';


//This was made stateful intentionally

class PdfViewerPage extends StatefulWidget {
  final BookModel book;

  const PdfViewerPage({super.key, required this.book});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  Key _viewerKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    final libraryController = Get.find<LibraryController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (libraryController.bookDetails.value?.id != widget.book.id &&
          !libraryController.isDetailsLoading.value) {
        libraryController.fetchBookDetails(widget.book.id);
      }
    });
  }

  void _resetViewer() {
    setState(() {
      _viewerKey = UniqueKey();
    });
  }

  Future<void> _confirmClearAnnotations(BookModel bookToUse) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Highlights?'),
        content: const Text(
          'This will remove all your saved highlights, underlines, and annotations for this document.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PdfStorageService.deleteSavedPdf(bookToUse.id, bookToUse.pdfUrl);
      _resetViewer();
      Get.snackbar(
        'Annotations Reset',
        'Your highlights have been cleared.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final libraryController = Get.find<LibraryController>();

    return Obx(() {
      final bookToUse = libraryController.bookDetails.value ?? widget.book;

      return Scaffold(
        appBar: AppBar(
          title: Text(bookToUse.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            _buildWishlistAction(bookToUse, libraryController),
            _buildReadAction(bookToUse, libraryController),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'clear_annotations') {
                  _confirmClearAnnotations(bookToUse);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_annotations',
                  child: Row(
                    children: [
                      Icon(Icons.layers_clear_outlined, size: 20, color: Colors.black87),
                      SizedBox(width: 8),
                      Text('Clear highlights'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: libraryController.isDetailsLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ViewerContent(key: _viewerKey, book: bookToUse),
      );
    });
  }

  Widget _buildWishlistAction(
    BookModel book,
    LibraryController libraryController,
  ) {
    return Obx(
      () => IconButton(
        icon: Icon(
          book.isWishlisted.value ? Icons.bookmark : Icons.bookmark_border,
          color: Colors.blue,
        ),
        onPressed: () {
          libraryController.toggleWishlist(book);
        },
      ),
    );
  }

  Widget _buildReadAction(
    BookModel book,
    LibraryController libraryController,
  ) {
    return Obx(
      () => IconButton(
        icon: Icon(
          book.isRead.value ? Icons.check : Icons.check_outlined,
          color: book.isRead.value ? Colors.green : Colors.grey,
        ),
        onPressed: () {
          libraryController.toggleRead(book);
        },
      ),
    );
  }
}
