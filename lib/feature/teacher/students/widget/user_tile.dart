import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/teacher/students/model/teacher_student_enrollment_model.dart';

class UserTile extends StatelessWidget {
  final TeacherStudentEnrollmentModel user;
  final VoidCallback onTap;
  final VoidCallback onProfileTap;

  const UserTile({
    super.key,
    required this.user,
    required this.onTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.blue.withValues(alpha: 0.10),
          backgroundImage: user.profilePicture.trim().isNotEmpty
              ? NetworkImage(user.profilePicture)
              : null,
          child: user.profilePicture.trim().isEmpty
              ? Text(
                  user.fallbackAvatarText,
                  style: getTextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                )
              : null,
        ),
        title: InkWell(
          onTap: onProfileTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              user.name,
              style: getTextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ),
        ),
        subtitle: InkWell(
          onTap: onProfileTap,
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 2),
            child: Text(
              user.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: getTextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ),
        trailing: Icon(
          user.isSelected.value
              ? Icons.radio_button_checked
              : Icons.radio_button_off,
          color: user.isSelected.value ? Colors.blue : Colors.grey.shade500,
        ),
        onTap: onTap,
      ),
    );
  }
}
