import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../model/pro_partners_dashboard_model.dart';

class ProPartnersChartCardWidget extends StatelessWidget {
  final List<DashboardChartData> Function() getChartData;

  const ProPartnersChartCardWidget({super.key, required this.getChartData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.sectionBorderColor),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impressions vs. Reach',
              style: TextStyle(
                color: AppColors.black09090B,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Weekly performance overview',
              style: TextStyle(
                color: AppColors.tertiaryTextColor,
                fontSize: 12.sp,
                height: 1.67,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 184.h,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  majorGridLines: MajorGridLines(width: 0),
                  axisLine: AxisLine(color: Colors.transparent),
                ),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 60,
                  interval: 10,
                  majorGridLines: MajorGridLines(color: AppColors.gainsboroD5F1DC),
                  axisLine: AxisLine(width: 0),
                  labelStyle: TextStyle(
                    color: AppColors.dimGray52525B,
                    fontSize: 11.sp,
                  ),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<DashboardChartData, String>>[
                  SplineSeries<DashboardChartData, String>(
                    dataSource: getChartData(),
                    xValueMapper: (d, i) => d.day,
                    yValueMapper: (d, i) => d.impressions,
                    splineType: SplineType.natural,
                    color: AppColors.blueViolet7C3AED,
                    width: 2,
                    markerSettings: MarkerSettings(isVisible: true),
                  ),
                  SplineSeries<DashboardChartData, String>(
                    dataSource: getChartData(),
                    xValueMapper: (d, i) => d.day,
                    yValueMapper: (d, i) => d.reach,
                    splineType: SplineType.natural,
                    color: AppColors.darkOrangeF97316,
                    width: 2,
                    markerSettings: MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
