part of '../controller/fusra_details_controller.dart';

class _NetworkVideoFullscreen extends StatelessWidget {
  const _NetworkVideoFullscreen({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FusraDetailsController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          if (controller.isFullscreenInitializing.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final player = controller.fullscreenVideoController;
          if (player == null || !player.value.isInitialized) {
            return const Center(
              child: Icon(Icons.videocam_off_outlined, color: Colors.white70),
            );
          }

          final position = controller.fullscreenPosition.value;
          final duration = controller.fullscreenDuration.value;

          return Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: player.value.aspectRatio <= 0
                      ? 16 / 9
                      : player.value.aspectRatio,
                  child: VideoPlayer(player),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 14,
                child: Column(
                  children: [
                    Slider(
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
                        controller.seekFullscreenTo(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: controller.toggleFullscreenPlayPause,
                          icon: Icon(
                            controller.isFullscreenPlaying.value
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: controller.toggleFullscreenMute,
                          icon: Icon(
                            controller.isFullscreenMuted.value
                                ? Icons.volume_off
                                : Icons.volume_up,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${_time(position)} / ${_time(duration)}',
                          style: getTextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _time(Duration d) {
    final mins = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$mins:$secs';
  }
}
