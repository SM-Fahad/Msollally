import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class PlansStateMessage extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  const PlansStateMessage({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: getTextStyle(fontSize: 15, color: Colors.black54),
            ),
            SizedBox(height: 12),
            OutlinedButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
