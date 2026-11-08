// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';

class ApplicantStatusBadge extends StatelessWidget {
  final String status;

  ApplicantStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = _schemeForStatus(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.border),
      ),
      child: Text(
        _label(status),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: scheme.foreground,
        ),
      ),
    );
  }

  _StatusScheme _schemeForStatus(String raw) {
    final value = raw.toLowerCase();
    if (value == 'shortlisted') {
      return _StatusScheme(
        background: AppColors.honeydewECFDF3,
        foreground: AppColors.forestGreen15803D,
        border: AppColors.powderBlueBBF7D0,
      );
    }
    if (value == 'rejected') {
      return _StatusScheme(
        background: AppColors.lavenderBlushFFF1F2,
        foreground: AppColors.crimsonDC2626,
        border: AppColors.lightPinkFDA4AF,
      );
    }
    return _StatusScheme(
      background: AppColors.aliceBlueEFF6FF,
      foreground: AppColors.royalBlue1D4ED8,
      border: AppColors.powderBlueBFDBFE,
    );
  }

  String _label(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return 'Pending';
    }
    return text
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class _StatusScheme {
  final Color background;
  final Color foreground;
  final Color border;

  _StatusScheme({
    required this.background,
    required this.foreground,
    required this.border,
  });
}
