import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../controller/add_job_controller.dart';

class DescriptionWidget extends StatelessWidget {
  final AddJobController controller = Get.find();

  DescriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Jobs Description',
        //   style: TextStyle(color: AppColors.blackAlpha7F1E1E1E, fontSize: 16),
        // ),
        // SizedBox(height: 8),
        Container(
          height: 260,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: quill.QuillSimpleToolbar(
                  controller: controller.quillController,
                  config: quill.QuillSimpleToolbarConfig(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: quill.QuillEditor.basic(
                    controller: controller.quillController,
                    config: quill.QuillEditorConfig(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
