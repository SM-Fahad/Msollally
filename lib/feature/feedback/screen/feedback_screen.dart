import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/feedback/controller/feedback_controller.dart';
import 'package:msollaally/feature/feedback/screen/add_edit_feedback_screen.dart';
import 'package:msollaally/feature/feedback/screen/feedback_detail_screen.dart';
import 'package:msollaally/core/widgets/global_app_bar.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/utils/responsive.dart';

import '../model/feedback_model.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FeedbackController controller = Get.put(FeedbackController());
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchFeedbacks(refresh: true);
    });
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && !controller.isLoading.value) {
        controller.fetchFeedbacks(refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ghostWhiteF5F7FB,
      appBar: GlobalAppBar(
        title: 'Feedback',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: AppColors.darkSlateGray1F2937),
            onPressed: () => controller.fetchFeedbacks(refresh: true),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.to(() => AddEditFeedbackScreen());
          controller.fetchFeedbacks(refresh: true);
        },
        backgroundColor: AppColors.primaryButtonColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Submit Feedback',
          style: appTextStyleHeading1(
            fontSize: 14.fontSize,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryButtonColor,
                    strokeWidth: 2.5,
                  ),
                );
              }
              if (controller.feedbacks.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.primaryButtonColor,
                  onRefresh: () => controller.fetchFeedbacks(refresh: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.65,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(24.width),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.inbox_rounded,
                              size: 56.fontSize,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          SizedBox(height: 20.height),
                          Text(
                            "No feedback yet",
                            style: appTextStyleHeading1(
                              fontSize: 18.fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 8.height),
                          Text(
                            "Pull down to refresh or tap below to share your thoughts",
                            style: appTextStyleHeading1(
                              fontSize: 14.fontSize,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.primaryButtonColor,
                onRefresh: () => controller.fetchFeedbacks(refresh: true),
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.fromLTRB(16.width, 16.height, 16.width, 100.height),
                  itemCount:
                      controller.feedbacks.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.feedbacks.length) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.width),
                          child: CircularProgressIndicator(
                            color: AppColors.primaryButtonColor,
                            strokeWidth: 2.5,
                          ),
                        ),
                      );
                    }
                    final feedback = controller.feedbacks[index];
                    return _buildFeedbackCard(feedback);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 14.height),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              icon: Icons.category_outlined,
              label: "Category",
              value: controller.selectedCategory,
              items: controller.categories,
              onChanged: (val) {
                if (val != null) controller.updateCategoryFilter(val);
              },
            ),
            SizedBox(width: 12.width),
            _buildFilterChip(
              icon: Icons.tune_rounded,
              label: "Status",
              value: controller.selectedStatus,
              items: controller.statuses,
              onChanged: (val) {
                if (val != null) controller.updateStatusFilter(val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required RxString value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Obx(() {
      final isActive = value.value != 'all';
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.width, vertical: 8.height),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryButtonColor.withValues(alpha: 0.08)
              : AppColors.ghostWhiteF5F7FB,
          borderRadius: BorderRadius.circular(24.radius),
          border: Border.all(
            color: isActive ? AppColors.primaryButtonColor : AppColors.lavenderE6EBF2,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.fontSize,
              color: isActive ? AppColors.primaryButtonColor : Colors.grey.shade600,
            ),
            SizedBox(width: 6.width),
            Text(
              "$label: ",
              style: appTextStyleHeading1(
                fontSize: 13.fontSize,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value.value,
                isDense: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isActive ? AppColors.primaryButtonColor : Colors.grey.shade600,
                  size: 18.fontSize,
                ),
                style: appTextStyleHeading1(
                  fontSize: 13.fontSize,
                  color: isActive ? AppColors.primaryButtonColor : AppColors.black1F1F1F,
                  fontWeight: FontWeight.w600,
                ),
                items: items
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.replaceAll('_', ' ').capitalizeFirst ?? c),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFeedbackCard(FeedbackModel feedback) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.height),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.radius),
          onTap: () async {
            if (feedback.id != null) {
              await Get.to(() => FeedbackDetailScreen(feedbackId: feedback.id!));
              controller.fetchFeedbacks(refresh: true);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(20.width),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title + status row ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (feedback.title != null && feedback.title!.isNotEmpty)
                      Expanded(
                        child: Text(
                          feedback.title!,
                          style: appTextStyleHeading1(
                            fontSize: 17.fontSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black1F1F1F,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    SizedBox(width: 12.width),
                    if (feedback.status != null && feedback.status!.isNotEmpty)
                      _buildStatusBadge(feedback.status!),
                    if (feedback.status == 'pending') ...[
                      SizedBox(width: 4.width),
                      _buildActionMenu(feedback),
                    ],
                  ],
                ),

                // ── Description ──
                if (feedback.description != null && feedback.description!.isNotEmpty) ...[
                  SizedBox(height: 10.height),
                  Text(
                    feedback.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: appTextStyleHeading1(
                      fontSize: 14.fontSize,
                      color: Colors.grey.shade600,
                    ).copyWith(height: 1.45),
                  ),
                ],

                // ── Category tag ──
                if (feedback.category != null && feedback.category!.isNotEmpty) ...[
                  SizedBox(height: 14.height),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.width, vertical: 5.height),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF4FF),
                          borderRadius: BorderRadius.circular(20.radius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.label_rounded, size: 13.fontSize, color: AppColors.primaryButtonColor),
                            SizedBox(width: 5.width),
                            Text(
                              feedback.category!.capitalizeFirst ?? '',
                              style: appTextStyleHeading1(
                                fontSize: 12.fontSize,
                                color: AppColors.primaryButtonColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                // ── Admin Reply ──
                if (feedback.adminReply != null && feedback.adminReply!.isNotEmpty) ...[
                  SizedBox(height: 14.height),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14.width, vertical: 12.height),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade50,
                          Colors.teal.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.radius),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4.width),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.support_agent_rounded,
                                size: 12.fontSize,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8.width),
                            Text(
                              "Admin Reply",
                              style: appTextStyleHeading1(
                                fontSize: 12.fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.height),
                        Text(
                          feedback.adminReply!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: appTextStyleHeading1(
                            fontSize: 13.fontSize,
                            color: Colors.green.shade900,
                          ).copyWith(height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── "View details" hint ──
                SizedBox(height: 14.height),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "View details",
                      style: appTextStyleHeading1(
                        fontSize: 12.fontSize,
                        color: AppColors.primaryButtonColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4.width),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14.fontSize,
                      color: AppColors.primaryButtonColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu(FeedbackModel feedback) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade500, size: 20.fontSize),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.radius)),
      elevation: 4,
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 'edit') {
          Get.to(() => AddEditFeedbackScreen(feedback: feedback));
        } else if (value == 'delete') {
          _confirmDelete(feedback.id!);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.width),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.radius),
                ),
                child: Icon(Icons.edit_outlined, color: Colors.blue.shade700, size: 18),
              ),
              SizedBox(width: 12.width),
              Text(
                "Edit Feedback",
                style: appTextStyleHeading1(fontSize: 14.fontSize, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.width),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.radius),
                ),
                child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade700, size: 18),
              ),
              SizedBox(width: 12.width),
              Text(
                "Delete",
                style: appTextStyleHeading1(fontSize: 14.fontSize, color: Colors.red, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'resolved':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        icon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        icon = Icons.cancel_rounded;
        break;
      case 'in_progress':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        icon = Icons.hourglass_top_rounded;
        break;
      default: // pending
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        icon = Icons.schedule_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.width, vertical: 5.height),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.fontSize, color: textColor),
          SizedBox(width: 4.width),
          Text(
            status.replaceAll('_', ' ').capitalizeFirst ?? '',
            style: appTextStyleHeading1(
              fontSize: 11.fontSize,
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    Get.defaultDialog(
      title: "Delete Feedback",
      titleStyle: appTextStyleHeading1(fontSize: 18.fontSize, fontWeight: FontWeight.bold),
      middleText: "Are you sure you want to delete this feedback? This action cannot be undone.",
      middleTextStyle: appTextStyleHeading1(fontSize: 14.fontSize, color: Colors.grey.shade600),
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.deleteFeedback(id);
      },
    );
  }
}
