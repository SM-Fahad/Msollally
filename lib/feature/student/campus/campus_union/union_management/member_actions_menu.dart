import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_union/controller/union_management_controller.dart';
import 'package:msollaally/feature/student/campus/campus_union/model/union_management_models.dart';

class MemberActionsMenu extends StatelessWidget {
  const MemberActionsMenu({
    super.key,
    required this.member,
    required this.ctrl,
  });

  final UnionMemberModel member;
  final UnionManagementController ctrl;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 20.fontSize, color: Colors.grey[600]),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => _handleAction(context, value),
      itemBuilder: (_) => [
        if (member.role == UnionManagementController.roleMember)
          const PopupMenuItem(
            value: 'promote',
            child: ListTile(
              leading: Icon(Icons.arrow_upward, color: AppColors.primaryButtonColor),
              title: Text('Promote to Official'),
              dense: true,
            ),
          ),
        if (member.role == UnionManagementController.roleOfficial) ...[
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
        ],
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'remove',
          child: ListTile(
            leading: Icon(Icons.person_remove, color: Colors.red),
            title: Text('Remove Member', style: TextStyle(color: Colors.red)),
            dense: true,
          ),
        ),
      ],
    );
  }

  void _handleAction(BuildContext context, String value) {
    switch (value) {
      case 'promote':
        ctrl.promoteToOfficial(member.id);
        break;
      case 'demote':
        ctrl.demoteToMember(member.id);
        break;
      case 'transfer':
        _confirmTransfer(context);
        break;
      case 'remove':
        _confirmRemove(context);
        break;
    }
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Member'),
        content: Text(
          'Are you sure you want to remove '
          '${member.user?.username ?? 'this member'} from the union?',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              ctrl.removeMember(member.id);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmTransfer(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Transfer Presidency'),
        content: Text(
          'Transfer union presidency to '
          '${member.user?.username ?? 'this member'}?\n\n'
          'You will no longer be the president.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () {
              Get.back();
              ctrl.transferPresidency(member.userId);
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
