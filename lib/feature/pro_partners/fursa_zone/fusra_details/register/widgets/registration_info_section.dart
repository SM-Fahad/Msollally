import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

import '../../details/controller/fusra_details_controller.dart';

class RegistrationInfoSection extends StatelessWidget {
  const RegistrationInfoSection({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.expanded,
    required this.onTap,
    this.fields = const [],
    this.accountNumber,
    this.badgeText,
  });

  final String title;
  final Color backgroundColor;
  final bool expanded;
  final VoidCallback onTap;
  final List<InfoField> fields;
  final String? accountNumber;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    final hasBankData =
        (accountNumber ?? '').trim().isNotEmpty && accountNumber != 'N/A';
    final shouldShowPlaceholder = fields.isEmpty && !hasBankData;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkSlateGray334155,
                    ),
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.secondaryTextColor,
                ),
              ],
            ),
          ),
          if (expanded) ...[
            if (fields.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                runSpacing: 12,
                spacing: 12,
                children: fields
                    .map((field) => _InfoFieldTile(field: field))
                    .toList(growable: false),
              ),
            ],
            if (hasBankData) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      accountNumber!,
                      style: getTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if ((badgeText ?? '').isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .75),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.tagBorderColor),
                      ),
                      child: Text(
                        badgeText!,
                        style: getTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            if (shouldShowPlaceholder) ...[
              const SizedBox(height: 12),
              Text(
                'N/A',
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slateGray64748B,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _InfoFieldTile extends StatelessWidget {
  const _InfoFieldTile({required this.field});

  final InfoField field;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 64) / 2;
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: getTextStyle(fontSize: 12, color: AppColors.slateGray64748B),
          ),
          const SizedBox(height: 2),
          Text(
            field.value,
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black0F172A,
            ),
          ),
        ],
      ),
    );
  }
}
