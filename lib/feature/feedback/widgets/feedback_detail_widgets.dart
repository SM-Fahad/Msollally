import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/feature/feedback/model/feedback_model.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackMainDetailsCard extends StatelessWidget {
  final FeedbackModel feedback;

  const FeedbackMainDetailsCard({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.width),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.lavenderE6EBF2.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (feedback.category != null && feedback.category!.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.width,
                    vertical: 6.height,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20.radius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.label_outline,
                        size: 14.fontSize,
                        color: Colors.blue.shade700,
                      ),
                      SizedBox(width: 6.width),
                      Text(
                        feedback.category!.capitalizeFirst ?? '',
                        style: appTextStyleHeading1(
                          fontSize: 12.fontSize,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (feedback.status != null && feedback.status!.isNotEmpty)
                FeedbackStatusBadge(status: feedback.status!),
            ],
          ),
          if (feedback.title != null && feedback.title!.isNotEmpty) ...[
            SizedBox(height: 16.height),
            Text(
              feedback.title!,
              style: appTextStyleHeading1(
                fontSize: 20.fontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.black1F1F1F,
              ),
            ),
          ],
          if (feedback.description != null &&
              feedback.description!.isNotEmpty) ...[
            SizedBox(height: 12.height),
            Text(
              feedback.description!,
              style: appTextStyleHeading1(
                fontSize: 15.fontSize,
                color: Colors.grey.shade700,
              ).copyWith(height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}

class FeedbackAttachmentCard extends StatelessWidget {
  final String url;
  const FeedbackAttachmentCard({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.lavenderE6EBF2.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.radius),
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(16.width),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.width),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.attachment, color: Colors.red.shade600),
                ),
                SizedBox(width: 16.width),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Attachment",
                        style: appTextStyleHeading1(
                          fontSize: 16.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.height),
                      Text(
                        "Tap to view the attached file",
                        style: appTextStyleHeading1(
                          fontSize: 13.fontSize,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  color: Colors.grey.shade400,
                  size: 20.fontSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeedbackAdminReplyCard extends StatelessWidget {
  final FeedbackModel feedback;
  const FeedbackAdminReplyCard({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    String adminName = "Admin";
    if (feedback.repliedBy != null && feedback.repliedBy!.username != null) {
      adminName = feedback.repliedBy!.username!;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.width),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16.radius),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.support_agent,
                color: Colors.green.shade700,
                size: 24.fontSize,
              ),
              SizedBox(width: 12.width),
              Text(
                "Reply from $adminName",
                style: appTextStyleHeading1(
                  fontSize: 16.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.height),
          Text(
            feedback.adminReply!,
            style: appTextStyleHeading1(
              fontSize: 15.fontSize,
              color: Colors.green.shade900,
            ).copyWith(height: 1.5),
          ),
          if (feedback.repliedAt != null) ...[
            SizedBox(height: 12.height),
            Text(
              "Replied on ${DateTime.parse(feedback.repliedAt!).toLocal().toString().split('.')[0]}",
              style: appTextStyleHeading1(
                fontSize: 12.fontSize,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FeedbackStatusBadge extends StatelessWidget {
  final String status;
  const FeedbackStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'resolved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'in_progress':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.width, vertical: 4.height),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.radius),
      ),
      child: Text(
        status.replaceAll('_', ' ').capitalizeFirst ?? '',
        style: appTextStyleHeading1(
          fontSize: 12.fontSize,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class FeedbackRepliesList extends StatelessWidget {
  final List<dynamic> replies;
  const FeedbackRepliesList({super.key, required this.replies});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.width, bottom: 16.height),
          child: Text(
            "Ticket Updates",
            style: appTextStyleHeading1(
              fontSize: 18.fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.black1F1F1F,
            ),
          ),
        ),
        ...replies.map((reply) {
          String text = "";
          String userType = "User";
          String date = "";

          if (reply is Map) {
            text = reply['message']?.toString() ?? "";
            date = reply['createdAt']?.toString() ?? "";

            if (reply['adminId'] != null) {
              userType = "Admin Support";
            } else if (reply['user'] != null &&
                reply['user']['username'] != null) {
              userType = reply['user']['username'];
            }
          } else {
            text = reply.toString();
          }

          bool isAdmin =
              userType == "Admin Support" ||
              (reply is Map && reply['adminId'] != null);

          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 16.height),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.radius),
              border: Border.all(
                color: isAdmin
                    ? Colors.blue.shade100
                    : AppColors.lavenderE6EBF2,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.width,
                    vertical: 12.height,
                  ),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? Colors.blue.withValues(alpha: 0.05)
                        : AppColors.ghostWhiteF5F7FB,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(11.radius),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: isAdmin
                            ? Colors.blue.shade100
                            : AppColors.lavenderE6EBF2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isAdmin
                                ? Icons.support_agent_rounded
                                : Icons.person_outline_rounded,
                            size: 16.fontSize,
                            color: isAdmin
                                ? Colors.blue.shade700
                                : Colors.grey.shade700,
                          ),
                          SizedBox(width: 8.width),
                          Text(
                            isAdmin ? "Support Team" : userType,
                            style: appTextStyleHeading1(
                              fontSize: 14.fontSize,
                              fontWeight: FontWeight.bold,
                              color: isAdmin
                                  ? Colors.blue.shade800
                                  : AppColors.black1F1F1F,
                            ),
                          ),
                        ],
                      ),
                      if (date.isNotEmpty)
                        Text(
                          DateTime.tryParse(
                                date,
                              )?.toLocal().toString().split('.')[0] ??
                              "",
                          style: appTextStyleHeading1(
                            fontSize: 12.fontSize,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.width),
                  child: Text(
                    text,
                    style: appTextStyleHeading1(
                      fontSize: 15.fontSize,
                      color: AppColors.black1F1F1F,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
