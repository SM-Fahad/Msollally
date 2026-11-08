
// import 'package:flutter/material.dart';
// import 'package:msollaally/core/common/styles/global_text_style.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:msollaally/core/const/icons_path.dart';
// import 'package:msollaally/core/utils/constants/colors.dart';
// import 'package:msollaally/feature/auth/signup/account_opening/widgets/basicinformation_nodmac.dart';

// class FacultyBasicInfoScreen extends StatelessWidget {
//   const FacultyBasicInfoScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(20.h),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.only(left: 6.w, right: 6.w),

//                   child: Row(
//                     children: [
//                       SizedBox(height: 26.h),
//                       SvgPicture.asset(
//                         IconsPath.nodmacIconNext,
//                         height: 40.h,
//                         width: 47.63.w,
//                       ),
//                       Text(
//                         "nodmac",
//                         style: getTextStyle(
//                           fontSize: 30,
//                           fontWeight: FontWeight.w500,
//                           letterSpacing: 30 * 0.03,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: 20.h),

//                 Row(
//                   children: [
//                     Container(
//                       height: 6.h,
//                       width: 90.w,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10.r),
//                         color: AppColors.primaryButtonColor,
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
//                         color: AppColors.sliderColorInboarding,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 19.h),
//                 SizedBox(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Help us personalize your experience",
//                         style: getTextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: 0.22,
//                         ),
//                       ),
//                       Text(
//                         "To start your profile, share where you are",
//                         style: getTextStyle(
//                           color: AppColors.appBarTitleColor.withValues(alpha: 0.7),
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400,
//                           letterSpacing: 0.0,
//                         ),
//                       ),
//                       Text(
//                         "on your journey.",
//                         style: getTextStyle(
//                           color: AppColors.appBarTitleColor.withValues(alpha: 0.7),
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400,
//                           letterSpacing: 0.0,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 BasicInformation(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
