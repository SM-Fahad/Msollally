import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';

class StudentMentalHealth extends StatelessWidget {
  const StudentMentalHealth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                leadingIcon: Icon(Icons.arrow_back),
                onLeadingTap: () {
                  Get.back();
                },
                title: "Mental Health",
              ),
              SizedBox(height: 20.height),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.width),
                child: Text(
                  "Mental Health",
                  style: appTextStyleHeading1(letterSpacing: 0.fontSize),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 15.width,
                  vertical: 14.height,
                ),
                child: Text(
                  "Mental health refers to a person’s emotional, psychological, and social well-being. It affects how we think, feel, and behave in daily life. It also influences how we handle stress, relate to others, and make decisions.",
                  style: appTextStyleHeading1(
                    fontSize: 14.fontSize,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.fontSize,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 15.width),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40.width,
                        vertical: 38.height,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.radius),
                        color: AppColors.black000000,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(ImagesPath.mentalIllness),

                          SizedBox(height: 25.height),

                          Text(
                            "WHAT’S MENTAL ?",
                            style: appTextStyleHeading2(
                              fontSize: 22.fontSize,
                              letterSpacing: 0.fontSize,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.height),
                          Text(
                            "As Mental Health America states, mental illness refers to conditions that cause mild to severe disturbances in thought, emotion, and/or behavior, resulting in an inability to cope with life’s ordinary demands and routines.",
                            style: appTextStyleHeading2(
                              fontSize: 13.fontSize,
                              letterSpacing: 0.fontSize,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.height),
                          Text(
                            "HOW MANY ARE?",
                            style: appTextStyleHeading2(
                              fontSize: 22.fontSize,
                              letterSpacing: 0.fontSize,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.height),
                          Text(
                            "There are more than 200 classified forms of mental illness. Some of the more common disorders are depression, anxiety, and bipolar disorder. Symptoms may include changes in mood, personality, personal habits, and/or social withdrawal.",
                            style: appTextStyleHeading2(
                              fontSize: 13.fontSize,
                              letterSpacing: 0.fontSize,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.height),
                          Text(
                            "WHAT PEOPLE BELIEVE",
                            style: appTextStyleHeading2(
                              fontSize: 22.fontSize,
                              letterSpacing: 0.fontSize,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.height),
                          Text(
                            "Most people believe that mental disorders are rare and \"happen to someone else.\" In fact, mental disorders are common and widespread across all ages and demographics.",
                            style: appTextStyleHeading2(
                              fontSize: 13.fontSize,
                              letterSpacing: 0.fontSize,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.height),
                          Text(
                            "ARE WE PREPARED?",
                            style: appTextStyleHeading2(
                              fontSize: 22.fontSize,
                              letterSpacing: 0.fontSize,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.height),
                          Text(
                            "Most families are not prepared to cope with learning their loved one has a mental illness. It can be physically and emotionally trying, but support, open conversations, and professional resources make recovery possible.",
                            style: appTextStyleHeading2(
                              fontSize: 13.fontSize,
                              letterSpacing: 0.fontSize,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.height),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.width,
                        vertical: 32.height,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.radius),
                        color: AppColors.black000000,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "CHARACTERISTICS",
                            style: appTextStyleHeading2(
                              fontSize: 20.fontSize,
                              letterSpacing: 0.fontSize,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20.height),
                          Image.asset(ImagesPath.mental2),

                          SizedBox(height: 25.height),

                          Text(
                            "EARLY WARNING SIGNS",
                            style: appTextStyleHeading2(
                              fontSize: 22.fontSize,
                              letterSpacing: 0.fontSize,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.height),
                          Text(
                            "Common early warning signs include eating or sleeping too much or too little, pulling away from people and usual activities, having low or no energy, and feeling unusually confused, forgetful, or anxious.",
                            style: appTextStyleHeading2(
                              fontSize: 13.fontSize,
                              letterSpacing: 0.fontSize,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.height),
                          Text(
                            "BUILDING RESILIENCE",
                            style: appTextStyleHeading2(
                              fontSize: 22.fontSize,
                              letterSpacing: 0.fontSize,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.height),
                          Text(
                            "Ways to maintain positive mental health include getting professional help if you need it, connecting with others, staying physically active, helping others, and developing healthy coping skills.",
                            style: appTextStyleHeading2(
                              fontSize: 13.fontSize,
                              letterSpacing: 0.fontSize,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
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
