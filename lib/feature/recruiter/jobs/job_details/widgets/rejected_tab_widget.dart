import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import '../controller/job_details_controller.dart';
import 'candidate_card_widget.dart';

class RejectedTabWidget extends StatelessWidget {
  const RejectedTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobDetailsController>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  'Rejected (${controller.rejectedCandidates.length})',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => debugPrint('Export tapped'),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.copy_rounded,
                            color: AppColors.primaryButtonColor,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Export',
                          style: TextStyle(
                            color: AppColors.primaryButtonColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Obx(() {
            if (controller.isRejectedLoading.value) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.rejectedCandidates.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('No rejected candidates yet'),
                ),
              );
            }

            return Column(
              children: List.generate(
                controller.rejectedCandidates.length,
                (i) => CandidateCardWidget(
                  candidate: controller.rejectedCandidates[i],
                  onShortlist: null,
                  onReject: null,
                  onReserve: null,
                  showActionButtons: false,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
