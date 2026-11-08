// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';

class ApplicantLoadingState extends StatelessWidget {
  ApplicantLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children: [
        SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.royalBlue1D4ED8,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Loading applicants...',
                style: TextStyle(fontSize: 14, color: AppColors.slateGray64748B),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ApplicantErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  ApplicantErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children: [
        SizedBox(height: 48),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: _StateCard(
            icon: Icons.cloud_off_rounded,
            iconColor: AppColors.crimsonDC2626,
            title: 'Could not load applicants',
            subtitle: message,
            child: TextButton(onPressed: onRetry, child: Text('Try Again')),
          ),
        ),
      ],
    );
  }
}

class ApplicantEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  ApplicantEmptyState({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children: [
        SizedBox(height: 48),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: _StateCard(
            icon: Icons.inbox_rounded,
            iconColor: AppColors.royalBlue1D4ED8,
            title: title,
            subtitle: subtitle,
          ),
        ),
      ],
    );
  }
}

class _StateCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? child;

  _StateCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black0F172A,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.slateGray64748B,
            ),
          ),
          if (child != null) ...[SizedBox(height: 10), child!],
        ],
      ),
    );
  }
}
