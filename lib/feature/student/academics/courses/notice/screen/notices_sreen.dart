import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/notice_controller.dart';
import '../model/course_notice_model.dart';
import '../widgets/notice_detail_bottom_sheet.dart';

class NoticeScreen extends StatelessWidget {
  final int? courseId;

  const NoticeScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      NoticeController(courseId: courseId),
      tag: 'student-notice-$courseId',
    );

    return Obx(() {
      if (controller.isLoading.value && controller.notices.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value != null && controller.notices.isEmpty) {
        return _ErrorStateView(
          message: controller.errorMessage.value!,
          onRetry: controller.fetchNotices,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchNotices,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryButtonColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.campaign_rounded,
                        size: 22,
                        color: AppColors.primaryButtonColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Course Notices",
                                style: getTextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if (controller.notices.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryButtonColor
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${controller.notices.length}',
                                    style: getTextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryButtonColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Announcements and updates from your instructor",
                            style: getTextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      color: Colors.grey.shade600,
                      tooltip: 'Refresh',
                      onPressed: controller.fetchNotices,
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1),
              ),
            ),
            if (controller.notices.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyStateView(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final notice = controller.notices[index];
                      return _NoticeCard(notice: notice, index: index);
                    },
                    childCount: controller.notices.length,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _NoticeCard extends StatelessWidget {
  final CourseNoticeModel notice;
  final int index;

  const _NoticeCard({required this.notice, required this.index});

  @override
  Widget build(BuildContext context) {
    final themeColors = _cardTheme(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: notice.isImportant
              ? Colors.amber.shade300
              : themeColors.borderColor.withValues(alpha: 0.55),
          width: notice.isImportant ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: themeColors.primaryColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => NoticeDetailBottomSheet.show(context, notice),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left decorative accent bar
                Container(
                  width: 5,
                  color: notice.isImportant ? Colors.amber.shade600 : themeColors.primaryColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Important badge if flagged
                        if (notice.isImportant) ...[
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.bolt_rounded, size: 12, color: Color(0xFFB45309)),
                                    const SizedBox(width: 2),
                                    Text(
                                      'IMPORTANT',
                                      style: getTextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFB45309),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Header: Icon + Title + Time Tag
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: themeColors.primaryColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.push_pin_rounded,
                                size: 14,
                                color: themeColors.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                notice.title,
                                style: getTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade900,
                                ),
                              ),
                            ),
                            if (notice.createdAt != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(notice.createdAt),
                                      style: getTextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Message Content (preview limited to 3 lines)
                        Text(
                          notice.note,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: getTextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: Colors.grey.shade800,
                          ),
                        ),

                        const SizedBox(height: 12),
                        // Footer: Creator name + Tap to read more hint
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey.shade200,
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (notice.creatorName.isNotEmpty) ...[
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: themeColors.primaryColor.withValues(alpha: 0.15),
                                  child: Text(
                                    notice.creatorName[0].toUpperCase(),
                                    style: getTextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: themeColors.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Posted by ${notice.creatorName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: getTextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ] else
                                const Spacer(),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Read more',
                                    style: getTextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: themeColors.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 11,
                                    color: themeColors.primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _NoticeTheme _cardTheme(int index) {
    final themes = [
      _NoticeTheme(
        primaryColor: AppColors.primaryButtonColor,
        borderColor: const Color(0xFFC7D9FE),
      ),
      _NoticeTheme(
        primaryColor: const Color(0xFF8B5CF6),
        borderColor: const Color(0xFFDDD6FE),
      ),
      _NoticeTheme(
        primaryColor: const Color(0xFF0EA5E9),
        borderColor: const Color(0xFFBAE6FD),
      ),
      _NoticeTheme(
        primaryColor: const Color(0xFF10B981),
        borderColor: const Color(0xFFA7F3D0),
      ),
    ];
    return themes[index % themes.length];
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    final localTime = dateTime.toLocal();
    final difference = DateTime.now().difference(localTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return DateFormat('MMM d, yyyy').format(localTime);
  }
}

class _NoticeTheme {
  final Color primaryColor;
  final Color borderColor;

  const _NoticeTheme({
    required this.primaryColor,
    required this.borderColor,
  });
}

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryButtonColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 48,
                color: AppColors.primaryButtonColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No Notices Yet",
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Any announcements or updates from your instructor will appear here.",
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorStateView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: getTextStyle(
                color: Colors.red.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
