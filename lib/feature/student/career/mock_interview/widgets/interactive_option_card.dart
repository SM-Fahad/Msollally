import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class InteractiveOptionCard extends StatelessWidget {
  final String optionText;
  final int optIndex;
  final bool isSelected;
  final VoidCallback onTap;

  const InteractiveOptionCard({
    super.key,
    required this.optionText,
    required this.optIndex,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.height),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.radius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 14.height),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primaryButtonColor.withValues(alpha: 0.04) 
                : Colors.white,
            borderRadius: BorderRadius.circular(14.radius),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primaryButtonColor 
                  : AppColors.sectionBorderColor,
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColors.primaryButtonColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 28.width,
                height: 28.height,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primaryButtonColor 
                      : Colors.grey.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected 
                        ? AppColors.primaryButtonColor 
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16.radius,
                          color: Colors.white,
                        )
                      : Text(
                          String.fromCharCode(65 + optIndex), // A, B, C, D
                          style: getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 14.width),
              Expanded(
                child: Text(
                  optionText,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected 
                        ? AppColors.primaryButtonColor 
                        : AppColors.primaryTextColor,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
