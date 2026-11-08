import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_home/service/fursa_service.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';

class UserRegistrationData {
  final String fullName;
  final String studentId;
  final String university;
  final String program;
  final String email;

  UserRegistrationData({
    required this.fullName,
    required this.studentId,
    required this.university,
    required this.program,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'studentId': studentId,
    'university': university,
    'program': program,
    'email': email,
  };
}

class QuizData {
  final int totalQuestions;
  final int correctAnswers;
  final int timeLimit;
  final double passPercentage;
  final List<String> answers;
  final double score;
  final bool qualified;

  QuizData({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeLimit,
    required this.passPercentage,
    required this.answers,
    required this.score,
    required this.qualified,
  });

  Map<String, dynamic> toJson() => {
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'timeLimit': timeLimit,
    'passPercentage': passPercentage,
    'answers': answers,
    'score': score,
    'qualified': qualified,
  };
}

class BrochureEngagementData {
  final int readingTimeSeconds;
  final double scrollPercentage;
  final bool qualifiesForPoints;

  BrochureEngagementData({
    required this.readingTimeSeconds,
    required this.scrollPercentage,
    required this.qualifiesForPoints,
  });

  Map<String, dynamic> toJson() => {
    'readingTimeSeconds': readingTimeSeconds,
    'scrollPercentage': scrollPercentage,
    'qualifiesForPoints': qualifiesForPoints,
  };
}

class ChatEngagementData {
  final int messagesSent;
  final int engagementTimeSeconds;
  final List<String> messages;
  final bool qualifiesForPoints;

  ChatEngagementData({
    required this.messagesSent,
    required this.engagementTimeSeconds,
    required this.messages,
    required this.qualifiesForPoints,
  });

  Map<String, dynamic> toJson() => {
    'messagesSent': messagesSent,
    'engagementTimeSeconds': engagementTimeSeconds,
    'messages': messages,
    'qualifiesForPoints': qualifiesForPoints,
  };
}

class DialogboxController extends GetxController {
  final fullNameController = TextEditingController();
  final studentIdController = TextEditingController();
  final universityController = TextEditingController();
  final programController = TextEditingController();
  final emailController = TextEditingController();

  Rx<UserRegistrationData?> userRegistration = Rx<UserRegistrationData?>(null);
  Rx<QuizData?> quizData = Rx<QuizData?>(null);
  Rx<BrochureEngagementData?> brochureEngagement = Rx<BrochureEngagementData?>(
    null,
  );
  Rx<ChatEngagementData?> chatEngagement = Rx<ChatEngagementData?>(null);

  RxBool isRegistrationComplete = false.obs;
  RxBool isBrochureRead = false.obs;
  RxBool isQAChatComplete = false.obs;
  RxBool isQuizComplete = false.obs;

  RxString currentDialogState = 'none'.obs;
  RxInt participationScore = 0.obs;
  final registrationId = 0.obs;

  // Brochure Dialog State
  final RxInt brochureSecondsLeft = 47.obs;
  Timer? _brochureTimer;

  // Product Video Dialog State
  final RxInt videoSecondsRemaining = 47.obs;
  Timer? _videoTimer;

  // Video and Brochure Data from Competition
  final RxString promoVideoLink = ''.obs;
  final RxString partnerInfoFileLink = ''.obs;
  final RxInt minimumVideoWatchTime = 120.obs;
  final RxInt minimumBrochureReadTime = 60.obs;
  final RxInt videoPoints = 50.obs;
  final RxInt brochurePoints = 30.obs;

  // Chat Dialog State
  final RxInt chatMessageCount = 0.obs;
  final RxInt chatEngagementSeconds = 0.obs;
  final RxList<String> chatMessages = <String>[].obs;

  // Quiz State
  final RxInt quizCurrentQuestion = 1.obs;
  final int quizTotalQuestions = 50;
  final RxString quizSelectedAnswer = ''.obs;
  final RxInt quizAnsweredCount = 0.obs;
  final RxInt quizTimeRemaining = 3600.obs;
  Timer? _quizTimer;

