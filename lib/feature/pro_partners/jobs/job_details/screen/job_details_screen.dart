import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/pro_partners/jobs/all_jobs/model/job_model.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/screen/job_applicants_screen.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_details/controller/job_details_controller.dart';

class JobDetailsScreen extends StatelessWidget {
  final JobModel job;

  const JobDetailsScreen({super.key, required this.job});

  factory JobDetailsScreen.fromArgs() {
    final args = Get.arguments;
    if (args is JobModel) return JobDetailsScreen(job: args);
    throw Exception('JobModel expected in arguments');
  }

  @override
  Widget build(BuildContext context) {
    final tag = 'job-details-${job.id}';
    final controller = Get.isRegistered<JobDetailsController>(tag: tag)
        ? Get.find<JobDetailsController>(tag: tag)
        : Get.put(JobDetailsController(job), tag: tag);

    return Obx(() {
      final details = controller.details.value;
      final status = details.status.toLowerCase();
      final canViewApplicants = status == 'published';
      final canPublish = status == 'draft';
      final canUpdate = status == 'published';

      final infoItems = <_InfoItem>[
        if (controller.hasValue(details.locationType))
          _InfoItem(
            Icons.location_on_outlined,
            'Location',
            details.locationType,
          ),
        if (controller.hasValue(details.jobType))
          _InfoItem(
            Icons.schedule_outlined,
            'Job Type',
            controller.prettyLabel(details.jobType),
          ),
        if (controller.formatSalary().isNotEmpty)
          _InfoItem(
            Icons.payments_outlined,
            'Salary',
            controller.formatSalary(),
          ),
        if (controller.formatDate(details.applicationDeadline).isNotEmpty)
          _InfoItem(
            Icons.calendar_today_outlined,
            'Deadline',
            controller.formatDate(details.applicationDeadline),
          ),
        if (controller.formatExperience().isNotEmpty)
          _InfoItem(
            Icons.workspace_premium_outlined,
            'Experience',
            controller.formatExperience(),
          ),
        if (details.applications > 0)
          _InfoItem(
            Icons.groups_outlined,
            'Applications',
            '${details.applications}',
          ),
        if (details.views > 0)
          _InfoItem(Icons.remove_red_eye_outlined, 'Views', '${details.views}'),
      ];

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.appBarTitleColor,
            ),
            onPressed: Get.back,
          ),
          title: const Text(
            'Job Details',
            style: TextStyle(color: AppColors.appBarTitleColor),
          ),
        ),
        body: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : controller.errorMessage.value.isNotEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: controller.fetchJobDetails,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderCard(
                        job: details,
                        controller: controller,
                        canViewApplicants: canViewApplicants,
                        canPublish: canPublish,
                        canUpdate: canUpdate,
                      ),
                      if (infoItems.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _SectionTitle('Quick Overview'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: infoItems
                              .map((item) => _InfoCard(item: item))
                              .toList(),
                        ),
                      ],
                      if (controller.hasValue(details.description)) ...[
                        const SizedBox(height: 18),
                        _SectionTitle('Job Description'),
                        const SizedBox(height: 8),
                        _BodyCard(child: Text(details.description)),
                      ],
                      _ListSection(
                        title: 'Requirements',
                        items: details.requirements,
                      ),
                      _ListSection(
                        title: 'Main Responsibilities',
                        items: details.responsibilities,
                      ),
                      _ListSection(title: 'Benefits', items: details.benefits),
                      _ListSection(
                        title: 'Professional Skills',
                        items: details.professionalSkills,
                      ),
                      _ListSection(
                        title: 'Other Facilities',
                        items: details.otherFacilities,
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
      );
    });
  }
}

class _HeaderCard extends StatelessWidget {
  final JobModel job;
  final JobDetailsController controller;
  final bool canViewApplicants;
  final bool canPublish;
  final bool canUpdate;

