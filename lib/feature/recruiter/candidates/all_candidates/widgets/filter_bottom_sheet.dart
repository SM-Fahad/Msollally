import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/all_candidates_controller.dart';
import 'university_autocomplete.dart';
import 'filter_actions.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final AllCandidatesController controller = Get.find();
    final universityController = TextEditingController();
    final gradeController = TextEditingController();
    final skillsController = TextEditingController();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter',
                style: appTextStyleHeading2(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close)),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            'University name',
            style: appTextStyleHeading2(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(
            () => controller.isLoadingUniversities.value
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryButtonColor,
                          ),
                        ),
                      ),
                    ),
                  )
                : UniversityAutocomplete(
                    controller: universityController,
                    universities: controller.universities,
                  ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Skills',
            style: appTextStyleHeading2(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: skillsController,
            decoration: InputDecoration(
              hintText: 'e.g Writing, Research',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 14.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.textfieldBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.primaryButtonColor),
              ),
            ),
          ),
          SizedBox(height: 30.h),
          FilterActions(
            onFilter: () {
              controller.updateFilter(
                university: universityController.text,
                grade: gradeController.text,
                skills: skillsController.text,
              );
              controller.applyFilters();
              Get.back();
            },
            onClear: () {
              universityController.clear();
              gradeController.clear();
              skillsController.clear();
              controller.clearFilters();
              Get.back();
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
