// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../controller/mock_interview.dart';
import '../widgets/exit_confirmation_dialog.dart';
import '../widgets/interview_progress_header.dart';
import '../widgets/question_index_selector.dart';
import '../widgets/interactive_option_card.dart';
import '../widgets/interview_bottom_bar.dart';

class MockInterviewScreen extends StatelessWidget {
  final String topicId;
  final Duration duration;
  final String categoryTitle;

  const MockInterviewScreen({
    super.key,
    required this.topicId,
    this.duration = const Duration(minutes: 5),
    this.categoryTitle = "Mock Interview",
  });

  @override
  Widget build(BuildContext context) {
    // Inject controller with required params
    final controller = Get.put(
      MockController(
        topicId: topicId,
        duration: duration,
        categoryTitle: categoryTitle,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.panelBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryTextColor, size: 24.radius),
          onPressed: () => showExitConfirmationDialog(context),
        ),
        title: Text(
          categoryTitle,
          style: getTextStyle(
            color: AppColors.primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primaryButtonColor),
                SizedBox(height: 20.height),
                Text(
                  "Loading interview questions...",
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.questions.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.width),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, color: Colors.grey.shade400, size: 64.radius),
                  SizedBox(height: 16.height),
                  Text(
                    'No interview questions available for your university/department/program',
                    style: getTextStyle(
                      color: AppColors.secondaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final question = controller.currentQuestion;
        final currentIndex = controller.currentIndex.value;

        return Column(
          children: [
            InterviewProgressHeader(controller: controller),
            QuestionIndexSelector(controller: controller),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.width),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    key: ValueKey<int>(currentIndex),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.width),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.radius),
                          border: Border.all(color: AppColors.sectionBorderColor, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.01),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.width, vertical: 4.height),
                              decoration: BoxDecoration(
                                color: AppColors.tagBackgroundColor,
                                borderRadius: BorderRadius.circular(6.radius),
                              ),
                              child: Text(
                                "QUESTION ${currentIndex + 1}",
                                style: getTextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.tertiaryTextColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            SizedBox(height: 14.height),
                            Text(
                              question.question,
                              style: getTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryTextColor,
                                  height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.height),
                      Text(
                        "Select your answer",
                        style: getTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      SizedBox(height: 12.height),
                      ...List.generate(question.options.length, (optIndex) {
                        final optionText = question.options[optIndex];
                        final isSelected = controller.selectedAnswer.value == optIndex;
                        
                        return InteractiveOptionCard(
                          optionText: optionText,
                          optIndex: optIndex,
                          isSelected: isSelected,
                          onTap: () => controller.selectOption(optIndex),
                        );
                      }),
                      SizedBox(height: 24.height),
                    ],
                  ),
                ),
              ),
            ),
            InterviewBottomBar(controller: controller),
          ],
        );
      }),
    );
  }
}
