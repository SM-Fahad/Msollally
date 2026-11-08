import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import '../controller/jobs.controller.dart';
import '../widgets/job_card_widget.dart';
import '../widgets/job_filter_sheet.dart';
import '../widgets/job_tab_bar.dart';
import '../widgets/my_job_applications_view.dart';

class JobScreen extends StatelessWidget {
  JobScreen({super.key});

  final JobController controller = Get.put(JobController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          JobTabBar(controller: controller),
          Expanded(
            child: Obx(() {
              return controller.selectedTab.value == 0
                  ? _JobDiscoverView(
                      controller: controller,
                      onFilterTap: () => _showFilterSheet(context),
                    )
                  : MyJobApplicationsView(controller: controller);
            }),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JobFilterSheet(controller: controller),
    );
  }
}

class _JobDiscoverView extends StatelessWidget {
  final JobController controller;
  final VoidCallback onFilterTap;

  const _JobDiscoverView({
    required this.controller,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _JobSearchBar(
          controller: controller,
          onFilterTap: onFilterTap,
        ),
        _ActiveFiltersRow(controller: controller),
        Expanded(child: _JobListBody(controller: controller)),
      ],
    );
  }
}

class _JobSearchBar extends StatelessWidget {
  final JobController controller;
  final VoidCallback onFilterTap;

  const _JobSearchBar({required this.controller, required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10, left: 16, right: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: TextField(
          onChanged: controller.searchJobs,
          decoration: InputDecoration(
            hintText: 'Search jobs, companies, skills...',
            hintStyle: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => controller.searchJobs(''),
                        )
                      : SizedBox(),
                ),
                IconButton(
                  icon: Icon(Icons.filter_list, color: Colors.black),
                  onPressed: onFilterTap,
                ),
              ],
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}

// ─── Active Filters Row ───────────────────────────────────────────────────────

class _ActiveFiltersRow extends StatelessWidget {
  final JobController controller;

  const _ActiveFiltersRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.selectedFilters.isNotEmpty
          ? SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.selectedFilters.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Clear All'),
                        onSelected: (_) => controller.clearFilters(),
                        backgroundColor: Colors.red.shade100,
                        selectedColor: Colors.red.shade200,
                      ),
                    );
                  }
                  final filter = controller.selectedFilters[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: true,
                      onSelected: (_) => controller.toggleFilter(filter),
                      selectedColor: Colors.blue.shade100,
                    ),
                  );
                },
              ),
            )
          : const SizedBox(),
    );
  }
}

// ─── Job List Body ────────────────────────────────────────────────────────────

class _JobListBody extends StatelessWidget {
  final JobController controller;

  const _JobListBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ShimmerLoading.list(
            itemCount: 4,
            height: 140,
            borderRadius: 12,
          ),
        );
      }

      if (controller.filteredJobs.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No jobs found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshJobs,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.filteredJobs.length,
          itemBuilder: (context, index) {
            final job = controller.filteredJobs[index];
            return JobCard(job: job, controller: controller);
          },
        ),
      );
    });
  }
}
