import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';

class TaskActionCard extends StatelessWidget {
  final String taskKey;
  final String title;
  final String subtitle;
  final String points;
  final IconData taskIcon;
  final String buttonText;
  final Color taskColor;
  final Color? buttonColor;
  final VoidCallback? onTaskCompleted;
  final VoidCallback? onTap;
  final bool isEnabled;

  static const Color successColor = AppColors.checkBoxActiveColor;
  static const Color defaultButtonColor = AppColors.black0F1117;

  const TaskActionCard({
    super.key,
    required this.taskKey,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.taskIcon,
    required this.buttonText,
    this.taskColor = AppColors.mediumPurpleA855F7,
    this.buttonColor,
    this.onTaskCompleted,
    this.onTap,
    this.isEnabled = true,
  });

  void _handleTaskAction(StudentCampusController controller) {
    if (isEnabled && onTaskCompleted != null) {
      onTaskCompleted!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentCampusController>();
    final Color activeButtonColor = buttonColor ?? defaultButtonColor;

    return Obx(() {
      final isCompleted = controller.taskCompleted[taskKey] ?? false;
      final Color currentColor = isCompleted ? successColor : taskColor;

      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.sliderColorInboarding),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: currentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : taskIcon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black1D1D1D,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: currentColor,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            points,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isCompleted || !isEnabled
                      ? null
                      : () => _handleTaskAction(controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEnabled ? activeButtonColor : AppColors.powderBlueC6D9FF,
                    disabledBackgroundColor: isEnabled 
                        ? activeButtonColor.withValues(alpha: .8) 
                        : AppColors.powderBlueC6D9FF,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isCompleted ? "COMPLETED" : buttonText.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
