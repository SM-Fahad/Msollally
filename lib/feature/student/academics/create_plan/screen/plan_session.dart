import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/academics/create_plan/screen/take_quiz_screen.dart';

import '../controller/plan_controller.dart';

class PlanSessionScreen extends StatelessWidget {
  final String subject;
  final String courseName;

  const PlanSessionScreen({
    super.key,
    this.subject = 'Custom Course',
    this.courseName = 'Personalized Study Plan',
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlanSessionController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Plan For $subject"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Personalized Plan for:\n$courseName",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "The first step to success is getting organized.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 16),

            // Sessions List
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.sessions.length,
                  itemBuilder: (context, index) {
                    final session = controller.sessions[index];

                    Color cardColor;
                    Widget actionWidget;

                    if (session.status == "ongoing") {
                      cardColor = Colors.blue.shade50;
                      actionWidget = Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Get.to(TakeQuizScreen());
                            },
                            child: Text("Take a Quiz"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              controller.markCompleted(index);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(120, 40),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("Finish"),
                          ),
                        ],
                      );
                    } else if (session.status == "upcoming") {
                      cardColor = Colors.grey.shade100;
                      actionWidget = Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(120, 40), // Button size
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            textStyle: TextStyle(
                              // Fix text size
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text("Start Session"),
                        ),
                      );
                    } else {
                      cardColor = Colors.green.shade50;
                      actionWidget = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Get.to(TakeQuizScreen());
                                },
                                child: Text("Take a Quiz"),
                              ),
                              SizedBox(width: 100),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize: Size(120, 40), // Button size
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  textStyle: TextStyle(
                                    // Fix text size
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text("Completed"),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: session.progress / 100,
                            color: Colors.green,
                            backgroundColor: Colors.green.shade100,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Completed ${session.progress}%",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      );
                    }

                    return Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.black12),
                      ),
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date + Timer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  session.date,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                if (session.timer.isNotEmpty)
                                  Text(
                                    session.timer,
                                    style: TextStyle(
                                      color: session.status == "ongoing"
                                          ? Colors.red
                                          : Colors.black54,
                                    ),
                                  ),
                              ],
                            ),
                            if (session.time.isNotEmpty) ...[
                              SizedBox(height: 4),
                              Text(
                                session.time,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                            SizedBox(height: 12),

                            // Title
                            Text(
                              session.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),

                            // Task
                            Text.rich(
                              TextSpan(
                                text: "Task: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: session.task,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),

                            // Action area
                            actionWidget,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
