import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';

import '../controller/create_campaign_controller.dart';
import '../controller/create_campaign_profile_controller.dart';
import '../widgets/budget_tab_widget.dart';
import '../widgets/content_tab_widget.dart';
import '../widgets/preview_tab_widget.dart';
import '../widgets/targeting_tab_widget.dart';

class CreateCampaignScreen extends StatefulWidget {
  final int? campaignId;

  const CreateCampaignScreen({super.key, this.campaignId});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  late final CreateCampaignController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<CreateCampaignController>()) {
      Get.delete<CreateCampaignController>(force: true);
    }
    controller = Get.put(
      CreateCampaignController(initialCampaignId: widget.campaignId),
    );
    if (!Get.isRegistered<CreateCampaignProfileController>()) {
      Get.put(CreateCampaignProfileController());
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<CreateCampaignController>()) {
      Get.delete<CreateCampaignController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.panelBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          title: Obx(
            () => Text(
              controller.isEditMode.value
                  ? 'Update Campaign'
                  : 'Create Campaign',
              style: const TextStyle(
                color: AppColors.darkSlateGray1E293B,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          backgroundColor: AppColors.panelBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        body: Obx(
          () => controller.isFetchingDetails.value
              ? const Center(child: CircularProgressIndicator())
              : const Column(
                  children: [
                    Expanded(
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          ContentTabWidget(),
                          TargetingTabWidget(),
                          BudgetTabWidget(),
                          PreviewTabWidget(),
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
