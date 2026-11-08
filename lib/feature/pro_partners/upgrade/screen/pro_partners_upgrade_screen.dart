import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/feature/pro_partners/upgrade/controller/pro_partners_upgrade_controller.dart';
import 'package:msollaally/feature/pro_partners/upgrade/widgets/upgrade_to_premium_dialog.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';

class ProPartnersUpgradeScreen extends StatelessWidget {
  const ProPartnersUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProPartnersUpgradeController());

    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.only(top: 38.h),
            child: CustomAppBar(
              leadingIcon: Icon(Icons.close, size: 24.h),
              onLeadingTap: Get.back,
              title: 'Upgrade',
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: 16.w,
              vertical: 35.h,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Upgrade to premium to get more features.',
                    style: appTextStyleHeading1(
                      fontSize: 14.sp,
                      letterSpacing: 0.2.sp,
                      color: AppColors.black18181B,
                    ),
                  ),
                ),
                Obx(
                  () => ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: controller.upgradeListItems.length,
                    itemBuilder: (_, index) {
                      final item = controller.upgradeListItems[index];
                      return Padding(
                        padding: EdgeInsetsGeometry.only(top: 16.h),
                        child: Obx(
                          () => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: item.isChecked.value
                                  ? AppColors.mintCreamF6FCF8
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: item.isChecked.value
                                    ? AppColors.silverA4E0B3
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          controller.selectUpgradeItem(index),
                                      child: Container(
                                        width: 20.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            width: 1.5,
                                            color: item.isChecked.value
                                                ? AppColors.mediumSeaGreen57C773
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(3),
                                        child: item.isChecked.value
                                            ? Container(
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.mediumSeaGreen57C773,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: appTextStyleHeading2(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2.sp,
                                            color: AppColors.black18181B,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          item.subTitle,
                                          style: appTextStyleHeading2(
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.2.sp,
                                            fontSize: 12.sp,
                                            color: AppColors.tertiaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.charge,
                                        style: appTextStyleHeading2(
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.2.sp,
                                          color: AppColors.black18181B,
                                        ),
                                      ),
                                      item.discount.trim().isEmpty
                                          ? const SizedBox.shrink()
                                          : Text(
                                              item.discount.toString(),
                                              style: appTextStyleHeading2(
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.2.sp,
                                                color: AppColors.tertiaryTextColor,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20.h),
                CustomButton(
                  vertical: 8.h,
                  text: 'Upgrade',
                  onPressed: () => showProPartnersUpgradeToPremiumDialog(
                    context,
                    controller,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
