import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/pro_partners/more/settings/controller/pro_partners_settings_controller.dart';

class ProPartnersSettingsSubscription extends StatelessWidget {
  const ProPartnersSettingsSubscription({super.key, required this.controller});

  final ProPartnersSettingsController controller;

  Widget _buildValueChip(String value) {
    if (value.toLowerCase() == 'approved' || value.toLowerCase() == 'premium') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: const Color(0xFF10B981),
        ),
        child: Text(
          value,
          style: appTextStyleHeading1(
            fontSize: 12.sp,
            letterSpacing: 0.2.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Text(
      value,
      style: appTextStyleHeading1(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                topRight: Radius.circular(8.r),
              ),
            ),
            child: Text(
              'Registration Details',
              style: appTextStyleHeading1(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2.sp,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.r),
                bottomRight: Radius.circular(8.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: controller.subscriptionsList.length,
                    itemBuilder: (_, index) {
                      final item = controller.subscriptionsList[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: index == controller.subscriptionsList.length - 1 ? 0 : 16.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.title,
                              style: appTextStyleHeading1(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            _buildValueChip(item.valueText),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
