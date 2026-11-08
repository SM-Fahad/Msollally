import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/furza_zone/student_quiz_competition/controller/student_quiz_competition_controller.dart';
import 'package:msollaally/feature/furza_zone/student_quiz_competition/screen/three_tabs/widgets/competition_start_card.dart';
import 'package:msollaally/feature/furza_zone/student_quiz_competition/screen/three_tabs/widgets/peice_winner_card.dart';
import 'package:msollaally/feature/furza_zone/student_quiz_competition/screen/three_tabs/widgets/university_card.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentQuizCompetitionController>();
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Obx(
          () => Column(
            children: [
              const CompetitionOverviewWidget(),
              const SizedBox(height: 16),
              Container(
                height: 76,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.ghostWhiteFAF5FF, AppColors.aliceBlueEFF6FF],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.plumDAB2FF, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/crown.png',
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "This Week's Winners",
                          style: getTextStyle(
                            color: AppColors.blueViolet9810FA,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Current competition champions! 🎉",
                      style: getTextStyle(
                        color: AppColors.darkSlateGray4A5565,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...controller.prizeWinners.map(
                (winner) => Column(
                  children: [
                    PrizeWinnerCard(
                      rank: winner.rank,
                      userName: winner.userName,
                      points: winner.points,
                      price: winner.price,
                      imagePath: winner.imagePath,
                      gradientStartColor: winner.gradientStartColor,
                      gradientEndColor: winner.gradientEndColor,
                      avatarBackgroundColor: winner.avatarBackgroundColor,
                      borderColor: winner.borderColor,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Image.asset(IconsPath.round, width: 20, height: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Top Performing Schools',
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              ...controller.topUniversities.map(
                (uni) => Column(
                  children: [
                    UniversityCard(
                      indexText: uni.indexText,
                      title: uni.title,
                      subtitle: uni.subtitle,
                      badgeText: uni.badgeText,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
