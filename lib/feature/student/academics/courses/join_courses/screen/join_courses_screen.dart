import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../controller/join_courses_controller.dart';

class JoinCourseScreen extends StatelessWidget {
  final JoinCourseController controller = Get.put(JoinCourseController());

  JoinCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Course')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, thickness: 1),

          /// Course list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.courses.isEmpty) {
                return Center(
                  child: Text(
                    'No courses available',
                    style: getTextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.courses.length,
                itemBuilder: (context, index) {
                  final course = controller.courses[index];
                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        course.title,
                        style: getTextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          course.instructor,
                          style: getTextStyle(color: Colors.blueAccent),
                        ),
                      ),
                      trailing: SizedBox(
                        width: 110,
                        child: Obx(() {
                          final isEnrolled = controller.isEnrolled(index);
                          final isEnrolling = controller.isEnrolling(index);

                          return ElevatedButton(
                            onPressed: isEnrolled || isEnrolling
                                ? null
                                : () => controller.joinCourse(index),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              backgroundColor: isEnrolled
                                  ? Colors.green
                                  : Colors.blue,
                              disabledBackgroundColor: isEnrolled
                                  ? Colors.green.shade300
                                  : Colors.grey.shade300,
                            ),
                            child: isEnrolling
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isEnrolled ? 'Joined ✓' : 'Join Course',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: getTextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                          );
                        }),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
