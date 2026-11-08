import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class PracticeProgressBar extends StatelessWidget {
  final int answered;
  final int total;

  const PracticeProgressBar({
    super.key,
    required this.answered,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : answered / total;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$answered of $total questions answered",
            style: getTextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          ),
        ],
      ),
    );
  }
}
