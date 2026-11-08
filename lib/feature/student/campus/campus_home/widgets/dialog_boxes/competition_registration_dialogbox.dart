import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'controller/dialogbox_controller.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';

class CompetitionRegistrationDialog extends StatelessWidget {
  final int? competitionId;
  const CompetitionRegistrationDialog({super.key, this.competitionId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DialogboxController());
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Competition Registration",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black1D1D1D,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Complete your registration for the CRDB Bank Student Quiz Competition",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Academic Information",
                    style: TextStyle(
                      color: AppColors.blueViolet9333EA,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.honeydewF0FDF4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "Auto-filled",
                      style: TextStyle(color: AppColors.seaGreen16A34A, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildInputField(
                "Full Name",
                "John Doe",
                controller.fullNameController,
              ),
              _buildInputField(
                "Student ID",
                "STD-2024-9876",
                controller.studentIdController,
              ),
              _buildInputField(
                "University",
                "University of Dar es Salaam",
                controller.universityController,
              ),
              _buildInputField(
                "Program",
                "Computer Science",
                controller.programController,
              ),
              _buildInputField(
                "Email",
                "john.doe@student.udsm.ac.tz",
                controller.emailController,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.sliderColorInboarding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero, // Reduce internal padding
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: AppColors.black1D1D1D,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () async {
                          final userData = UserRegistrationData(
                            fullName: controller.fullNameController.text,
                            studentId: controller.studentIdController.text,
                            university: controller.universityController.text,
                            program: controller.programController.text,
                            email: controller.emailController.text,
                          );
                          controller.setUserRegistration(userData);
                          final success = await controller.submitRegistration(
                            competitionId: competitionId,
                          );
                          if (success) {
                            if (Get.isRegistered<StudentCampusController>()) {
                              Get.find<StudentCampusController>().loadFursaZoneData();
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueViolet9333EA,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Complete Registration",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String placeholder,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.darkSlateGray374151,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.sliderColorInboarding),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.sliderColorInboarding),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.blueViolet9333EA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
