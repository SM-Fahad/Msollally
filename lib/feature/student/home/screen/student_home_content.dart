import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import 'package:msollaally/feature/student/home/controller/student_home_controller.dart';
import 'package:msollaally/feature/student/home/widgets/student_home_cards.dart';
import 'package:msollaally/feature/student/home/widgets/student_home_courses.dart';
import 'package:msollaally/feature/student/home/widgets/student_home_for_you.dart';
import 'package:msollaally/feature/student/home/widgets/student_home_header.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/feature/student/home/widgets/student_home_quick_tools.dart';

class StudentHomeContent extends StatelessWidget {
  const StudentHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<StudentHomeController>()
        ? Get.find<StudentHomeController>()
        : Get.put(StudentHomeController());

    return Material(
      color: Colors.white,
      child: RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 720;
              final contentWidth = isWide
                  ? constraints.maxWidth.clamp(0.0, 1000.0)
                  : constraints.maxWidth.clamp(0.0, 520.0);
              final sidePadding = isWide
                  ? (constraints.maxWidth > 1040 ? 0.0 : 20.width)
                  : (constraints.maxWidth > 560 ? 0.0 : 20.width);

              return Obx(() {
                if (controller.isLoadingAll.value) {
                  return _buildShimmer(context, sidePadding, contentWidth);
                }
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    sidePadding,
                    18.height,
                    sidePadding,
                    24.height,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const StudentHomeHeader(),
                          SizedBox(height: 14.height),
                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const StudentHomeFursaSection(),
                                      SizedBox(height: 16.height),
                                      const StudentHomeQuickTools(),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 24.width),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const StudentHomeQuickPickCard(),
                                      SizedBox(height: 16.height),
                                      const StudentHomeCourses(),
                                      SizedBox(height: 20.height),
                                      const StudentHomeForYou(),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const StudentHomeFursaSection(),
                                SizedBox(height: 16.height),
                                const StudentHomeQuickPickCard(),
                                SizedBox(height: 16.height),
                                const StudentHomeQuickTools(),
                                SizedBox(height: 20.height),
                                const StudentHomeCourses(),
                                SizedBox(height: 20.height),
                                const StudentHomeForYou(),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context, double sidePadding, double contentWidth) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(sidePadding, 18.height, sidePadding, 24.height),
      child: Center(
        child: SizedBox(
          width: contentWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ShimmerLoading.circle(radius: 23.radius),
                  SizedBox(width: 12.width),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading.line(width: 100.width, height: 14.height),
                      SizedBox(height: 4.height),
                      ShimmerLoading.line(width: 150.width, height: 18.height),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.height),
              ShimmerLoading.line(width: 120.width, height: 20.height),
              SizedBox(height: 8.height),
              ShimmerLoading.card(height: 130.height, borderRadius: 14.radius),
              SizedBox(height: 16.height),
              ShimmerLoading.card(height: 80.height, borderRadius: 14.radius),
              SizedBox(height: 20.height),
              ShimmerLoading.card(height: 50.height, borderRadius: 12.radius),
              SizedBox(height: 20.height),
              ShimmerLoading.line(width: 160.width, height: 20.height),
              SizedBox(height: 12.height),
              Row(
                children: [
                  Expanded(child: ShimmerLoading.card(height: 115.height, borderRadius: 16.radius)),
                  SizedBox(width: 12.width),
                  Expanded(child: ShimmerLoading.card(height: 115.height, borderRadius: 16.radius)),
                ],
              ),
              SizedBox(height: 20.height),
              ShimmerLoading.line(width: 120.width, height: 20.height),
              SizedBox(height: 12.height),
              ShimmerLoading.card(height: 70.height, borderRadius: 16.radius),
            ],
          ),
        ),
      ),
    );
  }
}
