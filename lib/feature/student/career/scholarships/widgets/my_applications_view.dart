import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../controller/scholarship_controller.dart';
import 'application_card.dart';

class MyApplicationsView extends StatelessWidget {
  final ScholarshipController controller;

  const MyApplicationsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isApplicationsLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      final list = controller.myApplications;
      if (list.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchMyApplications(),
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 20, top: 8),
          itemCount: list.length,
          itemBuilder: (context, index) =>
              ApplicationCard(application: list[index]),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_late_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Applications Yet',
            style: getTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scholarships you apply for will appear here',
            style: getTextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
