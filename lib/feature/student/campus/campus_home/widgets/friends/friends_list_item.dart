import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/student_campus_friends_for_you_model.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';

class FriendsListItem extends StatelessWidget {
  const FriendsListItem({super.key, required this.item});

  final StudentCampusFriendsForYouModel item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 6.height),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatar(),
                    SizedBox(width: 8.width),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildName(),
                          _buildInfo(),
                          SizedBox(height: 4.height),
                          _buildActions(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100.radius),
      child: item.imageUrl.startsWith('http')
          ? Image.network(
              item.imageUrl,
              height: 40.height,
              width: 40.width,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 40.height,
                width: 40.width,
                color: Colors.grey[200],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
            )
          : item.imageUrl.isNotEmpty
          ? Image.asset(
              item.imageUrl,
              height: 40.height,
              width: 40.width,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 40.height,
                width: 40.width,
                color: Colors.grey[200],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
            )
          : Container(
              height: 40.height,
              width: 40.width,
              color: Colors.grey[200],
              child: const Icon(Icons.person, color: Colors.grey),
            ),
    );
  }

  Widget _buildName() {
    return InkWell(
      onTap: () {
        Get.toNamed(AppRoute.studentCampusPublicProfile, arguments: item.id);
      },
      child: Text(
        item.name,
        style: appTextStyleHeading1(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInfo() {
    return Text(
      "${item.mutualNumber} Mutuals • ${item.uvName}",
      style: appTextStyleHeading2(fontSize: 12.fontSize),
    );
  }

  Widget _buildActions() {
    final controller = Get.find<StudentCampusController>();
    final isRequestsTab = controller.selectStudentFriendsTab.value == 2;

    if (isRequestsTab) {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              text: "Reject",
              onTap: () => controller.rejectFriendRequest(item.id),
              isPrimary: false,
            ),
          ),
          SizedBox(width: 12.width),
          Expanded(
            child: _buildActionButton(
              text: "Accept",
              onTap: () => controller.acceptFriendRequest(item.id),
              isPrimary: true,
            ),
          ),
        ],
      );
    }

    return Obx(() {
      final isAdded = controller.requestedUserIds.contains(item.id);

      return Row(
        children: [
          if (!isAdded)
            Expanded(
              child: _buildActionButton(
                text: "Ignore",
                onTap: () => controller.ignoreFriendSuggestion(item.id),
                isPrimary: false,
              ),
            ),
          if (!isAdded) SizedBox(width: 12.width),
          Expanded(
            child: _buildActionButton(
              text: isAdded ? "Added" : "Add",
              onTap: isAdded
                  ? () {}
                  : () => controller.sendFriendRequest(item.id),
              isPrimary: !isAdded,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 32.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.radius),
          color: isPrimary ? AppColors.primaryButtonColor : Colors.white,
          border: isPrimary ? null : Border.all(color: AppColors.primaryButtonColor),
        ),
        child: Center(
          child: Text(
            text,
            style: appTextStyleHeading2(
              fontWeight: FontWeight.w500,
              color: isPrimary ? Colors.white : AppColors.primaryButtonColor,
            ),
          ),
        ),
      ),
    );
  }
}
