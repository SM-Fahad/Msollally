import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class QuizCompetitionCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Color tagColor;
  final Color tagTextColor;
  final String tagText;
  final String leftText;
  final String rightText;
  final String endText;
  final VoidCallback? onTap;

  const QuizCompetitionCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.tagColor,
    required this.tagTextColor,
    required this.tagText,
    required this.leftText,
    required this.rightText,
    required this.endText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: getTextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                height: 122.37,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tagText,
                        style: getTextStyle(fontSize: 10, color: tagTextColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(leftText, style: getTextStyle(fontSize: 10)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(rightText, style: getTextStyle(fontSize: 10)),
                ),
                Text(endText, style: getTextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
