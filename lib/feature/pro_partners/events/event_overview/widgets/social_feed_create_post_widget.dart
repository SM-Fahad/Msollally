import 'dart:io';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/event_overview_controller.dart';

class CreatePostCard extends StatelessWidget {
  final String controllerTag;

  const CreatePostCard({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventOverviewController>(tag: controllerTag);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: AppColors.whiteSmokeECECEC),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Post',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            'Share Updates with event attendees',
            style: TextStyle(fontSize: 12, color: AppColors.gray7A7A7A),
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(child: Text('TC')),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller.draftController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'What would you like to share with attendees?',
                        filled: true,
                        fillColor: AppColors.whiteSmokeF5F5F6,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.lavenderEAEAEA),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.whiteSmokeECECEC),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.lightGrayCCCCCC),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Obx(() {
                      if (controller.pickedFilePath.value != null) {
                        final p = controller.pickedFilePath.value!;
                        if (controller.pickedFileType.value == 'image') {
                          final f = File(p);
                          if (f.existsSync()) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                f,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            );
                          }
                        }
                        // video or missing file fallback
                        return Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child: Icon(Icons.videocam, size: 40)),
                        );
                      }
                      return SizedBox.shrink();
                    }),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () async => await controller.pickImage(),
                icon: Icon(
                  Icons.photo_outlined,
                  size: 18,
                  color: AppColors.black111111,
                ),
                label: Text(
                  'Photo',
                  style: TextStyle(fontSize: 14, color: AppColors.black111111),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.black111111,
                  side: BorderSide(color: AppColors.whiteSmokeECECEC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () async => await controller.pickVideo(),
                icon: Icon(
                  Icons.videocam_outlined,
                  size: 18,
                  color: AppColors.black111111,
                ),
                label: Text(
                  'Video',
                  style: TextStyle(fontSize: 14, color: AppColors.black111111),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.black111111,
                  side: BorderSide(color: AppColors.whiteSmokeECECEC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  controller.addPostFromDraft();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  elevation: 0,
                ),
                child: Text(
                  'Post',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
