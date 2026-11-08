import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/student_search_controller.dart';
import '../widgets/student_search_header.dart';
import '../widgets/student_search_category_chips.dart';
import '../widgets/student_search_results.dart';

class StudentSearchScreen extends StatelessWidget {
  const StudentSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentSearchController());

    return Scaffold(
      backgroundColor: AppColors.whiteFDFEFF,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StudentSearchHeader(controller: controller),
            StudentSearchCategoryChips(controller: controller),
            SizedBox(height: 12.height),
            Expanded(child: StudentSearchResults(controller: controller)),
          ],
        ),
      ),
    );
  }
}
