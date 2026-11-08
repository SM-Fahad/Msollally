import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/teacher/more/session/controller/teacher_session_controller.dart';
import 'package:msollaally/feature/teacher/more/session/model/teacher_session_model.dart';
import 'package:msollaally/feature/teacher/widgets/default_teacher_app_bar.dart';

class TeacherSessionScreen extends StatelessWidget {
  TeacherSessionScreen({super.key});

  final TeacherSessionController controller = Get.put(
    TeacherSessionController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultTeacherAppBar(title: 'Session', isHomePage: false),
      body: RefreshIndicator(
        onRefresh: controller.fetchSessions,
        child: Obx(() {
          if (controller.isLoading.value && controller.sessions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.sessions.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildEmptyState(),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              ...controller.sessions.map(_buildSessionCard),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.aliceBlueEEF4FF, AppColors.ghostWhiteF9FBFF],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lavenderD8E5FF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Sessions',
            style: getTextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Review where your account is signed in and remove old device sessions.',
            style: getTextStyle(fontSize: 13, color: Colors.grey[700]!),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(TeacherSessionModel session) {
    final isDeleting = controller.isDeletingSession(session.id);
    final isCurrent = session.isCurrentSession;
    final accent = isCurrent
        ? AppColors.seaGreen1D9B5F
        : AppColors.primaryButtonColor;

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent ? AppColors.gainsboroCDEDDC : AppColors.lavenderE7EAF0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(controller.displayIcon(session), color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.displayDevice(session),
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'IP ${session.ipAddress.isEmpty ? 'Unknown' : session.ipAddress}',
                      style: getTextStyle(
                        fontSize: 12,
                        color: Colors.grey[600]!,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.honeydewE6F7EE,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Current',
                    style: getTextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.seaGreen1D9B5F,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _buildMetaRow(label: 'Issued', value: _formatDate(session.issuedAt)),
          const SizedBox(height: 8),
          _buildMetaRow(
            label: 'Expires',
            value: _formatDate(session.expiresAt),
          ),
          const SizedBox(height: 8),
          _buildMetaRow(
            label: 'Role',
            value: session.user?.role.isNotEmpty == true
                ? session.user!.role
                : 'N/A',
          ),
          if ((session.user?.phoneNumber ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildMetaRow(label: 'Phone', value: session.user!.phoneNumber),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isCurrent || isDeleting
                  ? null
                  : () => controller.confirmDeleteSession(session),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isCurrent
                      ? Colors.grey.shade300
                      : AppColors.uiDangerColor.withValues(alpha: 0.4),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.logout_rounded,
                      color: isCurrent ? Colors.grey : AppColors.uiDangerColor,
                    ),
              label: Text(
                isCurrent
                    ? 'Current Session'
                    : isDeleting
                    ? 'Removing...'
                    : 'Remove Session',
                style: getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isCurrent ? Colors.grey : AppColors.uiDangerColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow({required String label, required String value}) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600]!,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: getTextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.devices_other_rounded,
            size: 42,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 12),
          Text(
            'No sessions found',
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Pull down to refresh and try again.',
            textAlign: TextAlign.center,
            style: getTextStyle(fontSize: 13, color: Colors.grey[600]!),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'N/A';
    }
    return DateFormat('MMM d, yyyy • hh:mm a').format(value.toLocal());
  }
}
