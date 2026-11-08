
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';
import '../controller/student_settings_edit_profile_controller.dart';

class StudentSettingsEditProfileScreen extends StatelessWidget {
  const StudentSettingsEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(StudentSettingsEditProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(top: 10.height),
                child: CustomAppBar(
                  leadingIcon: const Icon(Icons.arrow_back, size: 24),
                  onLeadingTap: () => Get.back(),
                  title: "Edit Profile",
                ),
              ),
            ),

            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryButtonColor,
                    ),
                  );
                }
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // ── Photo header ─────────────────────────────────────
                      _PhotoHeader(c: c),

                      // Avatar hangs down 44px, so we add 44 + 20 to keep 20px spacing
                      SizedBox(height: 64.height),

                      // ── Section Cards ─────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.width),
                        child: Column(
                          children: [
                            _SectionCard(
                              icon: Icons.person_outline_rounded,
                              title: 'Personal Information',
                              color: const Color(0xFF418AFF),
                              children: [
                                _FieldTile(
                                  label: 'Full Name',
                                  controller: c.fullNameController,
                                  icon: Icons.badge_outlined,
                                  hint: 'e.g. John Doe',
                                ),
                                _FieldTile(
                                  label: 'Email',
                                  controller: c.emailController,
                                  icon: Icons.email_outlined,
                                  hint: 'e.g. john@email.com',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                _GenderTile(c: c),
                                _DateTile(c: c, context: context),
                                _FieldTile(
                                  label: 'Bio',
                                  controller: c.bioController,
                                  icon: Icons.notes_rounded,
                                  hint: 'Tell us about yourself…',
                                  maxLines: 3,
                                ),
                                _FieldTile(
                                  label: 'Cell Phone Number',
                                  controller: c.cellPhoneNumberController,
                                  icon: Icons.phone_outlined,
                                  hint: '+880XXXXXXXXX',
                                  keyboardType: TextInputType.phone,
                                ),
                                _FieldTile(
                                  label: 'Designation',
                                  controller: c.designationController,
                                  icon: Icons.work_outline_rounded,
                                  hint: 'e.g. Lecturer',
                                ),
                              ],
                            ),
                            SizedBox(height: 16.height),

                            _SectionCard(
                              icon: Icons.school_outlined,
                              title: 'Academic Information',
                              color: const Color(0xFF7C3AED),
                              children: [
                                _FieldTile(
                                  label: 'Faculty',
                                  controller: c.facultyController,
                                  icon: Icons.account_balance_outlined,
                                  hint: 'e.g. Natural Sciences',
                                ),
                                _FieldTile(
                                  label: 'Program',
                                  controller: c.programController,
                                  icon: Icons.menu_book_outlined,
                                  hint: 'e.g. Computer Science',
                                ),
                                _FieldTile(
                                  label: 'Student ID',
                                  controller: c.studentIdController,
                                  icon: Icons.card_membership_outlined,
                                  hint: 'e.g. ST12345',
                                ),
                                _FieldTile(
                                  label: 'Enrollment Year',
                                  controller: c.enrollmentYearController,
                                  icon: Icons.calendar_today_outlined,
                                  hint: 'e.g. 2022',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                ),
                                _UniversityTile(c: c),
                                _ProgramTile(c: c),
                                _DepartmentTile(c: c),
                              ],
                            ),
                            SizedBox(height: 16.height),


                            // ── Save Button ──────────────────────────────────
                            Obx(
                              () => _SaveButton(
                                isSaving: c.isSaving.value,
                                onTap: c.updateProfile,
                              ),
                            ),
                            SizedBox(height: 32.height),
                          ],
                        ),
                      ),
                    ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Photo Header
