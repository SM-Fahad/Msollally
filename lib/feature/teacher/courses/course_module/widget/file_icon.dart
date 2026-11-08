import 'package:flutter/material.dart';

class FileIcon extends StatelessWidget {
  final String type;

  const FileIcon({super.key, required this.type});

  IconData _getIcon(String type) {
    switch (type) {
      case "pdf":
        return Icons.picture_as_pdf;
      case "image":
        return Icons.image;
      case "video":
        return Icons.play_circle_fill;
      case "zip":
        return Icons.archive;
      case "doc":
      case "docx":
        return Icons.description;
      case "ppt":
      case "pptx":
        return Icons.slideshow;
      case "xls":
      case "xlsx":
      case "csv":
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case "pdf":
        return Colors.red;
      case "image":
        return Colors.green;
      case "video":
        return Colors.orange;
      case "zip":
        return Colors.blueGrey;
      case "doc":
      case "docx":
        return Colors.blue;
      case "ppt":
      case "pptx":
        return Colors.deepOrange;
      case "xls":
      case "xlsx":
      case "csv":
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: _getColor(type).withValues(alpha: 0.1),
      child: Icon(_getIcon(type), size: 14, color: _getColor(type)),
    );
  }
}
