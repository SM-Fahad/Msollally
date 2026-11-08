import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/academics/create_plan/screen/create_plan.dart';
import '../../module/model/module_model.dart';
import '../widgets/class_file_card.dart';
import '../widgets/class_notes_card.dart';

class ClassDetailScreen extends StatelessWidget {
  final ModuleModel module;
  final ClassModel classItem;

  const ClassDetailScreen({
    super.key,
    required this.module,
    required this.classItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              classItem.title,
              style: getTextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            _buildAppBarActions(context),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateLocationRow(),
            SizedBox(height: 20),
            if (classItem.topics.isNotEmpty) _buildTopics(),
            Text(
              "Notes",
              style: getTextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 8),
            ClassNotesCard(),
            SizedBox(height: 20),
            if (classItem.files.isNotEmpty || module.files.isNotEmpty) _buildFiles(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarActions(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Get.to(CreatePlanScreen()),
          icon: Image.asset(
            'assets/icons/createPlan_icon.png',
            height: 50,
            width: 120,
          ),
        ),
        SizedBox(width: 12),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildDateLocationRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoColumn("Date & Time", classItem.time),
        _buildInfoColumn("Location", classItem.location),
      ],
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: getTextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          SizedBox(height: 4),
          Text(value, style: getTextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTopics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Topics",
          style: getTextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        SizedBox(height: 8),
        ...classItem.topics.map(
          (topic) => Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Text(
              "• $topic",
              style: getTextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFiles() {
    final filesToDisplay = classItem.files.isNotEmpty ? classItem.files : module.files;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Files",
          style: getTextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        SizedBox(height: 8),
        ...filesToDisplay.map((file) => ClassFileCard(file: file)),
      ],
    );
  }
}
