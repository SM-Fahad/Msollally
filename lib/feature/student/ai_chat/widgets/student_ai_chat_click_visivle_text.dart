import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:msollaally/feature/student/ai_chat/controller/student_ai_chat_controller.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/const/icons_path.dart';

class StudentChatAIClickVisibleText extends StatelessWidget {
  const StudentChatAIClickVisibleText({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentAIChatController>();

    return Obx(
      () => ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.width),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 20.height),
            child: Row(
              mainAxisAlignment: message.isUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── AI avatar (chatbot.png) ───────────────────────
                if (!message.isUser) ...[
                  ClipOval(
                    child: Image.asset(
                      IconsPath.chatbotIcon,
                      width: 36.width,
                      height: 36.height,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12.width),
                ],

                // ── Message bubble ────────────────────────────────
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.width,
                      vertical: 10.height,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.radius),
                        topRight: Radius.circular(12.radius),
                        bottomLeft: message.isUser
                            ? Radius.circular(12.radius)
                            : Radius.circular(0),
                        bottomRight: message.isUser
                            ? Radius.circular(0)
                            : Radius.circular(12.radius),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: MarkdownBody(
                      data: message.message,
                      styleSheet: MarkdownStyleSheet(
                        p: appTextStyleHeading2(
                            color: AppColors.darkSlateGray444444),
                        h1: appTextStyleHeading2(
                            color: AppColors.darkSlateGray444444,
                            fontWeight: FontWeight.bold),
                        h2: appTextStyleHeading2(
                            color: AppColors.darkSlateGray444444,
                            fontWeight: FontWeight.bold),
                        h3: appTextStyleHeading2(
                            color: AppColors.darkSlateGray444444,
                            fontWeight: FontWeight.bold),
                        h4: appTextStyleHeading2(
                            color: AppColors.darkSlateGray444444,
                            fontWeight: FontWeight.bold),
                        h5: appTextStyleHeading2(
                            color: AppColors.darkSlateGray444444,
                            fontWeight: FontWeight.bold),
                        h6: appTextStyleHeading2(
                            color: AppColors.darkSlateGray444444,
                            fontWeight: FontWeight.bold),
                        strong: appTextStyleHeading2(
                            color: AppColors.darkSlateGray444444,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                // ── User avatar (dynamic profile photo) ──────────
                if (message.isUser) ...[
                  SizedBox(width: 12.width),
                  _UserAvatar(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Dynamic user avatar widget ────────────────────────────────────────────────
class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Safely resolve profile image URL from StudentProfileController
    final profileImageUrl = Get.isRegistered<StudentProfileController>()
        ? Get.find<StudentProfileController>().profileImageUrl.value
        : '';

    if (profileImageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          profileImageUrl,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackAvatar(),
        ),
      );
    }

    return _fallbackAvatar();
  }

  Widget _fallbackAvatar() {
    return ClipOval(
      child: Image.asset(
        IconsPath.profileImageIconPNG,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
      ),
    );
  }
}
