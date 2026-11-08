import 'package:flutter_easyloading/flutter_easyloading.dart';

void showError(String message) async {
  EasyLoading.showError(message);
  await Future.delayed(Duration(seconds: 1));
  EasyLoading.dismiss();
}
