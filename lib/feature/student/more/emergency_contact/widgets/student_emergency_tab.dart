import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import '../controller/student_emergency_contact_controller.dart';

Padding studentEmergencyTab(StudentEmergencyContactController controller) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 16.height, horizontal: 16.width),
    child: Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(controller.emergencyTab.length, (index) {
            bool isSelected = controller.selectedTab.value == index;
            final item = controller.emergencyTab[index];

            return GestureDetector(
              onTap: () {
                controller.selectedTab.value = index;
                item.onTap();
              },
              child: Container(
                margin: EdgeInsets.only(right: 10.width),
                padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 8.height),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryButtonColor : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryButtonColor : AppColors.sectionBorderColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(100.radius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.02),
                      blurRadius: isSelected ? 8 : 4,
                      offset: Offset(0, isSelected ? 3 : 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.radius),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : item.color,
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          size: 18.radius,
                        ),
                        child: item.icon,
                      ),
                    ),
                    SizedBox(width: 8.width),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 12.fontSize,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}
