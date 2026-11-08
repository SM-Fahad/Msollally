import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/teacher/widgets/get_random_color.dart';

class NoticeCard extends StatelessWidget {
  final String title;
  final String message;
  final String? dateLabel;
  final VoidCallback? onTap;

  const NoticeCard({
    super.key,
    required this.title,
    required this.message,
    this.dateLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = getRandomColor().withValues(alpha: 0.08);
    final borderColor = getRandomColor().withValues(alpha: 0.9);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (dateLabel?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                dateLabel!,
                style: getTextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              message,
              style: getTextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