  // Bonus Item States
  final RxMap<String, bool> bonusItemEarned = <String, bool>{}.obs;

  // Task Action States
  final RxMap<String, bool> taskCompleted = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _autoFillRegistrationData();
  }

  void _autoFillRegistrationData() {
    if (Get.isRegistered<StudentProfileController>()) {
      final profileCtrl = Get.find<StudentProfileController>();
      if (fullNameController.text.trim().isEmpty) {
        fullNameController.text = profileCtrl.displayName.value;
      }

      if (emailController.text.trim().isEmpty) {
        final emailValue = profileCtrl.aboutItem
                .firstWhereOrNull((e) => e.title.toLowerCase() == 'email')
                ?.titleValue ??
            '';
        emailController.text = emailValue;
      }

      if (studentIdController.text.trim().isEmpty) {
        final studentIdValue = profileCtrl.aboutItem
                .firstWhereOrNull(
                  (e) =>
                      e.title.toLowerCase().contains('id') ||
                      e.title.toLowerCase().contains('student id'),
                )
                ?.titleValue ??
            '';
        studentIdController.text = studentIdValue;
      }

      if (universityController.text.trim().isEmpty) {
        final universityValue = profileCtrl.aboutItem
                .firstWhereOrNull(
                  (e) =>
                      e.title.toLowerCase() == 'institution' ||
                      e.title.toLowerCase() == 'university' ||
                      e.title.toLowerCase().contains('college'),
                )
                ?.titleValue ??
            '';
        universityController.text = universityValue;
      }

      if (programController.text.trim().isEmpty) {
        final programValue = profileCtrl.aboutItem
                .firstWhereOrNull(
                  (e) =>
                      e.title.toLowerCase() == 'faculty' ||
                      e.title.toLowerCase() == 'program' ||
                      e.title.toLowerCase() == 'department',
                )
                ?.titleValue ??
            '';
        programController.text = programValue;
      }
    }
  }

  void setUserRegistration(UserRegistrationData data) {
    userRegistration.value = data;
    isRegistrationComplete.value = true;
    currentDialogState.value = 'registration_complete';
    addParticipationScore(10);
  }

  void clearControllers() {
    fullNameController.clear();
    studentIdController.clear();
    universityController.clear();
    programController.clear();
    emailController.clear();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    studentIdController.dispose();
    universityController.dispose();
    programController.dispose();
    emailController.dispose();
    _brochureTimer?.cancel();
    _videoTimer?.cancel();
    _quizTimer?.cancel();
    super.onClose();
  }

  Future<bool> submitRegistration({int? competitionId}) async {
    try {
      if (userRegistration.value == null) return false;

      EasyLoading.show(status: 'Registering...');
      Get.put(FursaService());
      final service = Get.find<FursaService>();

      final success = await service.registerCompetition(
        competitionId: competitionId ?? 2,
        data: userRegistration.value!,
      );

      EasyLoading.dismiss();
      if (success) {
        EasyLoading.showSuccess('Registration Successful!');
        return true;
      }
      EasyLoading.showError('Registration Failed');
      return false;
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('An error occurred');
      return false;
    }
  }

  void setBrochureEngagement(BrochureEngagementData data) {
    brochureEngagement.value = data;
    isBrochureRead.value = data.qualifiesForPoints;
    currentDialogState.value = 'brochure_read';
    if (data.qualifiesForPoints) {
      addParticipationScore(15);
    }
  }

  void setChatEngagement(ChatEngagementData data) {
    chatEngagement.value = data;
    isQAChatComplete.value = data.qualifiesForPoints;
    currentDialogState.value = 'chat_complete';
    if (data.qualifiesForPoints) {
      addParticipationScore(20);
    }
  }

  void setQuizData(QuizData data) {
    quizData.value = data;
    isQuizComplete.value = true;
    currentDialogState.value = 'quiz_complete';
    if (data.qualified) {
      addParticipationScore(50);
    }
    submitQuizResults();
  }

