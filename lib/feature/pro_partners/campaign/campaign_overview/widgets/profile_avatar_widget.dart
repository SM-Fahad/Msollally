import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double radius;

  const ProfileAvatarWidget({
    super.key,
    required this.imageUrl,
    required this.name,
    this.radius = 18,
  });

  String _initials(String value) {
    final clean = value.trim();
    if (clean.isEmpty) return 'P';

    final parts = clean
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;

    return Container(
      width: radius.r * 2,
      height: radius.r * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lavenderE8EEF9,
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    _initials(name),
                    style: TextStyle(
                      fontSize: (radius * 0.62).sp,
                      color: AppColors.darkSlateGray1E3A5F,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  _initials(name),
                  style: TextStyle(
                    fontSize: (radius * 0.62).sp,
                    color: AppColors.darkSlateGray1E3A5F,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
      ),
    );
  }
}
