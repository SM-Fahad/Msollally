class MockQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String? reason;

  MockQuestion({
    this.id = '',
    required this.question,
    required this.options,
    this.correctAnswerIndex = -1,
    this.reason,
  });
}

class MockResult {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final Duration duration;
  final String categoryTitle;
  final String topicId;

  /// Stores all quiz questions asked
  final List<MockQuestion> questions;

  /// Stores the user's answers
  /// - Index in list = question index
  /// - Value = selected option index (-1 means no answer selected)
  final List<int> userAnswers;

  MockResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.duration,
    required this.questions,
    required this.userAnswers,
    required this.topicId,
    this.categoryTitle = "Mock Interview",
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
