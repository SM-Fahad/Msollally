import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import '../../controller/gigs_controller.dart';
import 'gig_form_styles.dart';

class GigTagSection extends StatelessWidget {
  const GigTagSection({super.key, required this.controller});

  final GigsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gigFieldLabel('Tags / Skills'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.tagInputController,
                decoration: gigFieldDecoration('e.g. React, Flutter, NestJS'),
                onSubmitted: (_) => controller.addTag(),
                textInputAction: TextInputAction.done,
              ),
            ),
            SizedBox(width: 8.width),
            ElevatedButton(
              onPressed: controller.addTag,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 15.height),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.radius),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        SizedBox(height: 10.height),
        Obx(
          () => controller.tags.isEmpty
              ? const SizedBox.shrink()
              : Wrap(
                  spacing: 8.width,
                  runSpacing: 4.height,
                  children: controller.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag, style: TextStyle(fontSize: 12.fontSize)),
                          onDeleted: () => controller.removeTag(tag),
                          backgroundColor: Colors.indigo.shade50,
                          deleteIconColor: Colors.indigo,
                          side: BorderSide.none,
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }
}
