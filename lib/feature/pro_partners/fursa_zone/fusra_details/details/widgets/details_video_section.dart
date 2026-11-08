import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../controller/fusra_details_controller.dart';
import 'details_state_card.dart';

class DetailsVideoSection extends StatelessWidget {
  const DetailsVideoSection({super.key, required this.controller});

  final FusraDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.videoError.value.isNotEmpty) {
        return StateCard(
          icon: Icons.videocam_off_outlined,
          text: controller.videoError.value,
        );
      }

      if (controller.isVideoInitializing.value) {
        return const _VideoFrame(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.isYoutubeVideo.value) {
        return _YoutubeVideoCard(controller: controller);
      }

      if (controller.isWebVideo.value) {
        return _WebVideoCard(controller: controller);
      }

      return _NetworkVideoCard(controller: controller);
    });
  }
}

class _YoutubeVideoCard extends StatelessWidget {
  const _YoutubeVideoCard({required this.controller});

  final FusraDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final yt = controller.youtubePlayerController;

    if (yt == null) {
      return const StateCard(
        icon: Icons.videocam_off_outlined,
        text: 'Video not available',
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: yt,
        showVideoProgressIndicator: true,
        bottomActions: const [
          CurrentPosition(),
          ProgressBar(isExpanded: true),
          RemainingDuration(),
          // FullScreenButton(),
        ],
      ),
      builder: (_, player) {
        return Obx(() {
          final showPreview = !controller.hasStartedYoutubeVideo.value;

          return _VideoFrame(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(child: player),

                if (showPreview)
                  Positioned.fill(
                    child: Image.network(
                      controller.youtubeThumbnailUrl.value,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Container(color: Colors.black12),
                    ),
                  ),

                _PlayOverlay(
                  visible: !controller.isVideoPlaying.value,
                  onTap: controller.playOrPause,
                ),

                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Row(
                    children: [
                      _MiniControlButton(
                        icon: controller.isVideoMuted.value
                            ? Icons.volume_off
                            : Icons.volume_up,
                        onTap: controller.muteOrUnmute,
                      ),
                      const SizedBox(width: 8),
                      _MiniControlButton(
                        icon: Icons.fullscreen,
                        onTap: controller.openYoutubeFullscreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

class _WebVideoCard extends StatelessWidget {
  const _WebVideoCard({required this.controller});

  final FusraDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return _VideoFrame(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.primaryTextColor),
          Center(
            child: GestureDetector(
              onTap: controller.openWebVideoLink,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: _MiniControlButton(
              icon: Icons.open_in_new,
              onTap: controller.openWebVideoLink,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkVideoCard extends StatelessWidget {
  const _NetworkVideoCard({required this.controller});

  final FusraDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final player = controller.videoPlayerController;

    if (player == null || !player.value.isInitialized) {
      return const StateCard(
        icon: Icons.videocam_off_outlined,
        text: 'Video unavailable',
      );
    }

    // ✅ FIX 1: Use controller.videoPosition / videoDuration (both are .obs)
    // instead of player.value.position / duration (ChangeNotifier, not GetX —
    // Obx never re-ran for them, so the slider was always frozen at 0).
    return Obx(() {
      final position = controller.videoPosition.value;
      final duration = controller.videoDuration.value;

      return _VideoFrame(
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: AspectRatio(
                  aspectRatio: player.value.aspectRatio <= 0
                      ? 16 / 9
                      : player.value.aspectRatio,
                  child: VideoPlayer(player),
                ),
              ),
            ),

            _PlayOverlay(
              visible: !controller.isVideoPlaying.value,
              onTap: controller.playOrPause,
            ),

            Positioned(
              left: 10,
              right: 10,
              bottom: 8,
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      min: 0,
                      max: duration.inMilliseconds > 0
                          ? duration.inMilliseconds.toDouble()
                          : 1,
                      value: position.inMilliseconds
                          .clamp(
                            0,
                            duration.inMilliseconds > 0
                                ? duration.inMilliseconds
                                : 1,
                          )
                          .toDouble(),
                      onChanged: (value) {
                        controller.seekTo(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
                    ),
                  ),

                  Row(
                    children: [
                      _MiniControlButton(
                        icon: controller.isVideoPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
                        onTap: controller.playOrPause,
                      ),
                      // _MiniControlButton(
                      //   icon: controller.isVideoMuted.value
                      //       ? Icons.volume_off
                      //       : Icons.volume_up,
                      //   onTap: controller.muteOrUnmute,
                      // ),
                      Text(
                        '${_time(position)} / ${_time(duration)}',
                        style: getTextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      _MiniControlButton(
                        icon: Icons.fullscreen,
                        onTap: controller.openNetworkFullscreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  String _time(Duration d) {
    final mins = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$mins:$secs';
  }
}

class _VideoFrame extends StatelessWidget {
  const _VideoFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _PlayOverlay extends StatelessWidget {
  const _PlayOverlay({required this.visible, required this.onTap});

  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Positioned.fill(
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniControlButton extends StatelessWidget {
  const _MiniControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}
