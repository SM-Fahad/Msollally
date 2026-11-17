// ignore_for_file: library_prefixes

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

class SocialSocketService extends GetxService {
  IO.Socket? _socket;
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper();

  // Observable events stream that controllers can listen to
  final onPostLiked = StreamController<Map<String, dynamic>>.broadcast();
  final onPostUnliked = StreamController<Map<String, dynamic>>.broadcast();
  final onPostCommented = StreamController<Map<String, dynamic>>.broadcast();
  final onNotification = StreamController<Map<String, dynamic>>.broadcast();

  Future<SocialSocketService> init() async {
    await _connect();
    return this;
  }

  Future<void> _connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = await _sharedPrefHelper.getAccessToken();
    if (token == null) {
      if (kDebugMode) {
        print("SocialSocketService: No access token found. Cannot connect.");
      }
      return;
    }

    final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';

    _socket = IO.io('${Urls.baseUrl}/social', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': formattedToken},
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      if (kDebugMode) {
        print("SocialSocketService: Connected");
      }
    });

    _socket!.onConnectError((data) {
      if (kDebugMode) {
        print("SocialSocketService: Connection Error: $data");
      }
    });

    _socket!.onDisconnect((_) {
      if (kDebugMode) {
        print("SocialSocketService: Disconnected");
      }
    });

    // Listen to Events
    _socket!.on('post:liked', (data) {
      if (kDebugMode) {
        print("SocialSocketService: post:liked -> $data");
      }
      if (data != null && data is Map) {
        onPostLiked.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('post:unliked', (data) {
      if (kDebugMode) {
        print("SocialSocketService: post:unliked -> $data");
      }
      if (data != null && data is Map) {
        onPostUnliked.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('post:commented', (data) {
      if (kDebugMode) {
        print("SocialSocketService: post:commented -> $data");
      }
      if (data != null && data is Map) {
        onPostCommented.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('notification', (data) {
      if (kDebugMode) {
        print("SocialSocketService: notification -> $data");
      }
      if (data != null && data is Map) {
        onNotification.add(Map<String, dynamic>.from(data));
      }
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  @override
  void onClose() {
    disconnect();
    onPostLiked.close();
    onPostUnliked.close();
    onPostCommented.close();
    onNotification.close();
    super.onClose();
  }
}
