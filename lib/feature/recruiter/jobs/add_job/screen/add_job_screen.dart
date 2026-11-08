import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/model/job_details_model.dart';
import '../controller/add_job_controller.dart';
import '../widgets/basic_details_widget.dart';
import '../widgets/image_upload_widget.dart';
import '../widgets/description_widget.dart';

class AddJobScreen extends StatelessWidget {
  AddJobScreen({super.key, this.editJob}) {
    if (Get.isRegistered<AddJobController>()) {
      Get.delete<AddJobController>();
    }
    controller = Get.put(AddJobController(editJob: editJob));
  }

  final JobDetailsModel? editJob;
  late final AddJobController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.primaryTextColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                controller.isEditMode ? 'Edit Job' : 'Add New Job',
                style: TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Details',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      BasicDetailsWidget(),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: GestureDetector(
                              onTap: controller.addImageSlot,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.aliceBlueF3F5FF,
                                child: Icon(
                                  Icons.add,
                                  color: AppColors.royalBlue3B82F6,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      SizedBox(height: 12),
                      ImageUploadWidget(),
                      SizedBox(height: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jobs Description',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Rocw(
                          //   children: [
                          //     Expanded(
                          //       child: TextButton(
                          //         onPressed: () {},
                          //         style: TextButton.styleFrom(
                          //           padding: EdgeInsets.zero,
                          //         ),
                          //         child: Align(
                          //           alignment: Alignment.centerLeft,
                          //           child: Text(
                          //             'Click to generate job Description',
                          //             style: TextStyle(
                          //               color: AppColors.blueViolet6B46FF,
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     SizedBox(width: 8),
                          //     Container(
                          //       padding: EdgeInsets.symmetric(
                          //         horizontal: 14,
                          //         vertical: 8,
                          //       ),
                          //       decoration: BoxDecoration(
                          //         color: AppColors.blueViolet6B46FF,
                          //         borderRadius: BorderRadius.circular(10),
                          //       ),
                          //       child: Row(
                          //         mainAxisSize: MainAxisSize.min,
                          //         children: [
                          //           Icon(
                          //             Icons.auto_awesome,
                          //             color: Colors.white,
                          //             size: 16,
                          //           ),
                          //           SizedBox(width: 8),
                          //           Text(
                          //             'Generate',
                          //             style: TextStyle(color: Colors.white),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                      SizedBox(height: 12),
                      DescriptionWidget(),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: CustomButton(
                  text: controller.isEditMode ? 'Update Job' : 'Create Job',
                  onPressed: controller.submit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
