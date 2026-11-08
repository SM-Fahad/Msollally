import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../controller/question_bank_controller.dart';
import '../model/question_bank_model.dart';
import 'practice_questions_screen.dart';
import 'qbank_pdf_viewer.dart';
import '../widgets/qbank_detail_card.dart';

class QbankDetailScreen extends StatelessWidget {
  final QuestionBankItem item;

  const QbankDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QbankController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.itemDetails.value?.id != item.id &&
          !controller.isDetailsLoading.value) {
        controller.fetchQuestionBankById(item.id);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.subjectName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Obx(() {
        if (controller.isDetailsLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.detailsErrorMessage.value.isNotEmpty &&
            controller.itemDetails.value == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 12),
                  Text(
                    controller.detailsErrorMessage.value,
                    textAlign: TextAlign.center,
                    style: getTextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.fetchQuestionBankById(item.id),
                    icon: Icon(Icons.refresh),
                    label: Text("Retry"),
                  ),
                ],
              ),
            ),
          );
        }

        final data = controller.itemDetails.value ?? item;

        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QbankDetailCard(item: data),
              SizedBox(height: 24),
              Text(
                "Documents",
                style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.folder_shared_outlined, size: 20),
                  label: Text(
                    "View Questions and Answer Sheet",
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    final targetUrl = data.answerSheetUrl.isNotEmpty
                        ? data.answerSheetUrl
                        : data.questionPaperUrl;
                    final title = "Questions & Answers – ${data.subjectName}";

                    if (targetUrl.isNotEmpty) {
                      Get.to(
                        () => QbankPdfViewer(
                          url: targetUrl,
                          title: title,
                        ),
                      );
                    } else {
                      EasyLoading.showInfo("Document not available yet.");
                    }
                  },
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Practice",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkSlateBlue3F51B5,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.quiz_outlined, size: 20),
                  label: Text(
                    "Start Practice Questions",
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () =>
                      Get.to(() => PracticeQuestionsScreen(qbankItem: data)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
