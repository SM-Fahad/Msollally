import '../mock_model.dart';

final List<MockQuestion> technicalQuestions = [
  MockQuestion(
    question: "What is the average time complexity of searching for an element in a Hash Map?",
    options: [
      "O(N)",
      "O(log N)",
      "O(1)",
      "O(N log N)"
    ],
    correctAnswerIndex: 2,
  ),
  MockQuestion(
    question: "In object-oriented programming, what does the 'Single Responsibility Principle' state?",
    options: [
      "A class should have only one reason to change, meaning it has only one job.",
      "A method should take only one parameter.",
      "An application should run on a single processing thread.",
      "A class should inherit from only one parent class."
    ],
    correctAnswerIndex: 0,
  ),
  MockQuestion(
    question: "What is the primary difference between a process and a thread?",
    options: [
      "A process runs inside a thread.",
      "A process has its own dedicated memory space, while threads share the process's memory space.",
      "Threads cannot run concurrently, whereas processes can.",
      "Processes are managed by the application, whereas threads are managed by the database."
    ],
    correctAnswerIndex: 1,
  ),
  MockQuestion(
    question: "Which of the following describes the concept of Polymorphism?",
    options: [
      "Restricting access to certain components of an object.",
      "The ability of different classes to respond to the same message or method call in their own way.",
      "Creating multiple instances of the same class.",
      "Bundling data and methods that operate on that data into a single unit."
    ],
    correctAnswerIndex: 1,
  ),
  MockQuestion(
    question: "In databases, what is the main purpose of a database index?",
    options: [
      "To secure the database from external network attacks.",
      "To speed up data retrieval operations on a table at the cost of additional write time and storage.",
      "To ensure that all fields in a database table contain unique values.",
      "To automatically backup the database content at scheduled intervals."
    ],
    correctAnswerIndex: 1,
  ),
];
