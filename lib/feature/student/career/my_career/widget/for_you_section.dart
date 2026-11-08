import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../controller/my_career_controller.dart';

/// Renders the "For You" items list from [CareerController.forYouItems].
class ForYouSection extends StatelessWidget {
  final CareerController controller;

  const ForYouSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.forYouItems.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No recommendations yet.',
              style: getTextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return Column(
        children: controller.forYouItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.grey.shade100,
              leading: item.icon != null
                  ? SvgPicture.asset(
                      IconsPath.rocketIcon,
                      height: 32,
                      width: 32,
                    )
                  : const Icon(Icons.info, color: Colors.blue),
              title: Text(
                item.title,
                style: getTextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(item.description),
              onTap: item.onTap,
            ),
          );
        }).toList(),
      );
    });
  }
}
