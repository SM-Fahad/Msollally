import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import '../controller/student_campus_event_controller.dart';
import '../widgets/student_event_card.dart';

class StudentCampusEventsScreen extends StatelessWidget {
  const StudentCampusEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentCampusEventController());
    final formatter = DateFormat('yyyy-MM-dd, hh:mm a');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 12.height),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with search icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Events',
                style: appTextStyleHeading1(
                  fontSize: 20.fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black09090B,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.height),

          // Events List
          Obx(() {
            if (controller.isLoading.value) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.height),
                child: ShimmerLoading.list(
                  itemCount: 3,
                  height: 120.height,
                  borderRadius: 16.radius,
                ),
              );
            }

            if (controller.events.isEmpty) {
              return const Center(child: Text('No events found.'));
            }

            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: controller.events.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.height),
              itemBuilder: (context, index) {
                return StudentEventCard(
                  event: controller.events[index],
                  formatter: formatter,
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
