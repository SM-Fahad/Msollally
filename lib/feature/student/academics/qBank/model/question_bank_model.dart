class QuestionBankItem {
  final String id;
  final DateTime? createdAt;
  final String subjectName;
  final String semester;
  final String universityName;
  final String programName;
  final String departmentName;
  final String examType;
  final int mcqCount;
  final String questionPaperUrl;
  final String answerSheetUrl;

  QuestionBankItem({
    required this.id,
    this.createdAt,
    required this.subjectName,
    required this.semester,
    required this.universityName,
    required this.programName,
    required this.departmentName,
    required this.examType,
    required this.mcqCount,
    required this.questionPaperUrl,
    required this.answerSheetUrl,
  });

  factory QuestionBankItem.fromMap(Map<String, dynamic> map) {
    return QuestionBankItem(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
      subjectName: map['subjectName'] ?? '',
      semester: map['semester'] ?? '',
      universityName: map['universityName'] ?? '',
      programName: map['programName'] ?? '',
      departmentName: map['departmentName'] ?? '',
      examType: map['examType'] ?? '',
      mcqCount: map['mcqCount'] ?? 0,
      questionPaperUrl: map['questionPaperUrl'] ?? '',
      answerSheetUrl: map['answerSheetUrl'] ?? '',
    );
  }
}

// ─── Practice Question Models ───────────────────────────────────────────────

class PracticeOption {
  final String id;
  final String text;
  final int order;
  final bool? isCorrect; // populated by GET /question-bank/question/{id}

  PracticeOption({
    required this.id,
    required this.text,
    required this.order,
    this.isCorrect,
  });

  factory PracticeOption.fromMap(Map<String, dynamic> map) {
    return PracticeOption(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      order: map['order'] ?? 0,
      isCorrect: map['isCorrect'],
    );
  }
}

class PracticeQuestion {
  final String id;
  final String questionText;
  final String imageUrl;
  final String explanation;
  final int order;
  final List<PracticeOption> options;
  // Correct option id — populated after fetching single question
  final String? correctOptionId;

  PracticeQuestion({
    required this.id,
    required this.questionText,
    required this.imageUrl,
    required this.explanation,
    required this.order,
    required this.options,
    this.correctOptionId,
  });

  factory PracticeQuestion.fromMap(Map<String, dynamic> map) {
    final rawOptions = map['options'];
    final options = rawOptions is List
        ? rawOptions
              .whereType<Map<String, dynamic>>()
              .map(PracticeOption.fromMap)
              .toList()
        : <PracticeOption>[];

    // Some endpoints embed the correct answer inline
    final correctId = map['correctOptionId'] as String?;

    return PracticeQuestion(
      id: map['id'] ?? '',
      questionText: map['questionText'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      explanation: map['explanation'] ?? '',
      order: map['order'] ?? 0,
      options: options,
      correctOptionId: correctId,
    );
  }

  /// Returns true when this question has enough info to show the correct answer
  bool get hasAnswer => correctOptionId != null && correctOptionId!.isNotEmpty;
}

class PracticeResultSummary {
  final int totalQuestions;
  final int attendedCount;
  final int unattendedCount;
  final int correctAnswersCount;
  final int wrongAnswersCount;
  final double scorePercentage;

  PracticeResultSummary({
    required this.totalQuestions,
    required this.attendedCount,
    required this.unattendedCount,
    required this.correctAnswersCount,
    required this.wrongAnswersCount,
    required this.scorePercentage,
  });

  factory PracticeResultSummary.fromMap(Map<String, dynamic> map) {
    return PracticeResultSummary(
      totalQuestions: map['totalQuestions'] ?? 0,
      attendedCount: map['attendedCount'] ?? 0,
      unattendedCount: map['unattendedCount'] ?? 0,
      correctAnswersCount: map['correctAnswersCount'] ?? 0,
      wrongAnswersCount: map['wrongAnswersCount'] ?? 0,
      scorePercentage: (map['scorePercentage'] ?? 0).toDouble(),
    );
  }
}

class PracticeResultItem {
  final String questionId;
  final bool isCorrect;
  final bool isAttended;
  final String correctOptionId;
  final String? selectedOptionId;

  PracticeResultItem({
    required this.questionId,
    required this.isCorrect,
    required this.isAttended,
    required this.correctOptionId,
    this.selectedOptionId,
  });

  factory PracticeResultItem.fromMap(Map<String, dynamic> map) {
    return PracticeResultItem(
      questionId: map['questionId'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
      isAttended: map['isAttended'] ?? false,
      correctOptionId: map['correctOptionId'] ?? '',
      selectedOptionId: map['selectedOptionId'],
    );
  }
}

class PracticeSubmissionResponse {
  final PracticeResultSummary summary;
  final List<PracticeResultItem> results;

  PracticeSubmissionResponse({
    required this.summary,
    required this.results,
  });

  factory PracticeSubmissionResponse.fromMap(Map<String, dynamic> map) {
    return PracticeSubmissionResponse(
      summary: PracticeResultSummary.fromMap(map['summary'] ?? {}),
      results: (map['results'] as List? ?? [])
          .map((e) => PracticeResultItem.fromMap(e))
          .toList(),
    );
  }
}

// ─── Legacy model kept for detail screen (MCQ quiz) ────────────────────────

class QuestionModel {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}

class QbankModel {
  final String courseName;
  final String code;
  final String module;
  final String year;
  final String semester;
  final String faculty;
  final String examInfo;
  final List<QuestionModel> questions;

  QbankModel({
    required this.courseName,
    required this.code,
    required this.module,
    required this.year,
    required this.semester,
    required this.faculty,
    required this.examInfo,
    required this.questions,
  });
}
