import 'package:video_player/video_player.dart';

/// Coordinates video playback across feeds and screens so that only ONE video
/// can play at any given time. This prevents audio overlapping, excessive
/// memory usage, and hardware decoder starvation crashes.
class FeedVideoManager {
  static VideoPlayerController? _activeController;

  /// Registers that a controller is playing and pauses any previously active video.
  static void onPlay(VideoPlayerController controller) {
    if (_activeController != null && _activeController != controller) {
      try {
        if (_activeController!.value.isInitialized &&
            _activeController!.value.isPlaying) {
          _activeController!.pause();
        }
      } catch (_) {}
    }
    _activeController = controller;
  }

  /// Called when a controller pauses.
  static void onPause(VideoPlayerController controller) {
    if (_activeController == controller) {
      _activeController = null;
    }
  }

  /// Pauses any active video player across the entire feed.
  static void pauseAll() {
    if (_activeController != null) {
      try {
        if (_activeController!.value.isInitialized &&
            _activeController!.value.isPlaying) {
          _activeController!.pause();
        }
      } catch (_) {}
      _activeController = null;
    }
  }

  /// Unregisters a controller when it is disposed.
  static void unregister(VideoPlayerController controller) {
    if (_activeController == controller) {
      _activeController = null;
    }
  }
}
