import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../model/question_bank_model.dart';

class PracticeOptionTile extends StatelessWidget {
  final PracticeOption option;
  final bool isSelected;
  final bool isRevealed;
  final String? correctOptionId;
  final VoidCallback onTap;

  const PracticeOptionTile({
    super.key,
    required this.option,
    required this.isSelected,
    required this.isRevealed,
    required this.correctOptionId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.grey.shade50;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.black87;
    IconData? trailingIcon;
    Color? iconColor;

    if (isRevealed && correctOptionId != null) {
      final isCorrect = option.id == correctOptionId;
      if (isCorrect) {
        bgColor = Colors.green.shade50;
        borderColor = Colors.green.shade400;
        textColor = Colors.green.shade800;
        trailingIcon = Icons.check_circle;
        iconColor = Colors.green;
      } else if (isSelected) {
        bgColor = Colors.red.shade50;
        borderColor = Colors.red.shade300;
        textColor = Colors.red.shade800;
        trailingIcon = Icons.cancel;
        iconColor = Colors.red;
      }
    } else if (isSelected) {
      bgColor = Colors.indigo.shade50;
      borderColor = Colors.indigo;
      textColor = Colors.indigo.shade800;
    }

    final label = String.fromCharCode(65 + option.order); // A, B, C, D

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    isSelected || (isRevealed && option.id == correctOptionId)
                    ? borderColor
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Text(
                label,
                style: getTextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color:
                      isSelected || (isRevealed && option.id == correctOptionId)
                      ? Colors.white
                      : Colors.grey.shade700,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                option.text,
                style: getTextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (trailingIcon != null)
              Icon(trailingIcon, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }
}
