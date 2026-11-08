import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/teacher/widgets/teacher_custom_text_field.dart';

class TeacherEditProfileNameScreen extends StatelessWidget {
  TeacherEditProfileNameScreen({super.key});

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Name"), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.amber[700]!.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Text("First Name", style: getTextStyle(fontSize: 16)),
                  TeacherCustomTextField(
                    controller: firstNameController,
                    hintText: "e.g. name",
                  ),
                  Text("Last Name", style: getTextStyle(fontSize: 16)),
                  TeacherCustomTextField(
                    controller: lastNameController,
                    hintText: "e.g. name",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                fixedSize: Size(double.maxFinite, 52),
              ),
              child: Text("Done"),
            ),
          ],
        ),
      ),
    );
  }
}
