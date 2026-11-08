import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/feature/student/home/controller/student_home_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/navbar/controller/navbar_controller.dart';
import 'package:msollaally/feature/navbar/model/navbar_item.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/student_campus_fursa_zone/fursa_zone_screen/student_campus_fursa_zone.dart';
import 'student_home_pill_card.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/feature/student/calender/screen/student_calender_page.dart';
class StudentHomeQuickPickCard extends StatelessWidget {
  const StudentHomeQuickPickCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentHomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StudentHomeSectionTitle("Today's Quick Pick"),
        SizedBox(height: 8.height),
        Obx(() {
          if (controller.isLoadingDashboard.value) {
            return ShimmerLoading.card(
              height: 56.height,
              borderRadius: 14.radius,
            );
          }
          final item = controller.upcomingClass.value;
          final hasClass = item != null;
          
          return GestureDetector(
            onTap: () {
              Get.to(() => const StudentCalenderPage());
            },
            child: StudentHomePillCard(
              leading: null,
              icon: hasClass ? Icons.book_rounded : Icons.calendar_month_rounded,
              title: hasClass ? item.title : 'No classes scheduled',
              subtitle: hasClass 
                  ? '${DateFormat('h:mm a').format(item.startDateTime)} - ${item.description}'
                  : 'Enjoy your free time!',
              backgroundColor: Colors.white,
              borderColor: const Color(0xFFE2E8F0),
            ),
          );
        }),
      ],
    );
  }
}

class StudentHomeReferralCard extends StatelessWidget {
  const StudentHomeReferralCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.height),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.radius),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF3E8FF),
            Color(0xFFE9D5FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFD8B4FE).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(AppRoute.referralScreen),
          borderRadius: BorderRadius.circular(16.radius),
          splashColor: const Color(0xFFA855F7).withOpacity(0.1),
          highlightColor: const Color(0xFFA855F7).withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 14.height),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.radius),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text('🎁', style: TextStyle(fontSize: 20.fontSize)),
                ),
                SizedBox(width: 14.width),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Referral Program',
                            style: TextStyle(
                              fontSize: 16.fontSize,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF581C87),
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(width: 8.width),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.width, vertical: 2.height),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9333EA), Color(0xFFA855F7)],
                              ),
                              borderRadius: BorderRadius.circular(20.radius),
                            ),
                            child: Text(
                              'EARN',
                              style: TextStyle(
                                fontSize: 9.fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.height),
                      Text(
                        'Invite friends & earn rewards',
                        style: TextStyle(
                          fontSize: 12.fontSize,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B21A8).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.radius),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14.fontSize,
                    color: const Color(0xFF581C87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StudentHomeFursaSection extends StatelessWidget {
  const StudentHomeFursaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final fursaController = Get.isRegistered<StudentCampusController>()
        ? Get.find<StudentCampusController>()
        : Get.put(StudentCampusController());

    if (fursaController.competitionsList.isEmpty) {
      fursaController.loadFursaZoneData();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StudentHomeSectionTitle('Fursa'),
        SizedBox(height: 8.height),
        // Fursa Zone Banner
        InkWell(
          onTap: () {
            Get.to(() => const StudentCampusFursaZone());
          },
          borderRadius: BorderRadius.circular(14.radius),
          child: Obx(() {
            final imageUrl = fursaController.fursaZoneBannerImage.value;

            return Container(
              height: 130.height,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.radius),
                color: Colors.grey.shade200,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.radius),
                child: imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/book1.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Image.asset(
                        imageUrl.isNotEmpty
                            ? imageUrl
                            : 'assets/images/book1.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
              ),
            );
          }),
        ),
        SizedBox(height: 10.height),
        // Referral Program Card
        const StudentHomeReferralCard(),
      ],
    );
  }
}
