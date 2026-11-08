import 'package:flutter/material.dart'
    show Colors, Icons, InkWell, showModalBottomSheet;
import 'package:flutter/widgets.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/ai_chat/widgets/custom_text_field_button_student_ai_chat.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';

import '../../../../core/const/images_path.dart';
import 'package:msollaally/core/const/appcolors.dart';

Future<dynamic> studentCommentModalBotomSheet(BuildContext context) {
  // ignore: no_leading_underscores_for_local_identifiers
  var _controller = Get.put(StudentProfileController());

  return showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(color: AppColors.aiChatBGColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 57.height,
              width: double.infinity,
              color: Colors.white,
            ),
            SizedBox(height: 20.height),

            Obx(
              () => SizedBox(
                height: 645.height,
                child: ListView.builder(
                  itemCount: _controller.comments.length,
                  itemBuilder: (_, index) {
                    // ignore: no_leading_underscores_for_local_identifiers
                    final _items = _controller.comments[index];
                    return Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal: 20.width,
                        vertical: 20.height,
                      ),
                      child: SizedBox(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      100.radius,
                                    ),
                                    child: Image.asset(
                                      ImagesPath.coverPhoto,
                                      fit: BoxFit.cover,
                                      height: 48.height,
                                      width: 48.height,
                                    ),
                                  ),
                                  SizedBox(width: 10.width),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _items.name,
                                        style: appTextStyleHeading1(
                                          fontSize: 20.fontSize,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.fontSize,
                                        ),
                                      ),

                                      SizedBox(
                                        child: Text(
                                          _items.comment,
                                          style: appTextStyleHeading2(
                                            fontSize: 18.fontSize,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 0.fontSize,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10.height),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            //time & like
                                            child: SizedBox(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    " ${_items.time} hr",
                                                    style: appTextStyleHeading2(
                                                      fontSize: 15.fontSize,
                                                    ),
                                                  ),
                                                  SizedBox(width: 24.width),

                                                  Obx(
                                                    () => InkWell(
                                                      onTap: () {
                                                        _items.isLiked.toggle();
                                                      },
                                                      child: Text(
                                                        "Like",
                                                        style:
                                                            appTextStyleHeading2(
                                                              fontSize: 15.fontSize,
                                                              color:
                                                                  _items
                                                                      .isLiked
                                                                      .value
                                                                  ? Colors.blue
                                                                  : AppColors.darkSlateGrayAlpha803F3F3F,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 130.width),

                                          //react and count
                                          SizedBox(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.favorite,
                                                  size: 24,
                                                  color:
                                                      AppColors.uiDangerColor,
                                                ),
                                                Text(
                                                  " 2",
                                                  style: appTextStyleHeading1(
                                                    fontSize: 14.fontSize,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.more_vert, size: 24),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Spacer(flex: 1),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 20.width,
                vertical: 32.height,
              ),
              child: CustomTextFieldButtonStudentAiChat(
                hintText: "Comment",
                controller: _controller.comentController,
                prefix: Icon(
                  Icons.camera_alt_sharp,
                  size: 24,
                  color: AppColors.textfieldBorderColor,
                ),
                suffix: InkWell(
                  onTap: () {
                    _controller.sendComment(_controller.comentController.text);
                    _controller.comentController.clear();

                    debugPrint(
                      "=============================== ${_controller.comments.length}",
                    );
                  },
                  child: Icon(
                    Icons.send,
                    color: AppColors.buttonTextColorGoogleAppleOnboarding,
                  ),
                ),
                gradient: LinearGradient(
                  colors: [AppColors.lightGrayCBD5E1, AppColors.lightGrayCBD5E1],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
