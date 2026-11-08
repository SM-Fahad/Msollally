import 'dart:io';
import 'package:msollaally/core/const/appcolors.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/helpers/app_helper.dart';
import '../service/student_file_converter_service.dart';

class StudentFileConverteController extends GetxController {
  static const Map<String, String> formatOptions = {
    'txt': 'TXT',
    'pdf': 'PDF',
    'docx': 'DOCX',
    'xlsx': 'XLSX',
  };

  final file = Rx<File?>(null);
  final selectedFormat = 'txt'.obs;
  final isUploading = false.obs;
  final isConverting = false.obs;
  final uploadedFileId = RxnInt();
  final uploadedFileName = ''.obs;
  final uploadedFileSize = ''.obs;
  final convertedFileName = ''.obs;
  final convertedFilePath = ''.obs;
  final convertedContentType = ''.obs;
  final convertedTextPreview = ''.obs;
  final downloadedFileLocation = ''.obs;

  bool get isBusy => isUploading.value || isConverting.value;

  String get convertButtonLabel {
    if (isUploading.value) {
      return 'Uploading...';
    }
    if (isConverting.value) {
      return 'Converting...';
    }
    return 'Convert File';
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.single.path == null) {
      return;
    }

    file.value = File(result.files.single.path!);
    _syncPickedFileDetails();
    uploadedFileId.value = null;
    clearConvertedResult();
  }

  void setSelectedFormat(String? value) {
    if (value == null || value.isEmpty) {
      return;
    }
    if (selectedFormat.value != value) {
      clearConvertedResult();
    }
    selectedFormat.value = value;
  }

  Future<bool> convertSelectedFile() async {
    final selectedFile = file.value;
    if (selectedFile == null) {
      AppHelperFunctions.showSnackBar('Please upload a file first.');
      return false;
    }

    try {
      isUploading.value = true;
      final uploadResponse = await StudentFileConverterService.uploadFile(
        file: selectedFile,
      );

      uploadedFileId.value = uploadResponse.fileId;
      uploadedFileName.value = uploadResponse.originalName;
      uploadedFileSize.value = uploadResponse.fileSize;
    } catch (e) {
      AppHelperFunctions.showSnackBar(_cleanError(e));
      return false;
    } finally {
      isUploading.value = false;
    }

    return _convertUploadedFile();
  }

  Future<bool> reconvertUploadedFile() async {
    if (uploadedFileId.value == null || uploadedFileId.value == 0) {
      return convertSelectedFile();
    }
    return _convertUploadedFile();
  }

  Future<void> copyConvertedText() async {
    if (convertedFilePath.value.isEmpty) {
      AppHelperFunctions.showSnackBar('No converted text available yet.');
      return;
    }

    try {
      final text = await File(convertedFilePath.value).readAsString();
      await Clipboard.setData(ClipboardData(text: text));
      EasyLoading.showSuccess('Converted text copied.');
    } catch (e) {
      AppHelperFunctions.showSnackBar(_cleanError(e));
    }
  }

  Future<void> saveConvertedFileToDownloads() async {
    if (convertedFilePath.value.isEmpty || convertedFileName.value.isEmpty) {
      AppHelperFunctions.showSnackBar('No converted file available yet.');
      return;
    }

    try {
      // 1. Open a rename dialog allowing the user to rename the file before saving
      final nameController = TextEditingController(
        text: convertedFileName.value,
      );

      await Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.save_alt, color: AppColors.appBarTitleColor),
              SizedBox(width: 8),
              Text(
                'Save Converted File',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rename File:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter file name',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The file will be saved directly to your Downloads folder, or via the system save panel if direct access is restricted.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            FilledButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isEmpty) {
                  AppHelperFunctions.showSnackBar('File name cannot be empty.');
                  return;
                }

                Get.back(); // Close dialog
                await _saveFileWithRename(newName);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.appBarTitleColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } catch (e) {
      AppHelperFunctions.showSnackBar(_cleanError(e));
    }
  }

  Future<void> _saveFileWithRename(String newName) async {
    try {
      final sourceFile = File(convertedFilePath.value);

      if (!await sourceFile.exists()) {
        AppHelperFunctions.showSnackBar('Source file not found.');
        return;
      }

      // Rename the cached file so the shared file has the custom name
      final parentDir = sourceFile.parent.path;
      final targetPathInCache = '$parentDir${Platform.pathSeparator}$newName';
      
      File renamedFile;
      if (sourceFile.path != targetPathInCache) {
        renamedFile = await sourceFile.rename(targetPathInCache);
      } else {
        renamedFile = sourceFile;
      }

      // Update our reactive variables
      convertedFilePath.value = renamedFile.path;
      convertedFileName.value = newName;

      bool savedDirectly = false;
      String finalSavedPath = '';

      if (Platform.isAndroid) {
        try {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            finalSavedPath = '${downloadDir.path}/$newName';
            await renamedFile.copy(finalSavedPath);
            savedDirectly = true;
          }
        } catch (e) {
          debugPrint('Direct save to Android Download folder failed: $e');
        }
      }

      if (savedDirectly) {
        downloadedFileLocation.value = finalSavedPath;
        EasyLoading.showSuccess('File saved to Downloads successfully.');
      } else {
        // Fallback: Open system share sheet which provides "Save to Files" (iOS) or native device save panel
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(renamedFile.path)],
          subject: 'Save Converted File',
        );
        EasyLoading.showSuccess('Ready to save via system options.');
      }
    } catch (e) {
      AppHelperFunctions.showSnackBar('Failed to save file: ${_cleanError(e)}');
    }
  }

  void removeFile() {
    file.value = null;
    uploadedFileId.value = null;
    uploadedFileName.value = '';
    uploadedFileSize.value = '';
    clearConvertedResult();
  }

  void clearConvertedResult() {
    convertedFileName.value = '';
    convertedFilePath.value = '';
    convertedContentType.value = '';
    convertedTextPreview.value = '';
    downloadedFileLocation.value = '';
  }

  Future<bool> _convertUploadedFile() async {
    final currentFileId = uploadedFileId.value;
    if (currentFileId == null || currentFileId == 0) {
      AppHelperFunctions.showSnackBar('File upload failed. Please try again.');
      return false;
    }

    try {
      isConverting.value = true;
      final convertedResponse = await StudentFileConverterService.convertFile(
        fileId: currentFileId,
        targetFormat: selectedFormat.value,
      );

      convertedFileName.value = convertedResponse.fileName;
      convertedFilePath.value = convertedResponse.savedPath;
      convertedContentType.value = convertedResponse.contentType;
      convertedTextPreview.value = convertedResponse.previewText;
      return true;
    } catch (e) {
      AppHelperFunctions.showSnackBar(_cleanError(e));
      return false;
    } finally {
      isConverting.value = false;
    }
  }

  void _syncPickedFileDetails() {
    final selectedFile = file.value;
    if (selectedFile == null) {
      uploadedFileName.value = '';
      uploadedFileSize.value = '';
      return;
    }

    uploadedFileName.value = selectedFile.path.split('/').last;
    uploadedFileSize.value = _formatBytes(selectedFile.lengthSync());
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _cleanError(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }
}
