import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';

class StudentPhysicalHealth extends StatelessWidget {
  const StudentPhysicalHealth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar(
                leadingIcon: Icon(Icons.arrow_back),
                onLeadingTap: () {
                  Get.back();
                },
                title: "Physical Health",
              ),

              SizedBox(height: 12.height),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.width),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Physical Health",
                      style: appTextStyleHeading1(letterSpacing: 0.fontSize),
                    ),
                    SizedBox(height: 16.height),
                    Text(
                      "Physical health refers to the overall state of your body, encompassing physical fitness, proper organ function, nutrition, and daily healthy lifestyle habits.",
                      style: appTextStyleHeading1(
                        letterSpacing: 0.fontSize,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 16.height),

                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.height,
                        horizontal: 16.width,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mistyRoseEDE1E1,
                        borderRadius: BorderRadius.circular(8.radius),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            ImagesPath.physicalHealth,
                            height: 335.height,
                            width: 326.width,
                          ),

                          SizedBox(height: 20.height),
                          Text(
                            "Body Health Basics: What is Physical Health?",
                            style: appTextStyleHeading2(
                              fontSize: 20.fontSize,
                              letterSpacing: 0.fontSize,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 16.height),

                          Text(
                            "Our physical health, or physical wellness, is how well our organs and body systems function. Keep reading to find answers to some frequently asked questions about physical health.",
                            style: appTextStyleHeading1(
                              fontSize: 14.fontSize,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.0.fontSize,
                            ),
                          ),
                          SizedBox(height: 16.height),
                          Text(
                            "What is Physical Health?",
                            style: appTextStyleHeading2(
                              fontSize: 20.fontSize,
                              letterSpacing: 0.fontSize,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: 16.height),

                          Text(
                            "Physical health, also known as physical wellness, is more than just how fit you are. Physical health is how well your organs and body systems function.\n\nEach person’s version of physical health is different. Someone can achieve their own definition of physical health, despite a disease, a disability, or their age.",
                            style: appTextStyleHeading1(
                              fontSize: 14.fontSize,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.0.fontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.height),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
