import 'package:get/get.dart';

class CreatePollController extends GetxController {
  var question = ''.obs;
  var options = <String>[].obs;
  var allowMultiple = false.obs;

  void addOption() {
    options.add('');
  }

  void removeOption(int index) {
    if (options.length > 1) {
      options.removeAt(index);
    }
  }

  void updateOption(int index, String value) {
    options[index] = value;
  }

  void toggleAllowMultiple(bool value) {
    allowMultiple.value = value;
  }
}
