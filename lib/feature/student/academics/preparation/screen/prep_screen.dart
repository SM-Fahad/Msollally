import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/academics/quiz/screen/start_quiz_screen.dart';
import 'package:msollaally/feature/student/academics/quiz/service/student_quiz_service.dart';
import 'package:msollaally/feature/student/academics/quiz/model/quiz_model.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/student/academics/preparation/service/prep_ai_service.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msollaally/core/const/appcolors.dart';

class StudentPrepScreen extends StatefulWidget {
  const StudentPrepScreen({super.key});

  @override
  State<StudentPrepScreen> createState() => _StudentPrepScreenState();
}

class _StudentPrepScreenState extends State<StudentPrepScreen> {
  final TextEditingController _moduleTitleController = TextEditingController();
  PlatformFile? _selectedModuleFile;
  bool _isGeneratingQuestions = false;

  String _selectedQuestionType = 'both'; // 'mcq', 'true_false', 'both'
  int _selectedQuestionCount = 10; // 5, 10, 15, 20

  List<QuizQuestion>? _generatedQuestions;
  String _lastGeneratedTitle = '';

  @override
  void dispose() {
    _moduleTitleController.dispose();
    super.dispose();
  }

  Future<void> _pickModuleFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedModuleFile = result.files.first;
          _generatedQuestions = null; // Reset previous generation
        });
        EasyLoading.showToast('Module selected: ${result.files.first.name}');
      }
    } catch (e) {
      debugPrint('Error picking module file: $e');
      EasyLoading.showError('Could not select file');
    }
  }

  Future<void> _generateQuestions() async {
    final title = _moduleTitleController.text.trim();
    if (title.isEmpty && _selectedModuleFile == null) {
      EasyLoading.showInfo('Please enter a module title or upload a course module file.');
      return;
    }

    setState(() {
      _isGeneratingQuestions = true;
    });
    EasyLoading.show(status: 'AI is analyzing module and generating questions...');

    try {
      final effectiveTitle = title.isNotEmpty
          ? title
          : (_selectedModuleFile?.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '') ?? 'Practice Module');

      final questions = await PrepAiService.generateQuestions(
        moduleTitle: title.isNotEmpty ? title : null,
        file: _selectedModuleFile,
        questionType: _selectedQuestionType,
        count: _selectedQuestionCount,
      );

      EasyLoading.dismiss();

      if (questions.isEmpty) {
        EasyLoading.showError('Failed to generate practice questions.');
        return;
      }

      setState(() {
        _generatedQuestions = questions;
        _lastGeneratedTitle = effectiveTitle;
      });

      EasyLoading.showSuccess('Practice questions generated successfully!');
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to generate questions: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingQuestions = false;
        });
      }
    }
  }

  void _startGeneratedQuiz() {
    if (_generatedQuestions == null || _generatedQuestions!.isEmpty) {
      EasyLoading.showInfo('Please generate questions first.');
      return;
    }

    Get.to(
      () => StartQuizScreen(
        quizTitle: 'Quiz: $_lastGeneratedTitle',
        generatedQuestions: _generatedQuestions,
        initialQuestionType: _selectedQuestionType,
        initialTotalQuestions: _selectedQuestionCount,
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadHistory() async {
    final service = StudentQuizService();
    int userId = 0;
    if (Get.isRegistered<StudentProfileController>()) {
      userId = Get.find<StudentProfileController>().userId.value;
    }

    int competitionId = 2; // fallback
    if (Get.isRegistered<StudentCampusController>()) {
      final campusCtrl = Get.find<StudentCampusController>();
      if (campusCtrl.competitionsList.isNotEmpty) {
        competitionId = campusCtrl.competitionsList.first.id;
      }
    }
    return service.fetchQuizHistory(
      userId: userId,
      competitionId: competitionId,
    );
  }

  IconData _getFileIcon(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/exam_icon.png',
                    height: 44,
                    width: 44,
                    color: Colors.blueGrey,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.quiz,
                        size: 44,
                        color: Colors.blueGrey,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Exam Prep Tool",
                    style: getTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              OutlinedButton(
                onPressed: () {
                  Get.to(() => const StartQuizScreen(quizTitle: "General Exam Prep"));
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.blue, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  "Start a Quiz",
                  style: getTextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// AI Practice Questions Generator Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryButtonColor.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryButtonColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primaryButtonColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "AI Practice Questions from Module",
                            style: getTextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "Provide module title or upload course material",
                            style: getTextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Option 1: Mention module title
                TextField(
                  controller: _moduleTitleController,
                  decoration: InputDecoration(
                    labelText: "Option 1: Mention Module Title / Topic",
                    hintText: "e.g., Kinematics, Organic Chemistry, Algorithms",
                    prefixIcon: const Icon(Icons.title, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (_) {
                    if (_generatedQuestions != null) {
                      setState(() => _generatedQuestions = null);
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Option 2: Upload course module file
                Text(
                  "Option 2: Upload Module Material (PDF, PPT, DOCX, XLSX)",
                  style: getTextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),

                if (_selectedModuleFile != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(_selectedModuleFile!.extension),
                          color: AppColors.primaryButtonColor,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedModuleFile!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: getTextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${(_selectedModuleFile!.size / 1024).toStringAsFixed(1)} KB",
                                style: getTextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedModuleFile = null;
                              _generatedQuestions = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                OutlinedButton.icon(
                  onPressed: _pickModuleFile,
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: Text(
                    _selectedModuleFile == null ? "Select / Upload Module File" : "Change Uploaded File",
                    style: getTextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryButtonColor,
                    side: const BorderSide(color: AppColors.primaryButtonColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Question Type and Count Selectors
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedQuestionType,
                        decoration: InputDecoration(
                          labelText: "Question Type",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: const [
                          DropdownMenuItem(value: "mcq", child: Text("MCQ")),
                          DropdownMenuItem(value: "true_false", child: Text("True/False")),
                          DropdownMenuItem(value: "both", child: Text("Both")),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedQuestionType = val;
                              _generatedQuestions = null;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedQuestionCount,
                        decoration: InputDecoration(
                          labelText: "Total Questions",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 5, child: Text("5 Questions")),
                          DropdownMenuItem(value: 10, child: Text("10 Questions")),
                          DropdownMenuItem(value: 15, child: Text("15 Questions")),
                          DropdownMenuItem(value: 20, child: Text("20 Questions")),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedQuestionCount = val;
                              _generatedQuestions = null;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Buttons: Generate Questions & Start Quiz
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isGeneratingQuestions ? null : _generateQuestions,
                        icon: const Icon(Icons.psychology, size: 18),
                        label: Text(
                          _generatedQuestions != null ? "Regenerate" : "Generate Questions",
                          style: getTextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButtonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    if (_generatedQuestions != null && _generatedQuestions!.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _startGeneratedQuiz,
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: Text(
                            "Start Quiz",
                            style: getTextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                if (_generatedQuestions != null && _generatedQuestions!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Ready! ${_generatedQuestions!.length} questions generated for '$_lastGeneratedTitle'.",
                            style: getTextStyle(fontSize: 12, color: Colors.green.shade800, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// History Section
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.quiz_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          "No past quiz attempts found.",
                          style: getTextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final history = snapshot.data!;

              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recent Quiz Attempts",
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final item = history[index];
                          
                          // Extract values with safe fallbacks
                          final type = item['quizType']?.toString() ?? 'Practice';
                          final correct = item['score'] ?? item['correctAnswers'] ?? 0;
                          final total = item['totalQuestions'] ?? 10;
                          
                          String dateStr = 'N/A';
                          if (item['createdAt'] != null) {
                            try {
                              dateStr = DateTime.parse(item['createdAt'].toString())
                                  .toLocal()
                                  .toString()
                                  .split(' ')
                                  .first;
                            } catch (_) {}
                          }
                          
                          String time = 'N/A';
                          if (item['timeTaken'] != null) {
                            try {
                              final int totalSeconds = int.tryParse(item['timeTaken'].toString()) ?? 0;
                              time = "${(totalSeconds ~/ 60)}m ${totalSeconds % 60}s";
                            } catch (_) {}
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 1,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade50,
                                child: const Icon(Icons.check_circle_outline, color: Colors.blue),
                              ),
                              title: Text(
                                "$type Quiz",
                                style: getTextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              subtitle: Text(
                                "Date: $dateStr • Time: $time",
                                style: getTextStyle(color: Colors.black54, fontSize: 12),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "$correct / $total",
                                  style: getTextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
