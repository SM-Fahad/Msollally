import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/furza_zone/student_quiz_competition/controller/student_quiz_competition_controller.dart';
import 'package:msollaally/feature/furza_zone/student_quiz_competition/screen/three_tabs/widgets/export_button.dart';
import 'package:msollaally/feature/furza_zone/student_quiz_competition/screen/three_tabs/widgets/registered_students.dart';
import 'package:msollaally/feature/furza_zone/student_quiz_competition/screen/three_tabs/widgets/students_info.dart';

class RegistrationsTab extends StatelessWidget {
  const RegistrationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentQuizCompetitionController>();
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Obx(
          () => Column(
            children: [
              RegisteredStudents(
                title: "Registered Students",
                subtitle:
                    "Total Registrations: \\${controller.registeredStudents.length}",
                icon: Icons.people_alt_outlined,
              ),
              const SizedBox(height: 17),
              Container(
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID, or university...',
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: Colors.grey,
                    ),
                    contentPadding: EdgeInsets.only(
                      top: 4,
                      bottom: 4,
                      right: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 17),
              Row(
                children: [
                  Expanded(
                    child: ExportButton(text: 'Export CSV', onTap: () {}),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ExportButton(text: 'Export Excel', onTap: () {}),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...controller.registeredStudents.map(
                (student) => Column(
                  children: [
                    StudentInfoCard(
                      studentName: student.studentName,
                      studentId: student.studentId,
                      position: student.position,
                      university: student.university,
                      year: student.year,
                      program: student.program,
                      email: student.email,
                      phone: student.phone,
                      region: student.region,
                      district: student.district,
                      ward: student.ward,
                      street: student.street,
                      bankAccount: student.bankAccount,
                      currency: student.currency,
                      registeredDate: student.registeredDate,
                    ),
                    const SizedBox(height: 12),
                    StudentInfoCard(
                      studentName: student.studentName,
                      studentId: student.studentId,
                      position: student.position,
                      university: student.university,
                      year: student.year,
                      program: student.program,
                      email: student.email,
                      phone: student.phone,
                      region: student.region,
                      district: student.district,
                      ward: student.ward,
                      street: student.street,
                      bankAccount: student.bankAccount,
                      currency: student.currency,
                      registeredDate: student.registeredDate,
                    ),
                    const SizedBox(height: 12),
                    StudentInfoCard(
                      studentName: student.studentName,
                      studentId: student.studentId,
                      position: student.position,
                      university: student.university,
                      year: student.year,
                      program: student.program,
                      email: student.email,
                      phone: student.phone,
                      region: student.region,
                      district: student.district,
                      ward: student.ward,
                      street: student.street,
                      bankAccount: student.bankAccount,
                      currency: student.currency,
                      registeredDate: student.registeredDate,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
