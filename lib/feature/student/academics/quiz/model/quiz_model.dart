// quiz_model.dart

class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  QuizQuestion({
    this.id = 0,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation = '',
  });

  factory QuizQuestion.fromModel(dynamic model) {
    // Check options mapping
    final List<String> opts = [
      model.optionA.toString(),
      model.optionB.toString(),
      model.optionC.toString(),
      model.optionD.toString(),
    ];
    int correctIdx = 0;
    final String correctChar = (model.correctAnswer ?? '').toString().toUpperCase();
    if (correctChar == 'B') {
      correctIdx = 1;
    } else if (correctChar == 'C') {
      correctIdx = 2;
    } else if (correctChar == 'D') {
      correctIdx = 3;
    }

    String explanation = '';
    try {
      explanation = (model.explanation ?? model.solution ?? model.note ?? '').toString();
    } catch (_) {}

    return QuizQuestion(
      id: model.id,
      question: model.question.toString(),
      options: opts,
      correctAnswerIndex: correctIdx,
      explanation: explanation,
    );
  }
}

/// Represents the final result of a quiz attempt
class QuizResult {
  final String quizTitle;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final Duration duration;

  /// Stores all quiz questions asked
  final List<QuizQuestion> questions;

  /// Stores the user's answers
  /// - Index in list = question index
  /// - Value = selected option index (-1 means no answer selected)
  final List<int> userAnswers;

  QuizResult({
    this.quizTitle = 'Practice Quiz',
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.duration,
    required this.questions,
    required this.userAnswers,
  });

  /// Get percentage score
  double get scorePercent =>
      totalQuestions == 0 ? 0 : (correctAnswers / totalQuestions.toDouble());

  /// Returns whether the answer for a specific question was correct
  bool isAnswerCorrect(int index) {
    if (index < 0 || index >= questions.length) return false;
    if (index >= userAnswers.length) return false;
    return userAnswers[index] == questions[index].correctAnswerIndex;
  }

  /// Returns the user’s selected answer text
  String getUserAnswerText(int index) {
    if (index >= userAnswers.length || userAnswers[index] == -1) {
      return "Not Answered";
    }
    return questions[index].options[userAnswers[index]];
  }

  /// Returns the correct answer text
  String getCorrectAnswerText(int index) {
    return questions[index].options[questions[index].correctAnswerIndex];
  }
}
