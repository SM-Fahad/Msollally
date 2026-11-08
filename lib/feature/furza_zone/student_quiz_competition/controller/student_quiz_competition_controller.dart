import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/student_campus_fursa_zone_model.dart';
import 'package:msollaally/feature/student/campus/campus_home/service/fursa_service.dart';
import 'package:msollaally/feature/furza_zone/student_quiz_competition/model/student_quiz_competition_model.dart';

class CompetitionOverviewItem {
  final String title;
  final String icon;
  final String value;
  final Color color;

  CompetitionOverviewItem({
    required this.title,
    required this.icon,
    required this.value,
    required this.color,
  });
}

class StudentQuizCompetitionController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final Rx<CompetitionModel?> competition = Rx<CompetitionModel?>(null);
  final RxBool isLoading = true.obs;
  final _fursaService = FursaService();

  // competitionId can be passed via Get.arguments
  int? competitionId;

  final List<Tab> myTabs = <Tab>[
    const Tab(text: 'Details'),
    const Tab(text: 'Analytics'),
    const Tab(text: 'Registrations'),
  ];

  // Analytics overview data
  final RxList<CompetitionOverviewItem> overviewData =
      <CompetitionOverviewItem>[].obs;

  // Prize winners
  final RxList<PrizeWinner> prizeWinners = <PrizeWinner>[].obs;

  // Top performing universities
  final RxList<UniversityPerformance> topUniversities =
      <UniversityPerformance>[].obs;

  // Registered students
  final RxList<StudentInfo> registeredStudents = <StudentInfo>[].obs;

  // Payment state (for pay implementation)
  final RxBool isPaymentProcessing = false.obs;
  final RxString paymentError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: myTabs.length);

    if (Get.arguments is int) {
      competitionId = Get.arguments as int;
      debugPrint('🔍 DEBUG: Competition ID passed: $competitionId');
    } else if (Get.arguments is String) {
      competitionId = int.tryParse(Get.arguments as String);
      debugPrint('🔍 DEBUG: Competition ID parsed from String: $competitionId');
    } else if (Get.arguments is Map) {
      final val = Get.arguments['id'] ??
          Get.arguments['competitionId'] ??
          Get.arguments['entityId'];
      competitionId = int.tryParse(val?.toString() ?? '');
      debugPrint('🔍 DEBUG: Competition ID parsed from Map: $competitionId');
    } else {
      debugPrint(
        '🔍 DEBUG: Competition ID argument is not recognized: ${Get.arguments}',
      );
    }

    loadCompetitionData();
  }

  Future<void> loadCompetitionData() async {
    debugPrint(
      '🔍 DEBUG: Starting to load competition data for ID: $competitionId',
    );
    if (competitionId == null) {
      isLoading.value = false;
      // fetchCompetitionOverview();
      // fetchPrizeWinners();
      // fetchTopUniversities();
      // fetchRegisteredStudents();
      return;
    }

    try {
      isLoading.value = true;
      final comp = await _fursaService.fetchCompetitionById(competitionId!);
      if (comp != null) {
        competition.value = comp;
        // Map competition data to overviewData, prizeWinners etc if needed
        _mapCompetitionToUI(comp);
      }
    } catch (e) {
      debugPrint('Error loading competition detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _mapCompetitionToUI(CompetitionModel comp) {
    // Example mapping
    overviewData.assignAll([
      CompetitionOverviewItem(
        title: 'Participants',
        icon: 'assets/icons/profileImageIcon.svg',
        value: comp.participants.toString(),
        color: AppColors.lightSkyBlue8EC5FF,
      ),
      CompetitionOverviewItem(
        title: 'Stage',
        icon: 'assets/icons/check.png',
        value: comp.currentStage,
        color: AppColors.honeydewDCFCE7,
      ),
    ]);

    if (comp.prizes != null) {
      final List<PrizeWinner> winners = comp.prizes!.map((p) {
        return PrizeWinner(
          rank: p['title'] ?? 'Prize',
          userName: '---',
          points: p['amount'] ?? '',
          price: p['title'] ?? '',
          imagePath: p['imageUrl'] ?? 'assets/images/phones.png',
          gradientStartColor: AppColors.oldLaceFFF2E0,
          gradientEndColor: AppColors.navajoWhiteFFD6A0,
          avatarBackgroundColor: AppColors.darkOrangeFF6900,
          borderColor: AppColors.orangeF59E0B,
        );
      }).toList();
      prizeWinners.assignAll(winners);
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void fetchCompetitionOverview() {
    overviewData.assignAll([
      CompetitionOverviewItem(
        title: 'Total Registered',
        icon: 'assets/icons/profileImageIcon.svg',
        value: '1,100',
        color: AppColors.lightSkyBlue8EC5FF,
      ),
      CompetitionOverviewItem(
        title: 'Quiz Taken',
        icon: 'assets/icons/check.png',
        value: '889',
        color: AppColors.honeydewDCFCE7,
      ),
      CompetitionOverviewItem(
        title: 'Avg. Score',
        icon: 'assets/icons/star_blue.svg',
        value: '8.5/10',
        color: AppColors.plumDAB2FF,
      ),
      CompetitionOverviewItem(
        title: 'Highest Score',
        icon: 'assets/icons/fire_icon.svg',
        value: '10/10',
        color: AppColors.papayaWhipFFEDD4,
      ),
    ]);
  }

  void fetchPrizeWinners() {
    prizeWinners.assignAll([
      PrizeWinner(
        rank: '1st',
        userName: '---',
        points: '-- pts',
        price: 'iPhone 17 pro',
        imagePath: 'assets/images/phones.png',
        gradientStartColor: AppColors.oldLaceFFF2E0,
        gradientEndColor: AppColors.navajoWhiteFFD6A0,
        avatarBackgroundColor: AppColors.darkOrangeFF6900,
        borderColor: AppColors.orangeF59E0B,
      ),
      PrizeWinner(
        rank: '2nd',
        userName: '---',
        points: '-- pts',
        price: 'Apple Watch ultra',
        imagePath: 'assets/images/watches.png',
        gradientStartColor: AppColors.oldLaceFEFCE8,
        gradientEndColor: AppColors.lemonChiffonFEF9C2,
        avatarBackgroundColor: AppColors.orangeF0B100,
        borderColor: AppColors.goldFDC700,
      ),
      PrizeWinner(
        rank: '3rd',
        userName: '---',
        points: '-- pts',
        price: 'Apple Watch',
        imagePath: 'assets/images/watch.png',
        gradientStartColor: AppColors.ghostWhiteF9FAFB,
        gradientEndColor: AppColors.tagBackgroundColor,
        avatarBackgroundColor: AppColors.darkGray99A1AF,
        borderColor: AppColors.darkGray99A1AF,
      ),
    ]);
  }

  void fetchTopUniversities() {
    topUniversities.assignAll([
      UniversityPerformance(
        indexText: '1',
        title: 'University of Dar es Salaam',
        subtitle: '2847 students',
        badgeText: '312 qualified',
      ),
      UniversityPerformance(
        indexText: '2',
        title: 'Ardhi University',
        subtitle: '1923 students',
        badgeText: '245 qualified',
      ),
      UniversityPerformance(
        indexText: '3',
        title: 'Muhimbili University',
        subtitle: '1654 students',
        badgeText: '198 qualified',
      ),
      UniversityPerformance(
        indexText: '4',
        title: 'Nelson Mandela Institute',
        subtitle: '2847 students',
        badgeText: '312 qualified',
      ),
      UniversityPerformance(
        indexText: '5',
        title: 'University of Dodoma',
        subtitle: '2847 students',
        badgeText: '312 qualified',
      ),
    ]);
  }

  void fetchRegisteredStudents() {
    registeredStudents.assignAll([
      StudentInfo(
        studentName: 'Sarah Johnson',
        studentId: 'STD-2024-8392',
        position: 1,
        university: 'University of Dar es Salaam',
        year: '3rd Year',
        program: 'Computer Science',
        email: 'sarah.johnson@student.udsm.ac.tz',
        phone: '+255 712 123 456',
        region: 'Dar es Salaam',
        district: 'Kinondoni',
        ward: 'Mwenge',
        street: 'Sam Nujoma Road',
        bankAccount: '0150*******123',
        currency: 'CRDB',
        registeredDate: '12/1/2024',
      ),
      // ...add more students as needed
    ]);
  }

  // Placeholder for payment logic
  Future<void> payToParticipate() async {
    isPaymentProcessing.value = true;
    paymentError.value = '';
    try {
      await Future.delayed(const Duration(seconds: 2));
      // On success, update state as needed
    } catch (e) {
      paymentError.value = 'Payment failed: \\${e.toString()}';
    } finally {
      isPaymentProcessing.value = false;
    }
  }
}
