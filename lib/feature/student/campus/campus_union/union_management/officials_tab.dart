import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_union/controller/union_management_controller.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/feature/student/campus/campus_union/model/union_management_models.dart';
import 'package:msollaally/feature/student/campus/campus_union/union_management/member_tile.dart';

/// Lists union officials with demote and remove actions.
class OfficialsTab extends StatelessWidget {
  const OfficialsTab({super.key, required this.ctrl});

  final UnionManagementController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoadingOfficials.value) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 16.height),
          child: ShimmerLoading.list(
            itemCount: 3,
            height: 72.height,
            borderRadius: 12.radius,
          ),
        );
      }
      if (ctrl.officials.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 56.fontSize,
                color: Colors.grey[400],
              ),
              SizedBox(height: 12.height),
              Text(
                'No officials appointed yet',
                style: TextStyle(
                  fontSize: 16.fontSize,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.height),
              Text(
                'Promote members from the Members tab',
                style: TextStyle(fontSize: 12.fontSize, color: Colors.grey[400]),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: ctrl.fetchOfficials,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 12.height, horizontal: 16.width),
          itemCount: ctrl.officials.length,
          itemBuilder: (_, i) {
            final official = ctrl.officials[i];
            return MemberTile(
              member: official,
              actions: [_actionsMenu(context, official)],
            );
          },
        ),
      );
    });
  }

  Widget _actionsMenu(BuildContext context, UnionMemberModel official) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 20.fontSize, color: Colors.grey[600]),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'demote') ctrl.demoteToMember(official.id);
        if (value == 'transfer') {
          _confirmTransfer(context, official);
        }
        if (value == 'remove') ctrl.removeMember(official.id);
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'demote',
          child: ListTile(
            leading: Icon(Icons.arrow_downward, color: Colors.orange),
            title: Text('Demote to Member'),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'transfer',
          child: ListTile(
            leading: Icon(Icons.swap_horiz, color: Colors.purple),
            title: Text('Transfer Presidency'),
            dense: true,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'remove',
          child: ListTile(
            leading: Icon(Icons.person_remove, color: Colors.red),
            title: Text('Remove', style: TextStyle(color: Colors.red)),
            dense: true,
          ),
        ),
      ],
    );
  }

  void _confirmTransfer(BuildContext context, UnionMemberModel official) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Transfer Presidency'),
        content: Text(
          'Transfer union presidency to '
          '${official.user?.username ?? 'this official'}?\n\n'
          'You will no longer be the president.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () {
              Get.back();
              ctrl.transferPresidency(official.userId);
            },
            child: const Text(
              'Transfer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
