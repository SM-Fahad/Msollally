import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';

import '../../../create_plan/screen/create_plan.dart';

class CreateExamScreen extends StatelessWidget {
  const CreateExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Field labels
    final List<String> fieldLabels = [
      "What Subject?",
      "What Module?",
      "How Many Questions?",
      "Question Type",
      "Question Level",
      "Duration",
      "Instructions (Optional)",
      "Upload File",
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // remove back arrow
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Create Exam",
              style: getTextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Row(
              children: [
                SizedBox(width: 12),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // All form fields
            ...List.generate(fieldLabels.length, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading text
                    Text(
                      fieldLabels[index],
                      style: getTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    // TextField with dropdown icon
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "Enter ${fieldLabels[index]}",
                        suffixIcon: Icon(Icons.arrow_drop_down),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // CustomButton at the end
            CustomButton(
              text: "Create Exam",
              onPressed: () {
                Get.to(() => CreatePlanScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}