  Future<bool> submitQuizResults() async {
    try {
      if (quizData.value == null) return false;

      final studentProfileCtrl = Get.find<StudentProfileController>();
      final campusCtrl = Get.find<StudentCampusController>();

      final myId = studentProfileCtrl.userId.value;
      final compId = campusCtrl.competitionsList.isNotEmpty
          ? campusCtrl.competitionsList.first.id
          : 2;
      final passed = quizData.value!.qualified;
      final scoreVal = quizData.value!.score.toInt();

      EasyLoading.show(status: 'Saving quiz result...');
      final success = await FursaService().updateQualificationQuizResult(
        userId: myId,
        competitionId: compId,
        passed: passed,
        score: scoreVal,
      );

      if (success) {
        EasyLoading.showSuccess('Quiz result saved successfully!');
        await campusCtrl.loadFursaZoneData();
      } else {
        EasyLoading.showError('Failed to save quiz result');
      }
      return success;
    } catch (e) {
      debugPrint('Error submitting quiz results: $e');
      EasyLoading.dismiss();
      return false;
    }
  }

  void addParticipationScore(int points) {
    participationScore.value += points;
  }

  bool canProceedToQuiz() {
    return isRegistrationComplete.value && isBrochureRead.value;
  }

  bool canProceedToFinals() {
    return isQuizComplete.value && (quizData.value?.qualified ?? false);
  }

  Map<String, dynamic> getAllDialogData() {
    return {
      'userRegistration': userRegistration.value?.toJson(),
      'quizData': quizData.value?.toJson(),
      'brochureEngagement': brochureEngagement.value?.toJson(),
      'chatEngagement': chatEngagement.value?.toJson(),
      'participationScore': participationScore.value,
      'completionStatus': {
        'registration': isRegistrationComplete.value,
        'brochureRead': isBrochureRead.value,
        'chatComplete': isQAChatComplete.value,
        'quizComplete': isQuizComplete.value,
      },
    };
  }

  void resetAllData() {
    userRegistration.value = null;
    quizData.value = null;
    brochureEngagement.value = null;
    chatEngagement.value = null;
    isRegistrationComplete.value = false;
    isBrochureRead.value = false;
    isQAChatComplete.value = false;
    isQuizComplete.value = false;
    currentDialogState.value = 'none';
    participationScore.value = 0;
    clearControllers();
  }

  void syncRegistrationProgress(var comp, Map<String, dynamic>? progress) {
    if (comp == null || !comp.isRegistered || comp.registrationId == null) {
      resetAllData();
      return;
    }

    registrationId.value = comp.registrationId!;
    isRegistrationComplete.value = true;
    
    if (progress != null) {
      isBrochureRead.value = progress['hasReadBrochure'] ?? false;
      isQAChatComplete.value = progress['hasCompletedQnA'] ?? false;
      isQuizComplete.value = progress['hasPassedQualification'] ?? false;
    }

    promoVideoLink.value = comp.promoVideoLink ?? '';
    partnerInfoFileLink.value = comp.partnerInfoFileLink ?? '';
    
    // In new model, limits are on comp model or fallback
    minimumVideoWatchTime.value = 15; 
    minimumBrochureReadTime.value = 15;
    
    videoPoints.value = comp.videoPoints ?? 50;
    brochurePoints.value = comp.brochurePoints ?? 30;
    
    debugPrint('🔍 DEBUG: Synced timers -> Video: ${minimumVideoWatchTime.value}s, Brochure: ${minimumBrochureReadTime.value}s');

    // Update participation score based on tasks completed
    participationScore.value = 0;
    if (isRegistrationComplete.value) participationScore.value += 10;
    if (isBrochureRead.value) participationScore.value += 15;
    if (isQAChatComplete.value) participationScore.value += 20;
    if (isQuizComplete.value) participationScore.value += 50;

    // Use AuthMe info or Profile if we need to show fields again
    _autoFillRegistrationData();
  }

  String getDialogStatus() {
    if (!isRegistrationComplete.value) return 'pending_registration';
    if (!isBrochureRead.value) return 'pending_brochure';
    if (!isQAChatComplete.value) return 'pending_chat';
    if (!isQuizComplete.value) return 'pending_quiz';
    if (!canProceedToFinals()) return 'not_qualified';
    return 'qualified_for_finals';
  }

