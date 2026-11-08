import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/fursa_zone/fusra_feed/controller/pro_partners_fursa_zone_controller.dart';
import 'package:msollaally/feature/pro_partners/fursa_zone/fusra_feed/model/pro_partners_fursa_zone_model.dart';
import 'package:msollaally/feature/pro_partners/fursa_zone/fusra_feed/widgets/pro_partners_quiz_competition_card.dart';
import 'package:msollaally/feature/pro_partners/more/controller/pro_partners_more_controller.dart';
import 'package:msollaally/feature/pro_partners/widgets/default_pro_partners_app_bar.dart';

import '../../fusra_details/screens/fursa_details_main_screen.dart';

class ProPartnersFursaZoneScreen extends StatelessWidget {
  const ProPartnersFursaZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProPartnersFursaZoneController());
    final moreController = Get.put(ProPartnersMoreController());

    return Scaffold(
      backgroundColor: AppColors.aliceBlueF4F7FB,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Obx(
          () => DefaultProPartnersAppBar(
            title: 'Fursa Zone',
            isHomePage: false,
            profileImageUrl: moreController.profileImageUrl,
            notificationCount: 9,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isInitialLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.competitions.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () =>
                      controller.fetchCompetitions(isRefresh: true),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 40.h),
                    children: const [
                      Center(child: Text('No competitions found')),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchCompetitions(isRefresh: true),
                child: ListView.builder(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(top: 10.h, bottom: 24.h),
                  itemCount:
                      controller.competitions.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= controller.competitions.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final competition = controller.competitions[index];
                    return ProPartnersQuizCompetitionCard(
                      onTap: () => Get.to(
                        () => FursaDetailsMainScreen(),
                        arguments: competition.id,
                      ),
                      title: competition.title,
                      imageUrl: competition.imageUrl,
                      tagColor:
                          competition.status == ProPartnersQuizStatus.completed
                          ? Colors.blue.shade50
                          : Colors.green.shade50,
                      tagTextColor:
                          competition.status == ProPartnersQuizStatus.completed
                          ? Colors.blue
                          : Colors.green,
                      tagText: controller.getTagText(competition),
                      leftText: '${competition.registeredUsers} Registered',
                      endText: controller.getEndText(competition),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