  const _HeaderCard({
    required this.job,
    required this.controller,
    required this.canViewApplicants,
    required this.canPublish,
    required this.canUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(job.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sectionBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CompanyAvatar(
                companyName: job.companyName,
                companyLogo: job.companyLogo,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.hasValue(job.title)
                          ? job.title
                          : 'Untitled Job',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.appBarTitleColor,
                      ),
                    ),
                    if (controller.hasValue(job.companyName)) ...[
                      const SizedBox(height: 4),
                      Text(
                        job.companyName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tertiaryTextColor,
                        ),
                      ),
                    ],
                    if (controller.hasValue(job.department)) ...[
                      const SizedBox(height: 3),
                      Text(
                        job.department,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.tertiaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusChip(
                label: controller.prettyLabel(job.status),
                style: style,
              ),
            ],
          ),
          if (controller.formatDate(job.publishedAt).isNotEmpty ||
              controller.formatDate(job.applicationDeadline).isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              [
                if (controller.formatDate(job.publishedAt).isNotEmpty)
                  'Posted ${controller.formatDate(job.publishedAt)}',
                if (controller.formatDate(job.applicationDeadline).isNotEmpty)
                  'Deadline ${controller.formatDate(job.applicationDeadline)}',
              ].join(' • '),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.tertiaryTextColor,
              ),
            ),
          ],
          if (canViewApplicants || canPublish || canUpdate) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (canViewApplicants)
                  _PrimaryAction(
                    text: 'View Applications',
                    icon: Icons.people_alt_outlined,
                    onTap: () => Get.to(() => JobApplicantsScreen(job: job)),
                  ),
                if (canPublish)
                  Obx(
                    () => _PrimaryAction(
                      text: 'Publish',
                      icon: controller.updatingStatus.value
                          ? null
                          : Icons.publish_outlined,
                      onTap: controller.updatingStatus.value
                          ? null
                          : () => controller.updateJobStatus('published'),
                      loading: controller.updatingStatus.value,
                    ),
                  ),
                if (canUpdate)
                  Obx(
                    () => _OutlineAction(
                      text: 'Update Status',
                      icon: controller.updatingStatus.value
                          ? null
                          : Icons.keyboard_arrow_down,
                      onTap: controller.updatingStatus.value
                          ? null
                          : () => _showStatusSheet(controller, job),
                      loading: controller.updatingStatus.value,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showStatusSheet(JobDetailsController controller, JobModel job) {
    final actions = const [
      _StatusAction('Close Job', 'closed', Icons.cancel_outlined),
      _StatusAction('Mark as Filled', 'filled', Icons.check_circle_outline),
      _StatusAction('Archive Job', 'archived', Icons.archive_outlined),
    ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.sectionBorderColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Update Job Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.appBarTitleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.hasValue(job.title) ? job.title : 'Untitled Job',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.tertiaryTextColor,
                ),
              ),
              const SizedBox(height: 18),
              ...actions.map(
                (action) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: Icon(
                    action.icon,
                    color: AppColors.primaryButtonColor,
                  ),
                  title: Text(
                    action.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.appBarTitleColor,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    controller.updateJobStatus(action.status);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _CompanyAvatar extends StatelessWidget {
  final String companyName;
  final String companyLogo;

  const _CompanyAvatar({required this.companyName, required this.companyLogo});

  @override
  Widget build(BuildContext context) {
    final hasLogo = companyLogo.trim().isNotEmpty;
    final hasName = companyName.trim().isNotEmpty;

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sectionBorderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasLogo
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: Image.network(
                companyLogo,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    _AvatarFallback(companyName: companyName),
              ),
            )
          : _AvatarFallback(companyName: companyName, hasName: hasName),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String companyName;
  final bool? hasName;

  const _AvatarFallback({required this.companyName, this.hasName});

  @override
  Widget build(BuildContext context) {
    final validName = hasName ?? companyName.trim().isNotEmpty;
    return Container(
      color: AppColors.primaryButtonColor.withValues(alpha: 0.10),
      alignment: Alignment.center,
      child: validName
          ? Text(
              companyName.trim()[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryButtonColor,
              ),
            )
          : const Icon(
              Icons.business_center_outlined,
              size: 30,
              color: AppColors.primaryButtonColor,
            ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem(this.icon, this.label, this.value);
}

class _InfoCard extends StatelessWidget {
  final _InfoItem item;

  const _InfoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 54) / 2,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sectionBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 18, color: AppColors.primaryButtonColor),
          const SizedBox(height: 10),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.tertiaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.appBarTitleColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.appBarTitleColor,
      ),
    );
  }
}

class _BodyCard extends StatelessWidget {
  final Widget child;

  const _BodyCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sectionBorderColor),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppColors.appBarTitleColor,
        ),
        child: child,
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _ListSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final validItems = items
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (validItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title),
          const SizedBox(height: 8),
          _BodyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: validItems.map((item) {
                final isHeader = (item.startsWith('**') && item.endsWith('**')) ||
                    item.endsWith(':') ||
                    item.startsWith('[Header]');
                final displayText = item
                    .replaceAll('**', '')
                    .replaceFirst('[Header]', '')
                    .trim();

                if (isHeader) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      displayText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.appBarTitleColor,
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '•  ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.appBarTitleColor,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          displayText,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: AppColors.appBarTitleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool loading;

  const _PrimaryAction({
    required this.text,
    this.icon,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryButtonColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool loading;

  const _OutlineAction({
    required this.text,
    this.icon,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryButtonColor,
              ),
            )
          : Icon(icon, size: 18),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryButtonColor,
        side: const BorderSide(color: AppColors.primaryButtonColor),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _StatusAction {
  final String label;
  final String status;
  final IconData icon;

  const _StatusAction(this.label, this.status, this.icon);
}

class _StatusChip extends StatelessWidget {
  final String label;
  final _StatusStyle style;

  const _StatusChip({required this.label, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: style.text,
        ),
      ),
    );
  }
}

class _StatusStyle {
  final Color background;
  final Color border;
  final Color text;

  const _StatusStyle({
    required this.background,
    required this.border,
    required this.text,
  });
}

_StatusStyle _statusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'draft':
      return const _StatusStyle(
        background: AppColors.cornsilkFFF8E1,
        border: AppColors.khakiF5D27A,
        text: AppColors.chocolateB7791F,
      );
    case 'published':
      return const _StatusStyle(
        background: AppColors.createTaskButtonColorHomePage,
        border: AppColors.powderBlueB7E4CA,
        text: AppColors.seaGreen2F9E62,
      );
    case 'closed':
      return const _StatusStyle(
        background: AppColors.lavenderBlushFEF2F2,
        border: AppColors.lightPinkF3C0C0,
        text: AppColors.indianRedC24141,
      );
    case 'filled':
      return const _StatusStyle(
        background: AppColors.aliceBlueEFF6FF,
        border: AppColors.powderBlueBFDBFE,
        text: AppColors.royalBlue2563EB,
      );
    default:
      return const _StatusStyle(
        background: AppColors.whiteSmokeF4F4F5,
        border: AppColors.sectionBorderColor,
        text: AppColors.tertiaryTextColor,
      );
  }
}
