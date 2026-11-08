import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/union_model.dart';
import 'package:msollaally/feature/student/campus/campus_union/controller/campus_union_controller.dart';
import 'package:msollaally/routes/app_route.dart';

class UnionDetailHeader extends StatelessWidget {
  const UnionDetailHeader({super.key, required this.union});

  final UnionModel union;

  bool get _isPresident => union.userMembership?.role == 'president';

  bool get _isMember => union.userMembership != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCoverImage(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 10.height),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              _buildVisibilityInfo(),
              SizedBox(height: 8.height),
              _buildStatusBadge(),
              SizedBox(height: 20.height),
              _buildActionButtons(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoverImage() {
    return Stack(
      children: [
        union.coverImageUrl != null && union.coverImageUrl!.isNotEmpty
            ? Image.network(
                union.coverImageUrl!,
                width: double.infinity,
                height: 200.height,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset(ImagesPath.chessClubImage, fit: BoxFit.cover),
              )
            : Image.asset(
                ImagesPath.chessClubImage,
                width: double.infinity,
                height: 200.height,
                fit: BoxFit.cover,
              ),
        if (_isPresident)
          Positioned(
            right: 16.width,
            bottom: 16.height,
            child: GestureDetector(
              onTap: () => Get.find<CampusUnionController>().pickCoverImage(),
              child: Container(
                padding: EdgeInsets.all(8.width),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt, color: Colors.white, size: 20.fontSize),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            union.name,
            style: appTextStyleHeading1(
              fontSize: 20.fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5.fontSize,
            ),
          ),
        ),
        if (_isPresident)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.width, vertical: 4.height),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.sandyBrownF4B942, AppColors.chocolateE67E22],
              ),
              borderRadius: BorderRadius.circular(20.radius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 12.fontSize, color: Colors.white),
                SizedBox(width: 4.width),
                Text(
                  'PRESIDENT',
                  style: TextStyle(
                    fontSize: 10.fontSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVisibilityInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.public, size: 13.fontSize, color: Colors.grey),
        SizedBox(width: 5.width),
        Text(
          "${union.isPublic ? 'Public' : 'Private'} union • ${union.memberCount} members",
          style: appTextStyleHeading1(
            fontSize: 15.fontSize,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 4.height),
      decoration: BoxDecoration(
        color: _getStatusColor(union.status).withValues(alpha: .1),
        borderRadius: BorderRadius.circular(6.radius),
      ),
      child: Text(
        "Status: ${(union.status.replaceAll('_', ' ').capitalizeFirst) ?? union.status}",
        style: TextStyle(
          color: _getStatusColor(union.status),
          fontSize: 13.fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // President sees: [Manage Union] [Invite]
    if (_isPresident) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              vertical: 10.height,
              text: '⚙ Manage Union',
              onPressed: () => Get.toNamed(
                AppRoute.unionManagementScreen,
                arguments: union.id,
              ),
            ),
          ),
          SizedBox(width: 10.width),
          Expanded(
            child: CustomButton(
              vertical: 10.height,
              color: AppColors.appBarTitleColor.withValues(alpha: 0.3),
              text: 'Invite',
              onPressed: () => Get.toNamed(
                AppRoute.inviteFriendsScreen,
                arguments: union.id,
              ),
            ),
          ),
        ],
      );
    }

    // Already a member (non-president) sees: [Joined ✓] [Leave]
    if (_isMember) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              vertical: 10.height,
              color: AppColors.appBarTitleColor.withValues(alpha: 0.36),
              text: 'Joined (${union.userMembership!.role.capitalizeFirst})',
              onPressed: null,
            ),
          ),
          SizedBox(width: 10.width),
          Expanded(
            child: CustomButton(
              vertical: 10.height,
              color: Colors.red.withValues(alpha: 0.8),
              text: 'Leave',
              onPressed: () => _confirmLeave(context),
            ),
          ),
        ],
      );
    }

    return CustomButton(
      vertical: 10.height,
      text: union.allowJoinRequests ? 'Join Union' : 'Request to Join',
      onPressed: () => _handleJoin(),
    );
  }

  void _handleJoin() {
    final ctrl = Get.find<CampusUnionController>();
    ctrl.joinUnion();
  }

  void _confirmLeave(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Leave Union'),
        content: Text('Are you sure you want to leave ${union.name}?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              final ctrl = Get.find<CampusUnionController>();
              ctrl.leaveUnion();
            },
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending_approval':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
