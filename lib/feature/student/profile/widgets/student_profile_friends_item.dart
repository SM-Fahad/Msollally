import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/images_path.dart';

import 'package:msollaally/core/common/widgets/shimmer_loading.dart';

import '../controller/student_profile_controller.dart';

class StudentProfileFriendsItems extends StatelessWidget {
  final StudentProfileController _controller;

  const StudentProfileFriendsItems({
    super.key,
    required StudentProfileController controller,
  }) : _controller = controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabs
        Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_controller.friendTabs.length, (index) {
              bool isSelected = _controller.selectedFriendTab.value == index;
              return GestureDetector(
                onTap: () => _controller.selectedFriendTab.value = index,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.width),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 6.height,
                      horizontal: 16.width,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.aliceBlueF4F8FF
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(50.radius),
                    ),
                    child: Text(
                      _controller.friendTabs[index],
                      style: appTextStyleHeading1(
                        fontSize: 14.fontSize,
                        color: isSelected
                            ? AppColors.primaryButtonColor
                            : AppColors.appBarTitleColor,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
        SizedBox(height: 16.height),
        Obx(() {
          if (_controller.isLoadingFriends.value) {
            return Padding(
              padding: EdgeInsets.all(20.radius),
              child: ShimmerLoading.list(
                itemCount: 3,
                height: 72.height,
                borderRadius: 12.radius,
              ),
            );
          }

          final currentTab = _controller.selectedFriendTab.value;
          var listToShow = currentTab == 0
              ? _controller.friends
              : (currentTab == 1
                    ? _controller.pendingRequests
                    : _controller.friendSuggestions);

          if (listToShow.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 16.height),
              child: Text(
                "No data found.",
                style: appTextStyleHeading2(fontSize: 14.fontSize),
              ),
            );
          }

          return SizedBox(
            height: 367.height,
            child: ListView.builder(
              itemCount: listToShow.length,
              itemBuilder: (_, index) {
                var items = listToShow[index];
                final isNetwork = items.imageUrl.startsWith('http');

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.width),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100.radius),
                                  child: isNetwork
                                      ? Image.network(
                                          items.imageUrl,
                                          height: 40.height,
                                          width: 40.width,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) =>
                                              Image.asset(
                                                ImagesPath.profileImageSVG,
                                                height: 40.height,
                                                width: 40.width,
                                                fit: BoxFit.cover,
                                              ),
                                        )
                                      : Image.asset(
                                          items.imageUrl,
                                          height: 40.height,
                                          width: 40.width,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                SizedBox(width: 8.width),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        items.name,
                                        style: appTextStyleHeading1(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "${items.mutualNumber} Mutuals • ${items.uvName}",
                                        style: appTextStyleHeading2(
                                          fontSize: 12.fontSize,
                                        ),
                                      ),
                                      SizedBox(height: 4.height),
                                      _buildActionButtons(currentTab, items.id),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons(int tabIndex, int userId) {
    if (tabIndex == 0) {
      // Friends
      return Row(
        children: [
          _buildOutlinedButton(
            "Remove",
            () => _controller.removeFriend(userId),
          ),
          SizedBox(width: 12.width),
          _buildFilledButton("Message", () {}),
        ],
      );
    } else if (tabIndex == 1) {
      // Pending
      return Row(
        children: [
          _buildOutlinedButton(
            "Reject",
            () => _controller.rejectFriendRequest(userId),
          ),
          SizedBox(width: 12.width),
          _buildFilledButton(
            "Accept",
            () => _controller.acceptFriendRequest(userId),
          ),
        ],
      );
    } else {
      // Suggestions
      return Row(
        children: [
          _buildFilledButton(
            "Add Friend",
            () => _controller.sendFriendRequest(userId),
          ),
        ],
      );
    }
  }

  Widget _buildOutlinedButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 32.height,
        width: 100.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.radius),
          color: Colors.white,
          border: Border.all(color: AppColors.primaryButtonColor),
        ),
        child: Center(
          child: Text(
            text,
            style: appTextStyleHeading2(
              fontWeight: FontWeight.w500,
              color: AppColors.primaryButtonColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilledButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 32.height,
        width: 100.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.radius),
          color: AppColors.primaryButtonColor,
        ),
        child: Center(
          child: Text(
            text,
            style: appTextStyleHeading2(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
