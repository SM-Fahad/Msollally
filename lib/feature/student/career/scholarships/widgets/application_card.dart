import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/scholarship_controller.dart';
import '../model/scholarship_application_model.dart';
import '../screen/application_detail_screen.dart';
import '../widgets/scholarship_apply_bottom_sheet.dart';

class ApplicationCard extends StatelessWidget {
  final ScholarshipApplicationModel application;

  const ApplicationCard({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final s = application.scholarship;
    final ScholarshipController controller = Get.find<ScholarshipController>();
    final statusColor = _getStatusColor(application.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(s, statusColor),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildFooter(context, s, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(s, Color statusColor) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                s.foundationName,
                style: getTextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            application.status.toUpperCase(),
            style: getTextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, s, controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submitted On',
              style: getTextStyle(fontSize: 11, color: Colors.black38),
            ),
            Text(
              _formatDate(application.submittedAt),
              style: getTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (application.status.toLowerCase() == 'pending' ||
                application.status.toLowerCase() == 'submitted')
              IconButton(
                onPressed: () => showScholarshipApplyBottomSheet(
                  context,
                  s,
                  controller,
                  existingApplication: application,
                ),
                icon: const Icon(Icons.edit_note_rounded, color: Colors.orange),
                tooltip: 'Edit Application',
              ),
            ElevatedButton(
              onPressed: () {
                controller.fetchApplicationDetails(application.applicationId);
                Get.to(() => const ScholarshipApplicationDetailScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButtonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('View'),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'submitted':
        return Colors.teal;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
