import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import '../controller/gigs_controller.dart';
import '../widgets/create_gig/gig_form_body.dart';

class CreateGigScreen extends StatelessWidget {
  const CreateGigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GigsController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.editingGigId.value != null ? 'Edit Gig' : 'Create Gig',
          ),
        ),
        leading: IconButton(
          onPressed: () {
            if (controller.editingGigId.value != null) {
              controller.resetForm();
            }
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.width),
        child: GigFormBody(controller: controller),
      ),
    );
  }
}
