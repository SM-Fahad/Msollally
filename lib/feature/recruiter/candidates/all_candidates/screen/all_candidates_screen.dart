import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/recruiter/candidates/all_candidates/controller/all_candidates_controller.dart';
import 'package:msollaally/feature/recruiter/candidates/all_candidates/widgets/candidate_card.dart';
import 'package:msollaally/feature/recruiter/candidates/all_candidates/widgets/filter_bottom_sheet.dart';
import 'package:msollaally/feature/recruiter/widgets/default_recruiter_app_bar.dart';

class RecruiterAllCandidatesScreen extends StatelessWidget {
  RecruiterAllCandidatesScreen({super.key});

  final AllCandidatesController controller = Get.put(AllCandidatesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultRecruiterAppBar(
        isHomePage: false,
        title: 'Candidates',
        profileImageUrl: controller.profileImageUrl,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              Text(
                'Talent Discovery',
                style: appTextStyleHeading2(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray9CA3AF,
                ),
              ),
              SizedBox(height: 16.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.tagBackgroundColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Use advanced filters to find the perfect candidates from the university\'s talent pool.',
                  style: appTextStyleHeading2(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              TextField(
                onChanged: (value) => controller.updateSearchText(value),
                decoration: InputDecoration(
                  hintText: 'Search by Name, Job Title, Skills',
                  hintStyle: TextStyle(
                    color: AppColors.darkGray9CA3AF,
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Icon(
                      Icons.search,
                      size: 20.sp,
                      color: AppColors.darkGray9CA3AF,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 14.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: AppColors.textfieldBorderColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AppColors.primaryButtonColor),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Candidates',
                    style: appTextStyleHeading2(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGray9CA3AF,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => FilterBottomSheet(),
                      );
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      height: 40.h,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryButtonColor),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 16.sp,
                            color: AppColors.primaryButtonColor,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Filter',
                            style: appTextStyleHeading2(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryButtonColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              Obx(() {
                if (controller.isLoading.value &&
                    controller.candidates.isEmpty) {
                  return SizedBox(
                    height: 200.h,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryButtonColor,
                      ),
                    ),
                  );
                }

                if (controller.filteredCandidates.isEmpty) {
                  return SizedBox(
                    height: 200.h,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48.sp,
                            color: AppColors.darkGray9CA3AF,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No candidates found',
                            style: appTextStyleHeading2(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkGray9CA3AF,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Try adjusting your search or filters',
                            style: appTextStyleHeading2(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.darkGray9CA3AF,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.filteredCandidates.length,
                      itemBuilder: (context, index) {
                        final candidate = controller.filteredCandidates[index];
                        return CandidateCard(
                          candidate: candidate,
                          onMessageTap: () =>
                              controller.onMessageTap(candidate),
                          onMenuTap: () =>
                              controller.onMenuTap(candidate.applicantId),
                          onTap: () {
                            Get.toNamed(
                              '/recruiter/candidate_details',
                              arguments: candidate.id.toString(),
                            );
                          },
                        );
                      },
                    ),
                    if (controller.hasMorePages.value)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: InkWell(
                          onTap: () => controller.loadMoreCandidates(),
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            height: 48.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primaryButtonColor),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Center(
                              child: controller.isLoading.value
                                  ? SizedBox(
                                      height: 20.h,
                                      width: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.w,
                                        color: AppColors.primaryButtonColor,
                                      ),
                                    )
                                  : Text(
                                      'See More',
                                      style: appTextStyleHeading2(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryButtonColor,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }
}
