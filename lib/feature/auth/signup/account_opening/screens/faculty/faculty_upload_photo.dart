
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:msollaally/core/common/styles/global_text_style.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:msollaally/core/common/widgets/custom_button.dart';
// import 'package:msollaally/core/const/icons_path.dart';
// import 'package:msollaally/core/utils/constants/colors.dart';
// import 'package:msollaally/feature/auth/signup/account_opening/controller/sign_up_screen_onboarding_controller.dart';
// import 'package:msollaally/feature/auth/signup/account_opening/widgets/bio_nodmac.dart';
// import 'package:msollaally/feature/auth/signup/account_opening/widgets/upload_your_photo.dart';
// import 'package:msollaally/feature/teacher/home/screen/teacher_home_screen.dart';

// class FacultyUploadPhotoScreen extends StatelessWidget {
//   const FacultyUploadPhotoScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     SignUpScreenOnboardingController controllerNodeMac = Get.put(
//       SignUpScreenOnboardingController(),
//       permanent: true,
//     );

//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 26.h),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // SizedBox(height: 26.h),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SizedBox(
//                       child: Row(
//                         children: [
//                           SvgPicture.asset(
//                             IconsPath.nodmacIconNext,
//                             height: 40.h,
//                             width: 47.63.w,
//                           ),
//                           Text(
//                             "nodmac",
//                           style: getTextStyle(
//                             fontSize: 30,
//                             fontWeight: FontWeight.w500,
//                             letterSpacing: 30 * 0.03,
//                           ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     InkWell(
//                       onTap: () {
//                         Get.to(TeacherHomeScreen());
//                       },
//                       child: Text(
//                         "Skip",
//                         style: getTextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: 0.18,
//                           color: AppColors.appBarTitleColor,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 SizedBox(height: 20.h),

//                 Row(
//                   // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   // mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       height: 6.h,
//                       width: 90.w,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10.r),
//                         color: AppColors.sliderColorInboarding,
//                       ),
//                     ),
//                     SizedBox(width: 12.w),
//                     Container(
//                       height: 6.h,
//                       width: 90.w,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10.r),
//                         color: AppColors.sliderColorInboarding,
//                       ),
//                     ),
//                     SizedBox(width: 12.w),

//                     Container(
//                       height: 6.h,
//                       width: 90.w,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10.r),
//                         color: AppColors.primaryButtonColor,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 17.h),
//                 UploadYourPhoto(controller: controllerNodeMac),
//                 SizedBox(height: 24.h),
//                 BioNodMac(controllerNodeMac: controllerNodeMac),
//                 SizedBox(height: 60.h),
//                 CustomButton(
//                   text: "Finish",
//                   onPressed: () {
//                     () async {

//                       final success = await controllerNodeMac.submitProfile();
//                       if (success) {
//                         Get.to(TeacherHomeScreen());
//                       } else {
//                         EasyLoading.showError(controllerNodeMac.errorMessage.value.isNotEmpty
//                             ? controllerNodeMac.errorMessage.value
//                             : 'Failed to complete profile. Please try again.');
//                       }
//                     }();
//                     // AppRoute.studentHomeScreen;
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
