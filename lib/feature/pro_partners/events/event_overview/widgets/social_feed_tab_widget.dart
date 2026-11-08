import 'package:flutter/material.dart';
import 'social_feed_index_widget.dart';

class SocialFeedTabWidget extends StatelessWidget {
  final String controllerTag;

  const SocialFeedTabWidget({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    return SocialFeedIndex(controllerTag: controllerTag);
  }
}
