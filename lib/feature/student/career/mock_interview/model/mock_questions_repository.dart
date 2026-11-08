import 'mock_model.dart';
import 'questions/behavioral_questions.dart';
import 'questions/technical_questions.dart';
import 'questions/aptitude_questions.dart';

class MockQuestionsRepository {
  static List<MockQuestion> getBehavioralQuestions() => behavioralQuestions;
  static List<MockQuestion> getTechnicalQuestions() => technicalQuestions;
  static List<MockQuestion> getAptitudeQuestions() => aptitudeQuestions;
}
