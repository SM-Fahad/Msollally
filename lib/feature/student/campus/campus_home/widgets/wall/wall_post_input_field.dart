import 'dart:io';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';

class WallPostInputField extends StatelessWidget {
  const WallPostInputField({super.key, required this.controller});

  final StudentCampusController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.width, vertical: 12.height),
      padding: EdgeInsets.all(16.width),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileImage(),
              SizedBox(width: 12.width),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildTextField(), _buildSelectedImagePreview()],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.height),
          Container(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
          SizedBox(height: 12.height),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildImagePickerButton(), _buildSendButton()],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Obx(() {
      final profileController = Get.find<StudentProfileController>();
      final profilePic = profileController.profileImageUrl.value;
      return ClipRRect(
        borderRadius: BorderRadius.circular(100.radius),
        child: profilePic.isNotEmpty
            ? Image.network(
                profilePic,
                height: 44.height,
                width: 44.width,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildProfileFallback(),
              )
            : _buildProfileFallback(),
      );
    });
  }

  Widget _buildProfileFallback() {
    return Container(
      height: 44.height,
      width: 44.width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Colors.grey.shade400,
        size: 28,
      ),
    );
  }

  Widget _buildTextField() {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 44.height, maxHeight: 120.height),
      child: TextFormField(
        controller: controller.postTextEditingController,
        onChanged: (value) => controller.update(),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          isDense: true,
          hintText: "What’s on your mind?",
          hintStyle: TextStyle(
            fontSize: 15.fontSize,
            fontWeight: FontWeight.w400,
            color: AppColors.appBarTitleColor.withValues(alpha: 0.4),
            letterSpacing: 0.2.fontSize,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerButton() {
    return InkWell(
      onTap: () => controller.pickImage(),
      borderRadius: BorderRadius.circular(8.radius),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.width, vertical: 4.height),
        child: Row(
          children: [
            const Icon(Icons.image_outlined, size: 24, color: Colors.green),
            SizedBox(width: 8.width),
            Text(
              "Photo",
              style: TextStyle(
                fontSize: 14.fontSize,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Obx(() {
      final hasContent =
          controller.selectedImagePath.value.isNotEmpty ||
          controller.postTextEditingController.text.trim().isNotEmpty;

      return InkWell(
        onTap: hasContent ? () => controller.createPost() : null,
        borderRadius: BorderRadius.circular(20.radius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.width,
            vertical: 8.height,
          ),
          decoration: BoxDecoration(
            color: hasContent ? Colors.blue : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20.radius),
          ),
          child: Text(
            "Post",
            style: TextStyle(
              fontSize: 14.fontSize,
              fontWeight: FontWeight.w600,
              color: hasContent ? Colors.white : Colors.grey.shade500,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSelectedImagePreview() {
    return Obx(() {
      if (controller.selectedImagePath.value.isEmpty) return const SizedBox();
      return Padding(
        padding: EdgeInsets.only(top: 12.height),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.radius),
              child: Image.file(
                File(controller.selectedImagePath.value),
                height: 180.height,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: InkWell(
                onTap: () => controller.removeSelectedImage(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
