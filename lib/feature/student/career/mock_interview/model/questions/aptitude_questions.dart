import '../mock_model.dart';

final List<MockQuestion> aptitudeQuestions = [
  MockQuestion(
    question: "A company spends 40% of its budget on salaries and 25% on marketing. If the remaining budget is \$35,000, what is the total budget?",
    options: [
      "\$100,000",
      "\$75,000",
      "\$120,000",
      "\$150,000"
    ],
    correctAnswerIndex: 0,
  ),
  MockQuestion(
    question: "If 6 machines can produce 6 widgets in 6 minutes, how long will it take 100 machines to produce 100 widgets?",
    options: [
      "100 minutes",
      "6 minutes",
      "60 minutes",
      "1 minute"
    ],
    correctAnswerIndex: 1,
  ),
  MockQuestion(
    question: "If all Bloops are Razzies and all Razzies are Lizzies, are all Bloops definitely Lizzies?",
    options: [
      "Yes, definitely.",
      "No, never.",
      "Only if some Lizzies are Bloops.",
      "It is impossible to tell from the information provided."
    ],
    correctAnswerIndex: 0,
  ),
  MockQuestion(
    question: "A store increases the price of an item by 20%, then later applies a 20% discount on the new price. What is the net price change?",
    options: [
      "No change (0%)",
      "Increase of 4%",
      "Decrease of 4%",
      "Decrease of 2%"
    ],
    correctAnswerIndex: 2,
  ),
  MockQuestion(
    question: "Choose the number that logically completes the sequence: 2, 6, 12, 20, 30, ...",
    options: [
      "38",
      "40",
      "42",
      "44"
    ],
    correctAnswerIndex: 2,
  ),
];
