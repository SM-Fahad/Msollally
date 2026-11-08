import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/student/referral_program/model/referral_model.dart';

class MilestoneCard extends StatelessWidget {
  final MilestoneModel milestone;
  final VoidCallback? onApply;
  final bool isFirst;
  final bool isLast;

  const MilestoneCard({
    super.key,
    required this.milestone,
    this.onApply,
    this.isFirst = false,
    this.isLast = false,
  });
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 68,
            child: Stack(
              children: [
                if (!isFirst)
                  Positioned(
                    top: 0,
                    left: 35,
                    child: Container(
                      width: 2,
                      height: 18,
                      color: Colors.grey[300],
                    ),
                  ),
                if (!isLast)
                  Positioned(
                    top: 50,
                    bottom: 0,
                    left: 35,
                    child: Container(width: 2, color: Colors.grey[300]),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: milestone.color.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      milestone.icon,
                      color: milestone.color,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    milestone.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildStatusBadge(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    String text;
    Color color;
    IconData iconData;

    switch (milestone.status) {
      case MilestoneStatus.unlocked:
        text = 'Apply Now';
        color = AppColors.blueViolet9333EA;
        iconData = Icons.arrow_forward;
        break;
      case MilestoneStatus.pending:
        text = 'Application Pending';
        color = AppColors.darkOrangeF97316;
        iconData = Icons.access_time_rounded;
        break;
      case MilestoneStatus.approved:
        text = 'Approved';
        color = AppColors.lightSeaGreen10B981;
        iconData = Icons.check_circle;
        break;
      case MilestoneStatus.locked:
        text = 'Locked';
        color = Colors.grey;
        iconData = Icons.lock;
        break;
    }
    if (milestone.status == MilestoneStatus.unlocked) {
      return InkWell(
        onTap: onApply,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.blueViolet9333EA, AppColors.mediumPurpleA855F7],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
