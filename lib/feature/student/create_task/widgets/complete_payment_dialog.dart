// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// void showCompletePaymentDialog(BuildContext context, controller) {
//   controller.selectedPaymentMethod.value = '';

//   final paymentMethods = [
//     {'name': 'Airtel Money', 'icon': Icons.phone_android},
//     {'name': 'Tigo Pesa', 'icon': Icons.phone_iphone},
//     {'name': 'HaloPesa', 'icon': Icons.phone},
//     {'name': 'Bank Card', 'icon': Icons.credit_card},
//   ];

//   Get.dialog(
//     Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Complete Payment',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Choose your preferred payment method.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//             SizedBox(height: 24),

//             // Total to pay
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Total to pay',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 Obx(() => Text(
//                   'TZS ${controller.discountedAmount.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 )),
//               ],
//             ),

//             SizedBox(height: 24),

//             // Payment methods
//             Text(
//               'Select Payment Method',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             SizedBox(height: 12),

//             ...paymentMethods.map((method) {
//               return Obx(() => GestureDetector(
//                 onTap: () => controller.selectPaymentMethod(method['name'] as String),
//                 child: Container(
//                   margin: EdgeInsets.only(bottom: 12),
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: controller.selectedPaymentMethod.value == method['name']
//                           ? Colors.blue
//                           : Colors.grey[300]!,
//                       width: controller.selectedPaymentMethod.value == method['name'] ? 2 : 1,
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         method['icon'] as IconData,
//                         color: controller.selectedPaymentMethod.value == method['name']
//                             ? Colors.blue
//                             : Colors.grey[600],
//                       ),
//                       SizedBox(width: 12),
//                       Text(
//                         method['name'] as String,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: controller.selectedPaymentMethod.value == method['name']
//                               ? FontWeight.w600
//                               : FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ));
//             }),

//             SizedBox(height: 24),

//             // Buttons
//             Obx(() => SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: controller.processPayment,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   'Pay TZS ${controller.discountedAmount.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             )),
//             SizedBox(height: 12),
//             TextButton(
//               onPressed: () => Get.back(),
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: Colors.grey[700],
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
