part of '../controller/fusra_details_controller.dart';

class AnalyticsStatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;

  const AnalyticsStatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
  });
}

class WeeklyWinner {
  final String rank;
  final String prize;
  final Color rankColor;
  final Color backgroundColor;
  final Color borderColor;
  final List<Color> productColors;
  final IconData productIcon;

  const WeeklyWinner({
    required this.rank,
    required this.prize,
    required this.rankColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.productColors,
    required this.productIcon,
  });
}

class TopSchool {
  final int rank;
  final String name;
  final String students;
  final String qualified;

  const TopSchool({
    required this.rank,
    required this.name,
    required this.students,
    required this.qualified,
  });
}

class RegistrationStudent {
  final String uniqueId;
  final String name;
  final String id;
  final String position;
  final Color positionColor;
  final Color positionTextColor;
  final String date;
  final String qualificationStatus;
  final String qualificationScore;
  final String attempts;
  final String coins;
  final RegistrationSectionData academic;
  final RegistrationSectionData contact;
  // final RegistrationSectionData address;
  // final BankSectionData bank;

  const RegistrationStudent({
    required this.uniqueId,
    required this.name,
    required this.id,
    required this.position,
    required this.positionColor,
    this.positionTextColor = Colors.white,
    required this.date,
    required this.qualificationStatus,
    required this.qualificationScore,
    required this.attempts,
    required this.coins,
    required this.academic,
    required this.contact,
    // required this.address,
    // required this.bank,
  });
}

class RegistrationSectionData {
  final String title;
  final Color backgroundColor;
  final List<InfoField> fields;

  const RegistrationSectionData({
    required this.title,
    required this.backgroundColor,
    required this.fields,
  });
}

class BankSectionData {
  final String title;
  final Color backgroundColor;
  final String accountNumber;
  final String badgeText;

  const BankSectionData({
    required this.title,
    required this.backgroundColor,
    required this.accountNumber,
    required this.badgeText,
  });
}

class InfoField {
  final String label;
  final String value;

  const InfoField({required this.label, required this.value});
}

class DetailsHeaderData {
  final String title;
  final String subtitle;
  final String bannerTitle;
  final String bannerSubtitle;
  final List<String> detailItems;

  const DetailsHeaderData({
    required this.title,
    required this.subtitle,
    required this.bannerTitle,
    required this.bannerSubtitle,
    required this.detailItems,
  });
}
