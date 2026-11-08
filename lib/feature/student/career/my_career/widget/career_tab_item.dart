import 'package:flutter/material.dart';

import 'package:msollaally/core/common/styles/global_text_style.dart';

/// A single tab label with an active indicator underline.
class CareerTabItem extends StatelessWidget {
  final String label;
  final bool isActive;

  const CareerTabItem({super.key, required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: getTextStyle(
              color: isActive ? Colors.blue : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 30,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }
}
