import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/ai_chat/widgets/custom_text_field_button_student_ai_chat.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';

import '../../../../core/const/icons_path.dart';
import '../../academics/create_plan/screen/create_plan.dart';
import '../controller/student_ai_tips_controller.dart';

class StudentAiTipsPage extends StatelessWidget {
  const StudentAiTipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    var _controller = Get.put(StudentAiTipsController());
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.height),
          CustomAppBar(
            leadingIcon: Icon(Icons.arrow_back, size: 24),
            onLeadingTap: () {
              Get.back();
            },
            title: "AI Tips",
            actionWidget: Icon(Icons.more_vert, size: 24),

            onActionTap: () {
              //

              //
            },
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: 20.width,
              vertical: 24.height,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(IconsPath.studyTipsIcon, height: 50.height, width: 50.width),
                SizedBox(height: 2.height),
                Text(
                  "Study Tips For Your Next Exam",
                  style: appTextStyleHeading1(
                    fontSize: 18.fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2.fontSize,
                  ),
                ),
                // Divider(
                //   color: AppColors.black000000.withValues(alpha: .12),
                //   thickness: 2,
                // ),
                SizedBox(height: 12.height),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: AppColors.black000000.withValues(alpha: .12),
                ),

                SizedBox(
                  height: 150.height,
                  child: Obx(() {
                    if (_controller.isLoading.value && _controller.studyTipsItem.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.mediumPurple8757F3,
                        ),
                      );
                    }
                    if (_controller.studyTipsItem.isEmpty) {
                      return Center(
                        child: Text(
                          "No study tips loaded. Try asking a question below!",
                          style: appTextStyleHeading2(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _controller.studyTipsItem.length,
                      itemBuilder: (_, index) {
                        final tip = _controller.studyTipsItem[index];
                        final isQuery = tip.startsWith("Query: ");
                        final displayText = isQuery ? tip.substring(7) : tip;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 13.height),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isQuery ? "❓" : "•",
                                style: appTextStyleHeading2(
                                  fontSize: 14.fontSize,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2.fontSize,
                                  color: isQuery ? AppColors.mediumPurple8757F3 : Colors.black,
                                ),
                              ),
                              SizedBox(width: 6.width),
                              Expanded(
                                child: Text(
                                  displayText,
                                  style: appTextStyleHeading2(
                                    fontSize: 14.fontSize,
                                    fontWeight: isQuery ? FontWeight.w700 : FontWeight.w500,
                                    letterSpacing: 0.2.fontSize,
                                    color: isQuery ? AppColors.mediumPurple8757F3 : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
                SizedBox(height: 24.height),
                Text(
                  "You can create a study Plan for your \nnext exam",
                  style: appTextStyleHeading1(letterSpacing: -0.2.fontSize),
                ),
                SizedBox(height: 12.height),

                InkWell(
                  onTap: () {
                    Get.to(() => const CreatePlanScreen());
                  },
                  borderRadius: BorderRadius.circular(8.radius),
                  child: Container(
                    height: 32.height,
                    width: 120.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.radius),
                      color: AppColors.mediumPurple8757F3,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            IconsPath.aiIcon,
                            height: 16.height,
                            width: 16.width,
                          ),
                          Text(
                            "Create Plan",
                            style: appTextStyleHeading2(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Spacer(flex: 1),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Obx(
              () => IgnorePointer(
                ignoring: _controller.isLoading.value,
                child: Opacity(
                  opacity: _controller.isLoading.value ? 0.6 : 1.0,
                  child: CustomTextFieldButtonStudentAiChat(
                    onSubmitted: (_) => _controller.submitQuery(),
                    hintText: _controller.isLoading.value ? "AI is typing..." : "Type here",
                    controller: _controller.aiTipsTexDitiongController,
                    prefix: Icon(Icons.add),
                    suffix: InkWell(
                      onTap: _controller.submitQuery,
                      child: SvgPicture.asset(IconsPath.voiceButtonIcon),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 21.height),
        ],
      ),
    );
  }
}
