import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/teacher/home/model/recent_courses_model.dart';

class RecentCourseWidget extends StatelessWidget {
  const RecentCourseWidget({super.key, required this.course});

  final RecentCoursesModel course;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        tileColor: Colors.blueGrey[50],
        leading: Icon(Icons.description, color: Colors.purple),
        title: Text(course.title),
        subtitle: Text(course.date),
        trailing: Text(
          course.status,
          style: getTextStyle(color: getColorForStatus(course.status)),
        ),
      ),
    );
  }
}

Color getColorForStatus(String status) {
  switch (status) {
    case 'In Progress':
      return Colors.orange;
    case 'Completed':
      return Colors.green;
    case 'Pending':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
