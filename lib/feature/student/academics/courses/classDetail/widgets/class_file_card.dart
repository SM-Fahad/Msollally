import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/file_viewer_helper.dart';
import 'package:msollaally/feature/student/academics/courses/module/model/module_model.dart';

class ClassFileCard extends StatelessWidget {
  final CourseFileModel file;

  const ClassFileCard({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(_getFileIcon(file.displayType), color: Colors.redAccent),
        title: Text(file.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Image.asset(
          'assets/icons/download_icon.png',
          height: 24,
          width: 24,
        ),
        onTap: () => openCourseFile(
          context,
          url: file.url,
          name: file.name,
          type: file.displayType,
        ),
      ),
    );
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case "pdf":
        return Icons.picture_as_pdf;
      case "doc":
      case "docx":
        return Icons.description;
      case "img":
      case "jpg":
      case "png":
        return Icons.image;
      case "video":
        return Icons.play_circle;
      case "ppt":
      case "pptx":
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }
}
