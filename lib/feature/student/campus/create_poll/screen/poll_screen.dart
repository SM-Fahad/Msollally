import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/common/widgets/custom_button.dart';
import '../controller/poll_controller.dart';

class CreatePollPage extends StatelessWidget {
  const CreatePollPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CreatePollController controller = Get.put(CreatePollController());

    // Initialize with two options
    if (controller.options.isEmpty) {
      controller.options.addAll(["", ""]);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Poll"),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            Text("Question"),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: "Ask a question",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => controller.question.value = value,
            ),
            SizedBox(height: 20),

            // Poll Options
            Text("Poll Options"),
            SizedBox(height: 8),
            Obx(
              () => Column(
                children: List.generate(controller.options.length, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        // Text field with checkbox inside
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Option ${index + 1}",
                              border: OutlineInputBorder(),
                              prefixIcon: Checkbox(
                                value: false,
                                onChanged: null, // Disabled
                              ),
                            ),
                            onChanged: (value) =>
                                controller.updateOption(index, value),
                          ),
                        ),

                        // Image button
                        IconButton(
                          icon: Icon(Icons.image_outlined),
                          onPressed: () {},
                        ),

                        // Remove option button
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => controller.removeOption(index),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 8),

            // Add Option Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.addOption(),
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.centerLeft, // ensures Row sticks left
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // keeps button height compact
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text("Add Poll Option"),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Settings
            Text("Settings"),
            SizedBox(height: 8),
            Obx(
              () => SwitchListTile(
                title: Text("Allow people to choose multiple options"),
                value: controller.allowMultiple.value,
                onChanged: (value) => controller.toggleAllowMultiple(value),
              ),
            ),
            Spacer(),

            // Create Poll Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(onPressed: () {}, text: 'Create Poll'),
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
