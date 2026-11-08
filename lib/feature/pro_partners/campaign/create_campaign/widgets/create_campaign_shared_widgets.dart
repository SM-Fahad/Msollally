import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';

class CampaignSectionCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const CampaignSectionCard({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.sliderColorInboarding),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackAlpha080F172A,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.black0F172A,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: AppColors.slateGray64748B,
            ),
          ),
          SizedBox(height: 20.h),
          child,
        ],
      ),
    );
  }
}

class CampaignFieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  final String? tag;

  const CampaignFieldLabel({
    super.key,
    required this.label,
    this.required = false,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.black0F172A,
            ),
            children: required
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.crimsonDC2626),
                    ),
                  ]
                : const [],
          ),
        ),
        if (tag != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.whiteSmokeF1F5F9,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              tag!,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.slateGray64748B,
              ),
            ),
          ),
      ],
    );
  }
}

InputDecoration campaignInputDecoration({
  required String hintText,
  String? helperText,
  String? errorText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    helperText: helperText,
    errorText: errorText,
    helperMaxLines: 3,
    errorMaxLines: 3,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.panelBackgroundColor,
    hintStyle: const TextStyle(
      color: AppColors.darkGray94A3B8,
      fontWeight: FontWeight.w500,
    ),
    helperStyle: const TextStyle(color: AppColors.slateGray64748B, height: 1.4),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.lavenderE2E8F0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.lavenderE2E8F0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.royalBlue2563EB, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.crimsonDC2626),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.crimsonDC2626, width: 1.6),
    ),
  );
}

class CampaignEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const CampaignEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lavenderE2E8F0),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: const BoxDecoration(
              color: AppColors.lavenderE2E8F0,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 26.sp, color: AppColors.darkSlateGray475569),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.black0F172A,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.45,
              color: AppColors.slateGray64748B,
            ),
          ),
        ],
      ),
    );
  }
}

class CampaignStepHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;

  const CampaignStepHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: AppColors.royalBlue2563EB,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.black0F172A,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          description,
          style: TextStyle(
            fontSize: 13.sp,
            height: 1.45,
            color: AppColors.slateGray64748B,
          ),
        ),
      ],
    );
  }
}

class CampaignFooterActions extends StatelessWidget {
  final String primaryText;
  final VoidCallback? primaryAction;
  final String? secondaryText;
  final VoidCallback? secondaryAction;
  final bool primaryFilled;

  const CampaignFooterActions({
    super.key,
    required this.primaryText,
    required this.primaryAction,
    this.secondaryText,
    this.secondaryAction,
    this.primaryFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    Widget content;
    if (secondaryText == null) {
      content = CustomButton(text: primaryText, onPressed: primaryAction);
    } else {
      content = Row(
        children: [
          Expanded(
            child: CustomButton(
              text: secondaryText!,
              onPressed: secondaryAction,
              color: Colors.white,
              textColor: AppColors.black0F172A,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomButton(
              text: primaryText,
              onPressed: primaryAction,
              color: primaryFilled ? null : Colors.white,
              textColor: primaryFilled ? Colors.white : AppColors.black0F172A,
            ),
          ),
        ],
      );
    }
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset + 16.h : 20.h),
      child: content,
    );
  }
}

class CampaignInfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;

  const CampaignInfoBanner({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.aliceBlueEFF6FF,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.powderBlueBFDBFE),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: AppColors.royalBlue2563EB),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.45,
                color: AppColors.darkSlateBlue1E3A8A,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
