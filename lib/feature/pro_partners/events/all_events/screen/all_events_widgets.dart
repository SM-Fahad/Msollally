import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/feature/pro_partners/events/event_overview/screen/event_overview_screen.dart';
import '../controller/all_events_controller.dart';
import '../model/event_model.dart';

class EventCard extends StatelessWidget {
  EventCard({super.key, required this.event, required this.controller});

  final EventModel event;
  final AllEventsController controller;
  final DateFormat formatter = DateFormat('yyyy-MM-dd, hh:mm a');

  @override
  Widget build(BuildContext context) {
    final badge = _statusStyle(event.status);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Get.to(() => EventOverviewScreen(event: event)),
        child: Ink(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.sliderColorInboarding),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkSlateGray32343A,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${event.rsvps}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryTextColor,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Joined',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.darkGray9CA3AF,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              InfoRow(
                icon: Icons.calendar_today_outlined,
                text: formatter.format(event.dateTime.toLocal()),
              ),
              SizedBox(height: 10),
              InfoRow(
                icon: Icons.location_on_outlined,
                text: event.location.isEmpty
                    ? 'Location not set'
                    : event.location,
              ),
              SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: badge.$1,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      event.status,
                      style: TextStyle(
                        color: badge.$2,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  Obx(() {
                    final isDeleting = controller.deletingEventIds.contains(
                      event.id,
                    );
                    final isFetching = controller.fetchingEventDetailIds
                        .contains(event.id);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 95,
                          child: CustomButton(
                            text: 'Update',
                            onPressed: isDeleting || isFetching
                                ? null
                                : () => controller
                                      .getEventByIdAndNavigateToUpdate(
                                        event.id,
                                      ),
                            vertical: 8,
                            fontSize: 14,
                            color: AppColors.aliceBlueEFF5FF,
                            textColor: AppColors.royalBlue2563EB,
                            leading: isFetching
                                ? SizedBox(
                                    height: 14,
                                    width: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.royalBlue2563EB,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 92,
                          child: CustomButton(
                            text: 'Delete',
                            onPressed: isDeleting || isFetching
                                ? null
                                : () => _confirmDelete(context),
                            vertical: 8,
                            fontSize: 14,
                            color: AppColors.seaShellFFEFEF,
                            textColor: AppColors.crimsonDC2626,
                            leading: isDeleting
                                ? SizedBox(
                                    height: 14,
                                    width: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.crimsonDC2626,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Delete Event?'),
        content: Text(
          'Are you sure you want to delete this event? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancel'),
          ),
          SizedBox(
            width: 96,
            child: CustomButton(
              text: 'Delete',
              onPressed: () => Navigator.of(dialogContext).pop(true),
              color: AppColors.crimsonDC2626,
              textColor: Colors.white,
              fontSize: 14,
              vertical: 8,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      controller.deleteEvent(event.id);
    }
  }

  (Color, Color) _statusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return (AppColors.oldLaceFFF4E8, AppColors.darkOrangeEA7A10);
      case 'completed':
        return (AppColors.honeydewEAFBF1, AppColors.forestGreen15803D);
      case 'cancelled':
        return (AppColors.linenFDEBEC, AppColors.crimsonDC2626);
      case 'draft':
        return (AppColors.aliceBlueEEF4FF, AppColors.royalBlue2563EB);
      default:
        return (AppColors.tagBackgroundColor, AppColors.darkSlateGray475569);
    }
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.secondaryTextColor),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13.5, color: AppColors.gray8B9099),
          ),
        ),
      ],
    );
  }
}
