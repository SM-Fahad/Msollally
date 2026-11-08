import 'package:flutter/material.dart';

class SessionGuard extends StatelessWidget {
  const SessionGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
