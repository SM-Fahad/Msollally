import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../controller/cv_controller.dart';

class CvPhoneField extends StatelessWidget {
  final String label;
  final CvController controller;

  const CvPhoneField({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color.fromARGB(255, 109, 112, 114),
            ),
          ),
          SizedBox(height: 4),
          IntlPhoneField(
            controller: controller.phoneController,
            initialCountryCode: 'TZ',
            onChanged: (phone) {
              controller.phoneValue.value = phone.completeNumber;
            },
            decoration: InputDecoration(
              hintText: "Enter $label",
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryButtonColor),
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.darkGray9DA4AE),
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
