import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/utils/responsive.dart';

import '../../../../core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/student_settings_controller.dart';

class StudentSettingsSubscription extends StatelessWidget {
  const StudentSettingsSubscription({super.key, required this.controller});

  final StudentSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 12.height),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.radius),
                topRight: Radius.circular(8.radius),
              ),
            ),
            child: Text(
              "Subscription",
              style: appTextStyleHeading1(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2.fontSize,
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 12.height),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),

              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.radius),
                bottomRight: Radius.circular(8.radius),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: 12.height,),
                Obx(() {
                  if (controller.isLoadingSubscriptions.value) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.height),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  if (controller.subscriptionsList.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.height),
                      child: Center(
                        child: Text(
                          "No active subscriptions",
                          style: getTextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    //padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,

                    itemCount: controller.subscriptionsList.length,

                    itemBuilder: (_, index) {
                      var items = controller.subscriptionsList[index];

                      return Padding(
                        padding: EdgeInsets.only(bottom: 24.height),
                        child: SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                items.title,
                                style: appTextStyleHeading1(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2.fontSize,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(width: 16.width),
                              //widgets
                              Expanded(child: items.subTitle),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
                GestureDetector(
                  onTap: () {
                    Get.dialog(
                      AlertDialog(
                        title: Text("Cancel Subscription", style: appTextStyleHeading1(fontWeight: FontWeight.bold, fontSize: 16.fontSize)),
                        content: Text("Are you sure you want to cancel your active subscription?", style: appTextStyleHeading1(fontSize: 14.fontSize)),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text("No", style: appTextStyleHeading1(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              controller.cancelSubscription();
                            },
                            child: Text("Yes, Cancel", style: appTextStyleHeading1(color: AppColors.uiDangerColor, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.height),
                    child: Text(
                      "Cancel Subscription",
                      style: appTextStyleHeading1(
                        fontSize: 14.fontSize,
                        letterSpacing: 0.2.fontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.uiDangerColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 135.height),
        ],
      ),
    );
  }
}
