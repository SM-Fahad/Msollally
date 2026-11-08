import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class PlanTaskCard extends StatelessWidget {
  final dynamic task;

  const PlanTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.title.isNotEmpty)
              Text(
                task.title,
                style: getTextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            if (task.task.isNotEmpty) ...[
              if (task.title.isNotEmpty) SizedBox(height: 6),
              Text(
                task.task,
                style: getTextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
            if (task.dateLabel.isNotEmpty ||
                task.timeLabel.isNotEmpty ||
                task.status.isNotEmpty) ...[
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (task.dateLabel.isNotEmpty)
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: task.dateLabel,
                    ),
                  if (task.timeLabel.isNotEmpty)
                    _InfoChip(
                      icon: Icons.access_time_outlined,
                      label: task.timeLabel,
                    ),
                  if (task.status.isNotEmpty)
                    _InfoChip(icon: Icons.flag_outlined, label: task.status),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          SizedBox(width: 6),
          Text(label, style: getTextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
