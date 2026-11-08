import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/student/settings/controller/student_settings_controller.dart';
import 'package:msollaally/feature/student/settings/model/device_session_model.dart';
import 'package:intl/intl.dart';
import '../../../../core/common/styles/global_text_style.dart';

class StudentSettingsDeviceSessions extends StatelessWidget {
  final StudentSettingsController controller;

  const StudentSettingsDeviceSessions({super.key, required this.controller});

  String _parseUserAgent(String userAgent) {
    if (userAgent.contains('Dart')) return 'Mobile App (msollaally)';

    String os = 'Unknown OS';
    String browser = 'Unknown Browser';

    if (userAgent.contains('Macintosh') || userAgent.contains('Mac OS X')) {
      os = 'Mac OS';
    } else if (userAgent.contains('Windows')) {
      os = 'Windows';
    } else if (userAgent.contains('Android')) {
      os = 'Android';
    } else if (userAgent.contains('iPhone') || userAgent.contains('iPad')) {
      os = 'iOS';
    } else if (userAgent.contains('Linux')) {
      os = 'Linux';
    }

    if (userAgent.contains('Chrome')) {
      browser = 'Chrome';
    } else if (userAgent.contains('Safari') && !userAgent.contains('Chrome')) {
      browser = 'Safari';
    } else if (userAgent.contains('Firefox')) {
      browser = 'Firefox';
    } else if (userAgent.contains('Edge')) {
      browser = 'Edge';
    }

    return '$os - $browser';
  }

  IconData _getIconForSession(String parsedAgent) {
    if (parsedAgent.contains('Mobile') ||
        parsedAgent.contains('iOS') ||
        parsedAgent.contains('Android')) {
      return Icons.phone_android;
    }
    return Icons.computer;
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildSessionItem(DeviceSessionModel session) {
    final parsedAgent = _parseUserAgent(session.userAgent);
    final icon = _getIconForSession(parsedAgent);
    final isThisDevice =
        session.isCurrentSession ||
        (controller.currentDeviceIp.value.isNotEmpty &&
            session.ipAddress == controller.currentDeviceIp.value);

    return Container(
      margin: EdgeInsets.only(bottom: 12.height),
      padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 12.height),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.width),
            decoration: BoxDecoration(
              color: AppColors.primaryButtonColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryButtonColor, size: 24),
          ),
          SizedBox(width: 12.width),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        parsedAgent,
                        style: appTextStyleHeading1(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isThisDevice)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.width,
                          vertical: 2.height,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4.radius),
                        ),
                        child: Text(
                          "This Device",
                          style: appTextStyleHeading1(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.height),
                Text(
                  "IP: ${session.ipAddress}",
                  style: appTextStyleHeading1(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4.height),
                Text(
                  "Last Login: ${_formatDate(session.issuedAt)}",
                  style: appTextStyleHeading1(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.width),
          if (!isThisDevice)
            InkWell(
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: Text('Revoke Session'),
                    content: Text(
                      'Are you sure you want to log out from this device?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.revokeSession(session.id);
                        },
                        child: Text(
                          'Revoke',
                          style: TextStyle(color: AppColors.uiDangerColor),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(8.width),
                decoration: BoxDecoration(
                  color: AppColors.uiDangerColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.power_settings_new,
                  color: AppColors.uiDangerColor,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 12.height),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.radius),
                topRight: Radius.circular(8.radius),
              ),
            ),
            child: Text(
              "Device Sessions",
              style: appTextStyleHeading1(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2.fontSize,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 12.height),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.radius),
                bottomRight: Radius.circular(8.radius),
              ),
            ),
            child: Obx(() {
              if (controller.isLoadingSessions.value) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.height),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryButtonColor,
                    ),
                  ),
                );
              }

              final sessions = controller.deviceSessionsList;
              if (sessions.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.height),
                  child: Center(
                    child: Text(
                      "No active sessions found",
                      style: appTextStyleHeading1(color: Colors.grey.shade600),
                    ),
                  ),
                );
              }

              final displayedSessions = controller.showAllSessions.value
                  ? sessions
                  : sessions.take(2).toList();

              return Column(
                children: [
                  ...displayedSessions.map(
                    (session) => _buildSessionItem(session),
                  ),
                  if (sessions.length > 2)
                    TextButton(
                      onPressed: () {
                        controller.showAllSessions.toggle();
                      },
                      child: Text(
                        controller.showAllSessions.value
                            ? "Show less"
                            : "Show more",
                        style: appTextStyleHeading1(
                          color: AppColors.primaryButtonColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
