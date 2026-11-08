import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/wall/wall_video_player.dart';

class CampaignMediaBanner extends StatelessWidget {
  final String imageOrVideoLink;
  const CampaignMediaBanner({super.key, required this.imageOrVideoLink});

  bool _isVideoUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.mp4') ||
        lower.contains('.mov') ||
        lower.contains('.avi') ||
        lower.contains('.mkv') ||
        lower.contains('.webm') ||
        lower.contains('.m3u8') ||
        lower.contains('video/upload');
  }

  @override
  Widget build(BuildContext context) {
    if (imageOrVideoLink.isEmpty) return const SizedBox.shrink();

    // If media link is a video, use WallVideoPlayer for active responsive playback
    if (_isVideoUrl(imageOrVideoLink)) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.radius),
          child: WallVideoPlayer(videoUrl: imageOrVideoLink),
        ),
      );
    }

    return Container(
      height: 180.height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => FullscreenImageView(
                imageUrl: imageOrVideoLink,
                isNetworkImage: true,
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.radius),
          child: Image.network(
            imageOrVideoLink,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade100,
                alignment: Alignment.center,
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 40.fontSize,
                  color: Colors.grey.shade400,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
