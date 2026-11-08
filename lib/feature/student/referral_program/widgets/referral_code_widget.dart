import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReferralCodeCard extends StatelessWidget {
  final String referralCode;
  final String? referralLink;
  final VoidCallback onCopy;

  const ReferralCodeCard({
    super.key,
    required this.referralCode,
    this.referralLink,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final link = referralLink ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Referral Code
        const Text(
          'Your Referral Code',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                referralCode,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: referralCode));
                  onCopy();
                },
                child: const Icon(Icons.copy, size: 20, color: Colors.grey),
              ),
            ],
          ),
        ),
        if (link.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Your Referral Link',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    link,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: link));
                    onCopy();
                  },
                  child: const Icon(Icons.copy, size: 20, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
