import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import '../../../../../core/common/styles/global_text_style.dart';

class CampaignParticipationCard extends StatelessWidget {
  final bool isLoaded;
  final String totalParticipants;
  final String qualifiedParticipants;
  final String daysRemaining;

  const CampaignParticipationCard({
    super.key,
    required this.isLoaded,
    required this.totalParticipants,
    required this.qualifiedParticipants,
    required this.daysRemaining,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Participation',
          style: appTextStyleHeading1(
            fontSize: 18.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.height),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 12.height),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.radius),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      totalParticipants,
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black09090B,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.height),
                    Text(
                      'Joined',
                      style: getTextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Container(height: 30.height, width: 1, color: Colors.grey.shade300),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      qualifiedParticipants,
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.forestGreen2E7D32,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.height),
                    Text(
                      'Qualified',
                      style: getTextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Container(height: 30.height, width: 1, color: Colors.grey.shade300),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      daysRemaining,
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.crimsonD32F2F,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.height),
                    Text(
                      'Days Left',
                      style: getTextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.height),
      ],
    );
  }
}
