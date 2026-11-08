import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';

class CampaignMediaPreviewWidget extends StatelessWidget {
  final String url;
  final double size;
  final double borderRadius;

  const CampaignMediaPreviewWidget({
    super.key,
    required this.url,
    this.size = 78,
    this.borderRadius = 12,
  });

  bool get _hasUrl => url.trim().isNotEmpty;

  bool get _isImage {
    final clean = url.split('?').first.toLowerCase();
    return clean.endsWith('.png') ||
        clean.endsWith('.jpg') ||
        clean.endsWith('.jpeg') ||
        clean.endsWith('.webp') ||
        clean.endsWith('.gif') ||
        clean.endsWith('.bmp');
  }

  bool get _isVideo {
    final clean = url.split('?').first.toLowerCase();
    return clean.endsWith('.mp4') ||
        clean.endsWith('.mov') ||
        clean.endsWith('.avi') ||
        clean.endsWith('.mkv') ||
        clean.endsWith('.webm');
  }

  bool get _isDocument {
    final clean = url.split('?').first.toLowerCase();
    return clean.endsWith('.pdf') ||
        clean.endsWith('.doc') ||
        clean.endsWith('.docx') ||
        clean.endsWith('.ppt') ||
        clean.endsWith('.pptx') ||
        clean.endsWith('.xls') ||
        clean.endsWith('.xlsx');
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: Container(
        width: size.w,
        height: size.w,
        color: AppColors.panelBackgroundColor,
        child: _isImage && _hasUrl
            ? GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => FullscreenImageView(
                        imageUrl: url,
                        isNetworkImage: true,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const _PlaceholderIcon(icon: Icons.broken_image_outlined),
                ),
              )
            : _PlaceholderIcon(
                icon: !_hasUrl
                    ? Icons.image_not_supported_outlined
                    : _isVideo
                    ? Icons.play_circle_outline
                    : _isDocument
                    ? Icons.description_outlined
                    : Icons.perm_media_outlined,
              ),
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  final IconData icon;

  const _PlaceholderIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(icon, color: AppColors.darkGray94A3B8, size: 28.sp),
    );
  }
}
