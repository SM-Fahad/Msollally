import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';

class _UniversityAutocompleteController extends GetxController {
  final suggestions = <String>[].obs;
  final showSuggestions = false.obs;

  void updateSuggestions(String text, List<String> universities) {
    if (text.isEmpty) {
      suggestions.clear();
      showSuggestions.value = false;
      return;
    }

    final matches = universities
        .where((u) => u.toLowerCase().contains(text.toLowerCase()))
        .toList();

    suggestions.value = matches;
    showSuggestions.value = matches.isNotEmpty;
  }

  void toggleSuggestions(List<String> universities) {
    if (showSuggestions.value) {
      showSuggestions.value = false;
      suggestions.clear();
    } else {
      suggestions.value = List.from(universities);
      showSuggestions.value = true;
    }
  }

  void clearSuggestions() {
    suggestions.clear();
    showSuggestions.value = false;
  }
}

class UniversityAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final List<String> universities;

  const UniversityAutocomplete({
    super.key,
    required this.controller,
    required this.universities,
  });

  @override
  Widget build(BuildContext context) {
    final autocompleteController = Get.put(_UniversityAutocompleteController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (value) => autocompleteController.updateSuggestions(
                  value.trim(),
                  universities,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g Cornell University',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14.sp,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 14.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: AppColors.textfieldBorderColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.primaryButtonColor),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            InkWell(
              onTap: () {
                autocompleteController.toggleSuggestions(universities);
              },
              child: Container(
                height: 48.h,
                width: 48.w,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textfieldBorderColor),
                  borderRadius: BorderRadius.circular(8.r),
                  color: Colors.white,
                ),
                child: Icon(Icons.keyboard_arrow_down),
              ),
            ),
          ],
        ),

        Obx(
          () =>
              autocompleteController.showSuggestions.value &&
                  autocompleteController.suggestions.isNotEmpty
              ? Container(
                  margin: EdgeInsets.only(top: 8.h),
                  constraints: BoxConstraints(maxHeight: 180.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.textfieldBorderColor),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemBuilder: (context, idx) {
                      final item = autocompleteController.suggestions[idx];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            controller.text = item;
                            autocompleteController.clearSuggestions();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            child: Text(
                              item,
                              style: appTextStyleHeading2(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemCount: autocompleteController.suggestions.length,
                  ),
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}
