import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../../../core/common/styles/global_text_style.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;
  final String lebelName;
  final Color? textFieldColor;
  final double? textFieldHeight;

  const CustomDropdown({
    super.key,
    this.textFieldColor,
    this.textFieldHeight,
    required this.lebelName,
    required this.items,
    this.value,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lebelName,
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 8.height),

          Container(
            height: textFieldHeight ?? 48.height,
            width: double.infinity,

            padding: EdgeInsets.only(left: 12.width, right: 12.width),
            decoration: BoxDecoration(
              color: textFieldColor ?? Colors.white,
              borderRadius: BorderRadius.circular(12.radius),
              border: Border.all(color: AppColors.textfieldBorderColor),
            ),

            child: DropdownButton<String>(
              isExpanded: true,
              underline: const SizedBox.shrink(),
              icon: const Icon(
                Icons.keyboard_arrow_down_sharp,
                color: Colors.grey,
              ),
              hint: Text(
                hint,
                style: getTextStyle(color: Colors.grey, fontSize: 16),
              ),
              value: value,
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