// ─────────────────────────────────────────────────────────────────────────────
class _PhotoHeader extends StatelessWidget {
  final StudentSettingsEditProfileController c;
  const _PhotoHeader({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Cover photo
          GestureDetector(
            onTap: c.pickCoverImage,
            child: Container(
              height: 160.height,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF418AFF), Color(0xFF7C3AED)],
                ),
              ),
              child: _buildCoverImage(c),
            ),
          ),

          // Edit cover badge
          Positioned(
            top: 12,
            right: 16,
            child: GestureDetector(
              onTap: c.pickCoverImage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Edit Cover',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Profile avatar
          Positioned(
            bottom: -44,
            child: GestureDetector(
              onTap: c.pickProfileImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(child: _buildAvatarImage(c)),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryButtonColor,
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCoverImage(StudentSettingsEditProfileController c) {
    if (c.coverImageFile.value != null) {
      return Image.file(c.coverImageFile.value!,
          fit: BoxFit.cover, width: double.infinity);
    }
    if (c.coverImageUrl.value.isNotEmpty) {
      return Image.network(
        c.coverImageUrl.value,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => const _CoverPlaceholder(),
      );
    }
    return const _CoverPlaceholder();
  }

  Widget _buildAvatarImage(StudentSettingsEditProfileController c) {
    if (c.profileImageFile.value != null) {
      return Image.file(c.profileImageFile.value!,
          fit: BoxFit.cover, width: 90, height: 90);
    }
    if (c.profileImageUrl.value.isNotEmpty) {
      return Image.network(
        c.profileImageUrl.value,
        fit: BoxFit.cover,
        width: 90,
        height: 90,
        errorBuilder: (_, __, ___) => const _AvatarPlaceholder(),
      );
    }
    return const _AvatarPlaceholder();
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: Colors.white.withValues(alpha: 0.8), size: 32),
            const SizedBox(height: 4),
            Text(
              'Tap to add cover photo',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Icon(Icons.person, color: Color(0xFF9CA3AF), size: 44),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Card
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryTextColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

          // Fields
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Field Tile
// ─────────────────────────────────────────────────────────────────────────────
class _FieldTile extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  const _FieldTile({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.secondaryTextColor),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryTextColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primaryTextColor,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryTextColor.withValues(alpha: 0.6),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primaryButtonColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gender Dropdown Tile
// ─────────────────────────────────────────────────────────────────────────────
class _GenderTile extends StatelessWidget {
  final StudentSettingsEditProfileController c;
  const _GenderTile({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wc_outlined,
                  size: 14, color: AppColors.secondaryTextColor),
              SizedBox(width: 5),
              Text(
                'Gender',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryTextColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButton<String>(
                value: c.selectedGender.value.isNotEmpty
                    ? c.selectedGender.value
                    : null,
                hint: Text(
                  'Select gender',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryTextColor.withValues(alpha: 0.6),
                  ),
                ),
                isExpanded: true,
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.secondaryTextColor),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
                items: c.genderOptions
                    .map(
                      (g) => DropdownMenuItem<String>(
                        value: g,
                        child: Text(g),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  c.selectedGender.value = val ?? '';
                  c.genderController.text = val ?? '';
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// University Dropdown Tile
// ─────────────────────────────────────────────────────────────────────────────
class _UniversityTile extends StatelessWidget {
  final StudentSettingsEditProfileController c;
  const _UniversityTile({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_city_outlined,
                  size: 14, color: AppColors.secondaryTextColor),
              SizedBox(width: 5),
              Text(
                'University',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryTextColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Obx(
            () {
              if (c.universities.isEmpty) {
                return _buildLoadingDropdown('Loading universities...');
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButton<int>(
                  value: c.selectedUniversityId.value,
                  hint: Text(
                    'Select University',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryTextColor.withValues(alpha: 0.6),
                    ),
                  ),
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.secondaryTextColor),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                  items: c.universities.map((u) {
                    return DropdownMenuItem<int>(
                      value: u['id'],
                      child: Text(u['name']?.toString() ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null && val != c.selectedUniversityId.value) {
                      c.selectedUniversityId.value = val;
                      c.fetchPrograms(val);
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Program Dropdown Tile
// ─────────────────────────────────────────────────────────────────────────────
class _ProgramTile extends StatelessWidget {
  final StudentSettingsEditProfileController c;
  const _ProgramTile({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.format_list_numbered_rounded,
                  size: 14, color: AppColors.secondaryTextColor),
              SizedBox(width: 5),
              Text(
                'Program',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryTextColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Obx(
            () {
              if (c.selectedUniversityId.value == null) {
                return _buildDisabledDropdown('Select university first');
              }
              if (c.programs.isEmpty) {
                return _buildLoadingDropdown('No programs available');
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButton<int>(
                  value: c.selectedProgramId.value,
                  hint: Text(
                    'Select Program',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryTextColor.withValues(alpha: 0.6),
                    ),
                  ),
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.secondaryTextColor),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                  items: c.programs.map((p) {
                    return DropdownMenuItem<int>(
                      value: p['id'],
                      child: Text(p['name']?.toString() ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null && val != c.selectedProgramId.value) {
                      c.selectedProgramId.value = val;
                      c.fetchDepartments(val);
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Department Dropdown Tile
// ─────────────────────────────────────────────────────────────────────────────
class _DepartmentTile extends StatelessWidget {
  final StudentSettingsEditProfileController c;
  const _DepartmentTile({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.category_outlined,
                  size: 14, color: AppColors.secondaryTextColor),
              SizedBox(width: 5),
              Text(
                'Department',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryTextColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Obx(
            () {
              if (c.selectedProgramId.value == null) {
                return _buildDisabledDropdown('Select program first');
              }
              if (c.departments.isEmpty) {
                return _buildLoadingDropdown('No departments available');
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButton<int>(
                  value: c.selectedDepartmentId.value,
                  hint: Text(
                    'Select Department',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryTextColor.withValues(alpha: 0.6),
                    ),
                  ),
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.secondaryTextColor),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                  items: c.departments.map((d) {
                    return DropdownMenuItem<int>(
                      value: d['id'],
                      child: Text(d['name']?.toString() ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      c.selectedDepartmentId.value = val;
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _buildLoadingDropdown(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.secondaryTextColor.withValues(alpha: 0.6),
          ),
        ),
        const Icon(Icons.keyboard_arrow_down_rounded,
            color: AppColors.secondaryTextColor),
      ],
    ),
  );
}

Widget _buildDisabledDropdown(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.secondaryTextColor.withValues(alpha: 0.5),
          ),
        ),
        Icon(Icons.keyboard_arrow_down_rounded,
            color: AppColors.secondaryTextColor.withValues(alpha: 0.5)),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Date of Birth Tile
// ─────────────────────────────────────────────────────────────────────────────
class _DateTile extends StatelessWidget {
  final StudentSettingsEditProfileController c;
  final BuildContext context;
  const _DateTile({required this.c, required this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cake_outlined,
                  size: 14, color: AppColors.secondaryTextColor),
              SizedBox(width: 5),
              Text(
                'Date of Birth',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryTextColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => c.selectDate(context),
            child: AbsorbPointer(
              child: TextField(
                controller: c.dateOfBirthController,
                readOnly: true,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryTextColor.withValues(alpha: 0.6),
                  ),
                  suffixIcon: const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.secondaryTextColor,
                    size: 18,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primaryButtonColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Save Button
// ─────────────────────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onTap;
  const _SaveButton({required this.isSaving, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSaving ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isSaving
              ? const LinearGradient(
                  colors: [Color(0xFFBDCCE8), Color(0xFFBDCCE8)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF418AFF), Color(0xFF6B5DFC)],
                ),
          boxShadow: isSaving
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF418AFF).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
