import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/furza_zone/controller/fursa_zone_controller.dart';
import 'package:msollaally/feature/furza_zone/model/fursa_zone_model.dart';
import 'package:msollaally/feature/furza_zone/widgets/quiz_competition_card.dart';
import 'package:msollaally/feature/student/widgets/default_student_app_bar.dart';
import 'package:msollaally/routes/app_route.dart';

class FursaZoneScreen extends StatelessWidget {
  const FursaZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultStudentAppBar(title: 'Fursa Zone', isHomePage: false),
      body: GetBuilder<FursaZoneController>(
        init: FursaZoneController(),
        builder: (controller) {
          return ListView.builder(
            itemCount: controller.quizCompetitions.length,
            itemBuilder: (context, index) {
              final competition = controller.quizCompetitions[index];
              return Column(
                children: [
                  QuizCompetitionCard(
                    onTap: index == 0
                        ? () => Get.toNamed(AppRoute.studentQuizCompetition)
                        : null,
                    title: competition.title,
                    imagePath: competition.imagePath,
                    tagColor: competition.status == QuizStatus.completed
                        ? Colors.blue.shade50
                        : Colors.green.shade50,
                    tagTextColor: competition.status == QuizStatus.completed
                        ? Colors.blue
                        : Colors.green,
                    tagText: competition.status == QuizStatus.completed
                        ? 'Completed'
                        : 'Ongoing',
                    leftText: '${competition.registeredUsers} Registered',
                    rightText: competition.rightText ?? '',
                    endText: competition.endDate ?? '',
                  ),
                  if (competition.status == QuizStatus.ongoing &&
                      competition.price != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 8.0,
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
