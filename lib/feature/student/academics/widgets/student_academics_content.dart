import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class StudentAcademicsContent extends StatelessWidget {
  const StudentAcademicsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Academics',
              style: getTextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'View your courses, grades, and assignments',
              style: getTextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Text(
              'Future: Add course list, grade tracking, assignments, etc.',
              style: getTextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
