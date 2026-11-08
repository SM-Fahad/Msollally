import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/campus/union/create_union/controller/create_union_controller.dart';
import 'package:msollaally/feature/student/campus/union/create_union/widgets/union_image_picker.dart';
import 'package:msollaally/feature/student/campus/union/create_union/widgets/create_union_form_fields.dart';
import 'package:msollaally/feature/student/campus/union/create_union/widgets/union_settings_switches.dart';

class CreateUnionScreen extends StatelessWidget {
  const CreateUnionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateUnionController controller = Get.put(CreateUnionController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Union',
          style: appTextStyleHeading1(fontSize: 18.fontSize),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.fontSize),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UnionImagePickers(controller: controller),
            SizedBox(height: 24.height),
            CreateUnionFormFields(controller: controller),
            SizedBox(height: 24.height),
            UnionSettingsSwitches(controller: controller),
            SizedBox(height: 32.height),
            _buildSubmitButton(controller),
            SizedBox(height: 40.height),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(CreateUnionController controller) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        onPressed: controller.createUnion,
        text: 'Create Union',
      ),
    );
  }
}
