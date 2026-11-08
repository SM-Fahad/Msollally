import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import '../../../../../core/const/icons_path.dart';
import '../controller/question_bank_controller.dart';
import '../model/question_bank_model.dart';
import 'question_bank_detail.dart';

class QuestionBankScreen extends StatelessWidget {
  final QbankController controller = Get.put(QbankController());

  QuestionBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text(
            "Question Bank",
            style: getTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Past Exam Papers from Your University",
            style: getTextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),

          /// Search bar
          TextField(
            onChanged: (value) => controller.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: "Search by subject, semester, university...",
              suffixIcon: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  IconsPath.searchIcon,
                  width: 20,
                  height: 20,
                  color: Colors.grey,
                ),
              ),
              filled: true,
              fillColor: Colors.white70,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          /// List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: getTextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: controller.fetchQuestionBanks,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }

              final list = controller.filteredQuestionBanks;

              if (list.isEmpty) {
                return const Center(child: Text("No results found"));
              }

              return RefreshIndicator(
                onRefresh: controller.fetchQuestionBanks,
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final QuestionBankItem item = list[index];
                    return _QuestionBankCard(item: item);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Card Widget ──────────────────────────────────────────────────────────────

class _QuestionBankCard extends StatelessWidget {
  final QuestionBankItem item;

  const _QuestionBankCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => QbankDetailScreen(item: item)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(167, 242, 241, 241),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Subject + Exam Type badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.subjectName,
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _ExamTypeBadge(examType: item.examType),
              ],
            ),
            const SizedBox(height: 6),

            /// University
            _InfoRow(label: "University", value: item.universityName),
            const SizedBox(height: 3),

            /// Program & Department
            _InfoRow(label: "Program", value: item.programName),
            const SizedBox(height: 3),
            _InfoRow(label: "Department", value: item.departmentName),
            const SizedBox(height: 8),

            /// Semester + MCQ count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 13,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.semester,
                      style: getTextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.quiz_outlined,
                      size: 13,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${item.mcqCount} MCQ${item.mcqCount != 1 ? 's' : ''}",
                      style: getTextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamTypeBadge extends StatelessWidget {
  final String examType;

  const _ExamTypeBadge({required this.examType});

  @override
  Widget build(BuildContext context) {
    final isFinal = examType.toLowerCase() == 'final';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isFinal ? Colors.blue.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isFinal ? Colors.blue.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Text(
        examType.toUpperCase(),
        style: getTextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isFinal ? Colors.blue.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "$label: ",
            style: getTextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          TextSpan(
            text: value,
            style: getTextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
