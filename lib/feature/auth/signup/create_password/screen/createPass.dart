// // ignore_for_file: file_names

// import 'package:flutter/material.dart';
// import 'package:msollaally/core/common/styles/global_text_style.dart';
// import 'package:get/get.dart';
// import 'package:msollaally/core/common/widgets/custom_button.dart';
// import 'package:msollaally/feature/auth/auth_controller/authController.dart';
// import 'package:msollaally/core/common/widgets/standard_text_field.dart';
// import '../../../login/login_page/screen/loginScreen.dart';

// class CreatePass extends StatelessWidget {
//   CreatePass({super.key});

//   final AuthController authController = Get.put(AuthController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 12, top: 8),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: IconButton(
//                   icon: const Icon(Icons.arrow_back, color: Colors.black),
//                   onPressed: () => Get.back(),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Container(
//               width: double.infinity,
//               height: 1,
//               color: Colors.grey.shade300,
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 20,
//                 ),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 96),

//                       Text(
//                         "Create Password",
//                         style: getTextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 8.0, top: 20.0),
//                         child: Text(
//                           "Password",
//                           style: getTextStyle(
//                             fontSize: 16,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ),
//                       Obx(
//                         () => TextField(
//                           controller: authController.passwordController,
//                           obscureText: authController.isPasswordHidden.value,
//                           onChanged: (value) {
//                             authController.passwordStrength.value = value;
//                           },
//                           decoration: standardInputDecoration(
//                             hintText: "Enter your password",
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 authController.isPasswordHidden.value
//                                     ? Icons.visibility_off
//                                     : Icons.visibility,
//                               ),
//                               onPressed: () {
//                                 authController.isPasswordHidden.value =
//                                     !authController.isPasswordHidden.value;
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Obx(() {
//                         String strength = authController.getPasswordStrength(
//                           authController.passwordStrength.value,
//                         );
//                         int level = authController.getStrengthLevel(
//                           authController.passwordStrength.value,
//                         );
//                         return Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               strength,
//                               style: getTextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: strength.isEmpty
//                                     ? Colors.grey
//                                     : strength == "Very Weak"
//                                     ? Colors.red
//                                     : strength == "Weak"
//                                     ? Colors.orange
//                                     : strength == "Medium"
//                                     ? Colors.blue
//                                     : Colors.green,
//                               ),
//                             ),
//                             Row(
//                               children: List.generate(3, (index) {
//                                 return Container(
//                                   margin: const EdgeInsets.symmetric(
//                                     horizontal: 2,
//                                   ),
//                                   height: 4,
//                                   width: 50,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(4),
//                                     color: index < level
//                                         ? (strength == "Very Weak"
//                                               ? Colors.red
//                                               : strength == "Weak"
//                                               ? Colors.orange
//                                               : strength == "Medium"
//                                               ? Colors.blue
//                                               : Colors.green)
//                                         : Colors.grey.shade300,
//                                   ),
//                                 );
//                               }),
//                             ),
//                           ],
//                         );
//                       }),
//                       const SizedBox(height: 50),
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 8.0, top: 20.0),
//                         child: Text(
//                           "Confirm Password",
//                           style: getTextStyle(
//                             fontSize: 16,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ),
//                       Obx(
//                         () => TextField(
//                           controller: authController.confirmPasswordController,
//                           obscureText:
//                               authController.isConfirmPasswordHidden.value,
//                           decoration: standardInputDecoration(
//                             hintText: "Re-enter your password",
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 authController.isConfirmPasswordHidden.value
//                                     ? Icons.visibility_off
//                                     : Icons.visibility,
//                               ),
//                               onPressed: () {
//                                 authController.isConfirmPasswordHidden.value =
//                                     !authController
//                                         .isConfirmPasswordHidden
//                                         .value;
//                               },
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 40),
//                       Obx(() {
//                         final loading = authController.isLoading.value;
//                         return CustomButton(
//                           text: loading ? "Please wait..." : "Finish",
//                           onPressed: loading
//                               ? () {}
//                               : () => authController.setPassword(
//                                   password:
//                                       authController.passwordController.text,
//                                   confirmPassword: authController
//                                       .confirmPasswordController
//                                       .text,
//                                 ),
//                         );
//                       }),
//                       const SizedBox(height: 16),

// ignore_for_file: file_names

//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 30),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Text("Already have an account? "),
//                             GestureDetector(
//                               onTap: () => Get.to(LoginScreen()),
//                               child: Text(
//                                 "Sign In",
//                                 style: getTextStyle(
//                                   color: Colors.blue,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
