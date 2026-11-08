import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/campus/campus_union/controller/invite_friends_controller.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/feature/student/campus/campus_union/union_management/invite_friend_tile.dart';

class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      InviteFriendsController(unionId: Get.arguments as int),
    );
    return Obx(() {
      final allSelected =
          ctrl.filtered.isNotEmpty &&
          ctrl.selected.length == ctrl.filtered.length;
      return Scaffold(
        backgroundColor: AppColors.ghostWhiteF7F8FC,
        appBar: AppBar(
          backgroundColor: AppColors.black0A0F24,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 18.fontSize, color: Colors.white),
            onPressed: Get.back,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invite Friends',
                style: appTextStyleHeading1(
                  fontSize: 16.fontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '${ctrl.selected.length} selected',
                style: TextStyle(
                  fontSize: 11.fontSize,
                  color: AppColors.primaryButtonColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            if (!ctrl.isLoading.value && ctrl.filtered.isNotEmpty)
              TextButton(
                onPressed: ctrl.selectAll,
                child: Text(
                  allSelected ? 'Deselect All' : 'Select All',
                  style: TextStyle(
                    color: AppColors.primaryButtonColor,
                    fontSize: 13.fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            _InviteSearchBar(onChanged: ctrl.onSearch),
            Expanded(
              child: ctrl.isLoading.value
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.width,
                        vertical: 8.height,
                      ),
                      child: ShimmerLoading.list(
                        itemCount: 5,
                        height: 72.height,
                        borderRadius: 12.radius,
                      ),
                    )
                  : ctrl.filtered.isEmpty
                  ? _InviteEmptyState(query: ctrl.query.value)
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.height,
                        horizontal: 16.width,
                      ),
                      itemCount: ctrl.filtered.length,
                      itemBuilder: (_, i) {
                        final f = ctrl.filtered[i];
                        return InviteFriendTile(
                          friend: f,
                          isSelected: ctrl.selected.contains(f.id),
                          onTap: () => ctrl.toggleSelect(f.id),
                        );
                      },
                    ),
            ),
            _InviteBottomBar(
              selected: ctrl.selected.length,
              isSending: ctrl.isSending.value,
              onInvite: ctrl.sendInvites,
            ),
          ],
        ),
      );
    });
  }
}

class _InviteSearchBar extends StatelessWidget {
  const _InviteSearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 12.height),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search friends...',
          hintStyle: TextStyle(fontSize: 14.fontSize, color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20.fontSize),
          filled: true,
          fillColor: AppColors.tagBackgroundColor,
          contentPadding: EdgeInsets.symmetric(vertical: 10.height),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.radius),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _InviteEmptyState extends StatelessWidget {
  const _InviteEmptyState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 56.fontSize, color: Colors.grey[300]),
          SizedBox(height: 12.height),
          Text(
            query.isEmpty ? 'No friends yet' : 'No results for "$query"',
            style: TextStyle(
              fontSize: 16.fontSize,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (query.isEmpty) ...[
            SizedBox(height: 6.height),
            Text(
              'Add friends to invite them to your union',
              style: TextStyle(fontSize: 12.fontSize, color: Colors.grey[400]),
            ),
          ],
        ],
      ),
    );
  }
}

class _InviteBottomBar extends StatelessWidget {
  const _InviteBottomBar({
    required this.selected,
    required this.isSending,
    required this.onInvite,
  });
  final int selected;
  final bool isSending;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.width, 12.height, 20.width, 24.height),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selected == 0
                ? Colors.grey[300]
                : AppColors.primaryButtonColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.radius),
            ),
            elevation: selected == 0 ? 0 : 3,
          ),
          onPressed: isSending || selected == 0 ? null : onInvite,
          child: isSending
              ? SizedBox(
                  height: 20.height,
                  width: 20.height,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  selected == 0
                      ? 'Select friends to invite'
                      : 'Invite $selected Friend${selected > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 15.fontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }
}
