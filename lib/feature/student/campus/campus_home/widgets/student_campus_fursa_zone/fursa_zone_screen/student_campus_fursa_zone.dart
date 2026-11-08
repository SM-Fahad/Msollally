import 'package:flutter/material.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/student_campus_fursa_zone/tabs/fursa_zone.dart';

class StudentCampusFursaZone extends StatelessWidget {
  const StudentCampusFursaZone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fursa Zone'),
        centerTitle: true,
      ),
      body: const FursaZone(),
    );
  }
}
