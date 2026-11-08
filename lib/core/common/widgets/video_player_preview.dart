import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:msollaally/core/const/appcolors.dart';

class VideoPlayerPreviewWidget extends StatefulWidget {
  final String? localFilePath;
  final String? remoteUrl;
  final double? height;
  final double borderRadius;
  final bool autoPlay;

  const VideoPlayerPreviewWidget({
    super.key,
    this.localFilePath,
    this.remoteUrl,
    this.height,
    this.borderRadius = 12,
    this.autoPlay = false,
  });

  @override
  State<VideoPlayerPreviewWidget> createState() =>
      _VideoPlayerPreviewWidgetState();
}

class _VideoPlayerPreviewWidgetState extends State<VideoPlayerPreviewWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localFilePath != widget.localFilePath ||
        oldWidget.remoteUrl != widget.remoteUrl) {
      _initPlayer();
    }
  }

  Future<void> _initPlayer() async {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _hasError = false;

    try {
      if (widget.localFilePath != null &&
          widget.localFilePath!.isNotEmpty &&
          File(widget.localFilePath!).existsSync()) {
        _controller = VideoPlayerController.file(File(widget.localFilePath!));
      } else if (widget.remoteUrl != null && widget.remoteUrl!.isNotEmpty) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.remoteUrl!),
        );
      }

      if (_controller != null) {
        await _controller!.initialize();
        if (widget.autoPlay) {
          await _controller!.play();
        }
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? 180;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        height: height,
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_hasError)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white70, size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      'Could not load video preview',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              )
            else if (!_isInitialized)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              GestureDetector(
                onTap: _togglePlayPause,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio > 0
                            ? _controller!.value.aspectRatio
                            : 16 / 9,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                    // Play / pause overlay
                    AnimatedOpacity(
                      opacity: _controller!.value.isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _controller!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                    // Video progress bar at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: VideoProgressIndicator(
                        _controller!,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: AppColors.primaryButtonColor,
                          bufferedColor: Colors.white30,
                          backgroundColor: Colors.black26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
