import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/core/utils/logging/logger.dart';
import 'package:msollaally/feature/pro_partners/chat/screen/pro_partners_chat_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../controller/event_overview_controller.dart';

class AttendeeCard extends StatelessWidget {
  const AttendeeCard({
    super.key,
    required this.attendee,
    required this.controller,
  });
  final Map<String, dynamic> attendee;
  final EventOverviewController controller;

  @override
  Widget build(BuildContext context) {
    final name = controller.buildAttendeeName(attendee);
    final meta = controller.buildAttendeeMeta(attendee);
    final imageUrl = controller.attendeeProfileImage(attendee);
    final status = controller.attendeeStatus(attendee);
    final attendeeId = controller.attendeeId(attendee);
    final extraInfo = controller.attendeeMetaInfo(attendee);
    final verified = controller.attendeeIsVerified(attendee);
    final accent = attendeeStatusColor(status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Colors.white, AppColors.ghostWhiteF8FBFF],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackAlpha120F172A,
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(name: name, imageUrl: imageUrl, accent: accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black0F172A,
                            ),
                          ),
                        ),
                        if (verified)
                          const Icon(
                            Icons.verified_rounded,
                            size: 18,
                            color: AppColors.royalBlue2563EB,
                          ),
                      ],
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: AppColors.dimGray5B6B83,
                        ),
                      ),
                    ],
                    if (extraInfo.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: accent),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              extraInfo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.slateGray7B8799,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),

              Column(
                children: [
                  StatusBadge(status: status),
                  IconButton(
                    onPressed: () async {
                      final receiverId = _attendeeUserId(attendee);
                      AppLoggerHelper.debug(
                        '[ProPartnersAttendeeCard] Chat tap: parsed receiverId=$receiverId attendee=$attendee',
                      );
                      if (receiverId <= 0) {
                        Get.snackbar('Error', 'Attendee user id not found');
                        return;
                      }
                      final storedUserId = await SharedPreferenceHelper()
                          .getUserId();
                      final senderId = int.tryParse(storedUserId ?? '') ?? 0;
                      AppLoggerHelper.debug(
                        '[ProPartnersAttendeeCard] Chat tap: parsed senderId=$senderId from storedUserId=$storedUserId',
                      );
                      if (senderId <= 0) {
                        Get.snackbar('Error', 'Current user id not found');
                        return;
                      }
                      final args = <String, dynamic>{
                        'senderId': senderId,
                        'receiverId': receiverId,
                        'receiverIds': <int>[receiverId],
                      };
                      AppLoggerHelper.info(
                        '[ProPartnersAttendeeCard] Navigating to ProPartnersChatScreen with args=$args',
                      );
                      Get.to(() => ProPartnersChatScreen(), arguments: args);
                    },
                    icon: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: accent,
                    ),
                    tooltip: 'Chat',
                  ),
                ],
              ),
            ],
          ),
          Obx(() {
            final isPending = controller.attendeeStatus(attendee) == 'pending';
            final isBusy = controller.attendeeActionIds.contains(attendeeId);
            if (!isPending || attendeeId.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isBusy
                            ? null
                            : () => controller.updateAttendeeStatus(
                                attendeeId: attendeeId,
                                action: 'reject',
                              ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          side: const BorderSide(color: AppColors.lightPinkF2B8B5),
                          foregroundColor: AppColors.firebrickB42318,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: AppColors.snowFFF7F7,
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isBusy
                            ? null
                            : () => controller.updateAttendeeStatus(
                                attendeeId: attendeeId,
                                action: 'approve',
                              ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          elevation: 0,
                          backgroundColor: AppColors.royalBlue2563EB,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isBusy
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Approve',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

int _attendeeUserId(Map<String, dynamic> attendee) {
  final user = attendee['user'];
  if (user is Map<String, dynamic>) {
    final userId = user['id'];
    if (userId is int) return userId;
    if (userId is num) return userId.toInt();
    final parsed = int.tryParse(userId?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  final direct =
      attendee['userId'] ?? attendee['user_id'] ?? attendee['attendeeUserId'];
  if (direct is int) return direct;
  if (direct is num) return direct.toInt();
  return int.tryParse(direct?.toString() ?? '') ?? 0;
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.name,
    required this.imageUrl,
    required this.accent,
  });
  final String name;
  final String? imageUrl;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [accent, accent.withValues(alpha: 0.35)],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.aliceBlueE8F0FF,
        backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
            ? NetworkImage(imageUrl!)
            : null,
        child: imageUrl == null || imageUrl!.isEmpty
            ? Text(
                initials,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkSlateBlue21407D,
                ),
              )
            : null,
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = attendeeStatusColor(status);
    final icon = switch (status) {
      'approved' => Icons.check_circle_rounded,
      'attended' => Icons.task_alt_rounded,
      'rejected' => Icons.cancel_rounded,
      'cancelled' => Icons.do_not_disturb_alt_rounded,
      _ => Icons.hourglass_top_rounded,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '${status[0].toUpperCase()}${status.substring(1)}',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class AttendeeShimmerCard extends StatelessWidget {
  const AttendeeShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lavenderE8EEF8,
      highlightColor: Colors.white,
      child: Container(
        height: 132,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

class AttendeesEmptyState extends StatelessWidget {
  const AttendeesEmptyState({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.aliceBlueEFF6FF,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                size: 42,
                color: AppColors.royalBlue2563EB,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No attendees to show',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black0F172A,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.slateGray64748B,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color attendeeStatusColor(String status) => switch (status) {
  'approved' => AppColors.royalBlue2563EB,
  'attended' => AppColors.seaGreen16A34A,
  'rejected' => AppColors.crimsonDC2626,
  'cancelled' => AppColors.secondaryTextColor,
  _ => AppColors.orangeF59E0B,
};
