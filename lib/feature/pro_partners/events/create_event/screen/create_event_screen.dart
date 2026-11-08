import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/events/all_events/model/event_model.dart';
import 'package:msollaally/feature/pro_partners/events/create_event/controller/create_event_controller.dart';
import 'package:msollaally/feature/pro_partners/events/create_event/widgets/event_info_card.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';

class CreateEventScreen extends StatelessWidget {
  CreateEventScreen({super.key, this.event, this.isEdit = false});

  final EventModel? event;
  final bool isEdit;
  final String controllerTag =
      'create_event_${DateTime.now().microsecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CreateEventController(event: event, isEdit: isEdit),
      tag: controllerTag,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.appBarTitleColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          isEdit ? 'Edit Event' : 'Create Event',
          style: TextStyle(color: AppColors.appBarTitleColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventInfoCard(controller: controller),
            SizedBox(height: 24.h),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        child: SafeArea(
          top: false,
          child: Obx(
            () => CustomButton(
              text: controller.isSubmitting.value
                  ? (isEdit ? 'Updating...' : 'Creating...')
                  : (isEdit ? 'Update Event' : 'Create Event'),
              onPressed: controller.isSubmitting.value
                  ? null
                  : controller.submitEvent,
            ),
          ),
        ),
      ),
    );
  }
}
