import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String iconPath;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconPath,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),

            padding: const EdgeInsets.all(6),
            child: ImageIcon(AssetImage(iconPath), color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: getTextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: getTextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
