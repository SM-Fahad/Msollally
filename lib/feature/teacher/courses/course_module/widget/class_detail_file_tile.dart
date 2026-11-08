import 'package:flutter/material.dart';
import 'package:msollaally/feature/teacher/courses/course_module/model/course_module_model.dart';
import 'package:msollaally/feature/teacher/courses/course_module/widget/file_icon.dart';

class FileTile extends StatelessWidget {
  const FileTile({super.key, required this.file, this.onDelete});

  final ClassFile file;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: FileIcon(type: file.fileType),
      title: Text(file.name, overflow: TextOverflow.ellipsis),
      // subtitle: file.mimeType.isEmpty ? null : Text(file.mimeType),
      trailing: onDelete == null
          ? null
          : IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
    );
  }
}
