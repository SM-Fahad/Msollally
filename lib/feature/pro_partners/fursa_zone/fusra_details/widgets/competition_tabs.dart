import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/quiz_competition_controller.dart';
import '../analytic/screens/analytics_screen.dart';
import '../details/screens/details_screen.dart';
import '../register/screens/registrations_screen.dart';

class CompetitionTabs extends StatelessWidget {
  const CompetitionTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuizCompetitionController>();

    final tabs = ['Analytics', 'Registrations(1100)', 'Details'];

    return Obx(
      () => Row(
        children: List.generate(tabs.length, (index) {
          final active = controller.selectedTab.value == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                controller.selectedTab.value = index;

                if (index == 0) {
                  Get.off(() => AnalyticsScreen());
                } else if (index == 1) {
                  Get.off(() => RegistrationsScreen());
                } else {
                  Get.off(() => DetailsScreen());
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: active ? Colors.blue : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
