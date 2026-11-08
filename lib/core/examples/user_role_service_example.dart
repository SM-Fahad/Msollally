// // Example: How to use UserRoleService throughout your app

// import 'package:flutter/material.dart';
// import 'package:msollaally/core/services/user_role_service.dart';
// import 'package:msollaally/core/controllers/user_role_controller.dart';

// class ExampleUsage extends StatelessWidget {
//   const ExampleUsage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'User Role: ${UserRoleService.selectedRoleString ?? "None"}',
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Example 1: Check if any role is selected
//             Text(
//               'Has Selected Role: ${UserRoleService.hasSelectedRole}',
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),

//             // Example 2: Check specific roles
//             if (UserRoleService.isStudent) const Text('Welcome Student! 🎓'),
//             if (UserRoleService.isTeacher) const Text('Welcome Teacher! 👩‍🏫'),
//             if (UserRoleService.isRecruiter)
//               const Text('Welcome Recruiter! 💼'),
//             if (UserRoleService.isProPartners)
//               const Text('Welcome Pro Partner! 🤝'),

//             const SizedBox(height: 16),

//             // Example 3: Get role as string
//             Text('Role as String: ${UserRoleService.selectedRoleString}'),

//             // Example 4: Get role as index
//             Text('Role Index: ${UserRoleService.selectedRoleIndex}'),

//             // Example 5: Get role as enum
//             Text('Role Enum: ${UserRoleService.selectedRole}'),

//             const SizedBox(height: 32),

//             // Example 6: Role-based UI
//             _buildRoleBasedContent(),

//             const SizedBox(height: 32),

//             // Example 7: Clear role button
//             ElevatedButton(
//               onPressed: () {
//                 UserRoleService.clearSelectedRole();
//                 // UI will update automatically if you're using Obx
//               },
//               child: const Text('Clear Selected Role'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRoleBasedContent() {
//     // Example of building different UI based on user role
//     switch (UserRoleService.selectedRole) {
//       case UserRole.STUDENT:
//         return Container(
//           padding: const EdgeInsets.all(16),
//           color: Colors.blue.shade50,
//           child: const Text('Student-specific content here'),
//         );
//       case UserRole.FACULTY:
//         return Container(
//           padding: const EdgeInsets.all(16),
//           color: Colors.purple.shade50,
//           child: const Text('Teacher-specific content here'),
//         );
//       case UserRole.RECRUITER:
//         return Container(
//           padding: const EdgeInsets.all(16),
//           color: Colors.green.shade50,
//           child: const Text('Recruiter-specific content here'),
//         );
//       case UserRole.PRO_PARTNER:
//         return Container(
//           padding: const EdgeInsets.all(16),
//           color: Colors.orange.shade50,
//           child: const Text('Pro Partners-specific content here'),
//         );
//       case null:
//         return Container(
//           padding: const EdgeInsets.all(16),
//           color: Colors.grey.shade50,
//           child: const Text('No role selected'),
//         );
//     }
//   }
// }
