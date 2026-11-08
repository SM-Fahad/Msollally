import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class MorePremiumCard extends StatelessWidget {
  const MorePremiumCard({super.key, required this.onTapUpgrade});
  final VoidCallback onTapUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 1)),
      ),
      child: Column(
        children: [
          Text(
            "Go Premium",
            style: getTextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "job from top recruiters, Premium resume templates AI-powered resume optimization, Highlighted profile for recruiters.",
            textAlign: TextAlign.start,
            style: getTextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: onTapUpgrade,
            child: Container(
              width: double.maxFinite,
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.withValues(alpha: 1),
              ),
              child: Center(
                child: Text(
                  "Upgrade",
                  style: getTextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
