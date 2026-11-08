class QuizQuestionModel {
  final int id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final int orderIndex;
  final String correctAnswer;

  QuizQuestionModel({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.orderIndex,
    this.correctAnswer = '',
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      question: json['question']?.toString() ?? '',
      optionA: json['optionA']?.toString() ?? '',
      optionB: json['optionB']?.toString() ?? '',
      optionC: json['optionC']?.toString() ?? '',
      optionD: json['optionD']?.toString() ?? '',
      orderIndex: json['orderIndex'] is int
          ? json['orderIndex']
          : int.tryParse('${json['orderIndex']}') ?? 0,
      correctAnswer: json['correctAnswer']?.toString() ?? '',
    );
  }
}
