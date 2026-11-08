import 'package:get/get.dart';

class StudentSettingsNotificationModel {
  final String title;
  final String subTitle;
  final RxBool isTapped;

  StudentSettingsNotificationModel({
    required this.isTapped,
    required this.subTitle,
    required this.title,
  });
}
