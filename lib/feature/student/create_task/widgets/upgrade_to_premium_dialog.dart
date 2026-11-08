
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import 'package:msollaally/core/common/styles/global_text_style.dart';
// import '../controller/student_create_task_controller.dart';
// import 'complete_payment_dialog.dart';

// void showUpgradeToPremiumDialog(
//   BuildContext context,
//   StudentCreateTaskController controller,
// ) {
//   final controller = Get.find<StudentCreateTaskController>();
//   final plan = controller.getSelectedPlan();

//   if (plan == null) {
//     EasyLoading.showError('Please select a plan');
//     return;
//   }

//   final amount = controller.extractAmount(plan.charge);
//   controller.originalAmount.value = amount;
//   controller.discountedAmount.value = amount;
//   controller.isDiscountApplied.value = false;
//   controller.referralCodeController.clear();

//   Get.dialog(
//     Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         width: 363,
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Upgrade to Premium',
//               style: getTextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.black1A1A1A,
//               ),
//             ),
//             const SizedBox(height: 6),

//             Text(
//               "Unlock exclusive features and boost your career.",
//               textAlign: TextAlign.center,
//               style: getTextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w400,
//                 color: AppColors.dimGray666666,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//               decoration: BoxDecoration(
//                 color: AppColors.lavenderDBEAFE,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     'Total Amount',
//                     style: getTextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w400,
//                       color: AppColors.dodgerBlue155DFC,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Obx(() {
//                     return Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             if (controller.isDiscountApplied.value) ...[
//                               Flexible(
//                                 child: Text(
//                                   'TZS ${controller.originalAmount.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
//                                   style:
//                                       getTextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w600,
//                                         color: AppColors.darkGray999999,
//                                       ).copyWith(
//                                         decoration: TextDecoration.lineThrough,
//                                       ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                             ],
//                             Flexible(
//                               child: Text(
//                                 'TZS ${controller.discountedAmount.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
//                                 style: getTextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w700,
//                                   color: AppColors.dodgerBlue155DFC,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     );
//                   }),
//                   const SizedBox(height: 8),
//                   Obx(() {
//                     if (controller.isDiscountApplied.value) {
//                       return Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(
//                             Icons.check_circle,
//                             color: AppColors.lightSeaGreen10B981,
//                             size: 14,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             '50% Discount Applied',
//                             style: getTextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.lightSeaGreen10B981,
//                             ),
//                           ),
//                         ],
//                       );
//                     }
//                     return const SizedBox.shrink();
//                   }),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Referral Code',
//                 style: getTextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.black1A1A1A,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             // Referral Code Input Row
//             Obx(() {
//               bool isApplied = controller.isDiscountApplied.value;

//               return Row(
//                 children: [
//                   Expanded(
//                     child: SizedBox(
//                       height: 36,
//                       child: TextField(
//                         controller: controller.referralCodeController,
//                         enabled: !isApplied,
//                         style: getTextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400,
//                           color: isApplied
//                               ? AppColors.darkGray999999
//                               : AppColors.black1A1A1A,
//                         ),
//                         decoration: InputDecoration(
//                           hintText: 'Phone number (e.g. 0712345678)',
//                           hintStyle: getTextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w400,
//                             color: AppColors.darkGray999999,
//                           ),
//                           filled: isApplied,
//                           fillColor: isApplied
//                               ? AppColors.todaysQuickPicContainerBGColor
//                               : Colors.white,
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 12,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: const BorderSide(
//                               color: AppColors.gainsboroE0E0E0,
//                               width: 1,
//                             ),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: const BorderSide(
//                               color: AppColors.gainsboroE0E0E0,
//                               width: 1,
//                             ),
//                           ),
//                           disabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: const BorderSide(
//                               color: AppColors.gainsboroE0E0E0,
//                               width: 1,
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: const BorderSide(
//                               color: AppColors.dodgerBlue2E7CF6,
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   SizedBox(
//                     height: 36,
//                     child: isApplied
//                         ? Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColors.aliceBlueF0F9FF,
//                               border: Border.all(
//                                 color: AppColors.gainsboroE0E0E0,
//                                 width: 1,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'Applied',
//                                 style: getTextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: AppColors.dodgerBlue155DFC,
//                                 ),
//                               ),
//                             ),
//                           )
//                         : TextButton(
//                             onPressed: () {
//                               controller.applyReferralCode(
//                                 controller.referralCodeController.text,
//                               );
//                             },
//                             style: TextButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: Text(
//                               'Apply',
//                               style: getTextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 color: AppColors.dodgerBlue2E7CF6,
//                               ),
//                             ),
//                           ),
//                   ),
//                 ],
//               );
//             }),
//             const SizedBox(height: 8),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "Enter a friend's phone number to get 50% off your first month.",
//                 style: getTextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w400,
//                   color: AppColors.darkGray999999,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Get.back();
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     //showCompletePaymentDialog(context, controller);
//                   });
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.dodgerBlue2E7CF6,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   'Proceed to Payment',
//                   style: getTextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: TextButton(
//                 onPressed: Get.back,
//                 style: TextButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   'Cancel',
//                   style: getTextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.black1A1A1A,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
