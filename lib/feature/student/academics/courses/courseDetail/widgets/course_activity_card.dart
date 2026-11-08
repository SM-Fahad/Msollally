import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class CourseActivityCard extends StatelessWidget {
  final dynamic activity;

  const CourseActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final isPositive =
        activity.type == "assignment" || activity.type == "module";
    final activityTime = activity.time is DateTime
        ? activity.time as DateTime
        : null;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: getTextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
              Text(activity.description),
            ],
          ),
          Text(
            _formatRelativeTime(activityTime),
            style: getTextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime? value) {
    if (value == null) return 'No time';

    final difference = DateTime.now().difference(value.toLocal());
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes} min ago';
    if (difference.inDays < 1) return '${difference.inHours} hr ago';
    return '${difference.inDays} day ago';
  }
}
