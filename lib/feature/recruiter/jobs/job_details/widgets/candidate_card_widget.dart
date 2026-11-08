import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/model/candidate_model.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/widgets/action_buttons.dart';
import '../controller/job_details_controller.dart';

class CandidateCardWidget extends GetView<JobDetailsController> {
  final CandidateModel candidate;
  final VoidCallback? onShortlist;
  final Function(String)? onReject;
  final VoidCallback? onReserve;
  final bool showActionButtons;

  const CandidateCardWidget({
    super.key,
    required this.candidate,
    this.onShortlist,
    this.onReject,
    this.onReserve,
    this.showActionButtons = true,
  });


  CandidateModel _live() {
    return controller.candidates.firstWhereOrNull((c) => c.id == candidate.id) ??
        controller.shortlistedCandidates
            .firstWhereOrNull((c) => c.id == candidate.id) ??
        controller.reservedCandidates
            .firstWhereOrNull((c) => c.id == candidate.id) ??
        controller.rejectedCandidates
            .firstWhereOrNull((c) => c.id == candidate.id) ??
        candidate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: TextStyle(
                        color: AppColors.appBarTitleColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      candidate.education,
                      style: TextStyle(
                        color: AppColors.appBarTitleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${candidate.experience} years experience',
                      style: TextStyle(
                        color: AppColors.darkSlateGrayAlphaB23F3F3F,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: candidate.skills
                            .map(
                              (skill) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Colors.black.withValues(alpha: 0.12),
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child:
                                    Text(skill, style: const TextStyle(fontSize: 10)),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(radius: 28, backgroundColor: Colors.grey[300]),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.black.withValues(alpha: 0.12)),
          const SizedBox(height: 12),

          // View Resume + action buttons 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // View Resume button (static – no reactivity needed)
              GestureDetector(
                onTap: () => controller.openResumeUrl(candidate.resumeUrl),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.12),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'View Resume',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),

              Obx(() {
                final live = _live();
                return ActionButtons(
                  live: live,
                  showActionButtons: showActionButtons,
                  onReserve: onReserve,
                  onReject: onReject,
                  onShortlist: onShortlist,
                  onShowRejectionDialog: () =>
                      _showRejectionDialog(context),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // rejection dialog 

  void _showRejectionDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejection Reason'),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            hintText: 'Enter rejection reason',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                Get.snackbar('Error', 'Please enter a rejection reason');
                return;
              }
              Navigator.pop(context);
              onReject?.call(reason);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
