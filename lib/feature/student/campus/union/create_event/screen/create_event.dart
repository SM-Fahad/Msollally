// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/common/widgets/custom_button.dart';
import '../controller/event_controller.dart';

class CreateEventStudentScreen extends StatelessWidget {
  final CreateEventController controller = Get.put(CreateEventController());

  CreateEventStudentScreen({super.key});

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? controller.startDate.value
          : controller.endDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStartDate ? controller.startDate.value : controller.endDate.value,
        ),
      );

      if (pickedTime != null) {
        final DateTime finalDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (isStartDate) {
          controller.updateStartDate(finalDate);
        } else {
          controller.updateEndDate(finalDate);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset('assets/images/event_image.png', height: 150),
            ),
            SizedBox(height: 24),

            Text(
              'Event Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: 333,
              height: 44,
              child: TextField(
                controller: controller.eventNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Name your group',
                ),
              ),
            ),
            SizedBox(height: 24),

            Text(
              'Start date & time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Obx(
              () => InkWell(
                onTap: () => _selectDate(context, true),
                child: Container(
                  width: 333,
                  height: 44,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat(
                          'EEEE, d MMMM yyyy HH:mm',
                        ).format(controller.startDate.value),
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'End date & time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Obx(
              () => InkWell(
                onTap: () => _selectDate(context, false),
                child: Container(
                  width: 333,
                  height: 44,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat(
                          'EEEE, d MMMM yyyy HH:mm',
                        ).format(controller.endDate.value),
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),

            Text(
              'Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Obx(
              () => InkWell(
                onTap: () {
                  Get.bottomSheet(
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text('Online'),
                            onTap: () {
                              controller.setLocation('Online');
                              Get.back();
                            },
                          ),
                          ListTile(
                            title: Text('Offsite'),
                            onTap: () {
                              controller.setLocation('Offsite');
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 333,
                  height: 44,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.locationValue.value,
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              controller.locationValue.value == 'Choose privacy'
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, size: 24),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),
            Text(
              'Privacy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Obx(
              () => InkWell(
                onTap: () {
                  Get.bottomSheet(
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text('Public'),
                            onTap: () {
                              controller.setPrivacy('Public');
                              Get.back();
                            },
                          ),
                          ListTile(
                            title: Text('Private'),
                            onTap: () {
                              controller.setPrivacy('Private');
                              Get.back();
                            },
                          ),
                          ListTile(
                            title: Text('Invite Only'),
                            onTap: () {
                              controller.setPrivacy('Invite Only');
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 333,
                  height: 44,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.privacyValue.value,
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              controller.privacyValue.value == 'Choose privacy'
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, size: 24),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),
            Text(
              'Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: 333,
              height: 120,
              child: TextField(
                controller: controller.detailsController,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'What are the details?',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: CustomButton(onPressed: () {}, text: 'Create Event'),
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
