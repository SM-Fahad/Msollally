import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class PracticeErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PracticeErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: getTextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh),
              label: Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
