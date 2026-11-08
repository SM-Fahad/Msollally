import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:email_validator/email_validator.dart';
import 'package:msollaally/routes/app_route.dart';

class TeacherBasicInfoController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  var gender = 'Male'.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController subjectTaughtController = TextEditingController();

  //university
  final RxnString selectuniversity = RxnString();
  final List<String> universityNameOption = [
    "PUB",
    "GUB",
    "AUST",
    "DU",
    "BUET",
    "RUET",
  ];

  // Faculty
  final RxnString selectFaculty = RxnString();
  final List<String> facultyOption = [
    "Faculty of Science",
    "Faculty of Arts",
    "Faculty of Engineering",
    "Faculty of Business",
    "Faculty of Law",
  ];

  // Observable stored data
  final RxString savedFullName = ''.obs;
  final RxString savedEmail = ''.obs;
  final RxString savedGender = 'Male'.obs;

  // Save profile data (without API call)
  void saveProfileData() {
    if (fullNameController.text.isEmpty) {
      EasyLoading.showError("Please Enter Full Name");
      return;
    }

    if (emailController.text.isEmpty) {
      EasyLoading.showError("Please Enter Email");
      return;
    }

    if (EmailValidator.validate(emailController.text) == false) {
      EasyLoading.showError("Please Enter Valid Email");
      return;
    }

    // Save the data to observables
    savedFullName.value = fullNameController.text;
    savedEmail.value = emailController.text;
    savedGender.value = gender.value;

    debugPrint('SAVE PROFILE DATA - Full Name: ${fullNameController.text}');
    debugPrint('SAVE PROFILE DATA - Email: ${emailController.text}');
    debugPrint('SAVE PROFILE DATA - Gender: ${gender.value}');

    // EasyLoading.showSuccess(
    //   'Profile data saved!',
    //   duration: const Duration(seconds: 1),
    //   dismissOnTap: true,
    // );

    Get.toNamed(AppRoute.teacherAcademicProfessionalInfoScreen);
  }
}
