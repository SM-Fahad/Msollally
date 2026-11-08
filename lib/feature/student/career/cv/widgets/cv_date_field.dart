import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../../../core/const/icons_path.dart';
import '../controller/cv_controller.dart';

class CvDateField extends StatelessWidget {
  final String label;
  final CvController controller;
  final String? dateKey;
  final TextEditingController? textController;

  const CvDateField({
    super.key,
    required this.label,
    required this.controller,
    this.dateKey,
    this.textController,
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
          Obx(
            () => TextFormField(
              controller: textController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: _hasSelectedDate
                    ? controller.getFormattedDate(_resolvedDateKey)
                    : "Select $label",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    IconsPath.calenderIcon,
                    height: 20,
                    width: 20,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.dodgerBlueAlpha08418AFF,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  final formattedDate =
                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                  textController?.text = formattedDate;
                  controller.setDate(_resolvedDateKey, pickedDate);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String get _resolvedDateKey => dateKey ?? label;

  bool get _hasSelectedDate =>
      textController?.text.isNotEmpty == true ||
      controller.selectedDates.containsKey(_resolvedDateKey);
}
