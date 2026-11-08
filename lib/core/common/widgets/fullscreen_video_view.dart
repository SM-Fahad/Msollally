import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:msollaally/core/const/appcolors.dart';

class FullscreenVideoView extends StatefulWidget {
  final String videoUrl;

  const FullscreenVideoView({
    super.key,
    required this.videoUrl,
  });

  @override
  State<FullscreenVideoView> createState() => _FullscreenVideoViewState();
}

class _FullscreenVideoViewState extends State<FullscreenVideoView> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      _videoPlayerController = controller;

      await controller.initialize();

      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        aspectRatio: controller.value.aspectRatio > 0
            ? controller.value.aspectRatio
            : 16 / 9,
        allowFullScreen: false, // Already in full screen mode
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryButtonColor,
          handleColor: AppColors.primaryButtonColor,
          backgroundColor: Colors.grey.shade700,
          bufferedColor: Colors.white38,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.white54, size: 42),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      );

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('FullscreenVideoView init error: $e');
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
    }
  }

  void _closeAndExit() {
    try {
      _chewieController?.pause();
      _videoPlayerController?.pause();
    } catch (_) {}
    Get.back();
  }

  @override
  void dispose() {
    try {
      _chewieController?.pause();
      _videoPlayerController?.pause();
    } catch (_) {}
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        try {
          _chewieController?.pause();
          _videoPlayerController?.pause();
        } catch (_) {}
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: _isError
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.white54, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'Failed to load video on this device',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isError = false;
                              });
                              _initializePlayer();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      )
                    : (_chewieController != null &&
                            _videoPlayerController != null &&
                            _chewieController!
                                .videoPlayerController.value.isInitialized)
                        ? AspectRatio(
                            aspectRatio: _chewieController!.aspectRatio ?? 16 / 9,
                            child: Chewie(controller: _chewieController!),
                          )
                        : const CircularProgressIndicator(color: Colors.white),
              ),

              // Close / Back button in top left
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: _closeAndExit,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
