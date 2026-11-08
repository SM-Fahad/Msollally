import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';

import '../controller/student_create_task_controller.dart';
import '../model/student_create_task_upgrade_model.dart';

class StudentCreateTaskUpgrade extends StatelessWidget {
  const StudentCreateTaskUpgrade({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(StudentCreateTaskController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 38.height),
            child: CustomAppBar(
              leadingIcon: Icon(Icons.close, size: 24.height),
              onLeadingTap: () {
                Get.back();
              },
              title: "Upgrade to Premium",
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isUpgradeLoading.value && controller.upgradeListItems.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.mediumSeaGreen57C773));
              }
              if (controller.upgradeListItems.isEmpty) {
                return Center(
                  child: Text(
                    "No subscription packages available.",
                    style: appTextStyleHeading2(color: AppColors.tertiaryTextColor),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 20.height),
                itemCount: controller.upgradeListItems.length,
                itemBuilder: (_, index) {
                  var item = controller.upgradeListItems[index];
                  return Obx(() {
                    bool isSelected = item.isChecked.value;
                    bool isCurrentPlan = item.id != null && item.id == controller.currentPlanId.value;
                    return _UpgradePackageCard(
                      item: item,
                      isSelected: isSelected,
                      isCurrentPlan: isCurrentPlan,
                      onSelect: () => controller.selectUpgradeItem(index),
                    );
                  });
                },
              );
            }),
          ),
          Container(
            padding: EdgeInsets.all(16.width),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Obx(() {
                final selectedPlan = controller.getSelectedPlan();
                if (selectedPlan == null) {
                  return CustomButton(
                    vertical: 14.height,
                    text: "Select a Plan",
                    color: Colors.grey,
                    onPressed: () {},
                  );
                }

                if (selectedPlan.id == controller.currentPlanId.value) {
                  return CustomButton(
                    vertical: 14.height,
                    text: "Cancel Subscription",
                    color: Colors.redAccent,
                    onPressed: () {
                      controller.cancelSubscription();
                    },
                  );
                }

                if (selectedPlan.isTrial) {
                  return CustomButton(
                    vertical: 14.height,
                    text: "Claim Free Trial",
                    onPressed: () {
                      controller.claimFreeTrial();
                    },
                  );
                }

                return CustomButton(
                  vertical: 14.height,
                  text: "Pay Now",
                  onPressed: () {
                    controller.subscribeToPackage();
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpgradePackageCard extends StatefulWidget {
  final StudentCreateTaskUpgradeModel item;
  final bool isSelected;
  final bool isCurrentPlan;
  final VoidCallback onSelect;

  const _UpgradePackageCard({
    required this.item,
    required this.isSelected,
    required this.isCurrentPlan,
    required this.onSelect,
  });

  @override
  State<_UpgradePackageCard> createState() => _UpgradePackageCardState();
}

class _UpgradePackageCardState extends State<_UpgradePackageCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onSelect();
        setState(() {
          isExpanded = true;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 16.height),
        decoration: BoxDecoration(
          color: widget.isSelected ? AppColors.mintCreamF6FCF8 : Colors.white,
          borderRadius: BorderRadius.circular(16.radius),
          border: Border.all(
            color: widget.isSelected ? AppColors.mediumSeaGreen57C773 : Colors.grey.shade200,
            width: widget.isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (widget.isSelected)
              BoxShadow(
                color: AppColors.mediumSeaGreen57C773.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            InkWell(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
                if (!widget.isSelected) widget.onSelect();
              },
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16.radius),
                bottom: Radius.circular(isExpanded ? 0 : 16.radius),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.radius),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.item.title,
                                style: appTextStyleHeading1(
                                  fontSize: 18.fontSize,
                                  color: widget.isSelected
                                      ? AppColors.mediumSeaGreen57C773
                                      : AppColors.black18181B,
                                ),
                              ),
                              if (widget.isCurrentPlan) ...[
                                SizedBox(width: 8.width),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.width, vertical: 4.height),
                                  decoration: BoxDecoration(
                                    color: AppColors.mediumSeaGreen57C773.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.radius),
                                  ),
                                  child: Text(
                                    "Current Plan",
                                    style: appTextStyleHeading2(
                                      fontSize: 10.fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.mediumSeaGreen57C773,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (widget.item.subTitle.isNotEmpty) ...[
                            SizedBox(height: 4.height),
                            Text(
                              widget.item.subTitle,
                              style: appTextStyleHeading2(
                                fontSize: 13.fontSize,
                                color: AppColors.tertiaryTextColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Obx(() {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 6.height),
                            decoration: BoxDecoration(
                              color: widget.isSelected ? AppColors.mediumSeaGreen57C773 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20.radius),
                            ),
                            child: Text(
                              widget.item.charge.isEmpty ? "Free" : widget.item.charge,
                              style: appTextStyleHeading2(
                                fontWeight: FontWeight.bold,
                                color: widget.isSelected ? Colors.white : AppColors.black18181B,
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 8.height),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.tertiaryTextColor,
                          size: 24.radius,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Expanded Content
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: EdgeInsets.only(left: 20.width, right: 20.width, bottom: 20.height),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: Colors.grey.shade200, height: 1),
                    SizedBox(height: 16.height),
                    if (widget.item.priceOptions.length > 1) ...[
                      Text(
                        "Billing Cycle:",
                        style: appTextStyleHeading2(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black18181B,
                        ),
                      ),
                      SizedBox(height: 12.height),
                      ...widget.item.priceOptions.map((priceOption) {
                        return Obx(() {
                          bool isPriceSelected = widget.item.selectedPrice.value?.id == priceOption.id;
                          return GestureDetector(
                            onTap: () {
                              widget.item.selectedPrice.value = priceOption;
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 8.height),
                              padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 12.height),
                              decoration: BoxDecoration(
                                color: isPriceSelected ? AppColors.mintCreamF6FCF8 : Colors.white,
                                borderRadius: BorderRadius.circular(12.radius),
                                border: Border.all(
                                  color: isPriceSelected ? AppColors.mediumSeaGreen57C773 : Colors.grey.shade300,
                                  width: isPriceSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    priceOption.billingInterval.capitalizeFirst ?? priceOption.billingInterval,
                                    style: appTextStyleHeading2(
                                      fontWeight: isPriceSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isPriceSelected ? AppColors.mediumSeaGreen57C773 : AppColors.black18181B,
                                    ),
                                  ),
                                  Text(
                                    priceOption.formattedCharge,
                                    style: appTextStyleHeading2(
                                      fontWeight: FontWeight.bold,
                                      color: isPriceSelected ? AppColors.mediumSeaGreen57C773 : AppColors.black18181B,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      }),
                      SizedBox(height: 16.height),
                    ],
                    if (widget.item.detailedFeatures.isNotEmpty) ...[
                      Text(
                        "Plan Features:",
                        style: appTextStyleHeading2(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black18181B,
                        ),
                      ),
                      SizedBox(height: 12.height),
                      ...widget.item.detailedFeatures.map((feature) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.height),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                feature.isAvailable ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                color: feature.isAvailable ? AppColors.mediumSeaGreen57C773 : Colors.red.shade300,
                                size: 18.radius,
                              ),
                              SizedBox(width: 8.width),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      feature.title,
                                      style: appTextStyleHeading2(
                                        fontSize: 14.fontSize,
                                        color: feature.isAvailable ? AppColors.black18181B : Colors.grey.shade500,
                                      ).copyWith(
                                        decoration: feature.isAvailable ? null : TextDecoration.lineThrough,
                                      ),
                                    ),
                                    if (feature.subtitle != null && feature.subtitle!.isNotEmpty) ...[
                                      SizedBox(height: 2.height),
                                      Text(
                                        feature.subtitle!,
                                        style: appTextStyleHeading2(
                                          fontSize: 12.fontSize,
                                          color: feature.isAvailable ? AppColors.mediumSeaGreen57C773 : Colors.grey.shade400,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ] else ...[
                      Text(
                        "No specific features found.",
                        style: appTextStyleHeading2(color: AppColors.tertiaryTextColor),
                      ),
                    ]
                  ],
                ),
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
