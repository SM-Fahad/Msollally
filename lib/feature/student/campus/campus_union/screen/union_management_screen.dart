import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/campus/campus_union/controller/union_management_controller.dart';
import 'package:msollaally/feature/student/campus/campus_union/union_management/members_tab.dart';
import 'package:msollaally/feature/student/campus/campus_union/union_management/officials_tab.dart';
import 'package:msollaally/feature/student/campus/campus_union/union_management/pending_requests_tab.dart';
import 'package:msollaally/feature/student/campus/campus_union/union_management/stats_tab.dart';

class UnionManagementScreen extends StatelessWidget {
  const UnionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int unionId = Get.arguments as int;
    final ctrl = UnionManagementController.of(unionId);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.black0A0F24,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 18.fontSize, color: Colors.white),
            onPressed: Get.back,
          ),
          title: Obx(() {
            final name = ctrl.union.value?.name ?? 'Union Management';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: appTextStyleHeading1(
                    fontSize: 16.fontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'President Dashboard',
                  style: TextStyle(
                    fontSize: 11.fontSize,
                    color: AppColors.primaryButtonColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white, size: 20.fontSize),
              onPressed: ctrl.loadAll,
              tooltip: 'Refresh all',
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppColors.primaryButtonColor,
            unselectedLabelColor: Colors.white54,
            indicatorColor: AppColors.primaryButtonColor,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 13.fontSize, fontWeight: FontWeight.w600),
            tabs: [
              Obx(() => Tab(text: 'Members (${ctrl.members.length})')),
              Obx(() => Tab(text: 'Officials (${ctrl.officials.length})')),
              Obx(
                () => Tab(
                  text: ctrl.pendingRequests.isEmpty
                      ? 'Pending'
                      : 'Pending (${ctrl.pendingRequests.length})',
                ),
              ),
              const Tab(text: 'Stats'),
            ],
          ),
        ),
        backgroundColor: AppColors.ghostWhiteF7F8FC,
        body: TabBarView(
          children: [
            MembersTab(ctrl: ctrl),
            OfficialsTab(ctrl: ctrl),
            PendingRequestsTab(ctrl: ctrl),
            StatsTab(ctrl: ctrl),
          ],
        ),
      ),
    );
  }
}
