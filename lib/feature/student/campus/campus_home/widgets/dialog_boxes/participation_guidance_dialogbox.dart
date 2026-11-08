import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/student_campus_fursa_zone_model.dart';

class ParticipationGuidanceDialogbox extends StatelessWidget {
  final CompetitionModel? competition;

  const ParticipationGuidanceDialogbox({super.key, this.competition});

  String _getDayName(DateTime? date) {
    if (date == null) return '';
    switch (date.weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _getLearningPhaseRange() {
    if (competition == null) return "Monday – Wednesday";
    if (competition!.learningPhaseRange != 'Monday – Wednesday') {
      return competition!.learningPhaseRange;
    }
    if (competition!.learningPhaseStartDate != null &&
        competition!.learningPhaseEndDate != null) {
      final start = _getDayName(competition!.learningPhaseStartDate);
      final end = _getDayName(competition!.learningPhaseEndDate);
      if (start.isNotEmpty && end.isNotEmpty) {
        if (start == end) {
          return start; // Same-day events output a single day name
        }
        return "$start – $end";
      }
    }
    return competition!.learningPhaseRange;
  }

  String _getQualificationQuizRange() {
    if (competition == null) return "Thursday - Saturday";
    if (competition!.qualificationQuizRange != 'Thursday - Saturday') {
      return competition!.qualificationQuizRange;
    }
    if (competition!.qualificationDate != null) {
      final day = _getDayName(competition!.qualificationDate);
      if (day.isNotEmpty) {
        return day;
      }
    }
    return competition!.qualificationQuizRange;
  }

  String _getWeeklyFinalsRange() {
    if (competition == null) return "Sunday";
    if (competition!.weeklyFinalsRange != 'Sunday') {
      return competition!.weeklyFinalsRange;
    }
    if (competition!.finalCompetitionDate != null) {
      final day = _getDayName(competition!.finalCompetitionDate);
      if (day.isNotEmpty) {
        return day;
      }
    }
    return competition!.weeklyFinalsRange;
  }

  String _getWinnersAnnouncementRange() {
    if (competition == null) return "Monday";
    if (competition!.winnersAnnouncementRange != 'Monday') {
      return competition!.winnersAnnouncementRange;
    }
    if (competition!.finalCompetitionDate != null) {
      final dayAfter = competition!.finalCompetitionDate!.add(
        const Duration(days: 1),
      );
      final day = _getDayName(dayAfter);
      if (day.isNotEmpty) {
        return day;
      }
    }
    return competition!.winnersAnnouncementRange;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Resolve Dynamic Timeline ranges (checking datetime ranges first)
    final String learnRange = _getLearningPhaseRange();
    final String quizRange = _getQualificationQuizRange();
    final String finalsDay = _getWeeklyFinalsRange();
    final String winnerDay = _getWinnersAnnouncementRange();

    // 2. Resolve Dynamic "How to Participate" steps
    List<String> participationSteps = [];
    if (competition?.howToParticipateOverride != null &&
        competition!.howToParticipateOverride!.isNotEmpty) {
      participationSteps = competition!.howToParticipateOverride!;
    } else {
      // Build dynamic list based on the partner toggles
      participationSteps = [
        "Watch the product video completely",
        "Read the digital brochure thoroughly",
        if (competition?.hasQaChat ?? true) "Ask questions in Q&A chat",
        "Earn bonus points by sharing and referring",
        "Qualify with ${competition?.passingScore ?? 70}% in the quiz",
        "Compete in $finalsDay finals for prizes",
      ];
    }

    // 3. Resolve Dynamic "Important Notes"
    List<String> notes = [];
    if (competition?.importantNotesOverride != null &&
        competition!.importantNotesOverride!.isNotEmpty) {
      notes = competition!.importantNotesOverride!;
    } else {
      notes = [
        "Complete minimum engagement time to qualify",
        "Top 1,000 scorers advance to finals",
        "Finals are live with screen recording",
        "Winners announced every $winnerDay",
      ];
    }

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Participation Guidance",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black1D1D1D,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Learn how to participate in the ${competition?.proPartner.isNotEmpty == true ? competition!.proPartner : 'weekly'} competition",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionHeader("📅 Competition Timeline"),
              const SizedBox(height: 12),
              _buildTimelineBox(
                "$learnRange: Learning Phase",
                AppColors.ghostWhiteFAF5FF,
              ),
              _buildTimelineBox(
                "$quizRange: Qualification Quiz",
                AppColors.aliceBlueEFF6FF,
              ),
              _buildTimelineBox(
                "$finalsDay: Weekly Finals",
                AppColors.seaShellFFF7ED,
              ),
              _buildTimelineBox(
                "$winnerDay: Winners Announcement",
                AppColors.honeydewF0FDF4,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader("🎯 How to Participate"),
              const SizedBox(height: 12),
              ...participationSteps.map((step) => _buildTextItem(step)),

              const SizedBox(height: 24),
              _buildSectionHeader("⚠ Important Notes"),
              const SizedBox(height: 12),
              ...notes.map((note) => _buildBulletItem(note)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.blueViolet9333EA,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
    );
  }

  Widget _buildTimelineBox(String text, Color bgColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 13),
      ),
    );
  }

  Widget _buildTextItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 13),
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: AppColors.secondaryTextColor)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
