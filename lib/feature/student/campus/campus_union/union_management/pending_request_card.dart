import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/feature/student/campus/campus_union/controller/union_management_controller.dart';
import 'package:msollaally/feature/student/campus/campus_union/model/union_management_models.dart';

class PendingRequestCard extends StatelessWidget {
  const PendingRequestCard({super.key, required this.req, required this.ctrl});

  final UnionMemberModel req;
  final UnionManagementController ctrl;

  @override
  Widget build(BuildContext context) {
    final user = req.user;
    final name = user?.username ?? 'User #${req.userId}';
    final avatar = user?.profilePicture;

    return Container(
      margin: EdgeInsets.only(bottom: 12.height),
      padding: EdgeInsets.all(14.width),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.orangeFFA726.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.radius,
            backgroundImage: avatar != null && avatar.isNotEmpty
                ? NetworkImage(avatar)
                : AssetImage(ImagesPath.profilePNG) as ImageProvider,
          ),
          SizedBox(width: 12.width),
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
                SizedBox(height: 2.height),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.width, vertical: 2.height),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.radius),
                  ),
                  child: Text(
                    'PENDING',
                    style: TextStyle(
                      fontSize: 10.fontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange[700],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (req.bio != null && req.bio!.isNotEmpty) ...[
                  SizedBox(height: 4.height),
                  Text(
                    '"${req.bio}"',
                    style: TextStyle(
                      fontSize: 11.fontSize,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: () => ctrl.approveRequest(req.id),
            borderRadius: BorderRadius.circular(8.radius),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.width, vertical: 8.height),
              decoration: BoxDecoration(
                color: AppColors.mediumSeaGreen27AE60,
                borderRadius: BorderRadius.circular(8.radius),
              ),
              child: Text(
                'Approve',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.width),
          InkWell(
            onTap: () => _confirmReject(context),
            borderRadius: BorderRadius.circular(8.radius),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.width, vertical: 8.height),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8.radius),
                border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Reject',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 12.fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReject(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Request'),
        content: Text(
          'Reject ${req.user?.username ?? 'this user'}\'s request to join?',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              ctrl.rejectRequest(req.id);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
