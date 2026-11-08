import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:msollaally/feature/student/academics/quiz/model/quiz_model.dart';

class PrepAiService {
  /// Generates questions tailored to the provided module title or uploaded file name.
  static Future<List<QuizQuestion>> generateQuestions({
    String? moduleTitle,
    PlatformFile? file,
    required String questionType, // 'mcq', 'true_false', 'both'
    required int count,
  }) async {
    // Determine effective topic title
    String topic = 'General Academic Module';
    if (moduleTitle != null && moduleTitle.trim().isNotEmpty) {
      topic = moduleTitle.trim();
    } else if (file != null && file.name.isNotEmpty) {
      final cleanName = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '').replaceAll('_', ' ').replaceAll('-', ' ');
      topic = cleanName;
    }

    final List<QuizQuestion> generated = [];
    final random = Random();

    // Standard high-yield template pools by question type
    final List<Map<String, dynamic>> mcqTemplates = [
      {
        'q': 'What is the primary objective of studying $topic in modern curricula?',
        'options': [
          'To understand foundational principles and systematic methodologies',
          'To memorize isolated factual definitions without practical context',
          'To replace traditional scientific inquiry entirely',
          'To limit experimentation to theoretical simulations only',
        ],
        'correct': 0,
        'sol': 'Understanding core foundational principles and methodologies enables students to extrapolate concepts to novel problems in $topic.',
      },
      {
        'q': 'Which of the following is considered a core attribute when analyzing $topic?',
        'options': [
          'Random non-repeatable outcomes',
          'Systematic analysis, empirical validation, and logical structuring',
          'Subjective opinions without verifiable evidence',
          'Rigid adherence to outdated paradigms',
        ],
        'correct': 1,
        'sol': 'Systematic analysis and empirical verification ensure accurate conclusions and reliability within $topic.',
      },
      {
        'q': 'When applying principles of $topic, how is system efficiency best optimized?',
        'options': [
          'By eliminating monitoring mechanisms',
          'By increasing redundant resource overheads',
          'Through calibrated measurement, constraint management, and iterative refinement',
          'By bypassing quality verification phases',
        ],
        'correct': 2,
        'sol': 'Iterative optimization with precise constraints and feedback loops guarantees the highest operational efficiency.',
      },
      {
        'q': 'What is the standard procedure to validate hypotheses related to $topic?',
        'options': [
          'Uncontrolled observational speculation',
          'Controlled testing with measurable metrics and reproducibility',
          'Immediate implementation without benchmarking',
          'Relying solely on preliminary anecdotal assumptions',
        ],
        'correct': 1,
        'sol': 'Hypothesis validation demands controlled experimentation and statistical reproducibility.',
      },
      {
        'q': 'In advanced problems within $topic, what is the most significant factor influencing variance?',
        'options': [
          'Boundary conditions and environmental variable constraints',
          'Nominal font formatting of problem statements',
          'Absolute static invariants without parameters',
          'Superficial aesthetic factors',
        ],
        'correct': 0,
        'sol': 'Boundary conditions dictate the limits of valid state spaces and explain dynamic behavior in $topic.',
      },
      {
        'q': 'Which methodology is widely recognized for problem-solving across $topic modules?',
        'options': [
          'Divide-and-conquer analytical decomposition',
          'Trial-and-error without logging attempts',
          'Arbitrary numerical estimation',
          'Heuristic guessing without theoretical basis',
        ],
        'correct': 0,
        'sol': 'Analytical decomposition breaks complex composite systems into tractable sub-components for rigorous analysis.',
      },
      {
        'q': 'How does error analysis contribute to model accuracy in $topic?',
        'options': [
          'It reveals deviations between predicted and observed metrics, allowing corrective compensation',
          'It is unnecessary once initial calibration finishes',
          'It artificially inflates computational complexity without benefits',
          'It only applies to historical legacy datasets',
        ],
        'correct': 0,
        'sol': 'Systematic residual and error analysis establishes confidence bounds and pinpoints corrective recalibrations.',
      },
      {
        'q': 'Which parameter serves as the fundamental baseline when evaluating performance in $topic?',
        'options': [
          'Standardized benchmark reference metric',
          'Maximum theoretical entropy',
          'Shortest temporal elapsed runtime ignoring accuracy',
          'Random sampling baseline',
        ],
        'correct': 0,
        'sol': 'Standard benchmark reference metrics provide an objective yardstick against which improvements are measured.',
      },
    ];

    final List<Map<String, dynamic>> tfTemplates = [
      {
        'q': 'True or False: In $topic, thorough understanding of fundamental axioms is required before tackling complex multidimensional problems.',
        'options': ['True', 'False'],
        'correct': 0,
        'sol': 'True. Complex problem architectures build upon elementary theorems; neglecting fundamentals introduces compound systemic errors.',
      },
      {
        'q': 'True or False: Quantitative models in $topic remain valid regardless of extreme boundary condition changes.',
        'options': ['True', 'False'],
        'correct': 1,
        'sol': 'False. Physical and theoretical models are strictly bounded by validity domains; exceeding boundary limits leads to divergence or breakdown.',
      },
      {
        'q': 'True or False: Iterative feedback and validation loops improve overall accuracy when assessing $topic case studies.',
        'options': ['True', 'False'],
        'correct': 0,
        'sol': 'True. Systematic verification against ground truth ensures stability and convergence toward optimal solutions.',
      },
      {
        'q': 'True or False: Empirical observations in $topic can completely replace mathematical formulation and theoretical rigor.',
        'options': ['True', 'False'],
        'correct': 1,
        'sol': 'False. Empirical data and mathematical formalism complement each other; theoretical structures explain underlying mechanics.',
      },
      {
        'q': 'True or False: Peer review and reproducible documentation are standard best practices when presenting findings in $topic.',
        'options': ['True', 'False'],
        'correct': 0,
        'sol': 'True. Reproducibility confirms integrity and allows other researchers to verify empirical results.',
      },
    ];

    int idCounter = 1000 + random.nextInt(9000);

    for (int i = 0; i < count; i++) {
      bool pickMcq;
      if (questionType == 'mcq') {
        pickMcq = true;
      } else if (questionType == 'true_false') {
        pickMcq = false;
      } else {
        // 'both'
        pickMcq = i % 2 == 0;
      }

      if (pickMcq) {
        final t = mcqTemplates[i % mcqTemplates.length];
        generated.add(
          QuizQuestion(
            id: idCounter++,
            question: t['q'] as String,
            options: List<String>.from(t['options']),
            correctAnswerIndex: t['correct'] as int,
            explanation: t['sol'] as String,
          ),
        );
      } else {
        final t = tfTemplates[i % tfTemplates.length];
        generated.add(
          QuizQuestion(
            id: idCounter++,
            question: t['q'] as String,
            options: List<String>.from(t['options']),
            correctAnswerIndex: t['correct'] as int,
            explanation: t['sol'] as String,
          ),
        );
      }
    }

    return generated;
  }
}
