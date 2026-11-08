import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/widgets/fullscreen_video_view.dart';
import 'package:msollaally/core/utils/feed_video_manager.dart';

class WallVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const WallVideoPlayer({super.key, required this.videoUrl});

  @override
  State<WallVideoPlayer> createState() => _WallVideoPlayerState();
}

class _WallVideoPlayerState extends State<WallVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _handleVideoState() {
    if (!mounted || _videoPlayerController == null) return;
    if (_videoPlayerController!.value.isPlaying) {
      FeedVideoManager.onPlay(_videoPlayerController!);
    }
  }

  Future<void> _initializePlayer() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      _videoPlayerController = controller;

      await controller.initialize();
      controller.addListener(_handleVideoState);

      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: false,
        aspectRatio: controller.value.aspectRatio > 0
            ? controller.value.aspectRatio
            : 16 / 9,
        allowFullScreen: false,
        allowMuting: true,
        showControls: true,
        showControlsOnInitialize: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryButtonColor,
          handleColor: AppColors.primaryButtonColor,
          backgroundColor: Colors.grey.shade700,
          bufferedColor: Colors.white38,
        ),
        placeholder: Container(
          color: Colors.black87,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        ),
      );

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('WallVideoPlayer init error: $e');
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.removeListener(_handleVideoState);
      FeedVideoManager.unregister(_videoPlayerController!);
      try {
        _videoPlayerController!.pause();
      } catch (_) {}
      _videoPlayerController!.dispose();
      _videoPlayerController = null;
    }
    _chewieController?.dispose();
    super.dispose();
  }

  void _openFullscreen() {
    // Pause all in-feed videos before opening fullscreen
    FeedVideoManager.pauseAll();
    try {
      _videoPlayerController?.pause();
    } catch (_) {}

    // Open dedicated fullscreen video player screen without touching scroll state
    Get.to(
      () => FullscreenVideoView(videoUrl: widget.videoUrl),
      transition: Transition.fadeIn,
    )?.then((_) {
      // Ensure in-feed video stays paused upon return
      try {
        _videoPlayerController?.pause();
      } catch (_) {}
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Container(
        height: 200.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8.radius),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 32),
              SizedBox(height: 8.height),
              Text(
                'Video unavailable on this device',
                style: TextStyle(color: Colors.white54, fontSize: 14.fontSize),
              ),
            ],
          ),
        ),
      );
    }

    if (_chewieController == null ||
        _videoPlayerController == null ||
        !_chewieController!.videoPlayerController.value.isInitialized) {
      return Container(
        height: 200.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8.radius),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.radius),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: _chewieController!.aspectRatio ?? 16 / 9,
              child: Chewie(controller: _chewieController!),
            ),
          ),
          Positioned(
            top: 8.height,
            right: 8.width,
            child: GestureDetector(
              onTap: _openFullscreen,
              child: Container(
                padding: EdgeInsets.all(6.width),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fullscreen_rounded,
                  color: Colors.white,
                  size: 20.fontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
