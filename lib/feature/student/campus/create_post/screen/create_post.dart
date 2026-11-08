import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';

import '../controller/create_post_controller.dart';

class CreatePost extends StatelessWidget {
  final String postableType;
  final int postableId;

  CreatePost({super.key, this.postableType = 'Union', this.postableId = 1});

  final PostController controller = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 22.fontSize),
          onPressed: () => Get.back(),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Create Post",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.fontSize),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 8.height),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 8.height),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.radius),
                ),
              ),
              onPressed: () {
                controller.createPost(
                  postableType: postableType,
                  postableId: postableId,
                );
              },
              child: Obx(
                () => controller.isSubmitting.value
                    ? SizedBox(
                        height: 16.fontSize,
                        width: 16.fontSize,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text("Post", style: TextStyle(fontSize: 14.fontSize)),
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Avatar + Name + Privacy
            Row(
              children: [
                GetBuilder<StudentProfileController>(
                  init: Get.find<StudentProfileController>(),
                  builder: (profileCtrl) {
                    return Obx(() {
                      final url = profileCtrl.profileImageUrl.value;
                      return CircleAvatar(
                        radius: 28.radius,
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                            (url.isNotEmpty && !url.contains('pravatar.cc'))
                            ? NetworkImage(url)
                            : const AssetImage("assets/images/profile.png")
                                  as ImageProvider,
                      );
                    });
                  },
                ),
                SizedBox(width: 12.width),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GetBuilder<StudentProfileController>(
                      init: Get.find<StudentProfileController>(),
                      builder: (profileCtrl) {
                        return Obx(
                          () => Text(
                            profileCtrl.displayName.value.isNotEmpty
                                ? profileCtrl.displayName.value
                                : "User",
                            style: TextStyle(
                              fontSize: 16.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                    Obx(
                      () => Text(
                        controller.selectedPrivacy.value,
                        style: TextStyle(fontSize: 14.fontSize, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                /// Privacy Dropdown
                Obx(
                  () => DropdownButtonHideUnderline(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.white, // popup background color
                      ),
                      child: DropdownButton<String>(
                        value: controller.selectedPrivacy.value,
                        icon: Icon(Icons.arrow_drop_down, size: 20.fontSize),
                        borderRadius: BorderRadius.circular(
                          12.radius,
                        ), // rounded corners
                        items: [
                          DropdownMenuItem(
                            value: "Public",
                            child: Row(
                              children: [
                                Icon(
                                  Icons.public,
                                  color: Colors.blue,
                                  size: 18.fontSize,
                                ),
                                SizedBox(width: 8.width),
                                Text(
                                  "Public",
                                  style: TextStyle(fontSize: 14.fontSize),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: "Friends",
                            child: Row(
                              children: [
                                Icon(
                                  Icons.group,
                                  color: Colors.green,
                                  size: 18.fontSize,
                                ),
                                SizedBox(width: 8.width),
                                Text(
                                  "Friends",
                                  style: TextStyle(fontSize: 14.fontSize),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (newValue) {
                          controller.selectedPrivacy.value = newValue!;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.height),

            /// Post Text Field
            TextField(
              controller: controller.textController,
              maxLines: 5,
              style: TextStyle(fontSize: 14.fontSize),
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(fontSize: 14.fontSize),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.radius),
                ),
                contentPadding: EdgeInsets.all(12.width),
              ),
            ),
            SizedBox(height: 20.height),

            /// Upload widget (Replaced UploadStudent with an Image Picker logic)
            Obx(() {
              if (controller.pickedFilePath.value != null) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.radius),
                      child: Image.file(
                        File(controller.pickedFilePath.value!),
                        width: double.infinity,
                        height: 200.height,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8.height,
                      right: 8.width,
                      child: GestureDetector(
                        onTap: controller.clearMedia,
                        child: CircleAvatar(
                          radius: 16.radius,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16.fontSize,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return GestureDetector(
                onTap: controller.pickMedia,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 20.height),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.radius),
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.image, size: 40.fontSize, color: Colors.grey),
                      SizedBox(height: 8.height),
                      Text(
                        "Add Photo",
                        style: TextStyle(
                          fontSize: 14.fontSize,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
