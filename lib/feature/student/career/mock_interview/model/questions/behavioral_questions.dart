import '../mock_model.dart';

final List<MockQuestion> behavioralQuestions = [
  MockQuestion(
    question: "How do you handle conflict or disagreements within a team setting?",
    options: [
      "Avoid the situation entirely and wait for others to resolve it.",
      "Arrange a private discussion to understand perspectives and work toward a compromise.",
      "Raise the issue publicly to force a quick decision.",
      "Insist on my viewpoint until the team agrees with me."
    ],
    correctAnswerIndex: 1,
  ),
  MockQuestion(
    question: "Describe how you prioritize tasks when managing multiple tight deadlines.",
    options: [
      "Work on the easiest tasks first, regardless of urgency or impact.",
      "Attempt to multitask on everything simultaneously.",
      "Use a priority matrix to evaluate urgency and impact, then tackle tasks systematically.",
      "Wait for supervisors to follow up and direct my immediate focus."
    ],
    correctAnswerIndex: 2,
  ),
  MockQuestion(
    question: "If a project you worked on failed to meet its goal, what would you do first?",
    options: [
      "Identify who was responsible for the failure.",
      "Conduct a retrospective to analyze what went wrong and document key lessons.",
      "Request to be moved to a different team or project immediately.",
      "Downplay the failure and move on to the next assignment."
    ],
    correctAnswerIndex: 1,
  ),
  MockQuestion(
    question: "How do you adapt when project requirements change suddenly?",
    options: [
      "Refuse the changes and continue with the original plan.",
      "Express frustration openly and slow down my work pace.",
      "Review the new requirements, seek clarification, and adjust my plan accordingly.",
      "Wait for the project manager to redesign my entire daily workflow."
    ],
    correctAnswerIndex: 2,
  ),
  MockQuestion(
    question: "What is your approach to receiving constructive criticism?",
    options: [
      "Take it personally and become defensive.",
      "Listen objectively, ask clarifying questions, and use the feedback to improve.",
      "Ignore the feedback if it does not align with my opinion.",
      "Agree immediately but continue working the exact same way."
    ],
    correctAnswerIndex: 1,
  ),
];
