import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/scholarship_controller.dart';
import '../model/scholarship_model.dart';
import '../widgets/scholarship_apply_bottom_sheet.dart';
import '../widgets/scholarship_detail_widgets.dart';

class ScholarshipDetailScreen extends StatelessWidget {
  final ScholarshipModel scholarship;
  final bool showApplyButton;

  const ScholarshipDetailScreen({
    super.key,
    required this.scholarship,
    this.showApplyButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final ScholarshipController controller = Get.find<ScholarshipController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Scholarship Details"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              controller.fetchScholarships();
              controller.fetchMyApplications();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScholarshipDetailHeader(
              title: scholarship.title,
              foundation: scholarship.foundationName,
              thumbnailUrl: scholarship.fullThumbnailUrl,
              foundationLogoUrl: scholarship.fullFoundationLogoUrl,
            ),
            const SizedBox(height: 16),
            _buildBadges(),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 20),
            _buildInfoSection(),
            const SizedBox(height: 24),
            _buildSectionTitle("Description"),
            const SizedBox(height: 8),
            Text(
              scholarship.description,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 32),
            if (showApplyButton) ...[
              if (scholarship.applicationLink.trim().isNotEmpty) ...[
                OutlinedButton.icon(
                  onPressed: () => _openExternalLink(
                    context,
                    scholarship.applicationLink,
                  ),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text(
                    'Apply on Official Website',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(
                      color: AppColors.primaryButtonColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              CustomButton(
                text: 'Apply for Scholarship (In-App)',
                onPressed: () => showScholarshipApplyBottomSheet(
                  context,
                  scholarship,
                  controller,
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternalLink(BuildContext context, String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    final fixedUrl = trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.tryParse(fixedUrl);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        Get.snackbar('Notice', 'Could not open application link');
      }
    }
  }

  Widget _buildBadges() {
    return Row(
      children: [
        ScholarshipInfoBadge(
          label: '${scholarship.currency} ${scholarship.amount}',
          icon: Icons.payments_rounded,
          color: Colors.green,
        ),
        const SizedBox(width: 10),
        if (scholarship.isFullyFunded)
          const ScholarshipInfoBadge(
            label: 'Fully Funded',
            icon: Icons.verified_rounded,
            color: Colors.blue,
          ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        ScholarshipDetailItem(
          label: "Country",
          value: scholarship.country,
          icon: Icons.public_rounded,
        ),
        ScholarshipDetailItem(
          label: "Minimum GPA",
          value: scholarship.minimumGPA,
          icon: Icons.stars_rounded,
        ),
        ScholarshipDetailItem(
          label: "Open Date",
          value: scholarship.openDate,
          icon: Icons.event_available_rounded,
        ),
        ScholarshipDetailItem(
          label: "Deadline",
          value: scholarship.dueDate,
          icon: Icons.event_busy_rounded,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
