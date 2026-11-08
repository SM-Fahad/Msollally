import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../model/question_bank_model.dart';
import 'qbank_badge.dart';
import 'qbank_info_row.dart';

class QbankDetailCard extends StatelessWidget {
  final QuestionBankItem item;

  const QbankDetailCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.subjectName,
                  style: getTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              QbankBadge(
                text: item.examType.toUpperCase(),
                color: item.examType.toLowerCase() == 'final'
                    ? Colors.blue
                    : Colors.orange,
              ),
            ],
          ),
          SizedBox(height: 14),
          Divider(),
          SizedBox(height: 10),
          QbankInfoRow(
            icon: Icons.school_outlined,
            label: "University",
            value: item.universityName,
          ),
          QbankInfoRow(
            icon: Icons.account_balance_outlined,
            label: "Program",
            value: item.programName,
          ),
          QbankInfoRow(
            icon: Icons.business_outlined,
            label: "Department",
            value: item.departmentName,
          ),
          QbankInfoRow(
            icon: Icons.calendar_month_outlined,
            label: "Semester",
            value: item.semester,
          ),
          QbankInfoRow(
            icon: Icons.quiz_outlined,
            label: "MCQ Count",
            value: "${item.mcqCount}",
          ),
          if (item.createdAt != null)
            QbankInfoRow(
              icon: Icons.access_time_outlined,
              label: "Added On",
              value: _formatDate(item.createdAt!),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year}";
  }
}
