import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../model/question_bank_model.dart';
import 'practice_option_tile.dart';

class PracticeQuestionCard extends StatelessWidget {
  final PracticeQuestion question;
  final int questionNumber;
  final String? selectedOptionId;
  final bool isRevealed;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onReveal;

  const PracticeQuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.selectedOptionId,
    required this.isRevealed,
    required this.onOptionSelected,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.darkSlateBlue3F51B5,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: Colors.white,
                  child: Text(
                    "$questionNumber",
                    style: getTextStyle(
                      color: AppColors.darkSlateBlue3F51B5,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    question.questionText,
                    style: getTextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (question.imageUrl.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  question.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                  errorBuilder: (_, __, ___) => SizedBox.shrink(),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Column(
              children: question.options.map((opt) {
                return PracticeOptionTile(
                  option: opt,
                  isSelected: selectedOptionId == opt.id,
                  isRevealed: isRevealed,
                  correctOptionId: question.correctOptionId,
                  onTap: () {
                    if (!isRevealed) onOptionSelected(opt.id);
                  },
                );
              }).toList(),
            ),
          ),
          if (isRevealed && question.explanation.isNotEmpty)
            Container(
              margin: EdgeInsets.fromLTRB(12, 0, 12, 4),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation,
                      style: getTextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          if (!isRevealed)
            Padding(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.indigo),
                  ),
                ),
                icon: Icon(Icons.remove_red_eye_outlined, size: 18),
                label: Text("Reveal Answer"),
                onPressed: onReveal,
              ),
            ),
          if (isRevealed) SizedBox(height: 12),
        ],
      ),
    );
  }
}
