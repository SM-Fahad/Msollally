import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';

class CreateNoticeScreen extends StatelessWidget {
  const CreateNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Notice'),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),

            SizedBox(height: 30),
            Text('Notice', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),

            TextField(
              decoration: InputDecoration(
                hintText: 'Write a notice',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 40),
            Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),

            TextField(
              decoration: InputDecoration(
                hintText: 'Write are the details?',
                border: OutlineInputBorder(),
              ),
            ),

            Spacer(),
            SizedBox(
              width: double.infinity,
              child: CustomButton(text: 'Create Notice', onPressed: () {}),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
