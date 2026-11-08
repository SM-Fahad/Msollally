import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/union/union_header.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/union/union_tabs.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/union/union_list_view.dart';

class StudentCampusUnion extends StatelessWidget {
  const StudentCampusUnion({
    super.key,
    required StudentCampusController controller,
  }) : _controller = controller;

  final StudentCampusController _controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.width),
      child: Column(
        children: [
          UnionHeader(controller: _controller),
          SizedBox(height: 23.height),
          UnionTabs(controller: _controller),
          SizedBox(height: 28.height),
          UnionListView(controller: _controller),
        ],
      ),
    );
  }
}
