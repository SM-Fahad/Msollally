import 'package:get/get_rx/get_rx.dart';

class ProPartnersUpgradeModel {
  final String title;
  final String subTitle;
  final String charge;
  final String discount;
  final RxBool isChecked;

  ProPartnersUpgradeModel({
    required this.title,
    required this.subTitle,
    required this.charge,
    this.discount = ' ',
    bool initializedChecked = false,
  }) : isChecked = RxBool(initializedChecked);
}
