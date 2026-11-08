import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/teacher_create_password_controller.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final TeacherCreatePasswordController controller;

  const PasswordStrengthIndicator({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String strength = controller.getPasswordStrength(
        controller.passwordStrength.value,
      );
      int level = controller.getStrengthLevel(
        controller.passwordStrength.value,
      );

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            strength,
            style: TextStyle(
              fontSize: 14,
              color: strength.isEmpty
                  ? Colors.grey
                  : strength == "Very Weak"
                  ? Colors.red
                  : strength == "Weak"
                  ? Colors.orange
                  : strength == "Medium"
                  ? Colors.blue
                  : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: List.generate(3, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 2),
                height: 4,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: index < level
                      ? (strength == "Very Weak"
                            ? Colors.red
                            : strength == "Weak"
                            ? Colors.orange
                            : strength == "Medium"
                            ? Colors.blue
                            : Colors.green)
                      : Colors.grey.shade300,
                ),
              );
            }),
          ),
        ],
      );
    });
  }
}