  // Brochure Timer Methods
  void startBrochureTimer() {
    brochureSecondsLeft.value = minimumBrochureReadTime.value;
    _brochureTimer?.cancel();
    _brochureTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (brochureSecondsLeft.value > 0) {
        brochureSecondsLeft.value--;
      } else {
        _brochureTimer?.cancel();
        final engagement = BrochureEngagementData(
          readingTimeSeconds: minimumBrochureReadTime.value,
          scrollPercentage: 1.0, // Should be actual from UI if needed
          qualifiesForPoints: true,
        );
        setBrochureEngagement(engagement);

        // Submit API
        final campusCtrl = Get.find<StudentCampusController>();
        final compId = campusCtrl.competitionsList.isNotEmpty
            ? campusCtrl.competitionsList.first.id
            : 2;
            
        debugPrint('🔍 DEBUG: Triggering Brochure Progress Submit -> compId: $compId, timeSpent: ${minimumBrochureReadTime.value}s');
        FursaService().recordLearningProgress(
          competitionId: compId,
          activityType: 'BROCHURE',
          timeSpent: minimumBrochureReadTime.value,
        ).then((success) {
          if (success) {
            campusCtrl.completeTask('brochure_task', null);
          }
        });
      }
    });
  }

  // Product Video Timer Methods
  void startVideoTimer() {
    videoSecondsRemaining.value = minimumVideoWatchTime.value;
    _videoTimer?.cancel();
    _videoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (videoSecondsRemaining.value > 0) {
        videoSecondsRemaining.value--;
      } else {
        _videoTimer?.cancel();
        
        // Submit API
        final campusCtrl = Get.find<StudentCampusController>();
        final compId = campusCtrl.competitionsList.isNotEmpty
            ? campusCtrl.competitionsList.first.id
            : 2;
            
        debugPrint('🔍 DEBUG: Triggering Video Progress Submit -> compId: $compId, timeSpent: ${minimumVideoWatchTime.value}s');
        FursaService().recordLearningProgress(
          competitionId: compId,
          activityType: 'VIDEO',
          timeSpent: minimumVideoWatchTime.value,
        ).then((success) {
          if (success) {
            campusCtrl.completeTask('video_task', null);
          }
        });
      }
    });
  }

  void cancelBrochureTimer() {
    _brochureTimer?.cancel();
  }

  void cancelVideoTimer() {
    _videoTimer?.cancel();
  }

  String formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "$mins:${secs.toString().padLeft(2, '0')}";
  }

  // Chat Methods
  void incrementChatMessageCount() {
    chatMessageCount.value++;
  }

  void addChatMessage(String message) {
    chatMessages.add(message);
  }

  // Quiz Methods
  void startQuizTimer() {
    const oneSec = Duration(seconds: 1);
    _quizTimer = Timer.periodic(oneSec, (Timer timer) {
      if (quizTimeRemaining.value == 0) {
        timer.cancel();
      } else {
        quizTimeRemaining.value--;
      }
    });
  }

  double get quizProgress => quizCurrentQuestion.value / quizTotalQuestions;
  bool get showQuizSubmitButton => quizAnsweredCount.value >= 2;

  void handleQuizNext() {
    if (quizSelectedAnswer.value.isEmpty) {
      return;
    }

    quizAnsweredCount.value++;

    if (!showQuizSubmitButton &&
        quizCurrentQuestion.value < quizTotalQuestions) {
      quizCurrentQuestion.value++;
      quizSelectedAnswer.value = '';
    }
  }

  // Bonus Item Methods
  void toggleBonusItemEarned(String itemKey) {
    bonusItemEarned[itemKey] = !(bonusItemEarned[itemKey] ?? false);
    bonusItemEarned.refresh();
  }

  // Task Action Methods
  void completeTask(String taskKey, VoidCallback? onTaskCompleted) {
    taskCompleted[taskKey] = true;
    taskCompleted.refresh();
    if (onTaskCompleted != null) onTaskCompleted();
  }
}
