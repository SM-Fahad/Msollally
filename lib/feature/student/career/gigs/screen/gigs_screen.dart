import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import '../controller/gigs_controller.dart';
import 'create_gig_screen.dart';
import '../widgets/gigs/gig_list_body.dart';

class GigScreen extends StatelessWidget {
  const GigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GigsController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.aliceBlueF4F6FB,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GigScreenHeader(controller: controller),
              _GigSearchBar(controller: controller),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.width),
                child: Container(
                  height: 44.height,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12.radius),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppColors.primaryButtonColor,
                      borderRadius: BorderRadius.circular(10.radius),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey.shade700,
                    labelStyle: TextStyle(
                      fontSize: 13.5.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      const Tab(
                        iconMargin: EdgeInsets.zero,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.explore_outlined, size: 18),
                            SizedBox(width: 6),
                            Text('Explore Gigs'),
                          ],
                        ),
                      ),
                      Tab(
                        iconMargin: EdgeInsets.zero,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_pin_outlined, size: 18),
                            const SizedBox(width: 6),
                            const Text('My Gigs'),
                            const SizedBox(width: 4),
                            Obx(() {
                              final count = controller.myGigs.length;
                              if (count == 0) return const SizedBox.shrink();
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.width,
                                  vertical: 1.height,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10.radius),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 11.fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.height),
              Expanded(
                child: TabBarView(
                  children: [
                    GigListBody(controller: controller, isMyGigs: false),
                    GigListBody(controller: controller, isMyGigs: true),
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

class _GigScreenHeader extends StatelessWidget {
  final GigsController controller;
  const _GigScreenHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.width, 16.height, 16.width, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student Gigs',
                style: TextStyle(
                  fontSize: 22.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2.height),
              Text(
                'Browse services or offer your skills',
                style: TextStyle(
                  fontSize: 12.5.fontSize,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              controller.resetForm();
              Get.to(() => const CreateGigScreen());
            },
            icon: Icon(Icons.add_rounded, size: 18.fontSize),
            label: Text(
              'Post Gig',
              style: TextStyle(fontSize: 13.fontSize, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButtonColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.radius),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.width, vertical: 10.height),
            ),
          ),
        ],
      ),
    );
  }
}

class _GigSearchBar extends StatelessWidget {
  final GigsController controller;
  const _GigSearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 12.height),
      child: TextField(
        onChanged: (val) => controller.searchQuery.value = val,
        decoration: InputDecoration(
          hintText: 'Search by title, skills, location...',
          hintStyle: TextStyle(fontSize: 13.5.fontSize, color: Colors.grey.shade500),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
              onPressed: () => controller.searchQuery.value = '',
            );
          }),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.radius),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.radius),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.radius),
            borderSide: const BorderSide(color: AppColors.primaryButtonColor),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10.height),
        ),
      ),
    );
  }
}
