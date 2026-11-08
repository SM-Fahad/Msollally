import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';

import 'package:msollaally/core/common/styles/global_text_style.dart';

import 'package:msollaally/feature/recruiter/more/profile/controller/recruiter_profile_controller.dart';
import 'package:msollaally/feature/recruiter/more/profile/edit_profile/controller/recruiter_edit_profile_controller.dart';
import 'package:msollaally/feature/recruiter/more/profile/widgets/recruiter_profile_tile.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';

class RecruiterProfileScreen extends StatelessWidget {
  RecruiterProfileScreen({super.key});

  final RecruiterProfileController controller = Get.put(
    RecruiterProfileController(),
  );

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
              onLeadingTap: () => Get.back(),
              title: 'Profile',
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: () {
                                final url = controller.coverPhotoUrl;
                                final uri = Uri.tryParse(url);
                                if (uri != null &&
                                    url.isNotEmpty &&
                                    (uri.hasScheme &&
                                        (uri.isScheme('http') ||
                                            uri.isScheme('https')))) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => FullscreenImageView(
                                        imageUrl: url,
                                        isNetworkImage: true,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: _resolveCoverImage(controller),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: InkWell(
                                onTap: controller.pickAndUpdateCoverPhoto,
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: AppColors.dodgerBlue2F80ED,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: -42,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    final url = controller.profileImageUrl;
                                    final uri = Uri.tryParse(url);
                                    if (uri != null &&
                                        url.isNotEmpty &&
                                        (uri.hasScheme &&
                                            (uri.isScheme('http') ||
                                                uri.isScheme('https')))) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (ctx) => FullscreenImageView(
                                            imageUrl: url,
                                            isNetworkImage: true,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 52,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 49,
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage: _resolveProfileImage(
                                        controller,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 25,
                              right: -80,
                              left: 0,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: GestureDetector(
                                    onTap: controller.pickAndUpdateProfilePhoto,
                                    behavior: HitTestBehavior.opaque,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.black12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: AppColors.dodgerBlue2F80ED,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 60),
                        Center(
                          child: Text(
                            controller.displayName,
                            style: getTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            controller.bio,
                            textAlign: TextAlign.center,
                            style: getTextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'About You',
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RecruiterProfileTile(
                          title: 'Name',
                          value: controller.displayName,
                          onTap: () => _openEdit(
                            field: RecruiterEditProfileControllerField.name,
                            initialValue: controller.displayName,
                          ),
                        ),
                        const Divider(height: 1),
                        RecruiterProfileTile(
                          title: 'Email',
                          value: controller.email,
                          onTap: () => _openEdit(
                            field: RecruiterEditProfileControllerField.email,
                            initialValue: controller.email,
                          ),
                        ),
                        const Divider(height: 1),
                        RecruiterProfileTile(
                          title: 'Cell',
                          value: controller.cell,
                          onTap: () => _openEdit(
                            field: RecruiterEditProfileControllerField.cell,
                            initialValue: controller.cell,
                          ),
                        ),
                        const Divider(height: 1),
                        RecruiterProfileTile(
                          title: 'Company Name',
                          value: controller.companyName,
                          onTap: () => _openEdit(
                            field:
                                RecruiterEditProfileControllerField.companyName,
                            initialValue: controller.companyName,
                          ),
                        ),
                        const Divider(height: 1),
                        RecruiterProfileTile(
                          title: 'Designation',
                          value: controller.designation,
                          onTap: () => _openEdit(
                            field:
                                RecruiterEditProfileControllerField.designation,
                            initialValue: controller.designation,
                          ),
                        ),
                        const Divider(height: 1),
                        RecruiterProfileTile(
                          title: 'Industry Type',
                          value: controller.industryType,
                          onTap: () => _openEdit(
                            field: RecruiterEditProfileControllerField
                                .industryType,
                            initialValue: controller.industryType,
                          ),
                        ),
                        const Divider(height: 1),
                        RecruiterProfileTile(
                          title: 'Bio',
                          value: controller.bio,
                          onTap: () => _openEdit(
                            field: RecruiterEditProfileControllerField.bio,
                            initialValue: controller.bio,
                          ),
                        ),
                      ],
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

  ImageProvider _resolveProfileImage(RecruiterProfileController controller) {
    final url = controller.profileImageUrl;
    final uri = Uri.tryParse(url);
    if (uri == null ||
        url.isEmpty ||
        !(uri.hasScheme && (uri.isScheme('http') || uri.isScheme('https')))) {
      return const AssetImage('assets/images/profilePNG.png');
    }
    return NetworkImage(url);
  }

  ImageProvider _resolveCoverImage(RecruiterProfileController controller) {
    final url = controller.coverPhotoUrl;
    final uri = Uri.tryParse(url);
    if (uri == null ||
        url.isEmpty ||
        !(uri.hasScheme && (uri.isScheme('http') || uri.isScheme('https')))) {
      return const AssetImage('assets/images/onboarding1.png');
    }
    return NetworkImage(url);
  }

  Future<void> _openEdit({
    required RecruiterEditProfileControllerField field,
    required String initialValue,
  }) async {
    final c = Get.find<RecruiterProfileController>();
    final result = await Get.toNamed(
      AppRoute.recruiterEditProfileScreen,
      arguments: {'field': field.name, 'initial': initialValue},
    );
    if (result is! Map) return;

    c.applyUpdatedProfile(
      fullName: result['fullName']?.toString(),
      email: result['email']?.toString(),
      bio: result['bio']?.toString(),
      profilePicture: result['profilePicture']?.toString(),
      coverPhoto: result['coverPhoto']?.toString(),
      companyName: result['companyName']?.toString(),
      companyType: result['companyType']?.toString(),
      designation: result['designation']?.toString(),
      faculty: result['faculty']?.toString(),
      phoneNumber: result['phoneNumber']?.toString(),
    );
  }
}
