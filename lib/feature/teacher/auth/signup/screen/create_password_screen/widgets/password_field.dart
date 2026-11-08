import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../controller/teacher_create_password_controller.dart';

class PasswordField extends StatelessWidget {
  final TeacherCreatePasswordController controller;

  const PasswordField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.0, top: 20.0),
          child: Text(
            "Password",
            style: getTextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        Obx(
          () => TextField(
            controller: controller.passwordController,
            obscureText: controller.isPasswordHidden.value,
            onChanged: (value) => controller.passwordStrength.value = value,
            decoration: InputDecoration(
              hintText: "Enter your password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordHidden.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () => controller.isPasswordHidden.value =
                    !controller.isPasswordHidden.value,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
