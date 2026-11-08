import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/candidate_details_controller.dart';
import '../model/candidate_details_model.dart';
import '../widgets/candidate_header_widget.dart';
import '../widgets/info_row_widget.dart';
import '../widgets/action_buttons_widget.dart';

class CandidateDetailsScreen extends StatelessWidget {
  CandidateDetailsScreen({super.key});

  final CandidateDetailsController controller = Get.put(
    CandidateDetailsController(),
  );

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;
    String candidateId;
    if (args is int) {
      candidateId = args.toString();
    } else if (args is String) {
      candidateId = args;
    } else {
      candidateId = '1';
    }
    controller.loadCandidate(candidateId);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0.5,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.primaryTextColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    'Candidate: ${controller.selectedCandidate.value?.name ?? ''}',
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return SizedBox(
                      height: 300.h,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryButtonColor,
                        ),
                      ),
                    );
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return SizedBox(
                      height: 300.h,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48.sp,
                              color: AppColors.uiDangerColor,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Error Loading Candidate',
                              style: getTextStyle(
                                color: AppColors.primaryTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: getTextStyle(
                                color: AppColors.secondaryTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final CandidateDetailsModel? candidate =
                      controller.selectedCandidate.value;
                  if (candidate == null) return SizedBox();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Candidate Details',
                            style: getTextStyle(
                              color: AppColors.blackAlpha7F1E1E1E,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.downloadCV(candidate.cvId),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  color: AppColors.primaryButtonColor,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Download CV',
                                  style: getTextStyle(
                                    color: AppColors.primaryButtonColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),
                      CandidateHeaderWidget(
                        candidate: candidate,
                        controller: controller,
                      ),
                      SizedBox(height: 8.h),
                      ActionButtonsWidget(controller: controller),

                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        color: AppColors.dodgerBlueAlpha0A418AFF,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 12.h,
                        ),
                        child: Text(
                          'Personal information',
                          style: getTextStyle(
                            color: AppColors.appBarTitleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      InfoRowWidget(
                        label: 'Candidate name',
                        value: candidate.name,
                      ),
                      InfoRowWidget(
                        label: 'Email Address',
                        value: candidate.email,
                      ),
                      InfoRowWidget(
                        label: 'Phone Number',
                        value: candidate.phone,
                      ),
                      InfoRowWidget(
                        label: 'Address (City, State)',
                        value: candidate.address,
                      ),
                      InfoRowWidget(
                        label: 'LinkedIn Profile',
                        value: candidate.linkedIn,
                      ),

                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        color: AppColors.dodgerBlueAlpha0A418AFF,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 12.h,
                        ),
                        child: Text(
                          'Educational information',
                          style: getTextStyle(
                            color: AppColors.appBarTitleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      InfoRowWidget(
                        label: 'University Name',
                        value: candidate.university,
                      ),
                      InfoRowWidget(label: 'Degree', value: candidate.degree),
                      InfoRowWidget(
                        label: 'Department',
                        value: candidate.department,
                      ),
                      // InfoRowWidget(
                      //   label: 'GPA(last semester)',
                      //   value: candidate.gpa,
                      // ),
                      InfoRowWidget(
                        label: 'Graduation Start Date',
                        value: candidate.graduationDate,
                      ),

                      // SizedBox(height: 16.h),
                      // Container(
                      //   width: double.infinity,
                      //   color: AppColors.dodgerBlueAlpha0A418AFF,
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: 8.w,
                      //     vertical: 12.h,
                      //   ),
                      //   child: Text(
                      //     'Work Experience',
                      //     style: getTextStyle(
                      //       color: AppColors.appBarTitleColor,
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 8.h),
                      // InfoRowWidget(label: 'Company Name', value: '-'),
                      // InfoRowWidget(label: 'Job Title', value: '-'),
                      // InfoRowWidget(
                      //   label: 'Duration (Start – End)',
                      //   value: '-',
                      // ),
                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        color: AppColors.dodgerBlueAlpha0A418AFF,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 12.h,
                        ),
                        child: Text(
                          'Skills',
                          style: getTextStyle(
                            color: AppColors.appBarTitleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ...candidate.skillSets.map(
                        (set) => InfoRowWidget(
                          label: set.title,
                          value: set.values.join(', '),
                        ),
                      ),

                      // SizedBox(height: 16.h),
                      // Container(
                      //   width: double.infinity,
                      //   color: AppColors.dodgerBlueAlpha0A418AFF,
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: 8.w,
                      //     vertical: 12.h,
                      //   ),
                      //   child: Text(
                      //     'Languages',
                      //     style: getTextStyle(
                      //       color: AppColors.appBarTitleColor,
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 8.h),
                      // InfoRowWidget(
                      //   label: 'Language',
                      //   value: candidate.languages.join(','),
                      // ),

                      // SizedBox(height: 16.h),
                      // Container(
                      //   width: double.infinity,
                      //   color: AppColors.dodgerBlueAlpha0A418AFF,
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: 8.w,
                      //     vertical: 12.h,
                      //   ),
                      //   child: Text(
                      //     'Extracurricular Activities',
                      //     style: getTextStyle(
                      //       color: AppColors.appBarTitleColor,
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 8.h),
                      // ...candidate.activities.map(
                      //   (a) => InfoRowWidget(label: 'Activities', value: a),
                      // ),
                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        color: AppColors.dodgerBlueAlpha0A418AFF,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 12.h,
                        ),
                        child: Text(
                          'Documents',
                          style: getTextStyle(
                            color: AppColors.appBarTitleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ...candidate.documents.map(
                        (d) => SizedBox(
                          height: 40.h,
                          child: GestureDetector(
                            onTap: () async {
                              String urlStr = d;
                              if (urlStr.isEmpty) {
                                Get.snackbar('Error', 'Invalid URL');
                                return;
                              }

                              Uri? uri = Uri.tryParse(urlStr);
                              if (uri == null || uri.scheme.isEmpty) {
                                // Try adding https scheme for URLs missing it
                                uri = Uri.tryParse('https://$urlStr');
                              }

                              if (uri == null) {
                                Get.snackbar('Error', 'Invalid URL');
                                return;
                              }

                              try {
                                final launched = await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                                if (!launched) {
                                  Get.snackbar('Error', 'Could not open URL');
                                }
                              } catch (e) {
                                debugPrint('Error launching URL: $e');
                                Get.snackbar('Error', 'Failed to open URL: $e');
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.public,
                                        color: AppColors.uiDangerColor,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          d,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: getTextStyle(
                                            color: AppColors.appBarTitleColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 80.h),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
