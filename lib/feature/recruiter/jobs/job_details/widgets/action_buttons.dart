import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/model/candidate_model.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/model/candidate_status_enum.dart';

class ActionButtons extends StatelessWidget {
  final CandidateModel live;
  final bool showActionButtons;
  final VoidCallback? onReserve;
  final Function(String)? onReject;
  final VoidCallback? onShortlist;
  final VoidCallback onShowRejectionDialog;

  const ActionButtons({super.key, 
    required this.live,
    required this.showActionButtons,
    required this.onReserve,
    required this.onReject,
    required this.onShortlist,
    required this.onShowRejectionDialog,
  });

  bool get _isReserved => live.status == CandidateStatus.accepted.apiValue;
  bool get _isShortlisted =>
      live.status == CandidateStatus.shortlisted.apiValue;
  bool get _isDeclined => live.status == CandidateStatus.rejected.apiValue;

  @override
  Widget build(BuildContext context) {
    if (showActionButtons) {
      return Row(
        children: [
          _reserveButton(),
          const SizedBox(width: 8),
          _rejectButton(),
          const SizedBox(width: 8),
          _shortlistButton(),
        ],
      );
    }

    // Read-only status badge when action buttons are hidden
    if (_isShortlisted || _isReserved || _isDeclined) {
      return _statusBadge();
    }

    return const SizedBox.shrink();
  }

  // ── Reserve ───────────────────────────────────────────────────────────────
  Widget _reserveButton() {
    final disabled = _isReserved || onReserve == null;
    return GestureDetector(
      onTap: disabled ? null : onReserve,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.forYouContainerBorderColor.withValues(alpha: 0.4)
              : AppColors.forYouContainerBorderColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _isReserved ? 'Reserved' : 'Reserve',
          style: const TextStyle(color: Colors.black, fontSize: 11),
        ),
      ),
    );
  }

  // ── Reject ────────────────────────────────────────────────────────────────
  Widget _rejectButton() {
    final disabled = _isDeclined || onReject == null;
    final color = disabled
        ? AppColors.uiDangerColor.withValues(alpha: 0.5)
        : AppColors.uiDangerColor;
    return GestureDetector(
      onTap: disabled ? null : onShowRejectionDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _isDeclined ? 'Rejected' : 'Reject',
          style: TextStyle(color: color, fontSize: 11),
        ),
      ),
    );
  }

  // ── Shortlist ─────────────────────────────────────────────────────────────
  Widget _shortlistButton() {
    final disabled = _isShortlisted || onShortlist == null;
    return GestureDetector(
      onTap: disabled ? null : onShortlist,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.primaryButtonColor.withValues(alpha: 0.6)
              : AppColors.primaryButtonColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _isShortlisted ? 'Shortlisted' : 'Shortlist',
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }

  // ── Read-only status badge ─────────────────────────────────────────────────
  Widget _statusBadge() {
    Color bgColor = Colors.transparent;
    Border? border;
    Color textColor = Colors.black;
    String label = '';

    if (_isShortlisted) {
      bgColor = AppColors.primaryButtonColor;
      textColor = Colors.white;
      label = 'Shortlisted';
    } else if (_isReserved) {
      bgColor = AppColors.forYouContainerBorderColor;
      textColor = Colors.black;
      label = 'Reserved';
    } else if (_isDeclined) {
      border = Border.all(
        color: AppColors.uiDangerColor.withValues(alpha: 0.5),
      );
      textColor = AppColors.uiDangerColor.withValues(alpha: 0.5);
      label = 'Rejected';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 11)),
    );
  }
}
