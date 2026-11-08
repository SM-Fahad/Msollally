import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/post_action_button.dart';
import 'package:msollaally/core/const/icons_path.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import '../controller/campaign_detail_controller.dart';
import '../widgets/campaign_media_banner.dart';
import '../widgets/campaign_header_section.dart';
import '../widgets/campaign_comment_sheet.dart';
import '../widgets/campaign_notices_section.dart';

class CampaignDetailScreen extends StatelessWidget {
  const CampaignDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final campaignId = Get.arguments?['id']?.toString() ?? '';
    final controller = Get.put(
      CampaignDetailController(campaignId: campaignId),
      tag: campaignId,
    );

    return Scaffold(
      backgroundColor: AppColors.whiteSmokeF1F5F9,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Campaign Details',
          style: appTextStyleHeading1(
            fontSize: 20.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final details = controller.campaignDetails.value;
        
        if (controller.isLoading.value && details == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (details == null) {
          return Center(
            child: Text(
              'Campaign not found',
              style: appTextStyleHeading2(color: Colors.grey),
            ),
          );
        }

        final title = details['title']?.toString() ?? 'Campaign';
        final tag = details['tag']?.toString() ?? 'Active';
        final description = details['description']?.toString() ?? 'No description provided.';
        final imageOrVideoLink = details['imageOrVideoLink']?.toString() ?? '';
        final isSponsored = details['isSponsored'] == 'true' || details['isSponsored'] == true;
        final authorName = details['authorName']?.toString() ?? 'Organizer';
        final authorAvatar = details['authorAvatar']?.toString() ?? details['companyLogo']?.toString() ?? details['logo']?.toString() ?? '';
        
        final likeCount = details['likeCount']?.toString() ?? '0';
        final commentCount = details['commentCount']?.toString() ?? '0';
        final isLikedByMe = details['isLikedByMe'] == 'true' || details['isLikedByMe'] == true;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 16.height),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.radius),
              border: Border.all(color: AppColors.lavenderE6EAF0),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.blackAlpha120F172A,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            padding: EdgeInsets.all(16.width),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CampaignHeaderSection(
                  campaignId: campaignId,
                  title: title,
                  tag: tag,
                  authorName: authorName,
                  authorAvatar: authorAvatar,
                  isSponsored: isSponsored,
                ),
                SizedBox(height: 12.height),
                _buildDescription(description),
                SizedBox(height: 16.height),
                _buildCampaignDetails(details),
                if (imageOrVideoLink.isNotEmpty) ...[
                  SizedBox(height: 16.height),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.radius),
                    child: CampaignMediaBanner(imageOrVideoLink: imageOrVideoLink),
                  ),
                ],
                SizedBox(height: 16.height),
                Divider(color: AppColors.sliderColorInboarding, height: 1.height),
                SizedBox(height: 12.height),
                Row(
                  children: [
                    Text(
                      '$likeCount Likes',
                      style: getTextStyle(
                        fontSize: 12,
                        color: AppColors.darkSlateGray475569,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$commentCount Comments',
                      style: getTextStyle(
                        fontSize: 12,
                        color: AppColors.darkSlateGray475569,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.height),
                Divider(color: AppColors.sliderColorInboarding, height: 1.height),
                SizedBox(height: 12.height),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    PostActionButton(
                      iconPath: IconsPath.reactIcon,
                      label: isLikedByMe ? 'Liked' : 'Like',
                      isActive: isLikedByMe,
                      activeColor: AppColors.royalBlue2563EB,
                      inactiveColor: AppColors.secondaryTextColor,
                      onTap: () => controller.toggleLikeCampaign(),
                    ),
                    PostActionButton(
                      iconPath: IconsPath.commentIcon,
                      label: 'Comment',
                      inactiveColor: AppColors.secondaryTextColor,
                      onTap: () {
                        controller.focusCommentComposer();
                        showCampaignCommentSheet(context, campaignId);
                      },
                    ),
                    PostActionButton(
                      iconPath: IconsPath.shareIcon,
                      label: 'Share',
                      inactiveColor: AppColors.secondaryTextColor,
                      onTap: () => controller.shareCampaign(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.height),
          CampaignNoticesSection(controller: controller),
        ],
      ),
        );
      }),
    );
  }

  Widget _buildCampaignDetails(Map<String, dynamic> details) {
    final startStr = details['startDate']?.toString();
    final endStr = details['endDate']?.toString();
    String dateRange = '';
    if (startStr != null && startStr.isNotEmpty) {
      try {
        final startDt = DateTime.parse(startStr).toLocal();
        final startFmt = '${startDt.day}/${startDt.month}/${startDt.year}';
        dateRange = startFmt;
        if (endStr != null && endStr.isNotEmpty) {
          final endDt = DateTime.parse(endStr).toLocal();
          final endFmt = '${endDt.day}/${endDt.month}/${endDt.year}';
          dateRange = '$startFmt  -  $endFmt';
        }
      } catch (_) {}
    }

    List<String> parseList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String) {
        if (value.startsWith('[') && value.endsWith(']')) {
          final trimmed = value.substring(1, value.length - 1);
          if (trimmed.isEmpty) return [];
          return trimmed.split(',').map((e) => e.replaceAll('"', '').trim()).toList();
        }
        return [value];
      }
      return [];
    }

    final universityList = parseList(details['university']);
    final majorList = parseList(details['major']);
    final genderList = parseList(details['gender']);
    
    final yearOfStudy = details['yearOfStudy']?.toString() ?? '0';
    final totalParticipants = details['totalParticipants']?.toString() ?? '0';
    final daysRemaining = details['daysRemaining']?.toString() ?? '0';

    return Padding(
      padding: EdgeInsets.only(bottom: 8.height),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dateRange.isNotEmpty)
            _detailRow(Icons.calendar_today_outlined, dateRange),
          if (universityList.isNotEmpty)
            _detailRow(Icons.account_balance_outlined, universityList.join(', ')),
          if (majorList.isNotEmpty || yearOfStudy != '0')
            _detailRow(
              Icons.school_outlined, 
              [if (majorList.isNotEmpty) majorList.join(', '), if (yearOfStudy != '0') 'Year $yearOfStudy'].join(' • '),
            ),
          if (genderList.isNotEmpty)
            _detailRow(Icons.wc_outlined, 'Gender: ${genderList.join(', ')}'),
          if (totalParticipants != '0' || daysRemaining != '0')
            _detailRow(
              Icons.analytics_outlined,
              [if (totalParticipants != '0') '$totalParticipants Participants', if (daysRemaining != '0') '$daysRemaining Days Left'].join(' • '),
            ),
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
    if (description.trim().startsWith('[') && description.trim().endsWith(']')) {
      try {
        final decoded = jsonDecode(description.trim());
        if (decoded is List) {
          final doc = quill.Document.fromJson(decoded);
          final qController = quill.QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
            readOnly: true,
          );
          return quill.QuillEditor.basic(
            controller: qController,
            config: const quill.QuillEditorConfig(
              checkBoxReadOnly: true,
              autoFocus: false,
              expands: false,
              padding: EdgeInsets.zero,
            ),
          );
        }
      } catch (_) {}
    }
    return Text(
      description,
      style: getTextStyle(
        fontSize: 14,
        color: AppColors.darkSlateGray1F2937,
        height: 1.45,
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.height),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.fontSize, color: AppColors.secondaryTextColor),
          SizedBox(width: 8.width),
          Expanded(
            child: Text(
              text,
              style: getTextStyle(
                fontSize: 13,
                color: AppColors.darkSlateGray475569,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
