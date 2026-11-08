import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/student_campus_wall.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/wall/wall_post_input_field.dart';

class StudentCampusWallField extends StatelessWidget {
  const StudentCampusWallField({
    super.key,
    required StudentCampusController controller,
  }) : _controller = controller;

  final StudentCampusController _controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WallPostInputField(controller: _controller),
        SizedBox(height: 10.height),
        const StudentCampusWall(),
      ],
    );
  }
}
