import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

import '../details/controller/fusra_details_controller.dart';
import '../widgets/fusra_details_app_bar.dart';
import '../analytic/screens/analytics_screen.dart';
import '../details/screens/details_screen.dart';
import '../register/screens/registrations_screen.dart';

class FursaDetailsMainScreen extends StatelessWidget {
  FursaDetailsMainScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;
  final FusraDetailsController controller = Get.put(FusraDetailsController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: controller.tabs.length,
      initialIndex: initialTabIndex.clamp(0, controller.tabs.length - 1),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              FusraDetailsAppBar(title: controller.competitionTitle),
              Material(
                color: Colors.white,
                child: TabBar(
                  labelColor: AppColors.primaryButtonColor,
                  unselectedLabelColor: AppColors.darkGray9CA3AF,
                  indicatorColor: AppColors.primaryButtonColor,
                  indicatorWeight: 2.4,
                  dividerColor: AppColors.sliderColorInboarding,
                  labelStyle: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overlayColor: WidgetStateProperty.all(
                    theme.colorScheme.primary.withValues(alpha: .06),
                  ),
                  tabs: controller.tabs
                      .map((tab) => Tab(text: tab))
                      .toList(growable: false),
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    AnalyticsScreen(),
                    RegistrationsScreen(),
                    DetailsScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
