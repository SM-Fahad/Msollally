import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class LibraryHeader extends StatelessWidget {
  const LibraryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Top Row
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/icons/library_icon.png',
              height: 70,
              width: 44,
              color: Colors.black,
            ),
            SizedBox(width: 8),
            Text(
              "Library",
              style: getTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        /// Grey line divider
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }
}
