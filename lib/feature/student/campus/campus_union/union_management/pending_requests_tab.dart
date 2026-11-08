import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_union/controller/union_management_controller.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/feature/student/campus/campus_union/union_management/pending_request_card.dart';

class PendingRequestsTab extends StatelessWidget {
  const PendingRequestsTab({super.key, required this.ctrl});

  final UnionManagementController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoadingPending.value) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 16.height),
          child: ShimmerLoading.list(
            itemCount: 4,
            height: 72.height,
            borderRadius: 12.radius,
          ),
        );
      }
      if (ctrl.pendingRequests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.done_all_rounded,
                size: 56.fontSize,
                color: AppColors.mediumSeaGreen27AE60,
              ),
              SizedBox(height: 12.height),
              Text(
                'All clear!',
                style: TextStyle(
                  fontSize: 18.fontSize,
                  color: AppColors.black1A1A2E,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.height),
              Text(
                'No pending join requests',
                style: TextStyle(fontSize: 13.fontSize, color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: ctrl.fetchPendingRequests,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 12.height, horizontal: 16.width),
          itemCount: ctrl.pendingRequests.length,
          itemBuilder: (_, i) {
            final req = ctrl.pendingRequests[i];
            return PendingRequestCard(req: req, ctrl: ctrl);
          },
        ),
      );
    });
  }
}
