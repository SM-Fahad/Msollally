import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../model/mock_model.dart';

class StatisticsSummaryCard extends StatelessWidget {
  final MockResult result;
  final double scorePercent;
  final int notAnswered;

  const StatisticsSummaryCard({
    super.key,
    required this.result,
    required this.scorePercent,
    required this.notAnswered,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.width, 16.height, 20.width, 24.height),
      child: Container(
        padding: EdgeInsets.all(20.width),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryButtonColor,
              AppColors.primaryButtonColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.radius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryButtonColor.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.categoryTitle,
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.height),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "YOUR SCORE",
                        style: getTextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 6.height),
                      Text(
                        "${result.correctAnswers} / ${result.totalQuestions} Correct",
                        style: getTextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.height),
                      Text(
                        "Completion rate: ${(scorePercent * 100).toInt()}%",
                        style: getTextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                CircularPercentIndicator(
                  radius: 46.radius,
                  lineWidth: 8.width,
                  percent: scorePercent.clamp(0.0, 1.0),
                  center: Text(
                    "${(scorePercent * 100).toInt()}%",
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  progressColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
              ],
            ),
            SizedBox(height: 20.height),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 10.height),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.radius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatBadge(
                    icon: Icons.check_circle_outline_rounded,
                    label: "Correct",
                    value: "${result.correctAnswers}",
                    color: Colors.green.shade100,
                    textColor: Colors.white,
                  ),
                  _buildStatBadge(
                    icon: Icons.cancel_outlined,
                    label: "Wrong",
                    value: "${result.wrongAnswers}",
                    color: Colors.red.shade100,
                    textColor: Colors.white,
                  ),
                  _buildStatBadge(
                    icon: Icons.help_outline_rounded,
                    label: "Unanswered",
                    value: "$notAnswered",
                    color: Colors.grey.shade200,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.radius, color: textColor.withValues(alpha: 0.8)),
            SizedBox(width: 4.width),
            Text(
              value,
              style: getTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.height),
        Text(
          label,
          style: getTextStyle(
            fontSize: 11,
            color: textColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
