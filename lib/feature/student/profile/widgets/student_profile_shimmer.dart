import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:shimmer/shimmer.dart';

class StudentProfileShimmer extends StatelessWidget {
  const StudentProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.gainsboroE0E0E0,
      highlightColor: AppColors.todaysQuickPicContainerBGColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover photo ──────────────────────────────────────────────────
            Container(
              height: 200.height,
              width: double.infinity,
              color: Colors.white,
            ),

            SizedBox(height: 8.height),

            // ── Avatar + name row ────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.width),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.height),

                  // Avatar circle (mirrors the Positioned avatar in cover widget)
                  _box(width: 110.width, height: 20.height, radius: 6.radius),
                  SizedBox(height: 10.height),

                  // Name
                  _box(width: 160.width, height: 20.height, radius: 6.radius),
                  SizedBox(height: 8.height),

                  // Friends count
                  _box(width: 90.width, height: 14.height, radius: 4.radius),
                  SizedBox(height: 8.height),

                  // Bio line 1
                  _box(width: double.infinity, height: 13.height, radius: 4.radius),
                  SizedBox(height: 5.height),

                  // Bio line 2
                  _box(width: 220.width, height: 13.height, radius: 4.radius),
                  SizedBox(height: 20.height),

                  // Tabs row
                  Row(
                    children: [
                      _box(width: 55.width, height: 16.height, radius: 4.radius),
                      SizedBox(width: 36.width),
                      _box(width: 45.width, height: 16.height, radius: 4.radius),
                      SizedBox(width: 36.width),
                      _box(width: 58.width, height: 16.height, radius: 4.radius),
                    ],
                  ),
                  SizedBox(height: 12.height),
                ],
              ),
            ),

            // Divider
            Container(height: 1, width: double.infinity, color: Colors.white),
            SizedBox(height: 20.height),

            // ── About items ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 35.width),
              child: Column(
                children: List.generate(
                  7,
                  (i) => Padding(
                    padding: EdgeInsets.only(bottom: 34.height),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _box(width: 80.width, height: 16.height, radius: 4.radius),
                        _box(width: 130.width, height: 16.height, radius: 4.radius),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box({
    required double width,
    required double height,
    double radius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
