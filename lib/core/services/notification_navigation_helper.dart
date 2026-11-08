import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/feature/pro_partners/fursa_zone/fusra_details/screens/fursa_details_main_screen.dart';
import 'package:msollaally/feature/student/campus/chat/screen/chat_screen.dart';
import 'package:msollaally/feature/student/notification/model/student_notification_model.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationNavigationHelper {
  /// Resolves the raw action URL or path from a notification model.
  static String? resolveActionUrl(StudentNotificationModel notification) {
    final directUrl = notification.actionUrl?.trim();
    if (directUrl != null && directUrl.isNotEmpty) {
      return directUrl;
    }

    final data = notification.data;
    if (data != null) {
      final actionUrl = data['actionUrl']?.toString().trim() ??
          data['action_url']?.toString().trim() ??
          data['url']?.toString().trim() ??
          data['link']?.toString().trim() ??
          data['path']?.toString().trim() ??
          data['route']?.toString().trim();

      if (actionUrl != null && actionUrl.isNotEmpty) {
        return actionUrl;
      }

      final entityType = data['entityType']?.toString().trim() ??
          data['entity_type']?.toString().trim();
      final entityId = data['entityId'] ?? data['entity_id'] ?? data['id'];

      if (entityType != null && entityType.isNotEmpty) {
        if (entityId != null) {
          return '/$entityType/$entityId';
        }
        return '/$entityType';
      }
    }

    return null;
  }

  /// Determines if the notification has a navigable action or link.
  static bool hasAction(StudentNotificationModel notification) {
    final url = resolveActionUrl(notification);
    if (url != null && url.isNotEmpty) {
      return true;
    }

    final entityType =
        notification.data?['entityType']?.toString().toLowerCase() ??
        notification.data?['entity_type']?.toString().toLowerCase();
    if (entityType != null && entityType.isNotEmpty) {
      return true;
    }

    final type = notification.type.toLowerCase();
    if (type.contains('competition') ||
        type.contains('campaign') ||
        type.contains('event') ||
        type.contains('task') ||
        type.contains('job')) {
      return true;
    }

    return false;
  }

  /// Performs navigation based on notification action URL or entity metadata.
  static Future<void> navigateToAction(
    StudentNotificationModel notification,
  ) async {
    final rawUrl = resolveActionUrl(notification);
    final data = notification.data ?? const <String, dynamic>{};
    final entityType =
        (data['entityType'] ?? data['entity_type'])
            ?.toString()
            .toLowerCase()
            .trim();
    final dynamic rawEntityId =
        data['entityId'] ?? data['entity_id'] ?? data['id'];
    final notifType = notification.type.toLowerCase().trim();

    debugPrint(
      '🔔 [NotificationNav] rawUrl: $rawUrl, entityType: $entityType, entityId: $rawEntityId, notifType: $notifType',
    );

    // 1. Check if external web URL
    if (rawUrl != null && _isWebUrl(rawUrl)) {
      final launched = await _launchWebUrl(rawUrl);
      if (launched) return;
    }

    // 2. Handle Competition
    if (entityType == 'competition' ||
        notifType.contains('competition') ||
        (rawUrl != null &&
            (rawUrl.contains('competition') || rawUrl.contains('fursa')))) {
      final compId = rawEntityId ?? _extractIdFromUrl(rawUrl, 'competitions');
      _navigateToCompetition(compId);
      return;
    }

    // 3. Handle Campaign
    if (entityType == 'campaign' ||
        notifType.contains('campaign') ||
        (rawUrl != null && rawUrl.contains('campaign'))) {
      final campaignId = rawEntityId ?? _extractIdFromUrl(rawUrl, 'campaigns');
      if (UserRoleService.isProPartners) {
        Get.toNamed(AppRoute.proPartnersAllCampaigns);
        return;
      }
      if (campaignId != null && campaignId.toString().isNotEmpty) {
        Get.toNamed(
          AppRoute.studentCampusCampaignDetail,
          arguments: {'id': campaignId.toString()},
        );
      } else {
        Get.toNamed(AppRoute.studentCampus);
      }
      return;
    }

    // 4. Handle Event
    if (entityType == 'event' ||
        notifType.contains('event') ||
        (rawUrl != null && rawUrl.contains('event'))) {
      final eventId = rawEntityId ?? _extractIdFromUrl(rawUrl, 'events');
      if (UserRoleService.isProPartners) {
        Get.toNamed(AppRoute.proPartnersDashboard);
        return;
      }
      if (eventId != null && eventId.toString().isNotEmpty) {
        Get.toNamed(
          AppRoute.studentCampusEventDetail,
          arguments: {'id': eventId.toString()},
        );
      } else {
        Get.toNamed(AppRoute.studentCampus);
      }
      return;
    }

    // 5. Handle Task
    if (entityType == 'task' ||
        notifType.contains('task') ||
        (rawUrl != null && rawUrl.contains('task'))) {
      final taskId = rawEntityId ?? _extractIdFromUrl(rawUrl, 'tasks');
      if (taskId != null) {
        Get.toNamed(
          AppRoute.studentDetailsTask,
          arguments: int.tryParse(taskId.toString()) ?? taskId,
        );
      } else {
        Get.toNamed(AppRoute.studentAllTaskList);
      }
      return;
    }

    // 6. Handle Job / Career
    if (entityType == 'job' ||
        notifType.contains('job') ||
        (rawUrl != null && rawUrl.contains('job'))) {
      if (UserRoleService.isRecruiter) {
        Get.toNamed(AppRoute.recruiterAllJobs);
      } else if (UserRoleService.isProPartners) {
        Get.toNamed(AppRoute.proPartnersAllJobs);
      } else {
        Get.toNamed(AppRoute.studentCareer);
      }
      return;
    }

    // 7. Handle Candidate
    if (entityType == 'candidate' ||
        (rawUrl != null && rawUrl.contains('candidate'))) {
      final candId = rawEntityId ?? _extractIdFromUrl(rawUrl, 'candidates');
      if (candId != null && candId.toString().isNotEmpty) {
        Get.toNamed(AppRoute.recruiterCandidateDetails, arguments: candId);
      } else {
        Get.toNamed(AppRoute.recruiterAllCandidates);
      }
      return;
    }

    // 8. Handle Course / Academic
    if (entityType == 'course' ||
        notifType.contains('course') ||
        (rawUrl != null && rawUrl.contains('course'))) {
      if (UserRoleService.isTeacher) {
        Get.toNamed(AppRoute.teacherCourses);
      } else {
        Get.toNamed(AppRoute.studentAcademics);
      }
      return;
    }

    // 9. Handle Chat / Inbox
    if (entityType == 'chat' ||
        notifType.contains('chat') ||
        (rawUrl != null &&
            (rawUrl.contains('chat') || rawUrl.contains('inbox')))) {
      final chatId = rawEntityId ??
          _extractIdFromUrl(rawUrl, 'chat') ??
          data['chatId'] ??
          data['chat_id'];
      final chatArgs = Map<String, dynamic>.from(data);
      if (chatId != null) {
        chatArgs['chatId'] = chatId;
      }
      if (UserRoleService.isTeacher) {
        Get.toNamed(AppRoute.teacherChatScreen,
            arguments: chatArgs.isNotEmpty ? chatArgs : null);
      } else if (UserRoleService.isProPartners) {
        if (chatId != null) {
          Get.toNamed(AppRoute.proPartnersChat, arguments: chatArgs);
        } else {
          Get.toNamed(AppRoute.proPartnersInbox);
        }
      } else {
        if (chatId != null) {
          Get.to(() => CampusChatScreen(), arguments: chatArgs);
        } else {
          Get.toNamed(AppRoute.studentCampusInbox);
        }
      }
      return;
    }

    // 10. Check if it directly matches a registered named route
    if (rawUrl != null && rawUrl.startsWith('/')) {
      final routeExists = AppRoute.routes.any((r) => r.name == rawUrl);
      if (routeExists) {
        Get.toNamed(rawUrl);
        return;
      }
    }

    // 11. Fallback: try web launch if not empty
    if (rawUrl != null && rawUrl.isNotEmpty) {
      final launched = await _launchWebUrl(rawUrl);
      if (launched) return;
    }

    Get.snackbar('Notice', 'Could not open link');
  }

  static void _navigateToCompetition(dynamic competitionId) {
    final parsedId =
        competitionId != null ? int.tryParse(competitionId.toString()) : null;

    if (UserRoleService.isProPartners) {
      if (parsedId != null) {
        Get.to(() => FursaDetailsMainScreen(), arguments: parsedId);
      } else {
        Get.toNamed(AppRoute.proPartnersFursaZone);
      }
    } else {
      if (parsedId != null) {
        Get.toNamed(AppRoute.studentQuizCompetition, arguments: parsedId);
      } else {
        Get.toNamed(AppRoute.fursaZoneScreen);
      }
    }
  }

  static bool _isWebUrl(String url) {
    final lower = url.trim().toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return true;
    }
    if (lower.startsWith('www.')) {
      return true;
    }
    // Has a domain suffix and does NOT start with /
    if (!lower.startsWith('/') &&
        (lower.contains('.com') ||
            lower.contains('.org') ||
            lower.contains('.net') ||
            lower.contains('.io') ||
            lower.contains('.co') ||
            lower.contains('.tz') ||
            lower.contains('.edu'))) {
      return true;
    }
    return false;
  }

  static Future<bool> _launchWebUrl(String url) async {
    try {
      var formatted = url.trim();
      if (!formatted.startsWith('http://') &&
          !formatted.startsWith('https://')) {
        formatted = 'https://$formatted';
      }
      final uri = Uri.tryParse(formatted);
      if (uri == null) return false;

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Error launching web url: $e');
      return false;
    }
  }

  static dynamic _extractIdFromUrl(String? url, String pathSegment) {
    if (url == null || url.isEmpty) return null;
    final regex = RegExp('$pathSegment/([^/?#]+)', caseSensitive: false);
    final match = regex.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      final idStr = match.group(1);
      final parsedInt = int.tryParse(idStr ?? '');
      return parsedInt ?? idStr;
    }
    return null;
  }
}
