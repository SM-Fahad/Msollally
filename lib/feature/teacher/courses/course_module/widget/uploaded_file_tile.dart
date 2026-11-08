import 'package:flutter/material.dart';

import 'package:msollaally/core/common/styles/global_text_style.dart';

import 'package:msollaally/feature/teacher/courses/course_module/widget/file_icon.dart';
import '../model/upload_file.dart';

class UploadedFileTile extends StatelessWidget {
  final UploadFile file;
  final dynamic controller;

  const UploadedFileTile({
    super.key,
    required this.file,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withAlpha(100)),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: FileIcon(type: controller.getFileType(file.extension)),
        title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          'Size: ${file.size.toStringAsFixed(2)} kB',
          style: getTextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => controller.removeFile(file),
        ),
      ),
    );
  }
}
