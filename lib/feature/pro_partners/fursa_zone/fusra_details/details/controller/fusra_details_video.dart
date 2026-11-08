part of 'fusra_details_controller.dart';

extension FusraDetailsVideoX on FusraDetailsController {
  String? extractYoutubeVideoId(String url) {
    return YoutubePlayer.convertUrlToId(url);
  }

  String youtubeThumbnailFromId(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }

  Future<void> initializeVideo() async {
    await disposeVideoControllers();
    final url = promoVideoLink.value.trim();
    if (url.isEmpty) {
      videoError.value = 'Video URL not available';
      return;
    }

    final ytId = extractYoutubeVideoId(url);
    if (ytId != null && ytId.isNotEmpty) {
      isYoutubeVideo.value = true;
      isWebVideo.value = false;
      hasStartedYoutubeVideo.value = false;
      pendingYoutubeAutoPlay.value = false;
      youtubeThumbnailUrl.value = youtubeThumbnailFromId(ytId);
      youtubePlayerController =
          YoutubePlayerController(
            initialVideoId: ytId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              enableCaption: false,
              hideControls: false,
            ),
          )..addListener(() {
            final c = youtubePlayerController;
            if (c == null) return;
            if (pendingYoutubeAutoPlay.value && c.value.isReady) {
              c.play();
              pendingYoutubeAutoPlay.value = false;
            }
            isVideoPlaying.value = c.value.isPlaying;
            isVideoMuted.value = c.value.volume == 0;
          });
      return;
    }

    isYoutubeVideo.value = false;
    isWebVideo.value = false;
    isVideoInitializing.value = true;
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await videoPlayerController!.initialize();
      await videoPlayerController!.setLooping(false);
      await videoPlayerController!.setVolume(1);

      // ✅ FIX 1: Update position & duration observables so the slider animates live
      videoPlayerController!.addListener(() {
        final c = videoPlayerController;
        if (c == null || !c.value.isInitialized) return;
        isVideoPlaying.value = c.value.isPlaying;
        videoPosition.value = c.value.position;
        videoDuration.value = c.value.duration;
      });

