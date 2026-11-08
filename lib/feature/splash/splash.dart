import 'package:flutter/material.dart';
import 'package:msollaally/core/common/widgets/gradiant_custom.dart';
import 'package:msollaally/core/const/images_path.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: gradientBackground(
        Stack(
          alignment: Alignment.center,
          children: [
            Center(child: Image.asset(ImagesPath.splash)),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Text(
                'Version 1.0.0',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
