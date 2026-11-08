import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class CustomWallTextField extends StatelessWidget {
  const CustomWallTextField({
    super.key,
    required this.profileImage,
    required this.controller,
    this.hintText = "What’s on your mind?",
    this.onPhotoTap,
    this.onSubmitted,
    this.bottomWidget,
    this.readOnly,
    this.textFieldOntap,
  });

  final String profileImage;
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onPhotoTap;
  final VoidCallback? onSubmitted;
  final Widget? bottomWidget;
  final bool? readOnly;
  final VoidCallback? textFieldOntap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.width),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100.radius),
                child: Image.asset(profileImage, height: 44.height, width: 44.width),
              ),
              SizedBox(width: 7.width),

              /// Input Field
              Expanded(
                child: Container(
                  height: 44.height,
                  padding: EdgeInsets.only(left: 12.width, right: 12.width),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50.radius),
                    border: Border.all(color: AppColors.lightGrayCCCCCC),
                  ),
                  child: TextFormField(
                    onTap: textFieldOntap,
                    readOnly: readOnly ?? true,

                    controller: controller,
                    onFieldSubmitted: (_) => onSubmitted?.call(),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 12.height),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                      hintText: hintText,
                      hintStyle: getTextStyle(
                        fontSize: 14.fontSize,
                        fontWeight: FontWeight.w500,
                        color: AppColors.appBarTitleColor.withValues(alpha: 0.3),
                        letterSpacing: 0.2.fontSize,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 19.width),

              /// Photo Button
              GestureDetector(
                onTap: onPhotoTap,
                child: const Icon(
                  Icons.photo_library,
                  size: 24,
                  color: AppColors.appBarTitleColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.height),

        if (bottomWidget != null) bottomWidget!,
      ],
    );
  }
}
