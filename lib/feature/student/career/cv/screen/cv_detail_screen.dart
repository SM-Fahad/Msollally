import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/student/career/cv/controller/cv_controller.dart';
import 'package:msollaally/feature/student/career/cv/screen/cv_screen.dart';

class CvDetailScreen extends StatefulWidget {
  final String cvId;

  const CvDetailScreen({super.key, required this.cvId});

  @override
  State<CvDetailScreen> createState() => _CvDetailScreenState();
}

class _CvDetailScreenState extends State<CvDetailScreen> {
  final CvController _cvController = Get.find<CvController>();
  late Future<Map<String, dynamic>?> _cvFuture;

  @override
  void initState() {
    super.initState();
    _loadCv();
  }

  void _loadCv() {
    _cvFuture = _cvController.getCvById(widget.cvId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'CV Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.primaryButtonColor),
            tooltip: 'Download CV',
            onPressed: () => _cvController.downloadCvById(widget.cvId),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryButtonColor),
            tooltip: 'Edit CV',
            onPressed: () async {
              final ok = await _cvController.populateForEdit(widget.cvId);
              if (ok) {
                await Get.to(() => CvScreen());
                setState(() {
                  _loadCv();
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Delete CV',
            onPressed: () async {
              await _cvController.deleteCv(widget.cvId);
              Get.back();
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _cvFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cv = snapshot.data;
          if (cv == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('CV details could not be found.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadCv();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final firstName = cv['firstName'] ?? '';
          final middleName = cv['middleName'] ?? '';
          final lastName = cv['lastName'] ?? '';
          final fullName = [firstName, middleName, lastName]
              .where((s) => s.toString().trim().isNotEmpty)
              .join(' ');
          final email = cv['email'] ?? '';
          final mobile = cv['mobileNo'] ?? '';
          final address = cv['contactAddress'] ?? '';
          final sex = cv['sex'] ?? '';
          final nationality = cv['nationality'] ?? '';
          final maritalStatus = cv['maritalStatus'] ?? '';
          final otherMaritalStatus = cv['otherMaritalStatus'];
          final personalSummary = cv['personalSummery'] ?? '';
          final languages = (cv['languageProficiency'] as List?) ?? [];
          final hobbies = (cv['hobbiesAndInterest'] ?? cv['hobbies'] as List?) ?? [];
          final educations = (cv['educations'] as List?) ?? [];
          final experiences = (cv['experiences'] as List?) ?? [];
          final referrers = (cv['referrers'] as List?) ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Profile Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primaryButtonColor.withValues(alpha: 0.1),
                        child: Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'C',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryButtonColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullName.isNotEmpty ? fullName : 'Unnamed CV',
                        style: getTextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: getTextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                      if (mobile.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          mobile,
                          style: getTextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                      if (address.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              address,
                              style: getTextStyle(
                                fontSize: 13,
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: [
                          if (sex.isNotEmpty) _badge(sex.toString().toUpperCase()),
                          if (nationality.isNotEmpty) _badge(nationality),
                          if (maritalStatus.isNotEmpty)
                            _badge(otherMaritalStatus != null && otherMaritalStatus.toString().isNotEmpty
                                ? '$maritalStatus ($otherMaritalStatus)'
                                : maritalStatus),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Personal Summary
                if (personalSummary.isNotEmpty) ...[
                  _sectionCard(
                    title: 'Personal Summary',
                    icon: Icons.person_outline,
                    child: Text(
                      personalSummary,
                      style: getTextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Education Section
                if (educations.isNotEmpty) ...[
                  _sectionCard(
                    title: 'Education',
                    icon: Icons.school_outlined,
                    child: Column(
                      children: educations.map<Widget>((edu) {
                        final inst = edu['institution'] ?? '';
                        final deg = edu['degree'] ?? '';
                        final gpa = edu['gpa']?.toString() ?? '';
                        final sDate = edu['startDate'] ?? '';
                        final eDate = edu['endDate'] ?? '';
                        final desc = edu['description'] ?? '';

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      deg.isNotEmpty ? deg : inst,
                                      style: getTextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (gpa.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryButtonColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'GPA: $gpa',
                                        style: getTextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryButtonColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (deg.isNotEmpty && inst.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  inst,
                                  style: getTextStyle(
                                    fontSize: 13,
                                    color: AppColors.secondaryTextColor,
                                  ),
                                ),
                              ],
                              if (sDate.isNotEmpty || eDate.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '$sDate ${eDate.isNotEmpty ? '— $eDate' : ''}',
                                  style: getTextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                              if (desc.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  desc,
                                  style: getTextStyle(fontSize: 13, height: 1.4),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Experience Section
                if (experiences.isNotEmpty) ...[
                  _sectionCard(
                    title: 'Work Experience',
                    icon: Icons.work_outline,
                    child: Column(
                      children: experiences.map<Widget>((exp) {
                        final comp = exp['companyName'] ?? '';
                        final pos = exp['position'] ?? '';
                        final sDate = exp['startDate'] ?? '';
                        final eDate = exp['endDate'] ?? '';
                        final desc = exp['description'] ?? '';

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pos.isNotEmpty ? pos : comp,
                                style: getTextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (pos.isNotEmpty && comp.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  comp,
                                  style: getTextStyle(
                                    fontSize: 13,
                                    color: AppColors.secondaryTextColor,
                                  ),
                                ),
                              ],
                              if (sDate.isNotEmpty || eDate.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '$sDate ${eDate.isNotEmpty ? '— $eDate' : ''}',
                                  style: getTextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                              if (desc.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  desc,
                                  style: getTextStyle(fontSize: 13, height: 1.4),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Languages & Hobbies
                if (languages.isNotEmpty || hobbies.isNotEmpty) ...[
                  _sectionCard(
                    title: 'Skills & Interests',
                    icon: Icons.interests_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (languages.isNotEmpty) ...[
                          Text(
                            'Languages',
                            style: getTextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: languages.map<Widget>((lang) => _chip(lang.toString())).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (hobbies.isNotEmpty) ...[
                          Text(
                            'Hobbies & Interests',
                            style: getTextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: hobbies.map<Widget>((h) => _chip(h.toString())).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Referrers Section
                if (referrers.isNotEmpty) ...[
                  _sectionCard(
                    title: 'References',
                    icon: Icons.contact_page_outlined,
                    child: Column(
                      children: referrers.map<Widget>((ref) {
                        final rName = ref['name'] ?? '';
                        final rRole = ref['role'] ?? '';
                        final rOrg = ref['organization'] ?? '';
                        final rPhone = ref['phone'] ?? '';
                        final rAddr1 = ref['address1'] ?? '';
                        final rAddr2 = ref['address2'] ?? '';

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rName,
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (rRole.isNotEmpty || rOrg.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '$rRole${rRole.isNotEmpty && rOrg.isNotEmpty ? ' at ' : ''}$rOrg',
                                  style: getTextStyle(
                                    fontSize: 13,
                                    color: AppColors.secondaryTextColor,
                                  ),
                                ),
                              ],
                              if (rPhone.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      rPhone,
                                      style: getTextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                              if (rAddr1.isNotEmpty || rAddr2.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      [rAddr1, rAddr2].where((s) => s.isNotEmpty).join(', '),
                                      style: getTextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButtonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Download CV', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => _cvController.downloadCvById(widget.cvId),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryButtonColor,
                          side: const BorderSide(color: AppColors.primaryButtonColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit CV', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          final ok = await _cvController.populateForEdit(widget.cvId);
                          if (ok) {
                            await Get.to(() => CvScreen());
                            setState(() {
                              _loadCv();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryButtonColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryButtonColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: getTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryButtonColor,
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: getTextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
