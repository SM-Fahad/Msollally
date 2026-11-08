import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_union/controller/union_management_controller.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/feature/student/campus/campus_union/union_management/member_actions_menu.dart';
import 'package:msollaally/feature/student/campus/campus_union/union_management/member_tile.dart';

class MembersTab extends StatelessWidget {
  const MembersTab({super.key, required this.ctrl});

  final UnionManagementController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoadingMembers.value) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 16.height),
          child: ShimmerLoading.list(
            itemCount: 5,
            height: 72.height,
            borderRadius: 12.radius,
          ),
        );
      }
      if (ctrl.members.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_off_outlined,
                size: 56.fontSize,
                color: Colors.grey[400],
              ),
              SizedBox(height: 12.height),
              Text(
                'No members yet',
                style: TextStyle(
                  fontSize: 16.fontSize,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: ctrl.fetchMembers,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 12.height, horizontal: 16.width),
          itemCount: ctrl.members.length,
          itemBuilder: (_, i) {
            final member = ctrl.members[i];
            return MemberTile(
              member: member,
              actions: [MemberActionsMenu(member: member, ctrl: ctrl)],
            );
          },
        ),
      );
    });
  }
}
