import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/const/appcolors.dart';

class PlanHeaderCard extends StatelessWidget {
  final dynamic plan;

  const PlanHeaderCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final updatedLabel = _formatDateTime(plan.updatedAt);
    final createdLabel = _formatDateTime(plan.createdAt);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryButtonColor,
            AppColors.primaryButtonColor.withValues(alpha: 0.68),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.24),
                  ),
                ),
                child: Text(
                  plan.isDefault ? 'Default Plan' : 'Custom Plan',
                  style: getTextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Text(
            plan.title,
            style: getTextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            plan.description.isEmpty
                ? 'No description available for this plan.'
                : plan.description,
            style: getTextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetaTile(
                  label: 'Plan ID',
                  value: plan.id.isEmpty ? '-' : '#${plan.id}',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MetaTile(label: 'Updated', value: updatedLabel ?? '-'),
              ),
            ],
          ),
          if (createdLabel != null) ...[
            SizedBox(height: 12),
            _MetaTile(label: 'Created', value: createdLabel, fullWidth: true),
          ],
        ],
      ),
    );
  }

  String? _formatDateTime(DateTime? value) {
    if (value == null) return null;
    return DateFormat('dd MMM yyyy, hh:mm a').format(value.toLocal());
  }
}

class _MetaTile extends StatelessWidget {
  final String label;
  final String value;
  final bool fullWidth;

  const _MetaTile({
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: getTextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: getTextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
