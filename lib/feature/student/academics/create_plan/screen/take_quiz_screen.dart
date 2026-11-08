import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/academics/quiz/screen/start_quiz_screen.dart';

class TakeQuizScreen extends StatelessWidget {
  final String subject;

  const TakeQuizScreen({super.key, this.subject = 'Custom Plan'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plan For $subject"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => StartQuizScreen(quizTitle: "Quiz: $subject"));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text("Take a Quiz"),
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.red),
                    SizedBox(width: 5),
                    Text(
                      "37:23",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text("Finish"),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Title
            Text(
              subject,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Task
            Text.rich(
              TextSpan(
                text: "Task: ",
                style: TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: "Review Chapter 1: Kinematics",
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),

            // Description
            Text(
              "Spaced repetition is the key to long-term memory. "
              "This is a quick, low-stress session to review what we covered on Thursday. "
              "Using flashcards will help transfer these concepts from short-term to long-term memory.",
              style: TextStyle(fontSize: 16, height: 1.4),
            ),

            Spacer(),

            // Bottom Input
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Type here",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.mic)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
