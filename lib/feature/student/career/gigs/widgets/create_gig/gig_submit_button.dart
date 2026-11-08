import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/common/widgets/custom_button.dart';
import '../../controller/gigs_controller.dart';

class GigSubmitButton extends StatelessWidget {
  const GigSubmitButton({super.key, required this.controller});

  final GigsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: CustomButton(
          text: controller.isSubmitting.value
              ? controller.editingGigId.value != null
                    ? 'Updating...'
                    : 'Creating...'
              : controller.editingGigId.value != null
              ? 'Update Gig'
              : 'Create Gig',
          onPressed: controller.isSubmitting.value
              ? () {}
              : () {
                  final gigId = controller.editingGigId.value;
                  if (gigId != null) {
                    controller.updateGig(gigId);
                  } else {
                    controller.createGig();
                  }
                },
        ),
      ),
    );
  }
}
