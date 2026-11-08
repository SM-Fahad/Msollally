import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import '../controller/campaign_detail_controller.dart';
import '../../../../pro_partners/campaign/campaign_overview/widgets/expandable_text_widget.dart';

class CampaignNoticesSection extends StatelessWidget {
  final CampaignDetailController controller;
  const CampaignNoticesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingNotices.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }

      if (controller.notices.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Campaign Notices',
            style: appTextStyleHeading1(
              fontSize: 18.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.height),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: controller.notices.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.height),
            itemBuilder: (context, index) {
              final notice = controller.notices[index];
              return _StudentNoticeCard(notice: notice);
            },
          ),
          SizedBox(height: 24.height),
        ],
      );
    });
  }
}

class _StudentNoticeCard extends StatefulWidget {
  final Map<String, dynamic> notice;
  const _StudentNoticeCard({required this.notice});

  @override
  State<_StudentNoticeCard> createState() => _StudentNoticeCardState();
}

class _StudentNoticeCardState extends State<_StudentNoticeCard> {
  bool isExpanded = false;

  void toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.notice['title']?.toString() ?? 'Notice';
    final content = widget.notice['notice']?.toString() ?? widget.notice['content']?.toString() ?? '';
    final dateStr = (widget.notice['updatedAt'] ?? widget.notice['createdAt'])?.toString() ?? '';

    String formattedDate = 'Recent Update';
    if (dateStr.isNotEmpty) {
      try {
        final parsed = DateTime.tryParse(dateStr);
        if (parsed != null) {
          formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(parsed.toLocal());
        }
      } catch (_) {}
    }

    return Container(
      padding: EdgeInsets.all(12.width),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.radius),
        border: Border.all(color: AppColors.sectionBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.appBarTitleColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.height),
          ExpandableTextWidget(
            text: content,
            isExpanded: isExpanded,
            onToggle: toggleExpanded,
            style: getTextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.darkSlateGray334155,
            ),
          ),
          SizedBox(height: 8.height),
          Opacity(
            opacity: 0.6,
            child: Text(
              formattedDate,
              style: getTextStyle(fontSize: 12, color: AppColors.tertiaryTextColor),
            ),
          ),
        ],
      ),
    );
  }
}
