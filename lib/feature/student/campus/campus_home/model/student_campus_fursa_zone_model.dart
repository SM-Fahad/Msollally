import 'package:flutter/material.dart';

class FursaZoneModel {
  final String bannerImage;
  final String sponsorImage;
  final List<FursaTask> tasks;

  FursaZoneModel({
    required this.bannerImage,
    required this.sponsorImage,
    required this.tasks,
  });

  factory FursaZoneModel.fromJson(Map<String, dynamic> json) {
    return FursaZoneModel(
      bannerImage: json['bannerImage'] ?? '',
      sponsorImage: json['sponsorImage'] ?? '',
      tasks: (json['tasks'] as List? ?? [])
          .map((e) => FursaTask.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  FursaZoneModel copyWith({
    String? bannerImage,
    String? sponsorImage,
    List<FursaTask>? tasks,
  }) {
    return FursaZoneModel(
      bannerImage: bannerImage ?? this.bannerImage,
      sponsorImage: sponsorImage ?? this.sponsorImage,
      tasks: tasks ?? this.tasks,
    );
  }
}

class FursaTask {
  final String id;
  final String title;
  final Color taskColor;
  final String buttonText;
  final IconData taskIcon;
  final String subtitle;
  final String points;
  final Color? buttonColor;
  final String? type;

  FursaTask({
    required this.id,
    required this.title,
    required this.taskColor,
    required this.buttonText,
    required this.taskIcon,
    required this.subtitle,
    required this.points,
    this.buttonColor,
    this.type,
  });

  factory FursaTask.fromJson(Map<String, dynamic> json) {
    return FursaTask(
      id: json['id']?.toString() ?? '',
      title: json['campaignTitle'] ?? json['title'] ?? 'Untitled Task',
      taskColor: _parseColor(json['taskColor']),
      buttonText: json['buttonText'] ?? 'View Details',
      taskIcon: _parseIcon(json['taskIcon'] ?? json['campaignType']),
      subtitle: json['description'] ?? json['subtitle'] ?? '',
      points: '+${json['points'] ?? 15} pts',
      buttonColor: _parseColor(json['buttonColor']),
      type: json['campaignType'] ?? json['type'],
    );
  }

  FursaTask copyWith({
    String? id,
    String? title,
    Color? taskColor,
    String? buttonText,
    IconData? taskIcon,
    String? subtitle,
    String? points,
    Color? buttonColor,
    String? type,
  }) {
    return FursaTask(
      id: id ?? this.id,
      title: title ?? this.title,
      taskColor: taskColor ?? this.taskColor,
      buttonText: buttonText ?? this.buttonText,
      taskIcon: taskIcon ?? this.taskIcon,
      subtitle: subtitle ?? this.subtitle,
      points: points ?? this.points,
      buttonColor: buttonColor ?? this.buttonColor,
      type: type ?? this.type,
    );
  }

  static Color _parseColor(dynamic color) {
    if (color is String) {
      if (color.startsWith('#')) {
        return Color(int.parse(color.substring(1, 7), radix: 16) + 0xFF000000);
      }
    }
    return Colors.deepPurpleAccent;
  }

  static IconData _parseIcon(dynamic icon) {
    if (icon == 'video' || icon == 'CLIP') return Icons.video_call_outlined;
    if (icon == 'brochure' || icon == 'DOCUMENT') {
      return Icons.menu_book_outlined;
    }
    if (icon == 'chat' || icon == 'CHAT') return Icons.chat_outlined;
    return Icons.task_alt_outlined;
  }
}

class WinnerModel {
  final String rank;
  final String userName;
  final String points;
  final String price;
  final String imagePath;
  final Color? gradientStartColor;
  final Color? gradientEndColor;
  final Color? avatarBackgroundColor;
  final Color? borderColor;

  WinnerModel({
    required this.rank,
    required this.userName,
    required this.points,
    required this.price,
    required this.imagePath,
    this.gradientStartColor,
    this.gradientEndColor,
    this.avatarBackgroundColor,
    this.borderColor,
  });

  factory WinnerModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final profile = user['profile'] ?? {};
    final userName =
        json['userName'] ??
        json['fullName'] ??
        profile['fullName'] ??
        user['fullName'] ??
        user['name'] ??
        user['username'] ??
        'Unknown';
    final points =
        json['points'] ??
        json['totalPoints'] ??
        json['weeklyPoints'] ??
        json['totalCoins'] ??
        json['coins'] ??
        '0';
    final price = json['price'] ?? json['reward'] ?? json['prize'] ?? '';
    final rawPic =
        json['imagePath'] ??
        profile['profilePicture'] ??
        user['profilePicture'] ??
        user['avatar'];
    final imagePath = (rawPic != null && rawPic.toString().isNotEmpty)
        ? rawPic.toString()
        : '';

    return WinnerModel(
      rank: json['rank']?.toString() ?? '',
      userName: userName.toString(),
      points: points.toString(),
      price: price.toString(),
      imagePath: imagePath,
    );
  }
}

class TopSchoolModel {
  final int rank;
  final String schoolName;
  final int totalPoints;
  final int participantsCount;

  TopSchoolModel({
    required this.rank,
    required this.schoolName,
    required this.totalPoints,
    required this.participantsCount,
  });

  factory TopSchoolModel.fromJson(Map<String, dynamic> json) {
    return TopSchoolModel(
      rank: json['rank'] is int
          ? json['rank']
          : int.tryParse('${json['rank']}') ?? 0,
      schoolName:
          json['schoolName'] ??
          json['universityName'] ??
          json['name'] ??
          'Unknown School',
      totalPoints: json['totalPoints'] is int
          ? json['totalPoints']
          : int.tryParse(
                  '${json['totalPoints'] ?? json['points'] ?? json['totalCoins'] ?? json['coins']}',
                ) ??
                0,
      participantsCount: json['participantsCount'] is int
          ? json['participantsCount']
          : int.tryParse(
                  '${json['participantsCount'] ?? json['participants'] ?? json['studentCount']}',
                ) ??
                0,
    );
  }
}

class CompetitionModel {
  final int id;
  final String competitionName;
  final String? brandSlogan;
  final String proPartner;
  final DateTime? startDate;
  final DateTime? qualificationDate;
  final DateTime? finalCompetitionDate;
  final DateTime? learningPhaseStartDate;
  final DateTime? learningPhaseEndDate;
  final String? promoImageLink;
  final String? competitionGuidelines;
  final String? promoVideoLink;
  final String? partnerInfoFileLink;
  final String? knowledgeBaseFileLink;
  final String? qualificationQuizCsvFileLink;
  final String? finalQuizCsvFileLink;
  final List<dynamic>? prizes;
  final List<dynamic>? requirements;
  final List<dynamic>? registrations;
  final String currentStage;
  final String status;
  final int participants;

  // Dynamic Guideline Configuration Fields
  final String learningPhaseRange;
  final String qualificationQuizRange;
  final String weeklyFinalsRange;
  final String winnersAnnouncementRange;
  final bool hasQaChat;
  final int passingScore;
  final List<String>? howToParticipateOverride;
  final List<String>? importantNotesOverride;
  final bool isRegistered;
  final int? registrationId;
  final String? logo;
  final int videoPoints;
  final int brochurePoints;
  final int qnaPoints;
  final int qualificationPassMark;
  final int qualificationTopLimit;
  final int qualificationQuizQuestionsCount;
  final int qualificationQuizTimeLimit;
  final int finalQuizQuestionsCount;
  final int finalQuizTimeLimit;

  CompetitionModel({
    required this.id,
    required this.competitionName,
    this.brandSlogan,
    required this.proPartner,
    this.startDate,
    this.qualificationDate,
    this.finalCompetitionDate,
    this.learningPhaseStartDate,
    this.learningPhaseEndDate,
    this.promoImageLink,
    this.competitionGuidelines,
    this.promoVideoLink,
    this.partnerInfoFileLink,
    this.knowledgeBaseFileLink,
    this.qualificationQuizCsvFileLink,
    this.finalQuizCsvFileLink,
    this.prizes,
    this.requirements,
    this.registrations,
    required this.currentStage,
    required this.status,
    required this.participants,

    // Dynamic Fallbacks for absolute backward compatibility
    this.learningPhaseRange = 'Monday – Wednesday',
    this.qualificationQuizRange = 'Thursday - Saturday',
    this.weeklyFinalsRange = 'Sunday',
    this.winnersAnnouncementRange = 'Monday',
    this.hasQaChat = true,
    this.passingScore = 70,
    this.howToParticipateOverride,
    this.importantNotesOverride,
    this.isRegistered = false,
    this.registrationId,
    this.logo,
    this.videoPoints = 15,
    this.brochurePoints = 15,
    this.qnaPoints = 20,
    this.qualificationPassMark = 70,
    this.qualificationTopLimit = 1000,
    this.qualificationQuizQuestionsCount = 25,
    this.qualificationQuizTimeLimit = 30,
    this.finalQuizQuestionsCount = 50,
    this.finalQuizTimeLimit = 45,
  });

  factory CompetitionModel.fromJson(Map<String, dynamic> json) {
    // Parse guidanceConfig if present in response
    final config = json['guidanceConfig'] as Map<String, dynamic>? ?? {};

    return CompetitionModel(
      id: json['id'] ?? 0,
      competitionName: json['competitionName'] ?? json['competitionname'] ?? '',
      brandSlogan: json['brandSlogan'],
      proPartner: json['proPartner'] ?? json['propartner'] ?? '',
      startDate: json['competitionStartDate'] != null
          ? DateTime.parse(json['competitionStartDate'])
          : (json['startdate'] != null
                ? DateTime.parse(json['startdate'])
                : null),
      qualificationDate: json['qualificationDate'] != null
          ? DateTime.parse(json['qualificationDate'])
          : null,
      finalCompetitionDate: json['finalCompititionDate'] != null
          ? DateTime.parse(json['finalCompititionDate'])
          : (json['finalCompetitionDate'] != null
                ? DateTime.parse(json['finalCompetitionDate'])
                : null),
      learningPhaseStartDate: json['learningPhaseStartDate'] != null
          ? DateTime.parse(json['learningPhaseStartDate'])
          : null,
      learningPhaseEndDate: json['learningPhaseEndDate'] != null
          ? DateTime.parse(json['learningPhaseEndDate'])
          : null,
      promoImageLink: json['promoImageLink'] ?? json['banner'],
      competitionGuidelines: json['competitionGuidelines'],
      promoVideoLink: json['promoVideoLink'],
      partnerInfoFileLink: json['partnerInfoFileLink'],
      knowledgeBaseFileLink: json['knowledgeBaseFileLink'],
      qualificationQuizCsvFileLink: json['qualificationQuizCsvFileLink'],
      finalQuizCsvFileLink: json['finalQuizCsvFileLink'],
      prizes: json['prizes'],
      requirements: json['competitionRequirements'],
      registrations: json['registrations'],
      currentStage: json['currentStage'] ?? json['currentstage'] ?? '',
      status: json['status'] ?? '',
      participants: json['participants'] ?? json['totalRegistration'] ?? 0,

      // Assign dynamic guidance parameters
      learningPhaseRange: config['learningPhaseRange'] ?? 'Monday – Wednesday',
      qualificationQuizRange:
          config['qualificationQuizRange'] ?? 'Thursday - Saturday',
      weeklyFinalsRange: config['weeklyFinalsRange'] ?? 'Sunday',
      winnersAnnouncementRange: config['winnersAnnouncementRange'] ?? 'Monday',
      hasQaChat: config['hasQaChat'] ?? true,
      passingScore: config['passingScore'] is int
          ? config['passingScore']
          : int.tryParse(config['passingScore']?.toString() ?? '') ?? 70,
      howToParticipateOverride: config['howToParticipateOverride'] != null
          ? List<String>.from(config['howToParticipateOverride'])
          : null,
      importantNotesOverride: config['importantNotesOverride'] != null
          ? List<String>.from(config['importantNotesOverride'])
          : null,
      isRegistered: json['isRegistered'] == true,
      registrationId: json['registrationId'],
      logo: json['logo'],
      videoPoints: json['videoPoints'] ?? 15,
      brochurePoints: json['brochurePoints'] ?? 15,
      qnaPoints: json['qnaPoints'] ?? 20,
      qualificationPassMark: json['qualificationPassMark'] ?? 70,
      qualificationTopLimit: json['qualificationTopLimit'] ?? 1000,
      qualificationQuizQuestionsCount: json['qualificationQuizQuestionsCount'] ?? 25,
      qualificationQuizTimeLimit: json['qualificationQuizTimeLimit'] ?? 30,
      finalQuizQuestionsCount: json['finalQuizQuestionsCount'] ?? 50,
      finalQuizTimeLimit: json['finalQuizTimeLimit'] ?? 45,
    );
  }
}
