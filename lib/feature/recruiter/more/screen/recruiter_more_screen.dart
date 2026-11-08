import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/recruiter/more/controller/recruiter_more_controller.dart';
import 'package:msollaally/feature/recruiter/more/widgets/recruiter_more_menu_tile.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';
import 'package:msollaally/routes/app_route.dart';

class RecruiterMoreScreen extends StatelessWidget {
  RecruiterMoreScreen({super.key});

  final RecruiterMoreController controller = Get.put(RecruiterMoreController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leadingIcon: const Icon(
                Icons.arrow_back,
                color: AppColors.appBarTitleColor,
              ),
              onLeadingTap: () {
                if (Get.key.currentState?.canPop() ?? false) {
                  Get.back();
                }
              },
              title: 'More',
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchMe,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _HeaderCard(
                            name: controller.displayName,
                            photoUrl: controller.profileImageUrl,
                            coverUrl: controller.coverImageUrl,
                            subtitle:
                                controller.me.value?.profile?.bio ??
                                'Professor | Researcher in Archival Studies & Experimental Psychology | Multilingual Educator | Lifelong Learner',
                            onTapProfile: () =>
                                Get.toNamed(AppRoute.recruiterProfileScreen),
                          ),
                          SizedBox(height: 18),
                          // Get Primium
                          // Container(
                          //   padding: EdgeInsets.symmetric(
                          //     horizontal: 11.w,
                          //     vertical: 20.h,
                          //   ),
                          //   decoration: BoxDecoration(
                          //     color: AppColors.primaryButtonColor.withValues(alpha: .08),
                          //     borderRadius: BorderRadius.circular(12.r),

                          //     border: Border.all(
                          //       color: AppColors.primaryButtonColor.withValues(alpha: 0.5),
                          //     ),
                          //   ),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.center,
                          //     children: [
                          //       Text(
                          //         "Go Premium",
                          //         style: appTextStyleHeading1(),
                          //       ),
                          //       SizedBox(height: 10.h),

                          //       Text(
                          //         "job from top recruiters,Premium resume templates AI-powered resume optimization , Highlighted profile for recruiters ,AI-powered resume optimization",
                          //         style: appTextStyleHeading2(
                          //           color: AppColors.appBarTitleColor,
                          //         ),
                          //       ),
                          //       SizedBox(height: 31.h),
                          //       CustomButton(
                          //         vertical: 6.h,
                          //         text: "Upgrade",
                          //         onPressed: () {
                          //           // Get.toNamed(AppRoute.recruiterUpgrade);
                          //         },
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // SizedBox(height: 18),

                          // // Fursa Zone button
                          // GestureDetector(
                          //   onTap: () =>
                          //       Get.toNamed(AppRoute.proPartnersFursaZone),
                          //   child: Container(
                          //     height: 45,
                          //     width: double.infinity,
                          //     padding: EdgeInsets.all(8),
                          //     decoration: BoxDecoration(
                          //       color: AppColors.coralFF9244.withValues(alpha: 0.2),
                          //       borderRadius: BorderRadius.circular(8),
                          //       border: Border.all(
                          //         color: AppColors.sliderColorInboarding,
                          //         width: 1,
                          //       ),
                          //     ),
                          //     child: Row(
                          //       children: [
                          //         Image.asset(IconsPath.forsaicon),
                          //         SizedBox(width: 8),
                          //         Text(
                          //           "Fursa Zone",
                          //           style: getTextStyle(
                          //             fontSize: 18,
                          //             fontWeight: FontWeight.w400,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          SizedBox(height: 18),
                          Text(
                            "Profile & Settings",
                            style: getTextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...controller.options.map((option) {
                            return RecruiterMoreMenuTile(
                              title: option.title,
                              onTap: () {
                                switch (option.title) {
                                  case 'Settings':
                                    Get.toNamed(
                                      AppRoute.recruiterSettingsScreen,
                                    );
                                    break;
                                  case 'Help & Support':
                                    EasyLoading.showInfo('Coming soon');
                                    break;
                                  case 'Send Feedback':
                                    Get.toNamed(AppRoute.feedbackScreen);
                                    break;
                                  case 'About LinkYetu':
                                    Get.toNamed(AppRoute.termsAndPrivacyScreen, arguments: {'type': 'about', 'title': 'About LinkYetu'});
                                    break;
                                  case 'Terms & Conditions':
                                    Get.toNamed(AppRoute.termsAndPrivacyScreen, arguments: {'type': 'terms', 'title': 'Terms & Conditions'});
                                    break;
                                  case 'Privacy Policy':
                                    Get.toNamed(AppRoute.termsAndPrivacyScreen, arguments: {'type': 'privacy', 'title': 'Privacy Policy'});
                                    break;
                                  case 'Logout':
                                    controller.logout();
                                    break;
                                  default:
                                    break;
                                }
                              },
                            );
                          }),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String name;
  final String photoUrl;
  final String coverUrl;
  final String subtitle;
  final VoidCallback onTapProfile;

  const _HeaderCard({
    required this.name,
    required this.photoUrl,
    required this.coverUrl,
    required this.subtitle,
    required this.onTapProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Cover Photo
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: _resolveCoverImage(coverUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Profile Photo
            Positioned(
              left: 16,
              bottom: -32,
              child: InkWell(
                onTap: onTapProfile,
                borderRadius: BorderRadius.circular(48),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 37,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _resolveProfileImage(photoUrl),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 44),
        Text(
          name,
          style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: getTextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  ImageProvider _resolveProfileImage(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        url.isEmpty ||
        !(uri.hasScheme && (uri.isScheme('http') || uri.isScheme('https')))) {
      return const AssetImage('assets/images/profilePNG.png');
    }
    return NetworkImage(url);
  }

  ImageProvider _resolveCoverImage(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        url.isEmpty ||
        !(uri.hasScheme && (uri.isScheme('http') || uri.isScheme('https')))) {
      return const AssetImage('assets/images/onboarding1.png');
    }
    return NetworkImage(url);
  }
}
