import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import '../controller/event_overview_controller.dart';

class AttendeesHeader extends StatelessWidget {
  const AttendeesHeader({super.key, required this.controller});
  final EventOverviewController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Colors.white, AppColors.aliceBlueF4F8FF],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.lavenderDCE8FF),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackAlpha140F172A,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Attendees',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.midnightBlue102347,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage registrations, approvals, and attendance updates',
                      style: TextStyle(fontSize: 12, color: AppColors.slateGray64748B),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 48, 110, 255),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.attendees.length}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'visible attendees',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.powderBlueBFDBFE,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _StatusDropdown(controller: controller)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.controller});
  final EventOverviewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.lavenderD8E4FF),
          boxShadow: const [
            BoxShadow(
              color: AppColors.blackAlpha0D0F172A,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedAttendeeStatus.value,
            isExpanded: true,
            borderRadius: BorderRadius.circular(18),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.royalBlue3464D4,
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.midnightBlue102347,
            ),
            items: EventOverviewController.attendeeStatuses
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(_label(status)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null &&
                  value != controller.selectedAttendeeStatus.value) {
                controller.fetchAttendees(status: value);
              }
            },
          ),
        ),
      ),
    );
  }

  String _label(String value) =>
      value == 'all' ? 'All' : '${value[0].toUpperCase()}${value.substring(1)}';
}
