import 'package:flutter/material.dart';

class ExamFileCard extends StatelessWidget {
  final String fileType;

  const ExamFileCard({super.key, required this.fileType});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(_getFileIcon(fileType), color: Colors.redAccent),
        title: Text("Exam File.$fileType"),
        trailing: Image.asset(
          'assets/icons/download_icon.png',
          height: 24,
          width: 24,
        ),
        onTap: () {},
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
