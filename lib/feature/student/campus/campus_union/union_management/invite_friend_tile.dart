import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/feature/student/profile/model/student_profile_friends_model.dart';

class InviteFriendTile extends StatelessWidget {
  const InviteFriendTile({
    super.key,
    required this.friend,
    required this.isSelected,
    required this.onTap,
  });

  final StudentProfileFriendsModel friend;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isNetwork = friend.imageUrl.startsWith('http');
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: 10.height),
        padding: EdgeInsets.symmetric(horizontal: 14.width, vertical: 12.height),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryButtonColor.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14.radius),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryButtonColor
                : Colors.grey.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryButtonColor.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24.radius,
                  backgroundImage: isNetwork
                      ? NetworkImage(friend.imageUrl)
                      : AssetImage(ImagesPath.onboarding1) as ImageProvider,
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 18.width,
                      height: 18.height,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryButtonColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 11.fontSize,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.width),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.name,
                    style: TextStyle(
                      fontSize: 14.fontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black1A1A2E,
                    ),
                  ),
                  if (friend.uvName.isNotEmpty) ...[
                    SizedBox(height: 2.height),
                    Text(
                      friend.uvName,
                      style: TextStyle(
                        fontSize: 12.fontSize,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (friend.mutualNumber > 0) ...[
                    SizedBox(height: 2.height),
                    Text(
                      '${friend.mutualNumber} mutual${friend.mutualNumber > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 11.fontSize,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isSelected
                  ? Icon(
                      Icons.check_circle,
                      key: const ValueKey('c'),
                      color: AppColors.primaryButtonColor,
                      size: 24.fontSize,
                    )
                  : Icon(
                      Icons.radio_button_unchecked,
                      key: const ValueKey('u'),
                      color: Colors.grey[300],
                      size: 24.fontSize,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