      // Seed initial duration immediately after init
      videoDuration.value = videoPlayerController!.value.duration;
      videoPosition.value = Duration.zero;
    } catch (_) {
      isWebVideo.value = true;
      await videoPlayerController?.dispose();
      videoPlayerController = null;
    } finally {
      isVideoInitializing.value = false;
    }
  }

  Future<void> playOrPause() async {
    if (isYoutubeVideo.value) {
      final c = youtubePlayerController;
      if (c == null) return;
      if (!hasStartedYoutubeVideo.value) {
        hasStartedYoutubeVideo.value = true;
        if (c.value.isReady) {
          c.play();
        } else {
          pendingYoutubeAutoPlay.value = true;
        }
        return;
      }
      if (!c.value.isReady) return;
      if (c.value.isPlaying) {
        c.pause();
      } else {
        c.play();
      }
      return;
    }

    final c = videoPlayerController;
    if (c == null || !c.value.isInitialized) return;
    if (c.value.isPlaying) {
      await c.pause();
    } else {
      await c.play();
    }
  }

  Future<void> muteOrUnmute() async {
    if (isYoutubeVideo.value) {
      final c = youtubePlayerController;
      if (c == null || !c.value.isReady) return;
      if (isVideoMuted.value) {
        c.unMute();
        c.setVolume(100);
        isVideoMuted.value = false;
      } else {
        c.mute();
        c.setVolume(0);
        isVideoMuted.value = true;
      }
      return;
    }

    final c = videoPlayerController;
    if (c == null || !c.value.isInitialized) return;
    if (isVideoMuted.value) {
      await c.setVolume(1.0);
      isVideoMuted.value = false;
    } else {
      await c.setVolume(0.0);
      isVideoMuted.value = true;
    }
  }

  Future<void> seekTo(Duration value) async {
    final c = videoPlayerController;
    if (c == null || !c.value.isInitialized) return;
    await c.seekTo(value);
    videoPosition.value = value; // ✅ Update immediately for snappy slider feel
  }

  Future<void> openNetworkFullscreen() async {
    final c = videoPlayerController;
    if (c == null || !c.value.isInitialized) return;

    final wasPlaying = c.value.isPlaying;
    final startAt = c.value.position;
    if (wasPlaying) await c.pause();

    await prepareNetworkFullscreen(
      url: promoVideoLink.value,
      startAt: startAt,
      shouldAutoPlay: wasPlaying,
    );
    isFullscreenOpen.value = true;
    await Get.to<void>(
      () => _NetworkVideoFullscreen(url: promoVideoLink.value),
    );
    await restoreFromFullscreen();
  }

  Future<void> openYoutubeFullscreen() async {
    final c = youtubePlayerController;
    if (c == null || !c.value.isReady) return;
    c.toggleFullScreenMode();
  }

  Future<void> openWebVideoLink() async {
    final url = promoVideoLink.value.trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) {
      Get.snackbar('Invalid URL', 'Video link is not valid');
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      Get.snackbar('Unable to open', 'Could not open the video link');
    }
  }

  Future<void> disposeVideoControllers() async {
    await videoPlayerController?.dispose();
    videoPlayerController = null;
    youtubePlayerController?.dispose();
    youtubePlayerController = null;
    isVideoPlaying.value = false;
    isVideoMuted.value = false;
    hasStartedYoutubeVideo.value = false;
    pendingYoutubeAutoPlay.value = false;
    isYoutubeVideo.value =
        false; // ✅ FIX 2: Was missing — caused stale YouTube state
    isWebVideo.value = false;
    youtubeThumbnailUrl.value = '';
    videoPosition.value = Duration.zero; // ✅ FIX 1: Reset position/duration too
    videoDuration.value = Duration.zero;
    await disposeFullscreenController(restoreUi: false);
  }

  Future<void> prepareNetworkFullscreen({
    required String url,
    required Duration startAt,
    required bool shouldAutoPlay,
  }) async {
    await disposeFullscreenController(restoreUi: false);
    isFullscreenInitializing.value = true;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      await controller.seekTo(startAt);
      await controller.setVolume(isVideoMuted.value ? 0.0 : 1.0);
      if (shouldAutoPlay) {
        await controller.play();
      }
      controller.addListener(() {
        if (!controller.value.isInitialized) return;
        isFullscreenPlaying.value = controller.value.isPlaying;
        fullscreenPosition.value = controller.value.position;
        fullscreenDuration.value = controller.value.duration;
      });
      fullscreenVideoController = controller;
      isFullscreenPlaying.value = controller.value.isPlaying;
      isFullscreenMuted.value = isVideoMuted.value;
      fullscreenPosition.value = controller.value.position;
      fullscreenDuration.value = controller.value.duration;
    } catch (_) {
      videoError.value = 'Failed to open fullscreen video';
    } finally {
      isFullscreenInitializing.value = false;
    }
  }

  Future<void> toggleFullscreenPlayPause() async {
    final c = fullscreenVideoController;
    if (c == null || !c.value.isInitialized) return;
    if (c.value.isPlaying) {
      await c.pause();
    } else {
      await c.play();
    }
    isFullscreenPlaying.value = c.value.isPlaying;
  }

  Future<void> seekFullscreenTo(Duration value) async {
    final c = fullscreenVideoController;
    if (c == null || !c.value.isInitialized) return;
    await c.seekTo(value);
    fullscreenPosition.value = value;
  }

  Future<void> toggleFullscreenMute() async {
    final c = fullscreenVideoController;
    if (c == null || !c.value.isInitialized) return;
    if (isFullscreenMuted.value) {
      await c.setVolume(1.0);
      isFullscreenMuted.value = false;
    } else {
      await c.setVolume(0.0);
      isFullscreenMuted.value = true;
    }
  }

  Future<void> restoreFromFullscreen() async {
    final main = videoPlayerController;
    final full = fullscreenVideoController;
    if (main != null && full != null && main.value.isInitialized) {
      final position = full.value.position;
      await main.seekTo(position);
      videoPosition.value = position;
      await main.setVolume(isFullscreenMuted.value ? 0.0 : 1.0);
      isVideoMuted.value = isFullscreenMuted.value;
      if (full.value.isPlaying) {
        await main.play();
      }
      isVideoPlaying.value = main.value.isPlaying;
    }
    await disposeFullscreenController(restoreUi: true);
  }

  Future<void> closeFullscreen() async {
    if (Get.isOverlaysOpen || Get.currentRoute.isNotEmpty) {
      Get.back();
    }
  }

  Future<void> disposeFullscreenController({required bool restoreUi}) async {
    await fullscreenVideoController?.dispose();
    fullscreenVideoController = null;
    isFullscreenInitializing.value = false;
    isFullscreenPlaying.value = false;
    isFullscreenMuted.value = isVideoMuted.value;
    fullscreenPosition.value = Duration.zero;
    fullscreenDuration.value = Duration.zero;
    isFullscreenOpen.value = false;
    if (restoreUi) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
  }
}
