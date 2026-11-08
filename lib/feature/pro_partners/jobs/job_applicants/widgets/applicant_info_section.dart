// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';

class ApplicantInfoSection extends StatelessWidget {
  final String title;
  final List<ApplicantInfoRowData> rows;
  final Widget? child;

  ApplicantInfoSection({
    super.key,
    required this.title,
    required this.rows,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final visibleRows = rows
        .where((row) => row.value.trim().isNotEmpty)
        .toList();
    if (visibleRows.isEmpty && child == null) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black0F172A.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.black0F172A,
            ),
          ),
          if (visibleRows.isNotEmpty) ...[
            SizedBox(height: 14),
            ...visibleRows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              return ApplicantInfoRow(
                data: row,
                showDivider: index != visibleRows.length - 1 || child != null,
              );
            }),
          ],
          if (child != null) ...[SizedBox(height: 14), child!],
        ],
      ),
    );
  }
}

class ApplicantInfoRowData {
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Color? valueColor;
  final Widget? trailing;

  ApplicantInfoRowData({
    required this.label,
    required this.value,
    this.onTap,
    this.valueColor,
    this.trailing,
  });
}

class ApplicantInfoRow extends StatelessWidget {
  final ApplicantInfoRowData data;
  final bool showDivider;

  ApplicantInfoRow({super.key, required this.data, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final rowContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            data.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.slateGray64748B,
            ),
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  data.value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: data.valueColor ?? AppColors.black0F172A,
                  ),
                ),
              ),
              if (data.trailing != null) ...[
                SizedBox(width: 6),
                data.trailing!,
              ],
            ],
          ),
        ),
      ],
    );

    return Column(
      children: [
        data.onTap == null
            ? rowContent
            : InkWell(
                onTap: data.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: rowContent,
                ),
              ),
        if (showDivider) ...[
          SizedBox(height: 12),
          Container(height: 1, color: AppColors.whiteSmokeEFF2F7),
          SizedBox(height: 12),
        ],
      ],
    );
  }
}
