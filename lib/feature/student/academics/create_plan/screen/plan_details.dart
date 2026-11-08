// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/academics/create_plan/screen/plan_session.dart';
import '../controller/plan_controller.dart';

class PlanScreen extends StatelessWidget {
  final String subject;
  final String courseName;

  const PlanScreen({
    super.key,
    this.subject = 'Custom Course',
    this.courseName = 'Personalized Study Plan',
  });

  @override
  Widget build(BuildContext context) {
    final planController = Get.put(PlanController());

    Future<void> pickDate(int index) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );

      if (pickedDate != null) {
        String formattedDate = DateFormat("dd MMM, yyyy").format(pickedDate);
        planController.updateDate(index, formattedDate);
      }
    }

    Future<void> pickTime(int index) async {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final endHour = (pickedTime.hour + 1) % 24;
        final formattedTime =
            "${pickedTime.format(context)} - ${TimeOfDay(hour: endHour, minute: pickedTime.minute).format(context)}";

        planController.updateTime(index, formattedTime);
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Plan For $subject"),
        actions: [
          TextButton(
            onPressed: () {
              Get.to(() => PlanSessionScreen(subject: subject, courseName: courseName));
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 20),

            Text(
              "Your Personalized Plan for:\n$courseName",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "Your Personalized Plan for: $courseName\nThe first step to success is getting organized.",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 30),

            // Plans List
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: planController.plans.length,
                  itemBuilder: (context, index) {
                    final plan = planController.plans[index];
                    return Card(
                      color: Color.fromARGB(253, 223, 219, 219),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(width: 2, color: Colors.blueGrey),
                      ),
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => pickDate(index),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 16),
                                          SizedBox(width: 6),
                                          Text(
                                            plan.date,
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 50),

                                Expanded(
                                  child: InkWell(
                                    onTap: () => pickTime(index),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.access_time, size: 16),
                                          SizedBox(width: 6),
                                          Text(
                                            plan.time,
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),

                            Text(
                              "Task:",
                              style: getTextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                plan.task,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
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
