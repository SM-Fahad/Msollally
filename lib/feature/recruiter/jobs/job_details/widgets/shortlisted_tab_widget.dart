import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import '../controller/job_details_controller.dart';
import 'candidate_card_widget.dart';

class ShortlistedTabWidget extends StatelessWidget {
  const ShortlistedTabWidget({super.key});

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
                  'Shortlisted (${controller.shortlistedCandidates.length})',
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
                  // GestureDetector(
                  //   onTap: () {
                  //     showModalBottomSheet(
                  //       context: context,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.vertical(
                  //           top: Radius.circular(12),
                  //         ),
                  //       ),
                  //       builder: (_) => Padding(
                  //         padding: EdgeInsets.all(12),
                  //         child: Column(
                  //           mainAxisSize: MainAxisSize.min,
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             ListTile(
                  //               title: Text(
                  //                 'Jr Executive (Female)',
                  //                 style: TextStyle(fontSize: 16),
                  //               ),
                  //               onTap: () => Navigator.of(context).pop(),
                  //             ),
                  //             Divider(height: 1),
                  //             ListTile(
                  //               title: Text(
                  //                 'Ui/UX Designer',
                  //                 style: TextStyle(fontSize: 16),
                  //               ),
                  //               onTap: () => Navigator.of(context).pop(),
                  //             ),
                  //             Divider(height: 1),
                  //             ListTile(
                  //               title: Text(
                  //                 'Front Desk Officer',
                  //                 style: TextStyle(fontSize: 16),
                  //               ),
                  //               onTap: () => Navigator.of(context).pop(),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //   child: Container(
                  //     padding: EdgeInsets.all(8),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(8),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: AppColors.blackAlpha0A000000,
                  //           blurRadius: 4,
                  //           offset: Offset(0, 1),
                  //         ),
                  //       ],
                  //     ),
                  //     child: Icon(
                  //       Icons.tune,
                  //       size: 18,
                  //       color: AppColors.primaryTextColor,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Obx(() {
            if (controller.isShortlistedLoading.value) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.shortlistedCandidates.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('No shortlisted candidates yet'),
                ),
              );
            }

            return Column(
              children: List.generate(
                controller.shortlistedCandidates.length,
                (i) => CandidateCardWidget(
                  candidate: controller.shortlistedCandidates[i],
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
