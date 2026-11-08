import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/feature/student/campus/campus_union/model/union_management_models.dart';

/// Reusable tile shown in members, officials, and pending tabs.
class MemberTile extends StatelessWidget {
  const MemberTile({
    super.key,
    required this.member,
    this.actions = const [],
    this.subtitle,
  });

  final UnionMemberModel member;
  final List<Widget> actions;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    final user = member.user;
    final name = user?.username ?? 'User #${member.userId}';
    final avatar = user?.profilePicture;
    final roleColor = _roleColor(member.role);

    return Container(
      margin: EdgeInsets.only(bottom: 10.height),
      padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 10.height),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22.radius,
            backgroundImage: avatar != null && avatar.isNotEmpty
                ? NetworkImage(avatar)
                : AssetImage(ImagesPath.profilePNG) as ImageProvider,
          ),
          SizedBox(width: 12.width),
          // Name & role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.fontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black1A1A2E,
                  ),
                ),
                SizedBox(height: 3.height),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.width,
                        vertical: 2.height,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.radius),
                      ),
                      child: Text(
                        (member.role.capitalizeFirst ?? member.role)
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.fontSize,
                          fontWeight: FontWeight.w700,
                          color: roleColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (member.position != null &&
                        member.position!.isNotEmpty) ...[
                      SizedBox(width: 6.width),
                      Flexible(
                        child: Text(
                          member.position!,
                          style: TextStyle(
                            fontSize: 11.fontSize,
                            color: Colors.grey[500],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null) ...[SizedBox(height: 4.height), subtitle!],
              ],
            ),
          ),
          // Action widgets (popup menu, buttons, etc.)
          ...actions,
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'president':
        return AppColors.sandyBrownF4B942;
      case 'official':
        return AppColors.primaryButtonColor;
      case 'member':
        return AppColors.mediumSeaGreen27AE60;
      default:
        return Colors.grey;
    }
  }
}
