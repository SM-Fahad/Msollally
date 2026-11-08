import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class CreateEventController extends GetxController {
  final eventNameController = TextEditingController();
  final groupNameController = TextEditingController();
  final locationController = TextEditingController(text: 'Online');
  final detailsController = TextEditingController();

  var startDate = DateTime(2025, 7, 24, 10, 0).obs;
  var endDate = DateTime(2025, 7, 24, 10, 0).obs;
  var privacyValue = 'Choose privacy'.obs;
  var locationValue = 'Choose location'.obs;

  void updateStartDate(DateTime newDate) {
    startDate.value = newDate;
    // If end date is before start date, adjust end date
    if (endDate.value.isBefore(newDate)) {
      endDate.value = newDate.add(Duration(hours: 1));
    }
  }

  void updateEndDate(DateTime newDate) {
    endDate.value = newDate;
  }

  void setPrivacy(String value) {
    privacyValue.value = value;
  }

  void setLocation(String value) {
    locationValue.value = value;
  }
}
