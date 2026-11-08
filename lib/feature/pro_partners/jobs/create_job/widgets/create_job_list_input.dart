import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/pro_partners/jobs/create_job/widgets/create_job_input_field.dart';

class CreateJobListInput extends StatelessWidget {
  final String hint;
  final TextEditingController inputController;
  final RxList<String> items;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  const CreateJobListInput({
    super.key,
    required this.hint,
    required this.inputController,
    required this.items,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CreateJobInputField(
                controller: inputController,
                hint: hint,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryButtonColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (items.isEmpty) {
            return const SizedBox.shrink();
          }
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(items.length, (index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tagBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.tagBorderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        items[index],
                        style: const TextStyle(
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onRemove(index),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        }),
      ],
    );
  }
}
