import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class QuickToolButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final Color color;

  const QuickToolButton({
    super.key,
    required this.title,
    required this.iconPath,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ImageIcon(AssetImage(iconPath), color: color, size: 28),
        ),

        const SizedBox(height: 6),
        Text(title, style: getTextStyle(fontSize: 12)),
      ],
    );
  }
}
