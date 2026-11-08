// widgets/file_upload_box.dart
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class FileUploadBox extends StatelessWidget {
  final VoidCallback onSelectFile;
  final VoidCallback onUploadFile;

  const FileUploadBox({
    super.key,
    required this.onSelectFile,
    required this.onUploadFile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: DottedBorder(
        options: RectDottedBorderOptions(
          dashPattern: [10, 10],
          strokeWidth: 2,
          padding: EdgeInsets.all(8),
          color: Colors.grey,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(Icons.file_present_rounded, size: 40, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                "Drag and drop your files",
                style: getTextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                "PDF, DOC, DOCX, PPT, PPTX, XLSX, images, and videos up to 50MB",
                style: getTextStyle(fontSize: 12, color: Colors.black38),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onSelectFile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                child: Text("Select File"),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onUploadFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                child: Text("Upload File"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
