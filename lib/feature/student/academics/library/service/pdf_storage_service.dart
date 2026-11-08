import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfStorageService {
  static const String _dirName = 'annotated_pdfs';
  static const String _lastPagePrefix = 'pdf_last_page_';

  /// Generates a unique, safe filename for the given book ID and PDF URL.
  static String _generateFileName(String bookId, String pdfUrl) {
    String cleanId = bookId.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    if (cleanId.isEmpty || cleanId == '0') {
      final bytes = utf8.encode(pdfUrl);
      cleanId = base64UrlEncode(bytes).replaceAll('=', '');
      if (cleanId.length > 32) {
        cleanId = cleanId.substring(0, 32);
      }
    }
    return 'book_$cleanId.pdf';
  }

  /// Returns the directory where annotated PDFs are saved locally.
  static Future<Directory> _getStorageDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${appDocDir.path}/$_dirName');
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    return pdfDir;
  }

  /// Checks if a locally saved annotated PDF exists and returns the [File] if valid.
  static Future<File?> getSavedPdfFile(String bookId, String pdfUrl) async {
    try {
      final dir = await _getStorageDirectory();
      final fileName = _generateFileName(bookId, pdfUrl);
      final file = File('${dir.path}/$fileName');
      if (await file.exists()) {
        final length = await file.length();
        if (length > 0) {
          debugPrint('Found saved annotated PDF: ${file.path} ($length bytes)');
          return file;
        }
      }
    } catch (e) {
      debugPrint('Error getting saved PDF file: $e');
    }
    return null;
  }

  /// Saves the modified PDF bytes to local storage for persistent annotations.
  static Future<File?> saveAnnotatedPdf(
    String bookId,
    String pdfUrl,
    List<int> bytes,
  ) async {
    try {
      if (bytes.isEmpty) return null;
      final dir = await _getStorageDirectory();
      final fileName = _generateFileName(bookId, pdfUrl);
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      debugPrint('Saved ${bytes.length} bytes to annotated PDF at ${file.path}');
      return file;
    } catch (e) {
      debugPrint('Error saving annotated PDF: $e');
      return null;
    }
  }

  /// Deletes the locally saved annotated PDF for a book (resets annotations).
  static Future<bool> deleteSavedPdf(String bookId, String pdfUrl) async {
    try {
      final dir = await _getStorageDirectory();
      final fileName = _generateFileName(bookId, pdfUrl);
      final file = File('${dir.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
        debugPrint('Deleted saved annotated PDF at ${file.path}');
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting saved PDF: $e');
    }
    return false;
  }

  /// Persists the last read page number for a book.
  static Future<void> saveLastPage(String bookId, int pageNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_lastPagePrefix$bookId', pageNumber);
    } catch (e) {
      debugPrint('Error saving last page: $e');
    }
  }

  /// Retrieves the last read page number for a book.
  static Future<int> getLastPage(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('$_lastPagePrefix$bookId') ?? 1;
    } catch (e) {
      debugPrint('Error retrieving last page: $e');
      return 1;
    }
  }
}
