import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class ExamNotesCard extends StatelessWidget {
  const ExamNotesCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color.fromARGB(255, 211, 101, 11)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedBackgroundColor: AppColors.floralWhiteFFF9F4,
          backgroundColor: AppColors.floralWhiteFFF9F4,
          title: Text(
            "Exam Notes",
            style: getTextStyle(fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Add your exam notes or guidelines here. This section can be dynamically filled later.",
                style: getTextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
